//
//  CompareOpTests.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 20-FEB-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: CompareOpTests.m,v 1.1 2008/10/14 15:04:39 hns Exp $
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//  
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

#import "CompareOpTests.h"


@implementation CompareOpTests

// tests

- (void)testEqualCompare
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [table addFormula:@"B3 = if(B1 = B2, \"true\", \"false\")"];
    [pool release];
    [table recalculateFormulaSpace];

    // Hallo = Alpha is false
    [self assert:[[a1b3 value] stringValue] equals:@"false"];
    // -1 = 1 is false
    [self assert:[[a2b3 value] stringValue] equals:@"false"];
    // 1 = 1 is true
    [self assert:[[a3b3 value] stringValue] equals:@"true"];
}

- (void)testLessThanCompare
{
    [table addFormula:@"B3 = if(B1 < B2, \"true\", \"false\")"];
    [table recalculateFormulaSpace];

    // Hallo < Alpha is false
    [self assert:[[a1b3 value] stringValue] equals:@"false"];
    // -1 < 1 is true
    [self assert:[[a2b3 value] stringValue] equals:@"true"];
    // 1 < 1 is false
    [self assert:[[a3b3 value] stringValue] equals:@"false"];
}

- (void)testGreaterThanCompare
{
    [table addFormula:@"B3 = if(B1 > B2, \"true\", \"false\")"];
    [table recalculateFormulaSpace];

    // Hallo > Alpha is true
    [self assert:[[a1b3 value] stringValue] equals:@"true"];
    // -1 > 1 is false
    [self assert:[[a2b3 value] stringValue] equals:@"false"];
    // 1 > 1 is false
    [self assert:[[a3b3 value] stringValue] equals:@"false"];
}

- (void)testFormulaEclipse
{
    [table addFormula:@"B1 = \"first\""];
    [table addFormula:@"A3 = \"second\""];
    [table recalculateFormulaSpace];

    // first formula works
    [self assert:[[a1b1 value] stringValue] equals:@"first"];
    // second formula works
    [self assert:[[a3b3 value] stringValue] equals:@"second"];
    // A3B1 was calculated by the first formula!
    [self assert:[[a3b1 value] stringValue] equals:@"first"];

    // Now order formulae differently
    [table moveFormulaAtIndex:1 toIndex:0];
    [table recalculateFormulaSpace];
    [self assert:[[a3b1 value] stringValue] equals:@"second"];
}

@end
