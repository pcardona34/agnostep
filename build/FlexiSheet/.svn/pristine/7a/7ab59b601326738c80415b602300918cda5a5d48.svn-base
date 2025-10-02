//  $Id: FSFinancialFunctions.m,v 1.1 2008/10/14 15:04:26 hns Exp $
//
//  FSFinancialFunctions.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 20-OCT-2001.
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

#import "FSFinancialFunctions.h"
#import "FSVariable.h"
#import "FSValue.h"
#import "FSSelection.h"
#import "FSFormulaSpace.h"
#include <math.h>


@implementation FSCtermFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"cterm";
}

+ (NSString*)functionGroup
{
    return @"Financial";
}

+ (int)numberOfOperands
{
    return 3;
}

- (id)initWithArguments:(NSArray*)args
{
    self = [super init];
    if (self) {
        _interest = [[args objectAtIndex:0] retain];
        _fVal = [[args objectAtIndex:1] retain];
        _pVal = [[args objectAtIndex:2] retain];
    }
    return self;
}

- (void)dealloc
{
    [_fVal release];
    [_pVal release];
    [_interest release];
    [super dealloc];
}

+ (FSExpression*)functionWithArguments:(NSArray*)arguments
{
    NSAssert([arguments count] == 3, @"Invalid argument count");
    return [[[self alloc] initWithArguments:arguments] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)fs
/*" Returns the interest rate. "*/
{
    double fVal = [[_fVal formulaValueForKeySet:fs] doubleValue];
    double pVal = [[_pVal formulaValueForKeySet:fs] doubleValue];
    double intr = [[_interest formulaValueForKeySet:fs] doubleValue]/100.0;
    
    double result =  log(fVal/pVal) / log(1 + intr);
    
    return [NSNumber numberWithDouble:result];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@, %@, %@)", 
        [[self class] functionName], [_interest creatorString],
        [_fVal creatorString], [_pVal creatorString]];
}

@end


@implementation FSFvFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"fv";
}

+ (NSString*)functionGroup
{
    return @"Financial";
}

+ (int)numberOfOperands
{
    return 3;
}

- (id)initWithArguments:(NSArray*)args
{
    self = [super init];
    if (self) {
        _payment = [[args objectAtIndex:0] retain];
        _interest = [[args objectAtIndex:1] retain];
        _term = [[args objectAtIndex:2] retain];
    }
    return self;
}

- (void)dealloc
{
    [_payment release];
    [_interest release];
    [_term release];
    [super dealloc];
}

+ (FSExpression*)functionWithArguments:(NSArray*)arguments
{
    NSAssert([arguments count] == 3, @"Invalid argument count");
    return [[[self alloc] initWithArguments:arguments] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)fs
/*" Returns the future value of the payment. "*/
{
    double pymt = [[_payment formulaValueForKeySet:fs] doubleValue];
    double term = [[_term formulaValueForKeySet:fs] doubleValue];
    double intr = [[_interest formulaValueForKeySet:fs] doubleValue]/100.0;
    
    double result =  pymt * ((pow(1 + intr, term)-1)/intr);
    
    return [NSNumber numberWithDouble:result];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@, %@, %@)", 
        [[self class] functionName], [_payment creatorString],
        [_interest creatorString], [_term creatorString]];
}

@end


@implementation FSPaymentFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"pmt";
}

+ (NSString*)functionGroup
{
    return @"Financial";
}

+ (int)numberOfOperands
{
    return 3;
}

- (id)initWithArguments:(NSArray*)args
{
    self = [super init];
    if (self) {
        _principal = [[args objectAtIndex:0] retain];
        _interest = [[args objectAtIndex:1] retain];
        _term = [[args objectAtIndex:2] retain];
    }
    return self;
}

- (void)dealloc
{
    [_principal release];
    [_interest release];
    [_term release];
    [super dealloc];
}

+ (FSExpression*)functionWithArguments:(NSArray*)arguments
{
    NSAssert([arguments count] == 3, @"Invalid argument count");
    return [[[self alloc] initWithArguments:arguments] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)fs
/*" Returns the payment value. "*/
{
    double intr = [[_interest formulaValueForKeySet:fs] doubleValue]/100.0;
    double prin = [[_principal formulaValueForKeySet:fs] doubleValue];
    double term = [[_term formulaValueForKeySet:fs] doubleValue];
    
    double result = prin * (intr / (1 - pow(intr+1, -term)));
    
    return [NSNumber numberWithDouble:result];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@, %@, %@)", 
        [[self class] functionName], [_principal creatorString],
        [_interest creatorString], [_term creatorString]];
}

@end


@implementation FSNpvFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"npv";
}

+ (NSString*)functionGroup
{
    return @"Financial";
}

+ (int)numberOfOperands
{
    return 2;
}

- (id)initWithArguments:(NSArray*)args
{
    self = [super init];
    if (self) {
        _interest = [[args objectAtIndex:0] retain];
        _range = [[args objectAtIndex:1] retain];
    }
    return self;
}

- (void)dealloc
{
    [_range release];
    [_interest release];
    [super dealloc];
}

+ (FSExpression*)functionWithArguments:(NSArray*)arguments
{
    NSAssert([arguments count] == 2, @"Invalid argument count");
    return [[[self alloc] initWithArguments:arguments] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
/*" Returns the payment value. "*/
{
    FSSelection  *selection = [_range selection];
    NSArray      *values = [selection valuesForBaseSet:ks];
    FSValue      *value;
    double        intr = [[_interest formulaValueForKeySet:ks] doubleValue]/100.0;
    double        result = 0;
    int           count = 1;
    unsigned int  index = [values count];

    while (index-- > 0) {
        value = [values objectAtIndex:index];
        result += [value doubleValue] / pow(1+intr, count);
        count++;
    }
    
    return [NSNumber numberWithDouble:result];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@, %@)", 
        [[self class] functionName],
        [_interest creatorString], [_range creatorString]];
}

@end


@implementation FSRateFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"rate";
}

+ (NSString*)functionGroup
{
    return @"Financial";
}

+ (int)numberOfOperands
{
    return 3;
}

- (id)initWithArguments:(NSArray*)args
{
    self = [super init];
    if (self) {
        _fVal = [[args objectAtIndex:0] retain];
        _pVal = [[args objectAtIndex:1] retain];
        _term = [[args objectAtIndex:2] retain];
    }
    return self;
}

- (void)dealloc
{
    [_fVal release];
    [_pVal release];
    [_term release];
    [super dealloc];
}

+ (FSExpression*)functionWithArguments:(NSArray*)arguments
{
    NSAssert([arguments count] == 3, @"Invalid argument count");
    return [[[self alloc] initWithArguments:arguments] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)fs
/*" Returns the interest rate. "*/
{
    double fVal = [[_fVal formulaValueForKeySet:fs] doubleValue];
    double pVal = [[_pVal formulaValueForKeySet:fs] doubleValue];
    double term = [[_term formulaValueForKeySet:fs] doubleValue];
    
    double result =  pow(fVal/pVal, 1/term) - 1;
    
    return [NSNumber numberWithDouble:result];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@, %@, %@)", 
        [[self class] functionName], [_fVal creatorString],
        [_pVal creatorString], [_term creatorString]];
}

@end

