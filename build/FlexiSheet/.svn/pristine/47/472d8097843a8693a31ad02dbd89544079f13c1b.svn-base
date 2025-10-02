//  $Id: FSTable.m,v 1.2 2014/01/26 09:23:53 buzzdee Exp $
//
//  FSTable.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 10-SEP-2001.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
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
#import "FSGlobalHeader.h"
#import "FoundationExtentions.h"
#import "FSParserFunctions.h"
#import "FSHashMap.h"


NSString* FSTableWillChangeNotification  = @"FSTableWillChange";
/*" A FSTableWillChangeNotification is sent before the structure
    of a table changes, i.e. a header dimension is added or
    a label is added to an existing dimension."*/

NSString* FSTableDidChangeNotification   = @"FSTableDidChange";
/*" A FSTableWillChangeNotification is sent right after the structure
    of a table changed, i.e. a header dimension was added or
    a label was added to an existing dimension."*/

NSString* FSItemWillChangeNotification   = @"FSItemWillChange";
NSString* FSItemDidChangeNotification    = @"FSItemDidChange";
NSString* FSNewNameUserInfo              = @"FSNewName";
NSString* FSOldPathUserInfo              = @"FSOldPath";
/*" Sent right before/after a key will change name or group. 
    Object is Table. UserInfo: 
    Item, FSNewNameUserInfo "*/

NSString* FSValueDidChangeNotification   = @"FSValueDidChange";
/*" Sent after a value changed. "*/

NSString* FSEditRevertedNotification     = @"FSEditReverted";
/*" Sent after a ended edit change could not be completed. 
    This happens when renaming a label to an already used name. "*/

@implementation FSTable
/*" An FSTable instance (also just called a table) is where FlexiSheet stores values.
    Users can give tables a name to reference them by.  Default names for tables are
    Table 1, Table 2, and so forth.
    
    A document can have multiple tables, and views on the document (graphs, formulas)
    can access all present tables.  However, the table view is an exception for obvious
    reasons.  It is the view for exactly one table.
    "*/

- (id)init
{
    self = [super init];
    if (self) {
        _values = [[FSHashMap alloc] init];
        _headers = [[NSMutableArray alloc] init];
        _formulaSpace = [[FSFormulaSpace alloc] initWithTable:self];
        _postNotifications = YES;
        _keysets = [[NSMutableArray alloc] init];
        TEST_DBG [FSLog logDebug:@"FSTable %X allocated.", self];
    }
    return self;
}


- (id)retain
{
    TEST_DBG [FSLog logDebug:@"FSTable %X retained (now at %i).", self, [self retainCount]+1];
    return [super retain];
}


- (oneway void)release
{
    TEST_DBG [FSLog logDebug:@"FSTable %X released (now at %i).", self, [self retainCount]-1];
    [super release];
}


- (void)dealloc
{
    [[_document undoManager] removeAllActionsWithTarget:self];
    [_headers makeObjectsPerformSelector:@selector(setTable:) withObject:nil];
    [_headers release];
    [_values release];
    [_formulaSpace release];

    [_keysets release];
    
    [_name release];
    [_comment release];
    TEST_DBG [FSLog logDebug:@"FSTable %X deallocated.", self];
    [super dealloc];
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"FSTable '%@'\nHeaders:\n%@\n",
        _name, [_headers description]];
}


- (NSUndoManager*)undoManager
{
    return [_document undoManager];
}


- (NSNotificationCenter*)notificationCenter
{
    return (_postNotifications)?[NSNotificationCenter defaultCenter]:nil;
}


- (BOOL)shouldPostNotifications { return _postNotifications; }
- (void)setShouldPostNotifications:(BOOL)flag
{
    if (flag != _postNotifications) {
        _postNotifications = flag;
        if (flag == NO) {
            [[self notificationCenter] postNotificationName:FSTableWillChangeNotification object:self];
        } else {
            [[self notificationCenter] postNotificationName:FSTableDidChangeNotification object:self];
        }
    }
}


- (NSData*)comment
/*" Returns the comment. "*/
{
    return _comment;
}


- (void)setComment:(NSData*)comment
{
    if ([comment isEqualToData:_comment]) return;
    [[self undoManager]
        registerUndoWithTarget:self selector:@selector(setComment:) object:_comment];
    [_comment release];
    _comment = [comment copy];
}


- (NSString*)name
/*" Returns the name of this table. "*/
{
    return _name;
}


- (void)setName:(NSString*)name
/*" Sets the name of this table.  This method does not check for name conflicts within the document! "*/
{
    NSNotificationCenter *nc = [self notificationCenter];
    
    if ([name isEqualToString:_name]) return;
    [nc postNotificationName:FSTableWillChangeNotification object:self];
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setName:) object:_name];
    [_name release];
    _name = [name copy];
    [nc postNotificationName:FSTableDidChangeNotification object:self];
}

- (id<FSDocument>)document { return _document; }
- (void)setDocument:(id<FSDocument>)document \
/*" Document is not retained! "*/
{ _document = document; }


- (NSArray*)headers
/*" Returns an array of all FSHeader instances used in this document. "*/
{
    return _headers;
}


- (int)indexOfHeader:(FSHeader*)header
/*" Returns the index of header (headers are ordered). "*/
{
    return [_headers indexOfObject:header];
}


- (void)_revalidateAllExistingValues
{
    NSArray   *values = [_values allObjects];
    int        index = [values count];
    FSValue   *value;
    FSHashKey  oldHash;
    FSHashKey  newHash;
    
    while (index-- > 0) {
        value = [values objectAtIndex:index];
        oldHash = strdup([value hashcode]);
        [value revalidateKeys];
        newHash = [value hashcode];
        if (strcmp(oldHash, newHash) != 0) {
            [_values removeObjectForKey:oldHash];
            //[FSLog logInfo:@"Removing value for keyset %s", oldHash];
            if ([value hasCompleteKeys]) {
                [_values setObject:value forKey:newHash];
                //[FSLog logInfo:@"and adding it as %s", newHash];
            }
        } else {
            //[FSLog logInfo:@"Ignoring value for keyset %s", oldHash];
        }
        free((char*)oldHash);
    }
}

- (void)_revalidateAllExistingValuesAfterAddingHeader:(FSHeader*)header
{
    NSArray   *values = [_values allObjects];
    int        index = [values count];
    FSValue   *value;
    FSHashKey  oldHash;
    FSHashKey  newHash;
    FSKey     *onlyKey = [[header keys] lastObject];
    
    while (index-- > 0) {
        value = [values objectAtIndex:index];
        oldHash = strdup([value hashcode]);
        [value addKey:onlyKey];
        newHash = [value hashcode];
        [_values removeObjectForKey:oldHash];
        [_values setObject:value forKey:newHash];
        free((char*)oldHash);
    }
}

- (NSString*)nextAvailableHeaderName
{
    char name[3];
    
    name[1] = 0;
    name[0] = 'A'+[_headers count];
    
    return [NSString stringWithCString:name];
}

- (void)addHeader:(FSHeader*)newHeader
/*" Adds newHeader to the list of headers for this document. 
    Adding a header to an existing table with values in it
    is far more complicated than what this method does.
    All FSValue instances need to "*/
{

    if (newHeader == nil) return;
    
    if (NO == [_headers containsObject:newHeader]) {
        NSNotificationCenter *nc = [self notificationCenter];
        
        if ([newHeader table] != nil) {
            [NSException raise:@"FSException"
                format:@"FSHeader already belongs to a different table."];
        }
        [_headers addObject:newHeader];
        [newHeader setTable:self];
        [[self undoManager]
            registerUndoWithTarget:self 
            selector:@selector(removeHeader:)
            object:newHeader];
        [self _revalidateAllExistingValuesAfterAddingHeader:newHeader];
        [nc postNotificationName:FSTableDidChangeNotification object:self];
    }
}


- (void)reconstructHeader:(NSString*)label withPboard:(NSDictionary*)pbData
{
    NSNotificationCenter *nc = [self notificationCenter];
    FSHeader *header = [FSHeader headerNamed:label];

    [nc postNotificationName:FSTableWillChangeNotification object:self];
    [_headers addObject:header];
    [header pasteData:pbData atIndex:0];
    [header setTable:self];
    [self _revalidateAllExistingValuesAfterAddingHeader:header];
    [[[self undoManager] prepareWithInvocationTarget:self]
        removeHeader:header];
    [nc postNotificationName:FSTableDidChangeNotification object:self];
}


- (void)removeHeader:(FSHeader*)aHeader
/*" Removes aHeader from the list of headers for this table.
    A header can only be removed if there is at most one key
    in this header.  Otherwise, we would not know what should
    happen with the values. "*/
{
    NSNotificationCenter *nc = [self notificationCenter];

    if ([aHeader table] != self) {
        [NSException raise:@"FSException"
            format:@"FSHeader belongs to a different table; cannot remove."];
    }
    [nc postNotificationName:FSTableWillChangeNotification object:self];
    [[[self undoManager] prepareWithInvocationTarget:self]
        reconstructHeader:[aHeader label] 
        withPboard:[aHeader pboardDataFromRange:NSMakeRange(0,[[aHeader items] count])]];
    [aHeader retain];
    if ([aHeader globalHeader]) {
        [[aHeader globalHeader] removeHeader:aHeader];
    }
    [[self undoManager] disableUndoRegistration];
    [aHeader deleteItemsInRange:NSMakeRange(0,[[aHeader items] count])];
    [_headers removeObject:aHeader];
    [self _revalidateAllExistingValues];
    [[self undoManager] enableUndoRegistration];
    [nc postNotificationName:FSTableDidChangeNotification object:self];
    [aHeader release];
}


- (FSHeader*)headerWithName:(NSString*)name
{
    id  object;
    int index = [_headers count];
    while (index > 0) {
        object = [_headers objectAtIndex:--index];
        if ([[object label] isEqual:name])
            return object;
    }
    return nil;
}


- (NSArray*)keysForString:(NSString*)string
/*" string can specify an item label directly,
    or by prefixing it like this:
    '[[category.]group.][group.]item' "*/
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray        *parts = FSSplitStringByDots(string);
    int             index = [_headers count];
    FSHeader       *header;
    NSString       *keyName = [parts lastObject];
    NSArray        *keys;
    int             kdx;
    FSKey          *key;
    NSString       *name;
    
    if ([keyName length] == 0)
        return result;
    
    if ([keyName isSingleQuotedString]) {
        keyName = [keyName stringByTrimmingQuotes]; 
    }
    
    while (index-- > 0) {
        header = [_headers objectAtIndex:index];
        keys = [header keys];
        kdx = [keys count];
        while (kdx-- > 0) {
            key = [keys objectAtIndex:kdx];
            if ([[key label] isEqualToString:keyName]) {
                if ([parts count] > 1) {
                    int idx = [parts count]-1;
                    id  group = [key group];
                    while ((idx-- > 0) && group && key) {
                        name = [group label];
                        if ([name needsQuoting])
                            name = [name wrapInSingleQuotes];
                        if ([name isEqualToString:[parts objectAtIndex:idx]] == NO)
                            key = nil;
                        group = [group group];
                    }
                }
                if (key)
                    [result addObject:key];
            }
        }
    }
    
    return result;
}


- (NSArray*)groupsForString:(NSString*)string
/*" string can specify a group label directly,
    or by prefixing it like this:
    '[[category.]group.][group.]group' "*/
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray        *parts = FSSplitStringByDots(string);
    int             index = [_headers count];
    FSHeader       *header;
    NSString       *keyName = [parts lastObject];
    FSKeyGroup     *keygroup;
    NSString       *name;
    
    if ([keyName length] == 0)
        return result;
    
    while (index-- > 0) {
        header = [_headers objectAtIndex:index];
        
        name = [header label];
        if ([name needsQuoting]) {
            name = [name wrapInSingleQuotes];
        }
        
        if (([parts count] == 1) && [name isEqualToString:keyName]) {
            [result addObject:header];
        } else
        if ((keygroup = [header groupWithLabel:keyName])) {
            if ([parts count] > 1) {
                int idx = [parts count]-1;
                id  group = [keygroup group];
                while ((idx-- > 0) && group && keygroup) {
                    name = [group label];
                    if ([name needsQuoting])
                        name = [name wrapInSingleQuotes];
                    if ([name isEqualToString:[parts objectAtIndex:index]] == NO)
                        keygroup = nil;
                    group = [group group];
                }
            }
            if (keygroup)
                [result addObject:keygroup];
        }
    }
    
    return result;
}


- (NSArray*)headersWithNames:(NSArray*)names
{
    NSMutableArray *headers = [NSMutableArray array];
    int             index;
    
    for (index = 0; index < [names count]; index++) {
        [headers addObject:[self headerWithName:[names objectAtIndex:index]]];
    }
    
    return headers;
}


- (FSValue*)valueForKeySet:(FSKeySet*)keySet
/*" Finds the value for the given keySet and returns it.
    Creates an empty one if none exists. "*/
{
    FSHashKey     hashcode = [keySet hashcode];
    FSValue      *value;

    if (hashcode == NULL) return nil;
    if (hashcode[0] == 0) return nil;
    
    value = [_values objectForKey:hashcode];
    if (value) return value; 

    [[_document undoManager] disableUndoRegistration];
    value = [[FSValue alloc] initWithValue:nil forKeys:keySet];
    [[_document undoManager] enableUndoRegistration];
    [_values setObject:value forKey:[value hashcode]];
    [value release]; // still retained in _values
    
    return value;
}


- (FSValue*)setValue:(id)aValue forKeySet:(FSKeySet*)keySet
{
    FSHashKey   hashcode = [keySet hashcode];
    FSValue    *value;

    if (keySet == nil)
        [NSException raise:@"FSTable" format:@"Cannot set value for nil keyset."];
    
    value = [_values objectForKey:hashcode];
    if (value) {
        [value setValue:aValue postNotification:YES];
    } else {
        value = [[FSValue alloc] initWithValue:aValue forKeys:keySet];
        [_values setObject:value forKey:[value hashcode]];
        [value release]; // still retained in _values
    }
    
    return value;
}


- (NSArray*)keySetsForHeaders:(NSArray*)headers
/*" Returns an array of key sets. "*/
{
    int             index = 0;
    FSHeader       *header;
    NSArray        *labels;
    FSKeySet       *set = nil;
    FSKey          *key;
    NSArray        *result = nil;
    NSEnumerator   *keyCursor, *setCursor;
    NSMutableArray *temp;

    result = [[NSArray alloc] initWithObjects:[FSKeySet keySet], nil];
    while (index < [headers count]) {
        header = [headers objectAtIndex:index];
        labels = [header keys];
        if ([labels count]) {
            temp = [[NSMutableArray alloc] init];
            setCursor = [result objectEnumerator];
            while ((set = [setCursor nextObject])) {
                keyCursor = [labels objectEnumerator];
                while ((key = [keyCursor nextObject])) {
                    [temp addObject:[set setByAddingKey:key]];
                }
            }
            [result release];
            result = temp;
        }
        index++;
    }
    
    return [result autorelease];
}


- (NSArray*)valuesInSelection:(FSSelection*)selection
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray        *keySets = [selection completeKeySets];
    int             kdx = 0, kct = [keySets count];
    FSValue        *value;
    
    while (kdx < kct) {
        value = [self valueForKeySet:[keySets objectAtIndex:kdx]];
        [result addObject:[value value]];
        kdx++;
    }
    
    return result;
}


- (void)setValues:(NSArray*)values inSelection:(FSSelection*)selection
{
    NSArray *keySets = [selection completeKeySets];
    int      kdx = 0, kct = [keySets count];
    int      idx = 0, vct = [values count];
    
    if (vct > 0) {
        while (kdx < kct) {
            [[self valueForKeySet:[keySets objectAtIndex:kdx]]
                setValue:[values objectAtIndex:idx] postNotification:YES];
            kdx++;
            idx = (idx+1)%vct;
        }
    } else {
        while (kdx < kct) {
            [[self valueForKeySet:[keySets objectAtIndex:kdx]] 
                setValue:@"" postNotification:YES];
            kdx++;
        }
    }
}

@end


@implementation FSTable (Archiving)

- (NSArray*)_valuesForArchiving
/*" Returns an NSArray containing archiving dictionaries for all values in this table. "*/
{
    NSMutableArray *archive = [NSMutableArray array];
    NSArray        *values = [_values allObjects];
    int             index = 0, count = [values count];
    FSValue        *aValue;
    id              dict;
    
    for (index = 0; index < count; index++) {
        aValue = [values objectAtIndex:index];
        if (nil == [aValue calculatedByFormula]) {
            dict = [aValue dictionaryForArchiving];
            if (dict) {
                [archive addObject:dict];
            }
        }
    }
    
    return archive;
}


- (NSArray*)_headersForArchiving
/*" Returns an NSArray containing archiving dictionaries for all headers in this table. "*/
{
    NSMutableArray *archive = [NSMutableArray array];
    int             index = 0, count = [_headers count];
    
    for (index = 0; index < count; index++) {
        [archive addObject:[[_headers objectAtIndex:index] dictionaryForArchiving]];
    }
    
    return archive;
}


- (NSArray*)_formulaeForArchiving
/*" Returns an NSArray containing string representations for all formulas in this table. "*/
{
    NSMutableArray *archive = [NSMutableArray array];
    NSArray        *formulae = [_formulaSpace formulae];
    int             index = 0, count = [formulae count];
    
    for (index = 0; index < count; index++) {
        [archive addObject:[[formulae objectAtIndex:index] description]];
    }
    
    return archive;
}


- (void)_setValuesFromArray:(NSArray*)values
{
    NSMutableDictionary  *lookup = [NSMutableDictionary dictionary];
    int                   index, count = [values count];
    int                   i2, c2;
    NSDictionary         *dict, *keys;
    FSHeader             *hdr;
    FSValue              *value;
    NSString             *strg;
    
    // First, build a lookup for the document's headers.
    c2 = [_headers count];
    for (i2 = 0; i2 < c2; i2++) {
        hdr = [_headers objectAtIndex:i2];
        [lookup setObject:hdr forKey:[hdr label]];
    }
    
    // Then, read all stored values and create.
    for (index = 0; index < count; index++) {
        dict = [values objectAtIndex:index];
        keys = [dict objectForKey:@"KeySet"];
        strg = [dict objectForKey:@"Value"];
        if ([strg length]) {
            FSKeySet *keyset = [FSKeySet keySetWithKeys:keys inTable:self];
            if (keyset) {
                value = [self setValue:strg forKeySet:keyset];
            } else {
                [FSLog logError:@"Unable to make keyset from keys:\n%@", keys];
            }
        }
    }
    [[self notificationCenter] postNotificationName:FSValueDidChangeNotification object:self];
}


- (void)_setHeadersFromArray:(NSArray*)headers
{
    NSArray             *globalCategories;
    FSGlobalHeader      *gh;
    int                  index = 0, count = [headers count];
    NSDictionary        *dict;
    FSHeader            *hdr;
    NSString            *value;
    int                  ghIdx;
    
    globalCategories = [_document globalCategories];
    for (index = 0; index < count; index++) {
        dict = [headers objectAtIndex:index];
        hdr = [FSHeader headerNamed:[dict objectForKey:@"Name"]];
        [self addHeader:hdr];
        [hdr fillFromArray:[dict objectForKey:@"Labels"]];
        value = [dict objectForKey:@"GlobalLink"];
        if ([value isKindOfClass:[NSString class]]) {
            ghIdx = [value intValue];
            if (ghIdx < [globalCategories count]) {
                gh = [globalCategories objectAtIndex:ghIdx];
            } else {
                NSAssert(ghIdx == [globalCategories count], @"Corrupt file.");
                gh = [[FSGlobalHeader alloc] init];
                [_document addToGlobalCategories:gh];
                [gh release];
            }
            [gh addHeader:hdr];
        }
    }
}


- (void)_setFormulaeFromArray:(NSArray*)formulae
{
    int  index = 0, count = [formulae count];
    
    for (index = 0; index < count; index++) {
        [self addFormula:[formulae objectAtIndex:index]];
    }
}


- (BOOL)loadFromDictionary:(NSDictionary*)dict
{
    NSUndoManager *um = [self undoManager];
    id             value;

    [self setShouldPostNotifications:NO];
    [um disableUndoRegistration];
    [_headers removeAllObjects];
    [_values removeAllObjects];
    
    value = [dict objectForKey:@"Name"];
    if ([value isKindOfClass:[NSString class]]) [self setName:value];
    value = [dict objectForKey:@"Comment"];
    if ([value isKindOfClass:[NSData class]]) {
        [self setComment:value];
    }
    [self _setHeadersFromArray:[dict objectForKey:@"Headers"]];
    [self _setValuesFromArray:[dict objectForKey:@"Values"]];
    [self _setFormulaeFromArray:[dict objectForKey:@"Formulae"]];
    [um enableUndoRegistration];
    [self setShouldPostNotifications:YES];
 
    return YES;
}


- (NSDictionary*)dictionaryForArchiving
{
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    [dataDict setObject:@"FSTable" forKey:@"Class"];
    [dataDict setObject:[self name] forKey:@"Name"];
    if (_comment) [dataDict setObject:_comment forKey:@"Comment"];
    [dataDict setObject:[self _headersForArchiving] forKey:@"Headers"];
    [dataDict setObject:[self _valuesForArchiving] forKey:@"Values"];
    [dataDict setObject:[self _formulaeForArchiving] forKey:@"Formulae"];
    
    return dataDict;
}

@end
