//  $Id: FSVariable.m,v 1.2 2014/01/26 09:23:53 buzzdee Exp $
//
//  FSVariable.m
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

#import "FSVariable.h"
#import "FSConstant.h"
#import "FSExpressionError.h"
#import "FoundationExtentions.h"
#import "FSParserFunctions.h"
#import "FSFormulaSpace.h"
#import "FSFormulaSelection.h"
#import "FSCore.h"


NSString *FS_RCFN[5] = {@"FIRST", @"PREV", @"THIS", @"NEXT", @"LAST"};

@implementation FSVariable
/*" FSVariable is a reference to values of a table, 
    specified by FSKey objects.
    
    After initializing, a FSVariable is pretty immutable. "*/

/* TODO
 there is a lot of stuff missing from the modififer op implementation.
 the formula parser must assure that all mod ops are on the same category.
 offsets like [LAST - 1] should be allowed.
 right now, we could have mod ops on multiple groups and not store them!
 */

- (NSArray*)_splitStringIntoKeys:(NSString*)creator inTable:(FSTable*)table
{
    NSArray         *names;
    NSMutableArray  *keys = [NSMutableArray array];
    int              index;
    id<FSItem>       key;
    NSArray         *items;
    NSString        *name;
    
    names = FSSplitStringByColons(creator);
    for (index = 0; index < [names count]; index++) {
        name = [names objectAtIndex:index];
        if ([name hasSuffix:@"[THIS]"]) {
            _recSpc = FS_THIS;
            name = [name substringToIndex:[name length]-6];
            _rGroup = [[table groupsForString:name] lastObject];
        } else if ([name hasSuffix:@"[PREV]"]){
            _recSpc = FS_PREV;
            name = [name substringToIndex:[name length]-6];
            _rGroup = [[table groupsForString:name] lastObject];
        } else if ([name hasSuffix:@"[NEXT]"]){
            _recSpc = FS_NEXT;
            name = [name substringToIndex:[name length]-6];
            _rGroup = [[table groupsForString:name] lastObject];
        } else if ([name hasSuffix:@"[FIRST]"]){
            _recSpc = FS_FIRST;
            name = [name substringToIndex:[name length]-7];
            _rGroup = [[table groupsForString:name] lastObject];
        } else if ([name hasSuffix:@"[LAST]"]){
            _recSpc = FS_LAST;
            name = [name substringToIndex:[name length]-6];
            _rGroup = [[table groupsForString:name] lastObject];
        } else {
            items = [table keysForString:name];
            // Catch multiple items found
            key = [items lastObject];
            if (key) {
                [keys addObject:key];
            } else {
                key = [[table groupsForString:[names objectAtIndex:index]] lastObject];
                if (key) {
                    [keys addObject:key];
                } else {
                    keys = nil;
                }
            }
        }
        if (_rGroup) {
            [_rGroup retain];
        }
    }
    
    return keys;
}


- (id)_initError:(NSString*)errorStrg,...
{
    FSExpressionError  *error;
    NSString           *strg;
    va_list             args;
    
    va_start(args, errorStrg);
    strg = [[NSString alloc] initWithFormat:errorStrg arguments:args];
    error = [[FSExpressionError alloc] initWithErrorMessage:strg];
    [strg release];
    [self release];
    return error;
}


- (id)initWithCreator:(NSString*)creator inTable:(FSTable*)table
{
    self = [super init];
    if (self) {
        NSArray  *parts = FSSplitStringByDoubleColons(creator);
        
        // Look for table specifier first
        if ([parts count] > 2) {
            return [self _initError:@"%@ is not a valid cell specifier.", creator];
        } else if ([parts count] == 2) {
            creator = [parts objectAtIndex:1];
            table = [[table document] tableWithName:[parts objectAtIndex:0]];
            if (table == nil)
            return [self _initError:@"Table '%@' not found.", [parts objectAtIndex:0]];
            _table = table;
        }
        
        // Split into range parts
        parts = FSSplitStringByDoubleDots(creator);
        if ([parts count] > 2) {
            return [self _initError:@"%@: invalid multiple range.", creator];
        }
        _one = [[self _splitStringIntoKeys:[parts objectAtIndex:0] inTable:table] retain];

        if ([parts count] == 2)
            _two = [[self _splitStringIntoKeys:[parts objectAtIndex:1] inTable:table] retain];

        if (([_one count] == 0) && !_rGroup) {
            return [self _initError:@"%@ is not a valid cell specifier.",
                [parts objectAtIndex:0]];
        }
        if (_two && ([_two count] == 0)) {
            return [self _initError:@"%@ is not a valid cell specifier.",
                [parts objectAtIndex:1]];
        }
        // XXX Catch incomplete selection in cross table situation.
    }
    return self;
}


- (void)dealloc
{
    [_one release];
    [_two release];
    [super dealloc];
}


+ (FSExpression*)variableWithCreator:(NSString*)strg inTable:(FSTable*)table
{
    NSString  *creator = [strg stringByTrimmingWhitespace];
    NSScanner *scanner;
    double     value;
    
    // If it is a double quoted string, this is a string constant.
    if ([creator isDoubleQuotedString])
        return [FSConstant constantWithValue:creator];

    // If whatever comes in here is a simple numeric value, create a constant.
    scanner = [NSScanner scannerWithString:creator];
    if ([scanner scanDouble:&value] && [scanner isAtEnd])
        return [FSConstant constantWithValue:creator];

    return [[[self alloc] initWithCreator:creator inTable:table] autorelease];
}


- (FSValue*)_referencedSingleValueForKeySet:ks
/*" Throws exception if the value does not exist. "*/
{
    FSKeySet *set;
    
    if (_table) {
        set = [FSKeySet keySetWithKeys:_one];
        NSAssert([set isComplete], @"No value for incomplete key.");
    } else {
        set = [ks setByAddingKeys:[FSKeySet keySetWithKeys:_one]];
    }

    if (_rGroup) {
        NSArray  *keys = [_rGroup keys];
        FSKey     *key = [set keyForGroup:_rGroup];
        NSUInteger idx = [keys indexOfObject:key];
        switch (_recSpc) {
            case FS_THIS:
                break;
            case FS_FIRST:
                [set addKey:[keys objectAtIndex:0]];
                break;
            case FS_LAST:
                [set addKey:[keys lastObject]];
                break;
            case FS_PREV:
            case FS_NEXT:
                if (idx != NSNotFound) {
                    idx += _recSpc;
                    if (idx < [keys count]) {
                        [set addKey:[keys objectAtIndex:idx]];
                    } else {
                        [NSException raise:@"FSFormulaException" format:@"Index of of bounds in recursive calculation."];
                    }
                }
                break;
            default:
                [NSException raise:@"FSFormulaException" format:@"Unknown recSpc %i", _recSpc];
        }
    }

    return [set value];
}


- (id)formulaValueForKeySet:(FSKeySet*)ks
/*" Returns the current variable value. "*/
{
    if (_two) {
        [NSException raise:@"FSFormulaException" format:@"Ambiguous selection (%@).", [self creatorString]];
    }
    if (_one) {
        FSValue *value = [self _referencedSingleValueForKeySet:ks];
        return [value value];
    }
    return nil;
}


- (FSSelection*)referencedSelectionInFormulaSpace:(FSFormulaSpace*)fs
{
    if (_rGroup) {
        [NSException raise:@"FSFormulaException" format:@"Don't use -referencedSelectionInFormulaSpace: on a recursive FSVariable."];
    }
    return [self selection];
}


- (NSArray*)rangesForKeys:(NSArray*)k1 :(NSArray*)k2
{
    NSMutableArray *ranges = [NSMutableArray array];
    FSKeySet       *set = [FSKeySet keySetWithKeys:k2];
    int             i;
    FSKey          *key1;
    FSKey          *key2;
        
    for (i = 0; i < [k1 count]; i++) {
        key1 = [k1 objectAtIndex:i];
        key2 = [set keyForHeader:[key1 header]];
        if (key2 == nil) key2 = key1;
        if (key2) {
            [ranges addObject:[FSKeyRange keyRangeFromItem:key1 toItem:key2]];
        }
    }
    return ranges;
}


- (FSSelection*)selection
{
    NSArray *ranges;

    if (_rGroup) {
        if (_recSpc != FS_THIS) {
            [NSException raise:@"FSFormulaException" format:@"Don't use -selection on a recursive FSVariable."];
        }
    }
    if (_two) {
        ranges = [self rangesForKeys:_one :_two];
    } else {
        ranges = [self rangesForKeys:_one :_one];
    }
    return [FSSelection selectionWithRanges:ranges];
}


- (NSString*)_creatorForKeys:(NSArray*)keys
{
    NSMutableArray *names = [NSMutableArray array];
    NSString       *label;
    int i;

    // Variables are always single selections!
    // So make sure there is no other label (in another group) by the same name.
    for (i = 0; i < [keys count]; i++) {
        label = [[keys objectAtIndex:i] fullPath];
        /* Full paths are already quoted if needed 
        if ([label needsQuoting]) 
            label = [label wrapInSingleQuotes];
        */
        [names addObject:label];
    }
    
    return [names componentsJoinedByString:@":"];
}


- (NSString*)creatorString
{
    NSString *label1 = [self _creatorForKeys:_one];
    if (_table) {
        NSString *tName = [_table name];
        if ([tName needsQuoting]) 
            label1 = [NSString stringWithFormat:@"'%@'::%@", tName, label1];
        else
            label1 = [NSString stringWithFormat:@"%@::%@", tName, label1];
    }
    
    if (_rGroup) {
        NSString *lbl = [_rGroup label];
        NSString *rStrg = [NSString stringWithFormat:@"%@[%@]", lbl, FS_RCFN[_recSpc+2]];
        if ([label1 length] > 0) {
            label1 = [NSString stringWithFormat:@"%@:%@", label1, rStrg];
        } else {
            label1 = rStrg;
        }
    }
    
    if (_two) {
        NSString *label2 = [self _creatorForKeys:_two];
        return [NSString stringWithFormat:@"%@ .. %@", label1, label2];
    }

    return label1;
}


- (NSString*)description
{
    return [self creatorString];
}


- (NSArray*)one
{
    return _one;
}


- (BOOL)isFromDifferentTable
{
    return (_table != nil);
}


- (BOOL)isRange
{
    BOOL range = (_two != nil);
    int  idx = [_one count];
    
    while (!range && (idx-- > 0)) {
        if ([[_one objectAtIndex:idx] isKindOfClass:[FSKeyGroup class]])
            range = YES;
    }
    
    return range;
}


- (BOOL)isRecurrence
{
    return (_rGroup != nil);
}


- (FSKeyGroup*)recurrenceGroup
{
    return _rGroup;
}

@end
