//  $Id: FSSelection.m,v 1.2 2012/01/25 13:35:34 rmottola Exp $
//
//  FSSelection.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 02-OCT-2001.
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

@implementation FSSelection
/*" An FSSelection object (a selection) represents a selection in a table.
If there is exactly one range for each category in a table,
the selection is said to be complete.
Incomplete selections can be expanded to an array of complete sets
using a (complete) base key set. "*/

+ (FSSelection*)selection
{
    return [[[self allocWithZone:NULL] init] autorelease];
}


+ (FSSelection*)selectionWithRanges:(NSArray*)ranges
    /*" Will always return a FSRangeSelection"*/
{
    return [[[self allocWithZone:NULL] initWithRanges:ranges] autorelease];
}


+ (FSSelection*)selectionWithKeySets:(NSArray*)keySets
{
    return [[[self allocWithZone:NULL] initWithKeySets:keySets] autorelease];
}


- (NSEnumerator*)objectEnumerator
    /*" Creates a list of possibly incomplete keysets from the ranges.
    If for some reason this selection does not contain a single
    element, an enumerator with one empty keyset is returned. "*/
{
    return [[self selectedKeySets] objectEnumerator];
}


- (id)init
{
    self = [super init];
    if (self)
      {
        // we're open to be a range or keyset based selection
        _keySets = nil;
        _rangeForHeader = nil;
      }
    return self;
}


- (id)initWithRange:(FSKeyRange*)range
{
    self = [super init];
    if (self) {
        _rangeForHeader = [[NSMutableDictionary allocWithZone:NULL] init];
        [self extendWithRange:range];
    }
    return self;
}


- (id)initWithRanges:(NSArray*)ranges
{
    self = [super init];
    if (self) {
        int index = 0;

        _keySets = nil;
        while (index < [ranges count]) {
            [self extendWithRange:[ranges objectAtIndex:index]];
            index++;
        }
    }
    return self;
}


- (id)initWithKeySets:(NSArray*)keySets
{
    self = [super init];
    if (self) {
        if (keySets) {
            _keySets = [[NSMutableArray alloc] initWithArray:keySets];
        } else {
            _keySets = [[NSMutableArray alloc] init];
        }
        _rangeForHeader = nil;
    }
    return self;
}


- (void)dealloc
{
    [_rangeForHeader release];
    [_keySets release];
    [super dealloc];
}

//
//
//

- (BOOL)extendWithRange:(FSKeyRange*)aRange
{
    FSHeader *rangeHeader = [aRange header];

    if (_keySets != nil) return NO;
    if (_rangeForHeader == nil) {
        _rangeForHeader = [[NSMutableDictionary alloc] init];
    }
    if (rangeHeader != nil) {
        if ([_rangeForHeader count] == 0) {
            [_rangeForHeader setObject:aRange forKey:[rangeHeader label]];
        } else {
            //assert([rangeHeader table] == [self table]);
            [_rangeForHeader setObject:aRange forKey:[rangeHeader label]];
        }
    }
    
    return YES;
}


- (BOOL)extendWithKeySets:(NSArray*)keySets
    /*" adds keySets to the selection. "*/
{
    if (_rangeForHeader != nil) return NO;
    if (_keySets == nil) {
        _keySets = [[NSMutableArray alloc] initWithArray:keySets];
    } else {
        [_keySets addObjectsFromArray:keySets];
    }
    return YES;
}


- (BOOL)isComplete
{
    if (_rangeForHeader != nil) {
        FSTable *table = [[[_rangeForHeader allValues] lastObject] table];
        return ([_rangeForHeader count] == [[table headers] count]);
    }
    return NO;
}

//
// Singe selection
//

- (BOOL)isSingleSelection
{
    NSArray *ranges = [_rangeForHeader allValues];
    int      index = [ranges count];
    
    if ([self isComplete] == NO) return NO;
    
    while (index-- > 0) 
        if ([[ranges objectAtIndex:index] isSingleItem] == NO)
            return NO;
    return YES;
}

- (id)singleValue
/*" Make sure with -isSingleKey first! "*/
{
    NSArray        *ranges = [_rangeForHeader allValues];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    FSValue        *value = nil;
    int             index = [ranges count];
    
    while (index-- > 0) 
        [keys addObject:[[ranges objectAtIndex:index] singleItem]];

    value = [[FSKeySet keySetWithKeys:keys] value];
    [keys release];
    return value;
}

- (BOOL)isEmpty
{
    return ([_rangeForHeader count] == 0);
}

//
// Multiple selection
//

- (BOOL)isMultipleSelection
{
    return (![self isSingleSelection]);
}


- (int)headerCount
{
    return [_rangeForHeader count];
}


- (NSArray*)ranges
{
    return [_rangeForHeader allValues];
}


- (NSArray*)rangesForHeader:(FSHeader*)aHeader
{
    return [_rangeForHeader objectForKey:[aHeader label]];
}


- (BOOL)containsKeySet:(FSKeySet*)set
{
    if (_keySets != nil) {
        return [_keySets containsObject:set];
    } else {
        NSArray *ranges = [_rangeForHeader allValues];
        int      index = [ranges count];
        NSArray *labels;
        FSKey   *key;

        while (index-- > 0) {
            labels = [[ranges objectAtIndex:index] keysInRange];
            if ([labels count]) {
                key = [set keyForHeader:[[labels lastObject] header]];
                if ([labels containsObject:key] == NO)
                    return NO;
            }
        }
        return YES;
    }
}


- (NSArray*)completeKeySets
{
    NSArray        *result = [[NSArray alloc] initWithObjects:[FSKeySet keySet], nil];
    NSArray        *ranges = [_rangeForHeader allValues];
    int             index = [ranges count];
    NSArray        *labels;
    FSKeySet       *set = nil;
    FSKey          *key;
    NSEnumerator   *keyCursor, *setCursor;
    NSMutableArray *temp;
    NSMutableArray *missingHeaders
        = [[NSMutableArray alloc] initWithArray:[[[ranges lastObject] table] headers]];
    
    while (index-- > 0) {
        labels = [[ranges objectAtIndex:index] keysInRange];
        [missingHeaders removeObject:[[labels lastObject] header]];
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
    }
    index = [missingHeaders count];
    while (index-- > 0) {
        labels = [[missingHeaders objectAtIndex:index] keys];
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
    }
    [missingHeaders release];
    
    return [result autorelease];
}


- (BOOL)intersectsWithSelection:(FSSelection*)otherSelection
{
    NSArray *ourCompleteSets = [self completeKeySets];
    NSArray *otherSelectionSets = [otherSelection completeKeySets];
    return ([ourCompleteSets firstObjectCommonWithArray:otherSelectionSets] != nil);
}


- (NSArray*)selectedKeySets
{
    if (_keySets != nil) {
        return _keySets;
    } else {
        NSArray        *result = [NSArray arrayWithObject:[FSKeySet keySet]];
        NSArray        *ranges = [_rangeForHeader allValues];
        int             index = [ranges count];
        NSArray        *labels;
        FSKeySet       *set = nil;
        FSKey          *key;
        NSEnumerator   *keyCursor, *setCursor;
        NSMutableArray *temp;

        while (index-- > 0) {
            labels = [[ranges objectAtIndex:index] keysInRange];
            if ([labels count]) {
                temp = [NSMutableArray array];
                setCursor = [result objectEnumerator];
                while ((set = [setCursor nextObject])) {
                    keyCursor = [labels objectEnumerator];
                    while ((key = [keyCursor nextObject])) {
                        [temp addObject:[set setByAddingKey:key]];
                    }
                }
                result = temp;
            } else {
                [FSLog logError:@"No keys in range %@", [ranges objectAtIndex:index]];
            }
        }
        return result;
    }
}


- (NSArray*)valuesForBaseSet:(FSKeySet*)baseSet
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray        *selSets = [self selectedKeySets];
    int             index = [selSets count];
    FSTable        *thisTable = [[selSets lastObject] table];

    if ([self isComplete]) {
        while (index-- > 0)
            [result addObject:[(FSValue*)[selSets objectAtIndex:index] value]];
    } else {
        while (index-- > 0) {
            if (thisTable != [baseSet table]) {
                baseSet = [baseSet setInLinkedTable:thisTable];
            }
            [result addObject:[[baseSet setBySubstitutingKeys:[selSets objectAtIndex:index]] value]];
        }
    }

    return result;
}


- (NSString*)creatorString
/*" The creator string is something of the form: A1:B1 .. A2:B2 "*/
{
    BOOL        isSingle = YES;
    FSKeyRange *range;
    NSArray    *items;
    NSString   *strg1 = @"";
    NSString   *strg2 = @"";
    int         index = 0;
    NSArray    *ranges = [_rangeForHeader allValues];
    int         count = [ranges count];

    while (index < count) {
        range = [ranges objectAtIndex:index];
        items = [range itemsInRange];

        strg1 = [strg1 stringByAppendingString:[[items objectAtIndex:0] fullPath]];
        strg2 = [strg2 stringByAppendingString:[[items lastObject] fullPath]];
        if ([items count] > 1) {
            isSingle = NO;
        }
        if (++index < count) {
            strg1 = [strg1 stringByAppendingString:@":"];
            strg2 = [strg2 stringByAppendingString:@":"];
        }
    }

    if (isSingle)
        return strg1;

    return [NSString stringWithFormat:@"%@ .. %@", strg1, strg2];
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@: %@", [self class], [self creatorString]];
}

@end
