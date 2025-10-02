//  $Id: FSKeyGroup.h,v 1.1 2008/10/14 15:04:20 hns Exp $
//
//  FSKeyGroup.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 26-SEP-2001.
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

#import <Foundation/Foundation.h>
#import <FSCore/FSTypes.h>
#import <FSCore/FSDocumentProtocol.h>

@class FSHashMap;
@class FSKey, FSKeySet, FSKeyGroup, FSHeader, FSTable, FSDocument;

@protocol FSItem <NSObject>

- (FSTable*)table;
- (FSHeader*)header;
- (FSKeyGroup*)group;
- (NSArray*)groups;
- (void)setGroup:(FSKeyGroup*)group;

- (NSString*)fullPath;

- (NSString*)label;
- (void)setLabel:(NSString*)label;

- (void)removeFromHeader;

- (NSComparisonResult)smartCompare:(id<FSItem>)otherObject;
- (NSComparisonResult)smartCompareReverse:(id<FSItem>)otherObject;

@end

@interface FSKeyGroup : NSObject <FSItem>
{
    FSKeyGroup      *_group;     /*" The parent group.  Not retained. "*/
    NSString        *_label;     /*" The name this group goes by. "*/
    NSMutableArray  *_items;     /*" All keys and subgroups in this group. "*/
    NSString        *_fullPath;  /*" the full path [groupname.]label"*/
    NSArray         *_cachedKeys;
    NSArray         *_cachedGroups;
    NSUndoManager   *_cachedUM;  /*" This is retained. "*/
    FSHashMap       *_itemLookup;
}

+ (FSKeyGroup*)groupWithLabel:(NSString*)label;
+ (FSKeyGroup*)groupWithKeys:(NSArray*)keys;

// Attributes
- (id<FSDocument>)document;
- (FSTable*)table;
- (FSHeader*)header;
- (FSKeyGroup*)group;
- (void)setGroup:(FSKeyGroup*)group;
- (NSString*)label;
- (void)setLabel:(NSString*)label;
- (NSArray*)items;
- (void)setItems:(NSArray*)items;

// Accessing all keys flat
- (NSArray*)keys;

// Accessing all groups flat
- (NSArray*)subgroups;

// Pasteboard Support
- (NSDictionary*)pboardDataFromRange:(NSRange)range;
- (int)pasteData:(NSDictionary*)pbData atIndex:(int)index;

- (void)fillFromArray:(NSArray*)items;
- (void)deleteItemsInRange:(NSRange)range;

// Editing
- (FSKey*)appendKeyWithLabel:(NSString*)label;
- (FSKey*)insertKeyWithLabel:(NSString*)label atIndex:(int)index;
- (int)removeItemWithLabel:(NSString*)label;
- (void)moveItemFromIndex:(unsigned)idx1 toIndex:(unsigned)idx2;

- (FSKeyGroup*)groupItemsInRange:(NSRange)keyRange withLabel:(NSString*)label;
- (void)ungroupAtIndex:(unsigned)index;
- (void)ungroupItemsInGroup:(FSKeyGroup*)group;

// Sorting
- (void)sortItemsByName;
- (void)sortItemsByName:(BOOL)reverse;
- (void)sortItemsWithOtherKeys:(FSKeySet*)otherKeys;
- (void)sortItemsWithOtherKeys:(FSKeySet*)otherKeys ascending:(BOOL)order;

// Misc
- (BOOL)containsKey:(FSKey*)key;
- (id)itemWithLabel:(NSString*)label;
- (BOOL)item:(id<FSItem>)item willBeLabeled:(NSString*)newLabel;
- (FSKeyGroup*)groupWithLabel:(NSString*)aLabel;
- (FSKey*)keyWithLabel:(NSString*)aLabel;
- (FSKey*)keyWithPath:(NSString*)path;
- (id<FSItem>)itemWithPath:(NSString*)path;

@end


extern NSArray* FSExpandItemsToKeys(NSArray *items);
