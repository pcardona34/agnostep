//  $Id: FSTestDocument.m,v 1.1 2008/10/14 15:04:40 hns Exp $
//
//  FSTestDocument.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 07-DEC-2001.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//  
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

#import "FSTestDocument.h"


@implementation FSTestDocument

+ (FSTestDocument*)setupSingleTableExample
{
    FSTestDocument *document = [[FSTestDocument alloc] init];
    id              hdr;
    int             idx;
    NSString       *prefix;
    FSTable        *table = [[FSTable alloc] init];

    [table setName:@"Table"];
    [document addTable:table];
    [table release];

    prefix = [table nextAvailableHeaderName];
    hdr = [FSHeader headerNamed:prefix];
    [table addHeader:hdr];
    for (idx = 0; idx < 3; idx++) {
        [hdr appendKeyWithLabel:[NSString stringWithFormat:@"%@%i", prefix, idx+1]];
    }

    prefix = [table nextAvailableHeaderName];
    hdr = [FSHeader headerNamed:prefix];
    [table addHeader:hdr];
    for (idx = 0; idx < 3; idx++) {
        [hdr appendKeyWithLabel:[NSString stringWithFormat:@"%@%i", prefix, idx+1]];
    }

    [table setDocument:document];
    return [document autorelease];
}


+ (FSTestDocument*)setupLinkedTableExample
{
    FSTestDocument *document = [[FSTestDocument alloc] init];
    id              hdr;
    int             idx;
    NSString       *prefix;
    FSTable        *table1 = [[FSTable alloc] init];
    FSTable        *table2 = [[FSTable alloc] init];
    FSGlobalHeader *globalHeader = [[FSGlobalHeader alloc] init];

    [table1 setName:@"Table"];
    [document addTable:table1];
    [table1 release];

    [table2 setName:@"Clone"];
    [document addTable:table2];
    [table2 release];

    // This creates a category
    prefix = @"A";
    hdr = [FSHeader headerNamed:prefix];
    [table2 addHeader:hdr];
    [globalHeader addHeader:hdr];

    // in both tables and links them
    hdr = [FSHeader headerNamed:prefix];
    [table1 addHeader:hdr];
    [globalHeader addHeader:hdr];

    // Fill in the items (into both tables!)
    for (idx = 0; idx < 3; idx++) {
        [hdr appendKeyWithLabel:[NSString stringWithFormat:@"%@%i", prefix, idx+1]];
    }

    // Rename both categories to "Linked"
    [hdr setLabel:@"Linked"];

    prefix = [table1 nextAvailableHeaderName];
    hdr = [FSHeader headerNamed:prefix];
    [table1 addHeader:hdr];
    for (idx = 0; idx < 3; idx++) {
        [hdr appendKeyWithLabel:[NSString stringWithFormat:@"%@%i", prefix, idx+1]];
    }

    [table1 setDocument:document];
    [table2 setDocument:document];
    return [document autorelease];
}


- (id)init
{
    self = [super init];
    if (self != nil) {
        _tables = [[NSMutableArray alloc] init];
        _globalCategories = [[NSMutableArray alloc] init];
        _undoManager = [[NSUndoManager alloc] init];
        [FSLog logDebug:@"FSTestDocument %X allocated.", self];
    }
    return self;
}


- (void)dealloc
{
    [_undoManager release];
    _undoManager = nil;
    [_tables makeObjectsPerformSelector:@selector(setDocument:) withObject:nil];
    [_tables release];
    _tables = nil;
    [_globalCategories release];
    [FSLog logDebug:@"FSTestDocument %X deallocated.", self];
    [super dealloc];
}


- (NSArray*)tables
{
    return _tables;
}


- (void)addTable:(FSTable*)aTable
{
    [_tables addObject:aTable];
}


- (FSTable*)tableWithName:(NSString*)name
{
    FSTable *table;
    int      idx = 0;
    
    while (idx < [_tables count]) {
        table = [_tables objectAtIndex:idx];
        if ([name isEqualToString:[table name]])
            return table;
        idx++;
    }
    return nil;
}


- (NSUndoManager*)undoManager
{
    return _undoManager;
}


- (void)addToGlobalCategories:(FSGlobalHeader*)aGlobalHeader
{
    [_globalCategories addObject:aGlobalHeader];
}


- (void)removeFromGlobalCategories:(FSGlobalHeader*)aGlobalHeader
{
    [_globalCategories removeObject:aGlobalHeader];
}


- (NSArray*)globalCategories
{
    return _globalCategories;
}

@end
