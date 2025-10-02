//  $Id: FSExpression.m,v 1.1 2008/10/14 15:04:16 hns Exp $
//
//  FSExpression.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 17-MAY-2001.
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

#import <FSCore/FSExpression.h>
#import <FSCore/FSExpressionError.h>
#import <FSCore/FSExpressionParenthesis.h>
#import <FSCore/FSExpressionNegator.h>
#import <FSCore/FSVariable.h>
#import <FSCore/FSConstant.h>
#import <FSCore/FSOperator.h>
#import <FSCore/FSFunction.h>
#import <FSCore/FoundationExtentions.h>
#import <FSCore/FSParserFunctions.h>
#import <FSCore/FSLog.h>


@implementation FSExpression
/*" This class implements the formula parser. 

    Once the formula is parsed, it no longer contains textual elements,
    but only references to categories, items, and FSExpression objects.
    
    Note that FSExpression is never instanciated! "*/

+ (void)initialize
/*" FSExpression's +initialize method takes care that all subclasses are properly initialized. "*/
{
    [[self subclasses] makeObjectsPerformSelector:@selector(dummy)];
}


+ (void)dummy
{
    // All subclasses call this method once while initializing.
    // It is a real no-brainer.
}


+ (FSExpression*)_expressionInParenthesis:(NSString*)strg inTable:(FSTable*)table
/*" Call this method only with a string that has been split with ops! "*/
{
    NSString       *exprStrg = [strg stringByTrimmingWhitespace];
    BOOL            hasParenthesis = NO;
    FSExpression   *expression;
    
    if ([exprStrg hasPrefix:@"("] && [exprStrg hasSuffix:@")"]) {
        hasParenthesis = YES;
        exprStrg = [exprStrg substringWithRange:NSMakeRange(1,[exprStrg length]-2)];
        exprStrg = [exprStrg stringByTrimmingWhitespace];
    }
    expression = [self expressionWithString:exprStrg inTable:table];
    if (hasParenthesis)
        expression = [FSExpressionParenthesis parenthesisWithExpression:expression];
    return expression;
}


+ (NSArray*)_splitExpressionWithOperators:(NSString*)strg
/*" Returns an array of Expressionstrings and Operatorstrings:
    ( ES[,OS,ES]* ). "*/
{
    NSMutableArray *parts = [NSMutableArray array];
    NSArray        *ops = [FSOperator allOperatorSymbols];
    int             opIdx;
    NSString       *opSymbol;
    int             pNum = 0;
    unichar         currentQuote = 0;
    int             index = 0;
    int             length = 0;
    unichar         character;
    NSString       *tmp;
    FSOperatorTier  tier = FSFirstOperatorTier;

    do {
        index = 0;
        length = 0;
            
        // Move thru strg and put substrings into parts.
        while (index < [strg length]) {
            character = [strg characterAtIndex:index];
            if (currentQuote != 0) {
                // If we are inside of a quote block, 
                // ignore all chars except the closing quote.
                if (character == currentQuote) {
                    currentQuote = 0;
                }
                length++;
            } else {
                switch (character) {
                    case '"':
                        currentQuote = character;
                        length++;
                        break;
                    case '\'':
                        currentQuote = character;
                        length++;
                        break;
                    case '(':
                        pNum++;
                        length++;
                        break;
                    case ')':
                        pNum--;
                        length++;
                        break;
                    default:
                        if (pNum > 0) {
                            // Inside of parenthesis,
                            // we don't look for op symbols
                            length++;
                        } else {
                            // is the following string a symbol?
                            NSString       *sub = nil;
                            NSMutableArray *foundOps = [NSMutableArray array];
                            int             opLen = 0;
                            Class           opClass;
                            
                            for (opIdx=0; opIdx < [ops count]; opIdx++) {
                                opSymbol = [ops objectAtIndex:opIdx];
                                opClass = [FSOperator operatorClassForSymbol:opSymbol];
                                if (([opClass operatorTier] == tier) && ([opSymbol length] >= opLen)) {
                                    if ([opSymbol length] == 1) {
                                        if ([opSymbol characterAtIndex:0] == character) {
                                            [foundOps addObject:opSymbol];
                                        }
                                    } else {
                                        if (sub == nil) {
                                            sub = [strg substringFromIndex:index];
                                        }
                                        if ([sub hasPrefix:opSymbol]) {
                                            if (opLen < [opSymbol length]) {
                                                opLen = [opSymbol length];
                                                [foundOps removeAllObjects];
                                            }
                                            [foundOps addObject:opSymbol];
                                        }
                                    }
                                }
                            }

                            if ([foundOps count] == 1) {
                                // Store away the string.
                                tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
                                [parts addObject:[tmp stringByTrimmingWhitespace]];
                                // Store away operator
                                [parts addObject:[foundOps lastObject]];
                                length = 0;
                                index += [[foundOps lastObject] length]-1;
                            } else {
                                if ([foundOps count] > 1)
                                    [FSLog logError:@"Cannot parse ambiguous symbol."];
                                length++;
                            }
                        }
                }
            }
            index++;
        }
    } while ([parts count] == 0 && (tier++ < FSMaxOperatorTier));

    if (length > 0) {
        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
        [parts addObject:[tmp stringByTrimmingWhitespace]];
    } else {
        [parts addObject:@""];
    }
    
    // we must have an odd number of elements in parts.
    NSAssert([parts count]%2 == 1, @"Error in +[_splitExpressionWithOperators:]");
    return parts;
}


+ (FSExpression*)_parseFunctionFromString:(NSString*)strg inTable:(FSTable*)table
{
    NSArray        *funcs = [FSFunction allFunctionNames];
    NSMutableArray *found = [NSMutableArray array];
    int             fIdx;
    NSString       *fName;
    Class           fClass;
    FSExpression   *result = nil;
    NSCharacterSet *endChars = [NSCharacterSet characterSetWithCharactersInString:@" (\t"];
    
    for (fIdx=0; fIdx < [funcs count]; fIdx++) {
        fName = [funcs objectAtIndex:fIdx];
        if ([strg hasPrefix:fName]) {
            if (([strg length] == [fName length])
                || [endChars characterIsMember:[strg characterAtIndex:[fName length]]]) {
                [found addObject:fName];
            }
        }
    }
    
    if ([found count] == 1) {
        fName = [found lastObject];
        fClass = [FSFunction functionClassForName:fName];
        if (([fClass numberOfOperands] == 0) && [fName isEqualToString:strg]) {
            result = [fClass functionWithArguments:nil];
        } else {
            NSMutableArray *args = [NSMutableArray array];
            NSString *rest =
                [[strg substringFromIndex:[fName length]] stringByTrimmingWhitespace];
            NSArray *argStrings = FSSplitStringByCommas([rest stringByTrimmingParenthesis]);
            
            if ([argStrings count] == [fClass numberOfOperands]) {
                for (fIdx = 0; fIdx < [argStrings count]; fIdx++) {
                    result = [self _expressionInParenthesis:[argStrings objectAtIndex:fIdx] inTable:table];
                    if ([result isKindOfClass:[FSExpressionError class]])
                        return result;
                    [args addObject:result];
                }
                result = [fClass functionWithArguments:args];
            } else {
                result = [FSExpressionError expressionError:
                    [NSString stringWithFormat:@"Wrong number of arguments to function %@.", fName]];
            }
        }
    }
    return result;
}


+ (FSExpression*)_parseString:(NSString*)exprString inTable:(FSTable*)table
{
    FSExpression *expr = nil; // this is the result.
    NSArray      *parts = [self _splitExpressionWithOperators:exprString];
    // parts now contains strings, every second is an operator
    // parts contains at least one element!
    
    if ([parts count] == 1) {
        NSString *strg = [parts lastObject];
        
        if ([strg hasPrefix:@"("]) {
            // Need to iterate once more removing parenthesis.
            expr = [self _expressionInParenthesis:strg inTable:table];
        } else {
            // If we get a single string, it has to be a function or a variable.
            if (nil == (expr = [self _parseFunctionFromString:strg inTable:table])) {
                // wasn't a function, so it is a variable.
                expr = [FSVariable variableWithCreator:strg inTable:table];
            }
        }
    } else {
        NSArray      *args;
        int           index = 1;
        Class         opClass;
        FSExpression *expr2;

        // Special treatment for single leading minus sign
        //
        if ([[parts objectAtIndex:1] isEqualToString:@"-"] && ([[parts objectAtIndex:0] length] == 0)) {
            expr = [self _expressionInParenthesis:[parts objectAtIndex:2] inTable:table];
            if ([expr isKindOfClass:[FSExpressionError class]]) return expr;
            expr = [FSExpressionNegator negatorWithExpression:expr];
            index = 3;
        } else {
            expr = [self _expressionInParenthesis:[parts objectAtIndex:0] inTable:table];
            if ([expr isKindOfClass:[FSExpressionError class]]) return expr;
        }
        while (index < [parts count]) {
            opClass = [FSOperator operatorClassForSymbol:[parts objectAtIndex:index]];
            expr2 = [self _expressionInParenthesis:[parts objectAtIndex:index+1] inTable:table];
            if ([expr2 isKindOfClass:[FSExpressionError class]]) return expr2; 
            args = [NSArray arrayWithObjects:expr, expr2, nil];
            expr = [opClass operatorWithArguments:args];
            index += 2;
        }
    }
    return expr;
}


+ (NSString*)_cutOffComments:(NSString*)strg
/*" Looks for C style comments and cuts them out of the string. "*/
{
    BOOL            inComment = NO;
    unichar         currentQuote = 0;
    int             index = 0;
    unichar         character;
    
    // Move thru strg and cut comments.
    while (index < [strg length]) {
        character = [strg characterAtIndex:index];
        if (currentQuote != 0) {
            // If we are inside of a quote block, 
            // ignore all chars except the closing quote.
            if (character == currentQuote) {
                currentQuote = 0;
            }
        } if (inComment) {
            /* future enhancement; slash-star comments */
        } else {
            switch (character) {
                case '"':
                    currentQuote = character;
                    break;
                case '\'':
                    currentQuote = character;
                    break;
                case '/':
                    if (index+1 < [strg length]) {
                        if ([strg characterAtIndex:index+1] == '/')
                            return [strg substringToIndex:index];
                    }
                    break;
                default:
                    ;
            }
        }
        index++;
    }
    return strg;
}


+ (FSExpression*)expressionWithString:(NSString*)exprString inTable:(FSTable*)table
/*" Creates an autoreleased FSExpression instance from exprString. "*/
{
    NSScanner *scanner = nil;
    double     value = 0;
    NSString  *strg;
    
    if ([exprString length] == 0)
        return [FSExpressionError expressionError:@"Empty expression"];

    // If whatever comes in here is a simple numeric value, create a constant.
    scanner = [NSScanner scannerWithString:exprString];
    if ([scanner scanDouble:&value]) {
        if ([scanner isAtEnd]) {
            return [FSConstant constantWithValue:exprString];
        } else if ([scanner scanString:@"%" intoString:NULL] && [scanner isAtEnd]) {
            return [FSConstant constantWithValue:exprString];
        }
    }
    
    strg = [self _cutOffComments:exprString];
    
    return [self _parseString:strg inTable:table];
}


- (id)formulaValueForKeySet:(FSKeySet*)ks
{
    [NSException raise:@"FSExpressionSubclassingException"
                format:@"-[FSExpression formulaValueForKeySet:] must be overwritten in %@!", [self className]];
    return 0;
}


- (FSSelection*)referencedSelectionInFormulaSpace:(FSFormulaSpace*)fs
{
    [NSException raise:@"FSExpressionSubclassingException"
                format:@"-[FSExpression referencedSelectionInFormulaSpace:] must be overwritten in %@!",
        [self className]];
    return nil;
}


- (NSString*)creatorString
{
    return @"";
}


- (NSString*)description
{
    [NSException raise:@"FSExpressionSubclassingException"
        format:@"-[FSExpression description] must be overwritten!"];
    return nil;
}

@end
