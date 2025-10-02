//  $Id: FSFormulaSpace.m,v 1.1 2008/10/14 15:04:18 hns Exp $
//
//  FSFormulaSpace.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 01-OCT-2001.
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

#import "FSFormulaSpace.h"
#import "FSKeySet.h"
#import "FSSelection.h"
#import "FSFormula.h"
#import "FSTable.h"
#import "FSValue.h"
#import "FSLog.h"

@implementation FSFormulaSpace
/*" A FSFormulaSpace instance (or short a formula space)
    is the environment formulae belonging to a table
    are executed in.
    
    If variables are defined by one formula, the formula
    space is the place this variable gets stored in.
    So a formula that is executed later can access that variable.
    
    The formula space is completely capsulated by FSTable.
    An instance is automatically created for each FSTable instance.
    Further instances should not be needed and are useless
    without being attached to a table.
    "*/

- (id)initWithTable:(FSTable*)table
/*" Designated initializer. "*/
{
    self = [super init];
    if (self) {
        _table = table;
        _formulae = [[NSMutableArray alloc] init];
        _touchedKeySets = [[NSMutableArray alloc] init];
        _selection = nil;
    }
    return self;
}


- (void)dealloc
{
    [_formulae release];
    [_touchedKeySets release];
    [_selection release];
    [super dealloc];
}


- (FSTable*)table
/*" Returns the FSTable instance this formula space is attached to.
    All FSFormulaSpace instances are attached to exactly one table.
    "*/
{
    return _table;
}


- (FSKeySet*)selection
/*" Returns the current selection, i.e. the key set representing
    the value that is currently calculated.
    
    This method should only be called by formulas in this
    formula space during execution of their calculate method.
    "*/
{
    return _selection;
}

- (void)setSelection:(FSKeySet*)keySet
/*" Sets the key set representing the value currently in calculation.
    There should be no need to call this method directly.
    "*/
{
    [keySet retain];
    [_selection release];
    _selection = keySet;
}

- (NSArray*)formulae
/*" Returns the list of formulas in the formula space. "*/
{
    return _formulae;
}

- (void)addFormula:(FSFormula*)aFormula
{
    [_formulae addObject:aFormula];
}

- (void)insertFormula:(FSFormula*)aFormula atIndex:(int)index
{
    if (index > [_formulae count]) {
        [_formulae addObject:aFormula];
    } else {
        [_formulae insertObject:aFormula atIndex:index];
    }
}

- (void)removeFormula:(FSFormula*)aFormula
{
    // remove formulas from old touched keysets
    FSValue *value;
    NSArray *keySets = [[aFormula touchedSelection] completeKeySets];
    int      index = [keySets count];
    
    [_formulae removeObject:aFormula];
    while (index-- > 0) {
        value = [_table valueForKeySet:[keySets objectAtIndex:index]];
        [value setValue:@"" postNotification:NO];
    }
}


- (NSArray*)confirmTouchedKeySets:(NSArray*)keySets
/*" Removes all key sets from the array that have been touched 
    by prior formulae already.  Adds all other key sets to the
    touched list. "*/
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:keySets];
    int             index = 0;
    FSKeySet       *set;
    
    while (index < [result count]) {
        set = [result objectAtIndex:index];
        if ([_touchedKeySets indexOfObject:set] == NSNotFound) {
            [_touchedKeySets addObject:set];
            index++;
        } else {
            [result removeObjectAtIndex:index];
        }
    }
    
    return result;
}


- (void)disableRecalculation
{
    _disabled++;
}


- (void)enableRecalculation
{
    _disabled--;
    if (_disabled < 0) {
        [FSLog logError:@"Called -enableRecalculation too often!"];
        _disabled = 0;
    }
}


- (void)recalculate
{
    FSFormula       *formula;
    NSArray         *keySets = nil;
    int              fIdx = 0;
    int              index;
    FSValue         *value;
    
    if (_disabled > 0) return;

    _disabled++;
    
    //[FSLog logInfo:@"Recalculating formula space."];

    [_touchedKeySets removeAllObjects];

    while (fIdx < [_formulae count]) {
        formula = [_formulae objectAtIndex:fIdx];

        // remove formulas from old touched keysets
        keySets = [[formula touchedSelection] completeKeySets];
        index = [keySets count];
        while (index-- > 0) {
            value = [_table valueForKeySet:[keySets objectAtIndex:index]];
            [value setValue:@"" postNotification:NO];
        }
        
        keySets = [self confirmTouchedKeySets:[formula selectedKeySets]];
        //[FSLog logInfo:@"Formula %i calculates keysets %@.", fIdx, keySets];
        index = [keySets count];
        while (index-- > 0) {
            value = [_table valueForKeySet:[keySets objectAtIndex:index]];
            [value setValue:formula postNotification:NO];
        }
        [formula setTouchedSelection:[FSSelection selectionWithKeySets:keySets]];

        fIdx++;
    }

    [[_table notificationCenter] postNotificationName:FSValueDidChangeNotification object:_table];

    _disabled--;

    //[FSLog logInfo:@"Recalculation complete."];
}

@end
