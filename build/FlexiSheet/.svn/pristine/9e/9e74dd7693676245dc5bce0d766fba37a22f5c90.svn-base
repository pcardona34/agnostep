//  $Id: FSFormulaDefinition.m,v 1.1 2008/10/14 15:04:18 hns Exp $
//
//  FSFormulaDefinition.m
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

#import <FSCore/FSFormulaDefinition.h>
#import <FSCore/FSLog.h>
#import <FSCore/FSExpression.h>
#import <FSCore/FSExpressionError.h>
#import <FSCore/FSSelection.h>

@implementation FSFormulaDefinition
/*" FSFormulaDefinition is the left part of a formula. "*/

+ (FSFormulaDefinition*)formulaDefinitionWithString:(NSString*)definitionString inTable:(FSTable*)table
{
    return [[[self alloc] initWithString:definitionString inTable:table] autorelease];
}

- (BOOL)_parseInTable:(FSTable*)table
{
    BOOL result = NO;

    if ([_creator length] == 0) {
        [FSLog logError:@"Definition string is empty!"];
    } else {
        _expression = [FSExpression expressionWithString:_creator inTable:table];
        [_expression retain];
        if ([_expression isKindOfClass:[FSExpressionError class]]) {
            [FSLog logError:[_expression description]];
        } else {
            [_creator release];
            _creator = nil;
            result = YES;
        }
    }
    return result;
}

- (id)initWithString:(NSString*)definitionString inTable:(FSTable*)table
{
    self = [super init];
    if (self) {
        _creator = [definitionString copy];
        [self _parseInTable:table];
    }
    return self;
}


- (BOOL)isError
{
    // Could check for _expression isKindOfClass FSExpressionError
    return (_creator != nil);
}


- (void)dealloc
{
    [_creator release];
    [_expression release];
    [super dealloc];
}


- (NSArray*)validateCandidateKeySets:(NSArray*)candiates
{
    // Throw out all key sets that reference non-existing cells (for PREV/NEXT)
    NSMutableArray *filtered = [NSMutableArray array];
    int             index = [candiates count];
    FSKeySet       *set;

    while (index-- > 0) {
        NS_DURING
            set = [candiates objectAtIndex:index];
            [self formulaValueForKeySet:set];
            [filtered addObject:set];
        NS_HANDLER
            ;
        NS_ENDHANDLER
    }
    
    return filtered;
}


- (id)formulaValueForKeySet:(FSKeySet*)keySet
{
    return [_expression formulaValueForKeySet:keySet];
}


- (FSSelection*)referencedSelectionInFormulaSpace:(FSFormulaSpace*)fs
{
    return [_expression referencedSelectionInFormulaSpace:fs];
}


- (NSString*)description
{
    if (_creator) return _creator;
    return [_expression creatorString];
}

@end
