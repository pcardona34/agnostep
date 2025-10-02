//  $Id: FSKeyRange.h,v 1.1 2008/10/14 15:04:21 hns Exp $
//
//  FSKeyRange.h
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

#import <Foundation/Foundation.h>
#import <FSCore/FSKeyGroup.h>

@class FSKey, FSTable, FSHeader;

@interface FSKeyRange : NSObject
{
    id<FSItem>    _1st;
    id<FSItem>    _2nd;
    NSArray      *_keyCache;
}

+ (FSKeyRange*)keyRangeFromItem:(id<FSItem>)first toItem:(id<FSItem>)second;
+ (FSKeyRange*)keyRangeWithRange:(NSRange)range inGroup:(FSKeyGroup*)group;

// Accessors
- (FSTable*)table;
- (FSHeader*)header;
- (FSKeyGroup*)group;
- (NSString*)creatorString;

// Range
- (NSRange)indexRange;
- (NSRange)keyIndexRange;
- (NSArray*)keysInRange;
- (NSArray*)itemsInRange;

// Query
- (BOOL)isSingleItem;
- (id<FSItem>)singleItem;
- (BOOL)isAtTop;
- (BOOL)isAtBottom;

@end
