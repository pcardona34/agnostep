//  $Id: GroupFunctionsTests.m,v 1.1 2008/10/14 15:04:41 hns Exp $
//
//  GroupFunctionsTests.m
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

#import "GroupFunctionsTests.h"

@implementation GroupFunctionsTests

- (void)testCount
{
    [table addFormula:@"A1:B3 = count(B)"];
    [table recalculateFormulaSpace];

    [self assertInt:[[a1b3 value] intValue] equals:3];
}

- (void)testGroupSum
{
    [table addFormula:@"B3 = groupsum(B)"];

    [table recalculateFormulaSpace];
    [self assertInt:[[a3b3 value] intValue] equals:2];

    [table recalculateFormulaSpace];
    [self assertInt:[[a3b3 value] intValue] equals:2];
}

- (void)testSum
{
    [table addFormula:@"A1:B3 = sum(A3:B)"];
    [[a3b1 value] setValue:@"7"];
    [[a3b2 value] setValue:@"14"];
    [[a3b3 value] setValue:@"21"];

    [table recalculateFormulaSpace];
    [self assertInt:[[a1b3 value] intValue] equals:42];

    [table recalculateFormulaSpace];
    [self assertInt:[[a1b3 value] intValue] equals:42];
}

- (void)testProduct
{
    [table addFormula:@"A1:B3 = prod(A3:B)"];
    [[a3b1 value] setValue:@"3"];
    [[a3b2 value] setValue:@"2.5"];
    [[a3b3 value] setValue:@"2"];

    [table recalculateFormulaSpace];
    [self assertFloat:[[a1b3 value] doubleValue] equals:15 precision:0];
}

- (void)testAverage
{
    [table addFormula:@"A1:B3 = avg(A3:B)"];
    [[a3b1 value] setValue:@"3"];
    [[a3b2 value] setValue:@"7"];
    [[a3b3 value] setValue:@"2"];

    [table recalculateFormulaSpace];
    [self assertFloat:[[a1b3 value] doubleValue] equals:4 precision:0];
}

@end
