//  $Id: FSMaxFunction.m,v 1.1 2008/10/14 15:04:27 hns Exp $
//
//  FSMaxFunction.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 08-OCT-2001.
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

#import "FSMaxFunction.h"
#import "FSExpressionError.h"
#import "FSFormulaSpace.h"
#import "FSSelection.h"
#import "FSVariable.h"
#import "FSHeader.h"
#import "FSKeySet.h"
#import "FSValue.h"
#include <float.h>

@implementation FSMaxFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"max";
}

+ (NSString*)functionGroup
{
    return @"Statistic";
}

+ (int)numberOfOperands
{
    return 1;
}

- (id)initWithVariable:(FSVariable*)var
{
    self = [super init];
    if (self) {
        _elements = [var retain];
    }
    return self;
}

- (void)dealloc
{
    [_elements release];
    [super dealloc];
}

+ (FSExpression*)functionWithArguments:(NSArray*)arguments
{
    FSVariable *var;
    
    NSAssert([arguments count] == 1, @"Invalid argument count");
    var = [arguments objectAtIndex:0];
    if ([var isKindOfClass:[FSVariable class]] == NO)
        return [FSExpressionError expressionError:@"Invalid argument to max function (not a variable)."];
    if ([var isRange] == NO)
        return [FSExpressionError expressionError:@"Invalid argument to max function (not a range)."];
    return [[[self alloc] initWithVariable:var] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
/*" Returns the maximum of all values in the range, skipping empty cells. "*/
{
    FSSelection  *selection = [_elements selection];
    NSArray      *values = [selection valuesForBaseSet:ks];
    FSValue      *value;
    double        dValue;
    double        result = -DBL_MAX;
    BOOL          found = NO;
    int           index = [values count];

    while (index-- > 0) {
        value = [values objectAtIndex:index];
        if ([[value stringValue] length] > 0) {
            found = YES;
            dValue = [value doubleValue];
            if (dValue > result) {
                result = dValue;
            }
        }
    }
    
    if (!found) result = 0;
    return [NSNumber numberWithDouble:result];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@)", 
        [[self class] functionName], [_elements creatorString]];
}

@end
