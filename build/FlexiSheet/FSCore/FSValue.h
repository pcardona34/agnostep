//  $Id: FSValue.h,v 1.1 2008/10/14 15:04:24 hns Exp $
//
//  FSValue.h
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

#import <FSCore/FSTypes.h>

@class FSKey, FSKeySet, FSTable, FSFormula;

@interface FSValue : NSObject {

@private
    FSkeyset          _keyset;           /*" The value's key set structure. "*/
    NSString         *_type;             /*" Type of the value.  Usually a class name. "*/
    id                _value;            /*" The actual value; an instance of _type. "*/
    FSFormula        *_valueFormula;     /*" The formula calculating this value. "*/
    NSArray          *_possibleValues;   /*" Value options, e.g. for boolean values. "*/
    FSTable          *_table;            /*" Cached reference to the table this value belongs to. "*/
    NSUndoManager    *_cachedUM;         /*" Cached undo manager; this is retained! "*/
}

- (id)init;
- (id)initWithValue:(id)aValue;
- (id)initWithValue:(id)aValue forKeys:(FSKeySet*)keys;

- (void)setKeys:(FSKeySet*)newKeys;
- (void)addKey:(FSKey*)someKey;
- (void)revalidateKeys;
- (BOOL)hasCompleteKeys;

- (FSKeySet*)keySet;
- (FSHashKey)hashcode;
- (BOOL)hashcodeEqualTo:(FSHashKey)aHashcode;

- (NSString*)type;

- (NSComparisonResult)smartCompare:(FSValue*)otherObject;
- (NSComparisonResult)smartCompareReverse:(FSValue*)otherObject;

- (id)value;
- (void)setValue:(id)aValue;
- (void)setValue:(id)newValue postNotification:(BOOL)flag;

- (double)doubleValue;
- (int)intValue;
- (NSString*)stringValue;

- (FSFormula*)calculatedByFormula;

@end

@interface FSValue (Archiving)

- (NSDictionary*)dictionaryForArchiving;

@end
