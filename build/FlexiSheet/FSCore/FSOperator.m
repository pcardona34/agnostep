//  $Id: FSOperator.m,v 1.1 2008/10/14 15:04:22 hns Exp $
//
//  FSOperator.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-SEP-2001.
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

#import "FSOperator.h"
#import "FSSelection.h"
#import "FSLog.h"
#import <AppKit/NSAttributedString.h>

static NSMutableDictionary *__FSOperatorSubclasses;
static NSURL               *__FSOperatorBaseURL;

@implementation FSOperator
/*" FSOperator is an abstract superclass for all FSExpression elements
    that are operators.  An operator is a function that does
    not require parenthesis but stands between it's operands. "*/

+ (void)initialize
{
    if (__FSOperatorSubclasses == nil) {
        __FSOperatorSubclasses = [[NSMutableDictionary alloc] init];
    }
}


+ (NSURL*)helpBaseURL
{
    if (__FSOperatorBaseURL == nil)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *base = [NSString stringWithFormat:@"%@/FlexiSheet Help/Operators",
            [bundle resourcePath]];
        __FSOperatorBaseURL = [[NSURL fileURLWithPath:base] retain];
    }
    return __FSOperatorBaseURL;
}


+ (void)registerOperator:(Class)operatorClass
{
    NSString *symbol = [operatorClass operatorSymbol];
    if ([__FSOperatorSubclasses objectForKey:symbol] == nil) {
        [__FSOperatorSubclasses setObject:operatorClass forKey:symbol];
    } else {
        [FSLog logError:@"Class for operator symbol '%@' is already registered.", symbol];
    }
}


+ (NSArray*)allOperatorSymbols
{
    return [__FSOperatorSubclasses allKeys];
}


+ (Class)operatorClassForSymbol:(NSString*)symbol
{
    return [__FSOperatorSubclasses objectForKey:symbol];
}


+ (NSString*)operatorSymbol
/*" Must be overwritten in subclasses.  FSOperator's implementation raises,
    so don't call it in the subclass implementation! "*/
{
    [NSException raise:@"FSOperatorSubclassingException"
        format:@"+[FSOperator operatorSymbol] must be overwritten!"];
    return @"";
}


+ (FSOperatorTier)operatorTier
{
    return FSDefaultOperatorTier;
}


+ (FSOperator*)operatorWithArguments:(NSArray*)arguments
{
    FSOperator *instance = [[self alloc] init];
    instance->_firstArgument = [[arguments objectAtIndex:0] retain];
    instance->_secondArgument = [[arguments objectAtIndex:1] retain];
    return instance;
}


- (void)dealloc
{
    [_firstArgument release];
    [_secondArgument release];
    [super dealloc];
}


+ (NSString*)htmlHelpData
{
    return @"\n  Description forthcoming...";
}


- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@ %@ %@",
        [_firstArgument creatorString],
        [[self class] operatorSymbol],
        [_secondArgument creatorString]];
}


- (FSSelection*)referencedSelectionInFormulaSpace:(FSFormulaSpace*)fs
{
    NSMutableArray *keySets = [NSMutableArray array];

    [keySets addObjectsFromArray:[[_firstArgument referencedSelectionInFormulaSpace:fs] completeKeySets]];
    [keySets addObjectsFromArray:[[_secondArgument referencedSelectionInFormulaSpace:fs] completeKeySets]];

    return [FSSelection selectionWithKeySets:keySets];
}

@end
