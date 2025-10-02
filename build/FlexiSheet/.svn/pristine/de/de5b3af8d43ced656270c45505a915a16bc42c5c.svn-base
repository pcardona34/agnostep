//  $Id: FSFormulaSelection.m,v 1.1 2008/10/14 15:04:18 hns Exp $
//
//  FSFormulaSelection.m
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

#import <FSCore/FSFormulaSelection.h>
#import <FSCore/FoundationExtentions.h>
#import <FSCore/FSParserFunctions.h>
#import <FSCore/FSVariable.h>
#import <FSCore/FSCore.h>

@implementation FSFormulaSelection
/*" FSFormulaSelection is the right part of a formula.
    It selects one or more cells in a table.
    It handles all the parsing. "*/

//
// Creation
//

+ (FSFormulaSelection*)formulaSelectionWithString:(NSString*)selectionString inTable:(FSTable*)table
/*" Use this instead of calling alloc/init. "*/
{
    return [[[self alloc] initWithString:selectionString inTable:table] autorelease];
}

- (NSArray*)selectedKeySets
/*" Returns an array containing complete key sets
    that define the values selected by this formula.
    "*/
{
    FSSelection *sel = [_selection selection];
    NSArray     *keySets;
    
    if (_inItem) {
        FSKeyRange  *range = [FSKeyRange keyRangeFromItem:_inItem toItem:_inItem];
        sel = [FSSelection selectionWithRanges:[sel ranges]];
        [sel extendWithRange:range];
    }

    keySets = [sel completeKeySets];

    return keySets;
}

- (NSString*)_breakOffInClause:(NSString*)strg
{
    NSString *result = strg;

    if ([strg hasPrefix:@"In "]) {
        NSString *sub = [strg substringFromIndex:3];
        NSArray  *parts = FSSplitStringByCommas(sub);
        if ([parts count] == 2) {
            _inItem = [[_table keysForString:[parts objectAtIndex:0]] lastObject];
            [_inItem retain];
            result = [parts lastObject];
        } else {
            result = nil;
        }
    }

    return result;
}

- (void)_parse
{
    NSString *rest = [self _breakOffInClause:_creator];
    
    if (rest == nil) {
        return;
    }
    
    _selection = (id)[FSVariable variableWithCreator:rest inTable:_table];
    if ([_selection isKindOfClass:[FSVariable class]]) {
        [_selection retain];
        [_creator release];
        _creator = nil;
    } else {
        _selection = nil;
        [FSLog logError:@"Failed to parse selection string! (%@)\n", rest];
    }
}

- (id)initWithString:(NSString*)selectionString inTable:(FSTable*)table
{
    self = [super init];
    if (self) {
        _table = table;
        _selection = nil;
        _creator = [selectionString copy];
        [self _parse];
    }
    return self;
}

- (void)dealloc
{
    [_selection release];
    [_inItem release];
    [_creator release];
    [super dealloc];
}


- (BOOL)hasError
{
    return (_creator != nil);
}


- (NSString*)errorString
{
    return @"Failed to parse selection string!";
}


- (NSString*)creatorString
{
    NSString *inString = @"";
    
    if (_creator) return _creator;
    if (_inItem) {
        NSString *itemStrg = [_inItem label];
        if ([itemStrg needsQuoting]) {
            itemStrg = [itemStrg wrapInSingleQuotes];
        }
        inString = [NSString stringWithFormat:@"In %@, ", itemStrg];
    }
    return [NSString stringWithFormat:@"%@%@", inString, [_selection creatorString]];
}


- (NSString*)description
{
    return [self creatorString];
}

@end
