//  $Id: FSCellnameFunction.m,v 1.2 2010/09/22 21:47:28 rmottola Exp $
//
//  FSCellnameFunction.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 01-OCT-2001.
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

#include <assert.h>

#import "FSCellnameFunction.h"
#import "FSExpressionError.h"
#import "FoundationExtentions.h"
#import "FSFormulaSpace.h"
#import "FSVariable.h"
#import "FSKeySet.h"
#import "FSTable.h"
#import "FSValue.h"
#import "FSKey.h"
#import "FSLog.h"

@implementation FSCellnameFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"cellname";
}

+ (int)numberOfOperands
{
    return 1;
}

- (id)initWithCategoryName:(FSExpression*)name
{
    self = [super init];
    if (self) {
        _categoryName = [[[name description] stringByTrimmingQuotes] copy];
    }
    return self;
}

- (void)dealloc
{
    [_categoryName release];
    [super dealloc];
}

+ (FSFunction*)functionWithArguments:(NSArray*)arguments
{
    assert([arguments count] == 1);
    return [[[self alloc] initWithCategoryName:[arguments objectAtIndex:0]] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
/*" Returns a random value. "*/
{
    FSHeader *header = [[ks table] headerWithName:_categoryName];
    if (header == nil) [FSLog logError:@"Unknown category %@", _categoryName];
    return [[ks keyForHeader:header] label];
}

- (FSSelection*)referencedSelectionInFormulaSpace:(FSFormulaSpace*)fs
{
    return [FSSelection selection];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(\"%@\")", 
        [[self class] functionName], _categoryName];
}

@end

@implementation FSIsEmptyFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}


+ (NSString*)functionName
{
    return @"isEmpty";
}


- (id)initWithArgument:(FSExpression*)argument
{
    self = [super init];
    if (self) {
        // We need an FSVariable as our argument.
        if ([argument isKindOfClass:[FSVariable class]] == NO) {
            [self release];
            return [[FSExpressionError alloc] initWithErrorMessage:
                @"A cell is expected as argument to isEmpty."];
        }
        // and it must not be a range, but a single cell
        if ([(FSVariable*)argument isRange]) {
            [self release];
            return [[FSExpressionError alloc] initWithErrorMessage:
                @"A range is not allowed as argument to isEmpty."];
        }
        _argument = [argument retain];
    }
    return self;
}


- (id)formulaValueForKeySet:(FSKeySet*)ks
{
    FSValue *value = [_argument formulaValueForKeySet:ks];
    BOOL     result = ([value isKindOfClass:[NSString class]] && ![(NSString*)value length]);

    return [NSNumber numberWithBool:result];
}

@end

