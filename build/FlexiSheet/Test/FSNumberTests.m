//  $Id: FSNumberTests.m,v 1.1 2008/10/14 15:04:40 hns Exp $
//
//  FSNumberTests.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 09-MAY-2002.
//
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

#import "FSNumberTests.h"
#import <FSParserFunctions.h>

@implementation FSNumberTests

- (void)testFailsToParseStrings
{
    double value;

    [self assertFalse:FSScanDoubleFromString(nil, &value)     message:@"nil string"];
    [self assertFalse:FSScanDoubleFromString(@"", &value)     message:@"empty string"];
    [self assertFalse:FSScanDoubleFromString(@" ", &value)    message:@"single whitespace string"];
    [self assertFalse:FSScanDoubleFromString(@" \t ", &value) message:@"multiple whitespace string"];
    [self assertFalse:FSScanDoubleFromString(@"abc", &value)  message:@"ascii string"];
    [self assertFalse:FSScanDoubleFromString(@" A1", &value)  message:@"mixed string"];
    [self assertFalse:FSScanDoubleFromString(@"1A", &value)   message:@"number first string"];
    [self assertFalse:FSScanDoubleFromString(@"1 2", &value)  message:@"broken digits"];
}

- (void)testParseIntegers
{
    double value;

    [self assertTrue:FSScanDoubleFromString(@"1", &value)];
    [self assertTrue:(value == 1)];
    [self assertTrue:FSScanDoubleFromString(@"123", &value)];
    [self assertTrue:(value == 123)];
    [self assertTrue:FSScanDoubleFromString(@" 123 ", &value) message:@"leading whitespace int"];
    [self assertTrue:(value == 123)];
}

- (void)testParseFloats
{
    double value;

    [self assertTrue:FSScanDoubleFromString(@"1,0", &value)];
    [self assertTrue:(value == 1)];
    [self assertTrue:FSScanDoubleFromString(@"123.0", &value)];
    [self assertTrue:(value == 123)];
    [self assertTrue:FSScanDoubleFromString(@" 1,23 ", &value)];
    [self assertTrue:(value == 1.23)];
    [self assertTrue:FSScanDoubleFromString(@" ,23", &value)];
    [self assertTrue:(value == 0.23)];
    [self assertTrue:FSScanDoubleFromString(@" .23", &value)];
    [self assertTrue:(value == 0.23)];
}

- (void)testFailsWithMultiplePoints
{
    double value;

    [self assertFalse:FSScanDoubleFromString(@" 0.001,23 ", &value)];
    [self assertFalse:FSScanDoubleFromString(@" 0,001.23 ", &value)];
    [self assertFalse:FSScanDoubleFromString(@" ,11,23 ", &value)];
    [self assertFalse:FSScanDoubleFromString(@" .11.23 ", &value)];
}

- (void)testParseNegativeNumbers
{
    double value;

    [self assertTrue:FSScanDoubleFromString(@"-9", &value) message:@"Simple number"];
    [self assertTrue:(value == -9)];
    [self assertTrue:FSScanDoubleFromString(@" -9", &value) message:@"leading space"];
    [self assertTrue:FSScanDoubleFromString(@"-.9", &value) message:@"negative float"];
    [self assertTrue:FSScanDoubleFromString(@"- .9", &value) message:@"negative float"];
    [self assertTrue:FSScanDoubleFromString(@"- 9", &value)];
    [self assertTrue:FSScanDoubleFromString(@"- 9", &value)];
    [self assertFalse:FSScanDoubleFromString(@"--9", &value)];
}

@end
