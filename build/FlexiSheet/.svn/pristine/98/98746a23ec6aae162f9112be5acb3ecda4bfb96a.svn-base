//  $Id: FSTable+Formula.m,v 1.1 2008/10/14 15:04:23 hns Exp $
//
//  FSTable+Formula.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 12-OCT-2002.
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

#import "FlexiSheet.h"
#import <FSCore/FSTable.h>

@implementation FSTable (Formula)

- (NSArray*)formulae
    /*" Returns the list of formulas for the receiving FSTable instance. "*/
{
    return [_formulaSpace formulae];
}


- (void)addFormula:(NSString*)aFormula
    /*" Adds an FSFormula instance created with the aFormula string
    to the list of formulas for this table.
    "*/
{
    NSNotificationCenter *nc = [self notificationCenter];

    FSFormula *formula = [[FSFormula alloc] initWithString:aFormula inTable:self];
    [nc postNotificationName:FSTableWillChangeNotification object:self];
    [[self undoManager]
        registerUndoWithTarget:self
                      selector:@selector(removeFormula:)
                        object:formula];
    [_formulaSpace addFormula:formula];
    [nc postNotificationName:FSTableDidChangeNotification object:self];
    [formula release];
}


- (void)insertFormula:(NSString*)aFormula atIndex:(int)index
    /*" Inserts an FSFormula instance created with the aFormula string at index
    into the list of formulas for this table.
    "*/
{
    NSNotificationCenter *nc = [self notificationCenter];

    // We don't care if the formula can be inserted at that index.
    // Undo will remove that formula, no matter where it is.
    FSFormula *formula = [[FSFormula alloc] initWithString:aFormula inTable:self];
    [nc postNotificationName:FSTableWillChangeNotification object:self];
    [[self undoManager]
        registerUndoWithTarget:self
                      selector:@selector(removeFormula:)
                        object:formula];
    [_formulaSpace insertFormula:formula atIndex:index];
    [nc postNotificationName:FSTableDidChangeNotification object:self];
    [formula release];
}


- (void)setCreator:(NSString*)creator forFormula:(FSFormula*)formula
{
    NSNotificationCenter *nc = [self notificationCenter];

    [nc postNotificationName:FSTableWillChangeNotification object:self];
    [[[self undoManager] prepareWithInvocationTarget:self]
        setCreator:[formula description] forFormula:formula];
    [formula replaceFormulaWithString:creator];
    [nc postNotificationName:FSTableDidChangeNotification object:self];
}


- (void)removeFormula:(FSFormula*)aFormula
    /*" Removes aFormula, an FSFormula instance, from the list of formulas
    for this table.  This operation sets the Formula Dirty flag
    and causes automatic recalculation if it enabled.
    "*/
{
    NSNotificationCenter *nc = [self notificationCenter];

    if ([[_formulaSpace formulae] containsObject:aFormula] == NO)
        return;

    [nc postNotificationName:FSTableWillChangeNotification object:self];
    [[self undoManager]
        registerUndoWithTarget:self
                      selector:@selector(addFormula:)
                        object:[aFormula description]];
    [_formulaSpace removeFormula:aFormula];
    [nc postNotificationName:FSTableDidChangeNotification object:self];
}


- (void)moveFormulaAtIndex:(int)from toIndex:(int)dest
{
    NSNotificationCenter *nc = [self notificationCenter];

    NSArray   *formulae;
    FSFormula *f;
    if (from == dest) return;

    [nc postNotificationName:FSTableWillChangeNotification object:self];
    [[[self undoManager] prepareWithInvocationTarget:self]
        moveFormulaAtIndex:dest-(dest>from?1:0) toIndex:from+(dest<from?1:0)];

    if (dest > from) dest--;
    formulae = [_formulaSpace formulae];
    if (from >= [formulae count])
        from = [formulae count]-1;
    f = [formulae objectAtIndex:from];
    [f retain];
    [_formulaSpace removeFormula:f];
    [_formulaSpace insertFormula:f atIndex:dest];
    [f release];
    [self recalculateFormulaSpace];

    [nc postNotificationName:FSTableDidChangeNotification object:self];
}


- (void)recalculateFormulaSpace
    /*" A call to recalculateFormulaSpace causes all formulas to be recalculated.
    This happens from top to bottom in the formula list.

    Note that undo recording is disabled during calculation."*/
{
    // We disable the undoManager, because all new values
    // set during recalculation are either
    // reproducable or random anyway.
    [[_document undoManager] disableUndoRegistration];
    [_formulaSpace recalculate];
    [[_document undoManager] enableUndoRegistration];
}


- (void)disableRecalculation
{
    [_formulaSpace disableRecalculation];
}


- (void)enableRecalculation
{
    [_formulaSpace enableRecalculation];
}

@end
