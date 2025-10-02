//  $Id: FSIfFunction.m,v 1.1 2008/10/14 15:04:26 hns Exp $
//
//  FSIfFunction.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 04-OCT-2001.
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

#import "FSIfFunction.h"
#import "FSSelection.h"

@implementation FSIfFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"if";
}

+ (int)numberOfOperands
{
    return 3;
}

- (id)initWithArguments:(NSArray*)args
{
    self = [super init];
    if (self) {
        _arguments = [args copy];
    }
    return self;
}

- (void)dealloc
{
    [_arguments release];
    [super dealloc];
}

+ (FSFunction*)functionWithArguments:(NSArray*)arguments
{
    return [[[self alloc] initWithArguments:arguments] autorelease];
}


- (id)formulaValueForKeySet:(FSKeySet*)ks
    /*" Returns the second argument's value if the first argument evaluates to true,
    otherwise returns the third argument's value. "*/
{
    FSExpression *condition = [_arguments objectAtIndex:0];
    FSExpression *trueCase = [_arguments objectAtIndex:1];
    FSExpression *falseCase = [_arguments objectAtIndex:2];
    return ([[condition formulaValueForKeySet:ks] intValue] == 0)
        ?[falseCase formulaValueForKeySet:ks]
        :[trueCase formulaValueForKeySet:ks];
}


- (FSSelection*)referencedSelectionInFormulaSpace:(FSFormulaSpace*)fs
{
    NSMutableArray *keySets = [NSMutableArray array];
    FSSelection    *subSel = nil;
    int             i;
    
    for (i = 0; i < 3; i++) {
        subSel = [[_arguments objectAtIndex:0] referencedSelectionInFormulaSpace:fs];
        [keySets addObjectsFromArray:[subSel completeKeySets]];
    }
    return [FSSelection selectionWithKeySets:keySets];
}


- (NSString*)creatorString
{
    FSExpression *condition = [_arguments objectAtIndex:0];
    FSExpression *trueCase = [_arguments objectAtIndex:1];
    FSExpression *falseCase = [_arguments objectAtIndex:2];
    return [NSString stringWithFormat:@"%@(%@, %@, %@)", 
        [[self class] functionName],
        [condition creatorString],
        [trueCase creatorString],
        [falseCase creatorString]];
}

@end
