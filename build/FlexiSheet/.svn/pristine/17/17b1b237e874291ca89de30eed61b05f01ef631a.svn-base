//  $Id: FSCorrelFunction.m,v 1.1 2008/10/14 15:04:25 hns Exp $
//
//  FSCorrelFunction.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 14-MAY-2002.
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

#import "FSCorrelFunction.h"
#import "FSExpressionError.h"
#import "FSVariable.h"
#import "FSValue.h"
#include <math.h>


@implementation FSCorrelFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (int)numberOfOperands
{
    return 2;
}

+ (NSString*)functionName
{
    return @"correl";
}

+ (NSString*)functionGroup
{
    return @"Statistic";
}

- (id)initWithVariables:(FSVariable*)var1 :(FSVariable*)var2
{
    self = [super init];
    if (self) {
        _xElements = [var1 retain];
        _yElements = [var2 retain];
    }
    return self;
}

- (void)dealloc
{
    [_xElements release];
    [_yElements release];
    [super dealloc];
}

+ (FSExpression*)functionWithArguments:(NSArray*)arguments
{
    FSVariable *var1;
    FSVariable *var2;

    NSAssert([arguments count] == 2, @"Invalid argument count");
    var1 = [arguments objectAtIndex:0];
    if ([var1 isKindOfClass:[FSVariable class]] == NO)
        return [FSExpressionError expressionError:@"Invalid first argument to correl function (not a variable)."];
    if ([var1 isRange] == NO)
        return [FSExpressionError expressionError:@"Invalid first argument to correl function (not a range)."];
    var2 = [arguments objectAtIndex:1];
    if ([var2 isKindOfClass:[FSVariable class]] == NO)
        return [FSExpressionError expressionError:@"Invalid second argument to correl function (not a variable)."];
    if ([var2 isRange] == NO)
        return [FSExpressionError expressionError:@"Invalid second argument to correl function (not a range)."];
    return [[[self alloc] initWithVariables:var1 :var2] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
    /*" Returns the standard deviation of all values in the range. "*/
{
    FSSelection  *xSelection = [_xElements selection];
    FSSelection  *ySelection = [_yElements selection];
    NSArray      *xValues = [xSelection valuesForBaseSet:ks];
    NSArray      *yValues = [ySelection valuesForBaseSet:ks];
    
    int           index, n;
    double        xVal, yVal;
    double        xSum = 0.0, ySum = 0.0, pSum = 0.0;
    double        xQS = 0.0, yQS = 0.0;
    double        div = 0.0;
    double        result = 0.0;

    if ((n = [xValues count]) != [yValues count]) return @"Err";

    index = n;
    if (index == 0) return [NSNumber numberWithDouble:0];
    
    while (index-- > 0) {
        xVal = [[xValues objectAtIndex:index] doubleValue];
        yVal = [[yValues objectAtIndex:index] doubleValue];
        xSum += xVal;
        ySum += yVal;
        pSum += xVal * yVal;
        xQS += xVal * xVal;
        yQS += yVal * yVal;
    }

    div = (xQS-xSum*xSum/n) * (yQS-ySum*ySum/n);

    if (div != 0.0) {
        result = (pSum - xSum*ySum/n)/sqrt(div);
    }
    
    return [NSNumber numberWithDouble:result];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@, %@)",
        [[self class] functionName], [_xElements creatorString], [_yElements creatorString]];
}

@end
