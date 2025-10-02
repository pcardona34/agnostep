//  $Id: OperatorTests.m,v 1.1 2008/10/14 15:04:43 hns Exp $
//
//  OperatorTests.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 10-MAY-2002.
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

#import "OperatorTests.h"

@implementation OperatorTests

- (void)testAddition
{
    [table addFormula:@"B3 = B1 + B2"];
    [table recalculateFormulaSpace];

    // adding strings doesn't work that good.
    [self assertFloat:[[a1b3 value] doubleValue] equals:0 precision:0];
    // -1 + 1 is 0
    [self assertFloat:[[a2b3 value] doubleValue] equals:0 precision:0];
    // 1 + 1 is 2
    [self assertFloat:[[a3b3 value] doubleValue] equals:2 precision:0];
}

- (void)testSubtraction
{
    [table addFormula:@"B3 = B1 - B2"];
    [table recalculateFormulaSpace];

    // subtracting strings doesn't work that good.
    [self assertFloat:[[a1b3 value] doubleValue] equals:0 precision:0];
    // -1 - 1 is -1
    [self assertFloat:[[a2b3 value] doubleValue] equals:-2 precision:0];
    // 1 - 1 is 0
    [self assertFloat:[[a3b3 value] doubleValue] equals:0 precision:0];
}

- (void)testMultiplication
{
    [table addFormula:@"B3 = B1 * B2"];
    [[a1b1 value] setValue:@"8.0"];
    [[a1b2 value] setValue:@"4.0"];
    [table recalculateFormulaSpace];

    // 8 * 4 is 32
    [self assertFloat:[[a1b3 value] doubleValue] equals:32 precision:0];
    // -1 * 1 is -1
    [self assertFloat:[[a2b3 value] doubleValue] equals:-1 precision:0];
    // 1 * 1 is 1
    [self assertFloat:[[a3b3 value] doubleValue] equals:1 precision:0];
}

- (void)testDivision
{
    [table addFormula:@"B3 = B1 / B2"];
    [[a1b1 value] setValue:@"8.0"];
    [[a1b2 value] setValue:@"6.0"];
    [table recalculateFormulaSpace];

    // 8 / 6 is 1.3333
    [self assertFloat:[[a1b3 value] doubleValue] equals:1.33 precision:0.004];
    // -1 / 1 is -1
    [self assertFloat:[[a2b3 value] doubleValue] equals:-1 precision:0];
    // 1 / 1 is 1
    [self assertFloat:[[a3b3 value] doubleValue] equals:1 precision:0];
}

- (void)testPower
{
    [table addFormula:@"B3 = B1 ^ B2"];
    [[a1b1 value] setValue:@"2"];
    [[a1b2 value] setValue:@"8"];
    [table recalculateFormulaSpace];

    [self assertFloat:[[a1b3 value] doubleValue] equals:256 precision:0];
}

- (void)testStringCat
{
    [table addFormula:@"B3 = B1 & B2"];
    [table recalculateFormulaSpace];

    [self assert:[[a1b3 value] stringValue] equals:@"HalloAlpha"];
}

@end
