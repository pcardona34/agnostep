//  $Id: FSFormula.h,v 1.1 2008/10/14 15:04:17 hns Exp $
//
//  FSFormula.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-SEP-2001.
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

@class FSSelection, FSKeySetSelection, FSTable, FSKeyGroup, FSKeySet;
@class FSFormulaSelection, FSFormulaDefinition, FSFormulaSpace;

@interface FSFormula : NSObject {
    FSTable             *_table;          /*" Table this formula belongs to.  Not retained. "*/
    FSFormulaSelection  *_selection;      /*" The left side of the formula. "*/
    FSFormulaDefinition *_definition;     /*" The right side of the formula. "*/
    NSArray             *_skipElements;   /*" The SKIP part of the formula.  Type: FSKeySet. "*/
    FSKeyGroup          *_recurseGroup;   /*" The group all [THIS|PREV|etc] must reference. "*/
    NSString            *_originalString; /*" String this formula was created with. "*/
    FSSelection         *_touchedSel;     /*" Cached from last calculation. "*/
}

+ (FSFormula*)formulaWithString:(NSString*)formulaString inTable:(FSTable*)table;

- (id)initWithString:(NSString*)formulaString inTable:(FSTable*)table;

- (void)replaceFormulaWithString:(NSString*)formulaString;

- (NSArray*)selectedKeySets;
- (FSSelection*)touchedSelection;
- (void)setTouchedSelection:(FSSelection*)sel;

- (id)formulaValueForKeySet:(FSKeySet*)keySet;

- (BOOL)isOK;
- (NSString*)errorString;

@end
