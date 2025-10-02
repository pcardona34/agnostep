//  $Id: FSKeySet.m,v 1.3 2014/01/26 09:23:53 buzzdee Exp $
//
//  FSKeySet.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-JAN-2001.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//                2012 Free Software Foundation
//  
//  Redistribution and use in source and binary forms,  with or without
//  modification,  are permitted provided that the following conditions
//  are met:
//  
//  *  Redistributions of source code must retain the above copyright
//     notice,  this list of conditions and the following disclaimer.
//  
//  *  Redistributions  in  binary  form  must  reproduce  the  above
//     copyright notice,  this  list of conditions  and the following
//     disclaimer  in  the  documentation  and / or  other  materials
//     provided with the distribution.
//  
//  *  Neither the name  "FlexiSheet"  nor the names of its copyright
//     holders  or  contributors  may  be used  to endorse or promote
//     products  derived  from  this software  without specific prior
//     written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT
//  LIMITED TO,  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND  FITNESS
//  FOR  A PARTICULAR PURPOSE  ARE  DISCLAIMED.  IN NO EVENT  SHALL THE
//  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO,  PROCUREMENT  OF  SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN
//  ANY WAY  OUT  OF  THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//  

#import "FSCore.h"
#import "FoundationExtentions.h"


@implementation FSKeySet
/*" An FSKeySet instance (also referred to as a %{key set}) represents a selection of rows/columns/pages in a table.  A key set is valid only if all keys belong to a header dimension from the same table.  Complete key sets contain exactly one key for each header dimension in a table.  Complete key sets can be used to retrieve values from a table. "*/


+ (FSKeySet*)keySet
    /*" Creates and returns an autoreleased FSKeySet instance. "*/
{
    return [[[self allocWithZone:NULL] init] autorelease];
}


+ (FSKeySet*)keySet:(FSkeyset*)keyset
{
    FSKeySet *instance = [[self allocWithZone:NULL] init];
    FSkeysetCopyKeys(&(instance->_data), keyset);
    return [instance autorelease];
}


+ (FSKeySet*)keySetWithKeys:(NSArray*)keys
    /*" Creates and returns an autoreleased FSKeySet instance
    containing keys. "*/
{
    FSKeySet *instance = [[self allocWithZone:NULL] init];
    [instance addKeysFromArray:keys];
    return [instance autorelease];
}


+ (FSKeySet*)keySetWithKey:(FSKey*)key
    /*" Creates and returns an autoreleased FSKeySet instance
    containing key. "*/
{
    FSKeySet *instance = [[self allocWithZone:NULL] init];
    [instance addKey:key];
    return [instance autorelease];
}


+ (FSKeySet*)keySetWithKeys:(NSDictionary*)keys inTable:(FSTable*)table
    /*" Creates and returns an autorelease FSKeySet with
    the category/label pairs in keys found in table.
    All categories must exist and have a label.
    Otherwise, nil is returned."*/
{
    FSKeySet *instance = nil;

    if (table && [keys count]) {
        NSArray  *hNames = [keys allKeys];
        FSHeader *header = nil;
        NSString *key = nil;
        FSKey    *item = nil;
        int       index = [hNames count];

        instance = [[[self alloc] init] autorelease];
        while (index-- > 0) {
            key = [hNames objectAtIndex:index];
            header = [table headerWithName:key];
            item = [header keyWithPath:[keys objectForKey:key]];
            if (item) {
                [instance addKey:item];
            } else {
                instance = nil;
            }
        }
        // This is for safety reasons and cannot happen with
        // the current sematics of NSDictionary.
        // So we took it out for performance reasons.
        // if (instance)
        //     assert([keys count] == [instance count]);
    }
    return instance;
}


- (id)init
    /*" Creates an empty key set that is not yet associated with a table.   This is the designated initializer. "*/
{
    self = [super init];
    if (self != nil) {
        _data.keys = NULL;
        _data.count = 0;
        _data.hashcodeChars =  NULL;
        TEST_DBG [FSLog logDebug:@"%@ %X allocated.", [self className], self];
    }
    return self;
}


- (void)_releaseKeys
{
    FSkeysetDealloc(&_data);
}


- (void)dealloc
{
    FSkeysetDealloc(&_data);
    [_cachedAllKeys release];
    TEST_DBG [FSLog logDebug:@"%@ %X deallocated.", [self className], self];
    [super dealloc];
}


- (FSHashKey)hashcode
    /*" Generates and returns a unique identifier for this key set.
    The identifier is unique for the combination of keys, not for the object instance. "*/
{
    if (!_data.hashcodeChars) {
        FSkeysetGenerateHashcode(&_data);
    }
    return _data.hashcodeChars;
}


- (NSArray*)_allKeys
{
    NSMutableArray *array;

    if (_cachedAllKeys) return _cachedAllKeys;

    array = [[NSMutableArray alloc] init];
    if (_data.keys) {
        int index = _data.count;
        while (index-- > 0) {
            if (_data.keys[index]) {
                [array addObject:_data.keys[index]];
            }
        }
    }
    _cachedAllKeys = array;
    return array;
}


- (BOOL)isEqual:(id)object
{
    if ([object class] == [self class]) {
        FSHashKey otherHashcode = [object hashcode];

        if (otherHashcode == NULL) return NO;
        if (_data.hashcodeChars == NULL)
            FSkeysetGenerateHashcode(&_data);
        if (_data.hashcodeChars == NULL) return NO;
        return (strcmp(_data.hashcodeChars, otherHashcode) == 0);
    } else return NO;
}


- (NSUInteger)count
{
    return [[self _allKeys] count];
}


- (NSEnumerator*)objectEnumerator
{
    return [[self _allKeys] objectEnumerator];
}


- (FSTable*)table
{
    if (_data.keys == NULL) return nil;
    if (nil == _cachedTable) {
        int index = _data.count;
        while (index-- > 0) {
            if (_data.keys[index]) {
                _cachedTable = [_data.keys[index] table];
                break;
            }
        }
    }
    return _cachedTable;
}


- (void)addKey:(FSKey*)aKey
    /*" Adds aKey to the set.  Throws an exception if aKey belongs to a dimension header that is not in the same table than the rest of the key headers. "*/
{
    if (_data.keys == NULL) {
        // we don't have a key set yet.
        // this is easy.
        _cachedTable = [[aKey header] table];
    }
    FSkeysetAddKey(&_data, aKey);
    [_cachedAllKeys release];
    _cachedAllKeys = nil;
}


- (void)addKeysFromArray:(NSArray*)keys
{
    int index = [keys count];
    while (index-- > 0) {
        [self addKey:[keys objectAtIndex:index]];
    }
}


- (void)addKeys:(FSKeySet*)keys
{
    NSArray *ka = [keys _allKeys];
    int      index = [ka count];
    
    while (index-- > 0) {
        [self addKey:[ka objectAtIndex:index]];
    }
}


- (void)copyKeys:(FSKeySet*)otherSet
{
    FSkeysetCopyKeys(&_data, &(otherSet->_data));
    _cachedTable = otherSet->_cachedTable;
    [_cachedAllKeys release];
    _cachedAllKeys = [otherSet->_cachedAllKeys copyWithZone:NULL];
}


- (FSKeySet*)setInLinkedTable:(FSTable*)table
/*" This operation is expensive no matter what.  It is called not too often though. "*/
{
    FSKeySet     *newSet = [FSKeySet keySet];
    NSEnumerator *cursor = [self objectEnumerator];
    FSKey        *key;
    FSHeader     *link;
    FSKey        *otherKey;

    while ((key = [cursor nextObject])) {
        link = [[key header] linkedHeaderInTable:table];
        otherKey = [link keyWithPath:[key fullPath]];
        if (otherKey) [newSet addKey:otherKey];
    }

    return newSet;
}


- (FSKeySet*)setByAddingKey:(FSKey*)aKey
    /*" Returns a new instance created by adding aKey to the existing set. "*/
{
    FSKeySet     *newSet = [FSKeySet keySet];
    if (_data.count > 0) [newSet copyKeys:self];
    [newSet addKey:aKey];
    return newSet;
}


- (FSKeySet*)setByAddingKeys:(FSKeySet*)otherKeys
    /*" Returns a new instance created by adding all keys from otherKeys to the existing set. "*/
{
    FSKeySet     *newSet = [FSKeySet keySet];
    if (_data.count > 0) [newSet copyKeys:self];
    [newSet addKeysFromArray:[otherKeys _allKeys]];
    return newSet;
}


- (FSKeySet*)setBySubstitutingKey:(FSKey*)aKey
    /*" Returns a new instance created by substituting aKey
    for the key present in the existing set.
    Substituting can only be done on complete key sets."*/
{
    FSKeySet     *newSet = [FSKeySet keySet];

    NSAssert([self isComplete], @"Key substitution only works on complete FSKeySet!");
    [newSet copyKeys:self];
    if (aKey) [newSet addKey:aKey];

    NSAssert([newSet isComplete], @"Key substitution results in incomplete FSKeySet!");
    return newSet;
}


- (FSKeySet*)setBySubstitutingKeys:(FSKeySet*)keySet
{
    FSKeySet     *newSet = [FSKeySet keySet];
    FSKey        *key;
    int           index;

    NSAssert([self isComplete], @"Key substitution only works on complete FSKeySet!");
    [newSet copyKeys:self];

    if (keySet->_data.count) {
        NSAssert((_cachedTable == keySet->_cachedTable), @"Key substitution from different table detected!");
        index = keySet->_data.count;
        while (index-- > 0) {
            key = keySet->_data.keys[index];
            if (key) [newSet addKey:key];
        }
    }

    NSAssert([newSet isComplete], @"Key substitution results in incomplete FSKeySet!");
    return newSet;
}


- (BOOL)isValid
    /*" An FSKeySet is valid if all keys belong to the same table. "*/
{
    FSTable       *theTable = nil;
    FSKey         *aKey;
    int            index = _data.count;
    BOOL           result = YES;

    while (index-- > 0) {
        aKey = _data.keys[index];
        if (theTable == nil) {
            theTable = [aKey table];
        } else {
            if (theTable != [aKey table])
                result = NO;
        }
    }

    return result;
}


- (FSValue*)value
{
    if ([self isComplete])
        return [[self table] valueForKeySet:self];
    return nil;
}


- (BOOL)isComplete
    /*" An FSKeySet is complete if it contains exactly one key of each header of a single table. "*/
{
    FSTable       *theTable = nil;
    NSArray       *headers;
    FSKey         *aKey;
    int            index = _data.count;

    // No keys?  Cannot be complete.
    if (_data.keys == NULL) return NO;

    // First key not set?  Not complete.
    aKey = _data.keys[0];
    if (aKey == nil) return NO;

    // We have the table all keys must belong to.
    theTable = [aKey table];
    headers = [theTable headers];

    if ([headers count] != _data.count) {
        FSkeysetRevalidate(&_data);
        index = _data.count;
    }

    while (index-- > 0) {
        if (theTable != [_data.keys[index] table]) return NO;
    }
    return YES;
}


- (FSKey*)keyForHeader:(FSHeader*)header
    /*" Returns the key for dimension header or nil if such a key is not part of the set."*/
{
    FSTable  *table = [self table];
    NSInteger index = [table indexOfHeader:header];

    if (index == NSNotFound) return nil;
    if (!_data.count || !_data.keys) return nil;

    return _data.keys[index];
}


- (FSKey*)keyForGroup:(FSKeyGroup*)group
    /*" Returns the key in group or nil if such a key is not part of the set."*/
{
    NSEnumerator  *cursor = [self objectEnumerator];
    FSKey         *aKey = nil;

    while ((aKey = [cursor nextObject])) {
        if ([aKey header] == (id)group) break;
        if ([[aKey groups] containsObject:group]) break;
    }

    return aKey;
}


- (NSString*)description
    /*" Returns a textual representation of the header set.
    It's expensive.  Use this for logging only! "*/
{
    NSArray *_array = [self _allKeys];

    if ([_array count] == 0) {
        return @" * * * ";
    } else if ([_array count] == 1) {
        return [[_array lastObject] label];
    } else {
        NSArray           *headers = [[[[_array lastObject] header] table] headers];
        NSMutableString   *desc = [NSMutableString string];
        FSHeader          *header;
        FSKey             *key;
        int                index = 0;

        while (index < [headers count]) {
            header = [headers objectAtIndex:index];
            key = [self keyForHeader:header];
            index++;
            if (key) {
                [desc appendFormat:@"[%@]", [key label]];
            }
        }

        return desc;
    }
}

@end

@implementation FSKeySet (Archiving)

- (NSDictionary*)dictionaryForArchiving
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    FSKey               *key;
    int                  index = _data.count;

    if (_data.keys == NULL)
        [NSException raise:@"Invalid" format:@"Cannot archive an empty KeySet."];

    while (index-- > 0) {
        key = _data.keys[_data.count-index-1];
        if (key == nil)
            [NSException raise:@"Invalid" format:@"Cannot archive an incomplete KeySet."];
        [dict setObject:[key fullPath] forKey:[[key header] label]];
    }

    return dict;
}

@end

//
// FSkeyset Functions
//

void FSkeysetAddKey(FSkeyset *ks, FSKey *aKey)
{
    if (ks->keys == NULL) {
        // we don't have a key set yet.
        // this is easy.
        NSArray *headers = [[aKey table] headers];

        ks->count = [headers count];
        ks->keys = malloc(sizeof(id) * ks->count);
        memset(ks->keys, 0, ks->count*sizeof(id));
        ks->keys[[headers indexOfObject:[aKey header]]] = aKey;
    } else {
        FSTable *table = [aKey table];
        NSArray *headers = [table headers];
        int      index = [headers indexOfObject:[aKey header]];

        if ([headers count] != ks->count) {
            FSkeysetRevalidate(ks);
        }

        if ([aKey table] != nil) {
            char buffer[9];

            // How do we check for this?
            // [NSException raise:@"Mismatch" format:@"Key from different document!"];

            ks->keys[index] = aKey;

            // Fix up hashcode
            if (ks->hashcodeChars) {
                sprintf(buffer, "%08X", (int)aKey);
                strncpy(ks->hashcodeChars+index*8, buffer, 8);
            }
        }
    }
}

void FSkeysetCopyKeys(FSkeyset *ks, FSkeyset *otherSet)
{
    int    index = otherSet->count;

    FSkeysetDealloc(ks);
    
    ks->count = index;
    ks->keys = malloc(sizeof(id) * index);

    while (index-- > 0) {
        ks->keys[index] = otherSet->keys[index];
    }

    if (otherSet->hashcodeChars)
        ks->hashcodeChars = strdup(otherSet->hashcodeChars);
}

void FSkeysetRevalidate(FSkeyset *ks)
{
    if (ks->keys) {
        FSKey    *aKey;
        int       index = ks->count;
        FSTable  *_table = nil;

        while (index-- > 0) {
            aKey = ks->keys[index];
            if ((_table = [aKey table])) {
                index = 0;
            }
        }
        index = ks->count;
        if (ks->count == [[_table headers] count]) {
            while (index-- > 0) {
                aKey = ks->keys[index];
                if (aKey && ([aKey table] == nil)) {
                    ks->keys[index] = nil; // XXX no-release
                    if (ks->hashcodeChars) {
                        free(ks->hashcodeChars);
                        ks->hashcodeChars = NULL;
                    }
                }
            }
        } else {
            int  idx = ks->count;
            id  *keys = malloc(sizeof(id) * idx);
            memcpy(keys, ks->keys, sizeof(id) * idx);
            
            FSkeysetDealloc(ks);

            while (index-- > 0) {
                if (keys[index])
                    FSkeysetAddKey(ks, keys[index]);
            }
            
            free(keys);
        }
    } else {
        if (ks->hashcodeChars) {
            free(ks->hashcodeChars);
            ks->hashcodeChars = NULL;
        }
    }
}

void FSkeysetGenerateHashcode(FSkeyset *ks)
{
    if (ks->keys) {
        int index = 0;

        if (ks->hashcodeChars == NULL)
            ks->hashcodeChars = malloc(8*ks->count + 1);

        while (index < ks->count) {
            sprintf(ks->hashcodeChars+index*8, "%08X", (int)ks->keys[index]);
            index++;
        }
    }
}

void FSkeysetDealloc(FSkeyset *ks)
{
    if (ks->keys) {
        free(ks->keys);
        ks->keys = NULL;
        ks->count = 0;
        if (ks->hashcodeChars) {
            free(ks->hashcodeChars);
            ks->hashcodeChars = NULL;
        }
    }
}
