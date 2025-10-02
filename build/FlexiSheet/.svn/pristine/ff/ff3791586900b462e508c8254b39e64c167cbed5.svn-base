//  $Id: FSParserFunctions.m,v 1.1 2008/10/14 15:04:22 hns Exp $
//
//  FSParserFunctions.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 08-OCT-2001.
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
//  ----------------------------------------------------------
//  Functions called by methods with need for parsing strings.
//  ----------------------------------------------------------
//

#import "FSParserFunctions.h"
#import "FoundationExtentions.h"

NSArray* FSSplitStringByColons(NSString* strg)
/*" Splits strg into components separated by colons.
    Single quoted strings are recognized, double quoted strings are not. "*/
{
    NSMutableArray *parts = [NSMutableArray array];
    int             index = 0;
    int             length = 0;
    unichar         quote = 0;
    unichar         character;
    NSString       *tmp;
    
    while (index < [strg length]) {
        character = [strg characterAtIndex:index];
        if (quote) {
            // If we are inside of a quote block, 
            // ignore all chars except the closing quote.
            if (character == quote) {
                quote = 0;
            }
            length++;
        } else {
            switch (character) {
                case '\'':
                    quote = character;
                    length++;
                    break;
                default:
                    if (character == ':') {
                        // Store away the string.
                        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
                        [parts addObject:[tmp stringByTrimmingWhitespace]];
                        length = 0;
                    } else {
                        length++;
                    }
            }
        }
        index++;
    }
    if (length > 0) {
        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
        [parts addObject:[tmp stringByTrimmingWhitespace]];
    } else {
        [parts addObject:@""];
    }
    return parts;
}


NSArray* FSSplitStringByDots(NSString* strg)
/*" Splits strg into components separated by dots.
    Single quoted strings are recognized, double quoted strings are not. "*/
{
    NSMutableArray *parts = nil;
    int             index = 0;
    int             max = [strg length];
    int             length = 0;
    unichar         quote = 0;
    unichar         character;
    NSString       *tmp;

    while (index < max) {
        character = [strg characterAtIndex:index];
        if (quote) {
            // If we are inside of a quote block,
            // ignore all chars except the closing quote;
            // but skip quotes that are escaped by backslash.
            if (character == '\\') {
                if (++index < max) {
                    unichar nextChar = [strg characterAtIndex:index];
                    if (nextChar != quote) index--;
                }
            } else if (character == quote) {
                quote = 0;
            }
            length++;
        } else {
            switch (character) {
                case '\'':
                    quote = character;
                    length++;
                    break;
                default:
                    if (character == '.') {
                        // Store away the string.
                        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
                        if (parts == nil) {
                            parts = [NSMutableArray arrayWithObject:[tmp stringByTrimmingWhitespace]];
                        } else {
                            [parts addObject:[tmp stringByTrimmingWhitespace]];
                        }
                        length = 0;
                    } else {
                        length++;
                    }
            }
        }
        index++;
    }

    if (!parts && (length == max))
        return [NSArray arrayWithObject:strg];
    
    if (length > 0) {
        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
        if (parts == nil) {
            parts = [NSMutableArray arrayWithObject:[tmp stringByTrimmingWhitespace]];
        } else {
            [parts addObject:[tmp stringByTrimmingWhitespace]];
        }
    } else {
        // must have parts by now...
        [parts addObject:@""];
    }
    return parts;
}


NSArray* FSSplitStringByCommas(NSString* strg)
/*" Splits strg into components separated by commans.
    Singe and double quoted strings are recognized,
    also parts in parenthesis. "*/
{
    NSMutableArray *parts = [NSMutableArray array];
    int             pNum = 0;
    unichar         currentQuote = 0;
    int             index = 0;
    int             length = 0;
    unichar         character;
    NSString       *tmp;

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
                        // we don't look for comma
                        length++;
                    } else {
                        if (character == ',') {
                            // Store away the string.
                            tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
                            [parts addObject:[tmp stringByTrimmingWhitespace]];
                            length = 0;
                        } else {
                            length++;
                        }
                    }
            }
        }
        index++;
    }

    if (length > 0) {
        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
        [parts addObject:[tmp stringByTrimmingWhitespace]];
    } else {
        [parts addObject:@""];
    }
    
    return parts;
}


NSArray* FSSplitStringByDoubleColons(NSString* strg)
/*" Splits strg into components separated by double colons.
    Single quoted strings are recognized, double quoted strings are not. "*/
{
    NSMutableArray *parts = [NSMutableArray array];
    int             index = 0;
    int             length = 0;
    unichar         quote = 0;
    unichar         character;
    NSString       *tmp;
    
    while (index < [strg length]) {
        character = [strg characterAtIndex:index];
        if (quote) {
            // If we are inside of a quote block, 
            // ignore all chars except the closing quote.
            if (character == quote) {
                quote = 0;
            }
            length++;
        } else {
            switch (character) {
                case '\'':
                    quote = character;
                    length++;
                    break;
                default:
                    if ((character == ':') && (index < [strg length]-1)
                    && ([strg characterAtIndex:index+1] == ':')) {
                        // Store away the string.
                        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
                        [parts addObject:[tmp stringByTrimmingWhitespace]];
                        index++;
                        length = 0;
                    } else {
                        length++;
                    }
            }
        }
        index++;
    }
    if (length > 0) {
        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
        [parts addObject:[tmp stringByTrimmingWhitespace]];
    } else {
        [parts addObject:@""];
    }
    return parts;
}


NSArray* FSSplitStringByDoubleDots(NSString* strg)
/*" Splits strg into components separated by double dots.
    Single quoted strings are recognized, double quoted strings are not. "*/
{
    NSMutableArray *parts = [NSMutableArray array];
    int             index = 0;
    int             length = 0;
    unichar         quote = 0;
    unichar         character;
    NSString       *tmp;
    
    while (index < [strg length]) {
        character = [strg characterAtIndex:index];
        if (quote) {
            // If we are inside of a quote block, 
            // ignore all chars except the closing quote.
            if (character == quote) {
                quote = 0;
            }
            length++;
        } else {
            switch (character) {
                case '\'':
                    quote = character;
                    length++;
                    break;
                default:
                    if ((character == '.') && (index < [strg length]-1)
                    && ([strg characterAtIndex:index+1] == '.')) {
                        // Store away the string.
                        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
                        [parts addObject:[tmp stringByTrimmingWhitespace]];
                        index++;
                        length = 0;
                    } else {
                        length++;
                    }
            }
        }
        index++;
    }
    if (length > 0) {
        tmp = [strg substringWithRange:NSMakeRange(index-length, length)];
        [parts addObject:[tmp stringByTrimmingWhitespace]];
    } else {
        [parts addObject:@""];
    }
    return parts;
}


BOOL FSScanDoubleFromString(NSString* strg, double *result)
/*" Parses strg into a double value if possible.  Returns NO if it wasn't. "*/
{
    long           max = [strg length];
    long           index = 0;
    BOOL           foundPoint = NO;
    int            shift = 1;
    BOOL           noWhitespace = NO;
    BOOL           negative = NO;
    BOOL           error = NO;
    unichar       *buffer;
    double         temp = 0;

    // If string is empty, don't even start.
    if (max == 0)
        return NO;

    // Strings that are something else than ASCII will not be plain numbers.
    if ([strg canBeConvertedToEncoding:NSASCIIStringEncoding] == NO)
        return NO;

    // Get pointer to ascii characters
    buffer = malloc(sizeof(unichar)*[strg length]);
    [strg getCharacters:buffer];

    // Skip whitespace
    while (!noWhitespace) {
        switch (buffer[index]) {
            case '-':
                if (!negative) {
                    negative = YES;
                    index++;
                } else {
                    error = YES;
                    index++;
                    break;
                }
                break;
            case ' ':
            case '\t':
                if (++index < max)
                    break;
                // caution: fall-thru
            default:
                noWhitespace = YES;
        }
    }
    
    if (index < max) {
        // Parse numbers
        while (!error && (index < max)) {
            switch (buffer[index]) {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    if (!noWhitespace) {
                        error = YES;
                        break;
                    }
                    if (foundPoint) {
                        shift *= 10;
                        temp += (double)(buffer[index]-'0')/shift;
                    } else {
                        temp *= 10;
                        temp += buffer[index]-'0';
                    }
                    break;
                case '.':
                case ',':
                    if (foundPoint)
                        error = YES;
                    foundPoint = YES;
                    break;
                case ' ':
                case '\t':
                    noWhitespace = NO;
                    break;
                default:
                    error = YES;
            }
            index++;
        }
    } else {
        error = YES;
    }

    if (error) return NO;

    if (negative)
        *result = -temp;
    else
        *result = temp;
    return YES;
}

