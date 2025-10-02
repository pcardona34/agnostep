//  $Id: FSFormula.m,v 1.1 2008/10/14 15:04:17 hns Exp $
//
//  FSFormula.m
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

#import "FSFormula.h"
#import "FSLog.h"
#import "FSTable.h"
#import "FSValue.h"
#import "FSSelection.h"
#import "FSFormulaSpace.h"
#import "FSFormulaSelection.h"
#import "FSFormulaDefinition.h"
#import "FSExpressionError.h"
#import "FoundationExtentions.h"

@implementation FSFormula

+ (FSFormula*)formulaWithString:(NSString*)formulaString inTable:(FSTable*)table
/*" Use this instead of calling alloc/init. "*/
{
    return [[[self alloc] initWithString:formulaString inTable:table] autorelease];
}


- (BOOL)_breakString:(NSString*)strg intoSelection:(NSString**)sel andDefinition:(NSString**)def
{
    BOOL success = NO;
    int  index = 0;
    int  length = [strg length];
    BOOL skip = NO;
    
    NS_DURING
        while (index < length) {
            if (!skip && ([strg characterAtIndex:index]=='=')) {
                *sel = [[strg substringToIndex:index] stringByTrimmingWhitespace];
                *def = [[strg substringFromIndex:index+1] stringByTrimmingWhitespace];
                success = YES;
                break;
            }
            index++;
        }
    NS_HANDLER
        [FSLog logError:@"Error in formula string. (%@)", strg];
    NS_ENDHANDLER
    
    return success;
}


- (NSString*)_cutSkipClause:(NSString**)skip fromString:(NSString*)input
{
    NSCharacterSet *endChars = [NSCharacterSet characterSetWithCharactersInString:@" )]\t"];
    unichar         character;
    int             index = [input length];
    unichar         currentQuote = 0;
    
    *skip = nil;
    
    while (index-- > 5) {
        character = [input characterAtIndex:index];
        if (currentQuote != 0) {
            // If we are inside of a quote block, 
            // ignore all chars except the closing quote.
            if (character == currentQuote) {
                currentQuote = 0;
            }
        } else {
            switch (character) {
                case 'p':
                case 'P':
                    if ([[input substringWithRange:NSMakeRange(index-3,4)]
                            caseInsensitiveCompare:@"SKIP"] == NSOrderedSame) {
                        if ([endChars characterIsMember:[input characterAtIndex:index-4]]) {
                            *skip = [input substringFromIndex:index-3];
                            return [input substringToIndex:index-3];
                        }
                    }  
                    break;
                default:
                    ;
            }
        }
    }
    
    return input;
}


- (BOOL)_parse
{
    if (_originalString) {
        NSString *selection = nil;
        NSString *definition = nil;
        NSString *skipclause = nil;
        
        NSString *string = nil;
        
        // If it is a comment, ignore it.
        if ([_originalString hasPrefix:@"//"]) {
            return YES;
        }
        
        string = [self _cutSkipClause:&skipclause fromString:_originalString];
        
        if ([self _breakString:string intoSelection:&selection andDefinition:&definition]) {
            [_selection release];
            _selection = [[FSFormulaSelection alloc] initWithString:selection inTable:_table];
            [_definition release];
            _definition = [[FSFormulaDefinition alloc] initWithString:definition inTable:_table];
            if (_selection && _definition) {
                // Only with a valid selection and definition
                // we parse the skip clause.
                //
                // TBD
                //
                // and the original string is no longer needed.
                [_originalString release];
                _originalString = nil;
            }
        } else {
            return NO;
        }
    }
    return YES;
}


- (id)initWithString:(NSString*)formulaString inTable:(FSTable*)table
{
    self = [super init];
    if (self) {
        _originalString = [[formulaString stringByTrimmingWhitespace] retain];
        _selection = nil;
        _definition = nil;
        _skipElements = nil;
        _table = table;
        _touchedSel = nil;
    }
    return self;
}


- (void)replaceFormulaWithString:(NSString*)formulaString
{
    [_touchedSel release];
    _touchedSel = nil;
    [_selection release];
    _selection = nil;
    [_definition release];
    _definition = nil;
    [_originalString release];
    _originalString = [[formulaString stringByTrimmingWhitespace] retain];
}


- (void)dealloc
{
    [_touchedSel release];
    [_selection release];
    [_definition release];
    [_originalString release];
    [super dealloc];
}


- (NSArray*)selectedKeySets
{
    if (!_selection && !_definition)
        [self _parse];

    if ([self isOK]) {
        NSArray *candidates = [_selection selectedKeySets];
        return [_definition validateCandidateKeySets:candidates];
    }
    return nil;
}


- (BOOL)isOK
{
    if (!_selection && !_definition) [self _parse]; 
    return ((!_selection && !_definition) ||
        (_selection && _definition && ![_definition isError]));
}


- (NSString*)errorString
{
    NSString *msg = @"No definition specified.";

    if (!_selection && !_definition) [self _parse]; 

    if ([_selection hasError])
        msg = [_selection errorString];
    else if (_definition)
        msg = [_definition formulaValueForKeySet:nil];
    return [@"ERROR: " stringByAppendingString:msg];
}


- (id)formulaValueForKeySet:(FSKeySet*)keySet
{
    return [_definition formulaValueForKeySet:keySet];
}


- (void)setTouchedSelection:(FSSelection*)sel
{
    if (sel != _touchedSel) {
        [_touchedSel release];
        _touchedSel = [sel retain];
    }
}


- (FSSelection*)touchedSelection
{
    return _touchedSel;
}


- (NSString*)_skipString
{
    return nil;
}


- (NSString*)description
/*" Reproduces the formula string this instance was initialized with."*/
{
    if (_selection && _definition) {
        NSString *sel = [_selection description];
        NSString *def = [_definition description];
        NSString *skip = [self _skipString];
        
        if (skip) 
            return [NSString stringWithFormat:@"%@ = %@ %@", sel, def, skip];
        return [NSString stringWithFormat:@"%@ = %@", sel, def];
    }
    if (_originalString) 
        return _originalString;
    return [super description];
}

@end
