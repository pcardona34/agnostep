//  $Id: FSSelection.h,v 1.1 2008/10/14 15:04:22 hns Exp $
//
//  FSSelection.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 02-OCT-2001.
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


@class FSKeySet, FSHeader, FSKeyRange;

@interface FSSelection : NSObject
{
    // One of the following must be nil at all times.
    NSMutableDictionary  *_rangeForHeader; // Maps FSKeyRange objects to FSHeaders by name.
    NSMutableArray       *_keySets;        // contains FSKeySet objects building the selection.
}

// Creating and building selections
+ (FSSelection*)selection;
+ (FSSelection*)selectionWithRanges:(NSArray*)ranges;
+ (FSSelection*)selectionWithKeySets:(NSArray*)keySets;

- (id)initWithRange:(FSKeyRange*)range;
- (id)initWithRanges:(NSArray*)ranges;
- (id)initWithKeySets:(NSArray*)keySets;

// Editing a selection
- (BOOL)extendWithKeySets:(NSArray*)keySets;
- (BOOL)extendWithRange:(FSKeyRange*)range;

- (int)headerCount;
- (NSArray*)ranges;
- (NSArray*)rangesForHeader:(FSHeader*)aHeader;

- (NSArray*)completeKeySets;
- (BOOL)intersectsWithSelection:(FSSelection*)otherSelection;
- (BOOL)containsKeySet:(FSKeySet*)set;
- (NSArray*)selectedKeySets;

- (BOOL)isEmpty;
- (BOOL)isComplete;

    // Single selection methods
- (BOOL)isSingleSelection;
- (id)singleValue;

    // Multiple selection methods
- (BOOL)isMultipleSelection;
//- (NSEnumerator*)objectEnumerator;
- (NSArray*)valuesForBaseSet:(FSKeySet*)baseSet;

    // Creating
- (NSString*)creatorString;

@end
