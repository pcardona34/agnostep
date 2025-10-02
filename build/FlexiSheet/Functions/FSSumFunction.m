//  $Id: FSSumFunction.m,v 1.1 2008/10/14 15:04:29 hns Exp $
//
//  FSSumFunction.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 02-OCT-2001.
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

#import "FSSumFunction.h"
#import "FSExpressionError.h"
#import "FSFormulaSpace.h"
#import "FSSelection.h"
#import "FSVariable.h"
#import "FSHeader.h"
#import "FSKeySet.h"
#import "FSValue.h"
#include <math.h>

@implementation FSSumFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"sum";
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
        return [FSExpressionError expressionError:[NSString stringWithFormat:@"Invalid argument to %@ function (not a variable).", [self functionName]]];
    if ([var isRange] == NO)
        return [FSExpressionError expressionError:[NSString stringWithFormat:@"Invalid argument to sum function (not a range).", [self functionName]]];
    return [[[self alloc] initWithVariable:var] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
/*" Returns the sum of all values in the range. "*/
{
    FSSelection  *selection = [_elements selection];
    NSArray      *values = [selection valuesForBaseSet:ks];
    FSValue      *value;
    double        result = 0.0;
    unsigned int  index = [values count];

    while (index-- > 0) {
        value = [values objectAtIndex:index];
        result = result + [value doubleValue];
    }
    
    return [NSNumber numberWithDouble:result];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@)", 
        [[self class] functionName], [_elements creatorString]];
}

@end


@implementation FSGroupsumFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"groupsum";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
/*" Returns the groupsum, skipping the selected keyset. "*/
{
    FSSelection  *selection = [_elements selection];
    NSArray      *values = [selection valuesForBaseSet:ks];
    FSValue      *value;
    double        result = 0.0;
    FSKeySet     *current = ks;
    unsigned int  index = [values count];

    while (index-- > 0) {
        value = [values objectAtIndex:index];
        if ([value hashcodeEqualTo:[current hashcode]] == NO)
            result = result + [value doubleValue];
    }
    
    return [NSNumber numberWithDouble:result];
}

@end


@implementation FSCountFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"count";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
/*" Returns the count of values in the range. "*/
{
    FSSelection  *selection = [_elements selection];
    NSArray      *values = [selection valuesForBaseSet:ks];
    
    return [NSNumber numberWithInt:[values count]];
}

@end


@implementation FSAvgFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"avg";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
/*" Returns the average of all values in the range. "*/
{
    FSSelection  *selection = [_elements selection];
    NSArray      *values = [selection valuesForBaseSet:ks];
    FSValue      *value;
    BOOL          found = NO;
    unsigned int  index = [values count];
    double        result = 0.0;
    int           div = 0;
    
    while (index-- > 0) {
        value = [values objectAtIndex:index];
        if ([[value stringValue] length] > 0) {
            found = YES;
            result = result + [value doubleValue];
            div++;
        }
    }
    
    if (div == 0) return @"";
    
    return [NSNumber numberWithDouble:result/div];
}

@end


@implementation FSVarFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"var";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
    /*" Returns the statistical variance of all values in the range. "*/
{
    FSSelection  *selection = [_elements selection];
    NSArray      *values = [selection valuesForBaseSet:ks];
    unsigned int  index = [values count];
    double        avg = 0.0;
    double        diff;
    double        var = 0.0;
    int           div = 0;

    while (index-- > 0) {
        avg = avg + [[values objectAtIndex:index] doubleValue];
        div++;
    }

    if (div == 0) div = 1;
    avg /= div;

    index = [values count];
    while (index-- > 0) {
        diff = avg - [[values objectAtIndex:index] doubleValue];
        var = var + (diff * diff);
    }

    var /= div;

    return [NSNumber numberWithDouble:var];
}

@end


@implementation FSStddevFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"stddev";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
    /*" Returns the standard deviation of all values in the range. "*/
{
    FSSelection  *selection = [_elements selection];
    NSArray      *values = [selection valuesForBaseSet:ks];
    unsigned int  index = [values count];
    double        avg = 0.0;
    double        diff;
    double        dev = 0.0;
    int           div = 0;

    while (index-- > 0) {
        avg = avg + [[values objectAtIndex:index] doubleValue];
        div++;
    }

    if (div == 0) div = 1;
    avg /= div;

    index = [values count];
    while (index-- > 0) {
        diff = avg - [[values objectAtIndex:index] doubleValue];
        dev = dev + (diff * diff);
    }

    dev /= div;
    
    return [NSNumber numberWithDouble:sqrt(dev)];
}

@end

