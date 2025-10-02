//  $Id: FSHeader.m,v 1.1 2008/10/14 15:04:20 hns Exp $
//
//  FSHeader.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-JAN-2001.
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

#import <FSCore/FSHeader.h>
#import <FSCore/FSTable.h>
#import <FSCore/FSTable.h>
#import <FSCore/FSGlobalHeader.h>
#import <FSCore/FSKey.h>
#import <FSCore/FSKeyGroup.h>
#import <FSCore/FoundationExtentions.h>

@interface FSKeyGroup (ArchivingPrivate)

- (NSArray*)_keysForArchiving;

@end


@implementation FSHeader
/*" An FSHeader object represents a category within a spreadsheet table. 
    Categories contain items representing rows, columns, or pages 
    of the actual table. "*/


+ (FSHeader*)headerNamed:(NSString*)label
/*" Creates a new category named label.  
    No checking is performed that the name is unique in the table. "*/
{
    FSHeader  *instance = [[FSHeader alloc] init];
    [instance setLabel:label];
    return [instance autorelease];
}


- (id)init
/*" Designated initializer.  The name is set to A. "*/
{
    self = [super init];
    if (self) {
        [self setLabel:@"A"];
    }
    return self;
}


- (void)dealloc
{
    [_global release];
    [super dealloc];
}

//
//
//

- (FSDocument*)document
/*" Returns the FSDocument this header dimension belongs to. "*/
{
    return (FSDocument*)[_table document];
}


- (FSTable*)table
/*" Returns the FSTable this category belongs to. "*/
{
    return _table;
}


- (void)setTable:(FSTable*)table
/*" Sets the table.  Careful with this method! "*/
{
    _table = table; /* not retained! */
}


- (FSHeader*)cloneForTable:(FSTable*)otherTable
/*" Creates an exact copy of the receiving instance,
    but attached to otherTable.
    "*/
{
    FSHeader *clone = [FSHeader headerNamed:[self label]];
    [clone fillFromArray:[self _keysForArchiving]];
    [otherTable addHeader:clone];
    return clone;
}


- (FSHeader*)linkedHeaderInTable:(FSTable*)table
{
    if (table == _table) return self;
    if (_global == nil) return nil;
    return [_global linkedHeaderInTable:table];
}


- (FSGlobalHeader*)globalHeader
{
    return _global;
}


- (void)setGlobalHeader:(FSGlobalHeader*)globalHeader
{
    [globalHeader retain];
    [_global release];
    _global = globalHeader;
}


- (void)setLabel:(NSString*)label forItemWithPath:(NSString*)path
{
    [[self itemWithPath:path] setLabel:label];
}


- (void)moveItemFromIndex:(unsigned)idx1 toIndex:(unsigned)idx2 atPath:(NSString*)path
{
    FSKeyGroup *group = [self itemWithPath:path];
    [group moveItemFromIndex:idx1 toIndex:idx2];
}


- (void)insertKeyWithLabel:(NSString*)label intoGroupWithPath:(NSString*)path atIndex:(int)index
{
    FSKeyGroup *group = [self itemWithPath:path];
    [group insertKeyWithLabel:label atIndex:index];
}


- (NSDictionary*)dictionaryForArchiving
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[self className] forKey:@"Class"];
    [dict setObject:[self label] forKey:@"Name"];
    [dict setObject:[self _keysForArchiving] forKey:@"Labels"];
        
    if (_global) {
        NSArray  *links = [[self document] globalCategories];
        NSString *index = [NSString stringWithFormat:@"%i", [links indexOfObject:_global]];
        [dict setObject:index forKey:@"GlobalLink"];
    }
    
    return dict;
}

@end

@implementation FSKeyGroup (Archiving)

- (NSArray*)_keysForArchiving
{
    NSMutableArray *archive = [NSMutableArray array];
    int             index = 0, count = [_items count];
    id              object;
    
    for (index = 0; index < count; index++) {
        object = [_items objectAtIndex:index];
        if ([object isKindOfClass:[FSKeyGroup class]]) {
            [archive addObject:[object dictionaryForArchiving]];
        } else {
            [archive addObject:[object label]];
        }
    }    
    
    return archive;
}


- (NSDictionary*)dictionaryForArchiving
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[self className] forKey:@"Class"];
    [dict setObject:[self label] forKey:@"Name"];
    [dict setObject:[self _keysForArchiving] forKey:@"Labels"];
    
    return dict;
}

@end
