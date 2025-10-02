//  $Id: FSKeyRange.m,v 1.1 2008/10/14 15:04:21 hns Exp $
//
//  FSKeyRange.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 05-OCT-2001.
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

#import <FSCore/FSKeyRange.h>
#import <FSCore/FSCore.h>


@implementation FSKeyRange
/*" An FSKeyRange instance defines the range between
    two items of a group/header.
    Both items must be in the same group! "*/

- (id)initWithItems:(id<FSItem>)first :(id<FSItem>)second
{
    self = [super init];
    if (self) {
        _1st = [first retain];
        _2nd = [second retain];
        _keyCache = nil;
    }
    return self;
}


- (void)dealloc
{
    [_1st release];
    [_2nd release];
    [_keyCache release];
    [super dealloc];
}


+ (FSKeyRange*)keyRangeFromItem:(id<FSItem>)first toItem:(id<FSItem>)second
{
    FSKeyRange *result = nil;
    if ([first group] == [second group]) {
        result = [[FSKeyRange alloc] initWithItems:first :second];
        [result autorelease];
    }
    return result;
}


+ (FSKeyRange*)keyRangeWithRange:(NSRange)range inGroup:(FSKeyGroup*)group
{
    FSKeyRange *result = nil;
    NSArray    *items = [group items];
    id<FSItem>  first;
    id<FSItem>  second;
    
    if (range.location + range.length > [items count]) return nil;
    
    first = [items objectAtIndex:range.location];
    second = [items objectAtIndex:range.location+range.length-1];
    result = [[FSKeyRange alloc] initWithItems:first :second];

    return [result autorelease];
}


- (FSTable*)table
{
    FSHeader *header = [_1st header];
    if (header != [_2nd header]) return nil;
    return [header table];
}


- (FSHeader*)header
{
    FSHeader *header = [_1st header];
    if (header != [_2nd header]) return nil;
    return header;
}


- (FSKeyGroup*)group
{
    FSKeyGroup *group = [_1st group];
    if (group != [_2nd group]) return nil;
    return group;
}


- (int)count
{
    FSHeader  *header = [_1st header];
    int        idx1, idx2;
        
    idx1 = [[header keys] indexOfObject:_1st];
    idx2 = [[header keys] indexOfObject:_2nd];
    return ABS(idx1-idx2)+1;
}


- (NSRange)indexRange
/*" Returns the range of selected items in the group.
    This is not neccessarily the index of keys in the header!
    In most cases it is not. "*/
{
    FSKeyGroup *group = [_1st group];
    int         idx1, idx2;
    NSArray    *items;
    
    if (group == nil) return NSMakeRange(0,0);
    if (group != [_2nd group]) NSMakeRange(0,0);
    
    items = [group items];
    idx1 = [items indexOfObject:_1st];
    idx2 = [items indexOfObject:_2nd];
    return NSMakeRange(MIN(idx1,idx2), ABS(idx1-idx2)+1);
}


- (NSRange)keyIndexRange
{
    NSArray *keys = [self keysInRange];
    int      index;

    if ([keys count] == 0) return NSMakeRange(0,0);    
    index = [[[self header] keys] indexOfObject:[keys objectAtIndex:0]];
    
    if (index == -1) return NSMakeRange(0,0);
    return NSMakeRange(index, [keys count]);
}


- (NSArray*)keysInRange
/*" Returns a list of all keys in the range.
    This resolves all items into their keys! "*/
{
    FSKeyGroup *group = [_1st group];

    if (group == nil) {
        if ([_1st isKindOfClass:[FSHeader class]])
            return [(FSHeader*)_1st keys];
    }
    
    if (_keyCache == nil) {
        _keyCache = [[group items] subarrayWithRange:[self indexRange]];
        _keyCache = [FSExpandItemsToKeys(_keyCache) retain];
    }
    return _keyCache;
}


- (NSArray*)itemsInRange
/*" Returns a list of all items in the range. "*/
{
    FSKeyGroup *group = [_1st group];
    NSRange     range;
    int         idx1, idx2;
    NSArray    *items;
    
    if (group == nil) return nil;
    if (group != [_2nd group]) return nil;
    
    items = [group items];
    idx1 = [items indexOfObject:_1st];
    idx2 = [items indexOfObject:_2nd];
    range = NSMakeRange(MIN(idx1,idx2), ABS(idx1-idx2)+1);
        
    return [items subarrayWithRange:range];
}


- (BOOL)isSingleItem
{
    return (_1st == _2nd);
}


- (id<FSItem>)singleItem
{
    if (_1st == _2nd) return _1st;
    return nil;
}


- (BOOL)isAtTop
{
    NSRange range = [self indexRange];
    return (range.location == 0);
}


- (BOOL)isAtBottom
{
    NSArray *items = [[_1st group] items];
    NSRange range = [self indexRange];
    return (range.location+range.length == [items count]);
}


- (NSString*)creatorString
{
    if ([self isSingleItem])
        return [_1st fullPath];
    return [NSString stringWithFormat:@"%@ .. %@", [_1st fullPath], [_2nd fullPath]];
}


- (NSString*)description
{
    if ([self isSingleItem])
        return [_1st fullPath];
    return [NSString stringWithFormat:@"%@ .. %@", [_1st fullPath], [_2nd fullPath]];
}

@end
