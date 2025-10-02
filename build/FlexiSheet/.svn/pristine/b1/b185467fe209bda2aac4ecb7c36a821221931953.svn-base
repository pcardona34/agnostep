//  $Id: FoundationExtentions.m,v 1.6 2012/01/25 09:03:18 rmottola Exp $
//
//  FoundationExtentions.m
//  FSCore Framework
//
//  Created by Stefan Leuker on 11-SEP-2001.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//  2008-2015 Riccardo Mottola
//            GNUstep Application Project
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

// NOTE: This code isn't portable at all and very specific for the Obj-C Runtime

#include <assert.h>

#import "FoundationExtentions.h"

#ifdef __APPLE__
#import <objc/objc-api.h>
#import <objc/objc-class.h>
#import <objc/objc-runtime.h>

#if !(MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_4)
Class class_getSuperclass(Class subClass)
{
  return subClass -> super_class;
}
#endif
#endif

@implementation NSObject (Introspection)

BOOL FXClassIsSuperclassOfClass(Class aClass, Class subClass)
{	
    Class class;
    class = class_getSuperclass(subClass);
    while(class != nil)
        {
			if(class == aClass)
				return YES;
			class = class_getSuperclass(class);
        }
    return NO;
}

// used so that a class can perform selectors on all subclasses

NSArray *FXSubclassesOfClass(Class aClass)
{ // get all subclasses (nested) of given class
  NSLog(@"subclasses");
    NSMutableArray *subclasses = [NSMutableArray array];
    Class          *classes;
    int            numClasses = 0, newNumClasses, i;
	// Apple objc runtime
    newNumClasses = objc_getClassList(NULL, 0);
    classes = NULL;
    while (numClasses < newNumClasses)
        {
        numClasses = newNumClasses;
        classes = realloc(classes, sizeof(Class) * numClasses);
        newNumClasses = objc_getClassList(classes, numClasses);
        }

    for(i = 0; i < numClasses; i++)
        {
        if(FXClassIsSuperclassOfClass(aClass, classes[i]) == YES)
            [subclasses addObject:classes[i]];
        }
    free(classes);
#if 1
	NSLog(@"subclasses of %@: %@", NSStringFromClass(aClass), subclasses);
#endif
    return subclasses;
}


+ (NSArray *)subclasses
{
    return FXSubclassesOfClass(self);
}


- (NSString *)className
{
    return NSStringFromClass([self class]);
}

@end


@implementation NSArray (FoundationExtentions)

- (void)iteratePerformSelector:(SEL)aSelector target:(id)target
{
    NSEnumerator *cursor = [self objectEnumerator];
    id            object;
    
    while ((object = [cursor nextObject])) {
        if ([target respondsToSelector:aSelector]) 
            [target performSelector:aSelector withObject:object];
    }
}

@end


@implementation NSString (FoundationExtentions)

- (NSString*)followingString
/*" Returns a new string that is similar to the receiving string,
    but is different enough.  If the string ends in a number, 
    this number is increased.  Otherwise, 2 is appended. "*/
{
    NSCharacterSet   *dd = nil;
    
    NSScanner        *scanner = [[NSScanner alloc] initWithString:self];
    int               number;
    NSString         *skipped;
    NSMutableString  *newString = [NSMutableString string];

    if (!dd) dd = [NSCharacterSet decimalDigitCharacterSet];

    while (![scanner isAtEnd]) {
        if ([scanner scanUpToCharactersFromSet:dd intoString:&skipped]) {
            [newString appendString:skipped];
        }
        if ([scanner scanCharactersFromSet:dd intoString:&skipped]) {
            if ([scanner isAtEnd]) {
                number = [skipped intValue];
                number++;
                [newString appendString:[NSString stringWithFormat:@"%i", number]];
            } else {
                [newString appendString:skipped];
            }
        } else {
            [newString appendString:@" 2"];
        }
    }
    [scanner release];
    assert([self isEqualToString:newString] == NO);
    return newString;
}


- (NSString*)stringByTrimmingWhitespace
{
    static NSCharacterSet *ws = nil;

    NSRange          range;
    NSString        *result = self;
    int              max = [self length] - 1;

    if (!ws) ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    if (max > 0) {
        if ([ws characterIsMember:[self characterAtIndex:0]] || [ws characterIsMember:[self characterAtIndex:max]]) {
            NSMutableString *trimmed = [[NSMutableString alloc] initWithString:self];
            if ([trimmed length] > 0) {
                range = NSMakeRange(0,0);
                while ((range.length < [trimmed length]) && [ws characterIsMember:[trimmed characterAtIndex:range.length]])
                    range.length++;
                [trimmed deleteCharactersInRange:range];
            }
            if ([trimmed length] > 0) {
                range = NSMakeRange([trimmed length],0);
                while ((range.location > 0) && [ws characterIsMember:[trimmed characterAtIndex:range.location-1]]) {
                    range.location--;
                    range.length++;
                }
                [trimmed deleteCharactersInRange:range];
            }

            result = [trimmed copy];
            [result autorelease];
            [trimmed release];
        }
    }

    return result;
}


- (NSString*)_stripBackslashedQuotes:(unichar)quote
{
    NSMutableString *trimmed = [NSMutableString stringWithString:self];
    int              index = 1;

    while (index < [trimmed length]) {
        if ([trimmed characterAtIndex:index] == quote) {
            if ([trimmed characterAtIndex:index-1] == '\\') {
                index--;
                [trimmed deleteCharactersInRange:NSMakeRange(index,1)];
            }
        }
        index++;
    }
    
    return [[trimmed copy] autorelease];
}


- (NSString*)stringByTrimmingQuotes
{
    int max = [self length] - 1;

    if (max > 0) {
        if (([self characterAtIndex:0] == '"') && ([self characterAtIndex:max] == '"'))
            return [[self substringWithRange:NSMakeRange(1,max-1)] _stripBackslashedQuotes:'"'];
        if (([self characterAtIndex:0] == '\'') && ([self characterAtIndex:max] == '\''))
            return [[self substringWithRange:NSMakeRange(1,max-1)] _stripBackslashedQuotes:'\''];
    }
    return self;
}


- (NSString*)stringByTrimmingParenthesis
{
    int max = [self length] - 1;

    if (max > 0)
        if (([self characterAtIndex:0] == '(') && ([self characterAtIndex:max] == ')'))
            return [self substringWithRange:NSMakeRange(1,max-1)];
    return self;
}


- (BOOL)isDoubleQuotedString
{
    int max = [self length]-1;

    if (max > 0) {
        if (([self characterAtIndex:0] == '"') && ([self characterAtIndex:max] == '"')) {
            int index = max;
            while (--index > 0)
                if ([self characterAtIndex:index] == '"')
                    return NO;
            return YES;
        }
    }
    return NO;
}


- (BOOL)isSingleQuotedString
{
    int max = [self length]-1;

    if (max > 0) {
        if (([self characterAtIndex:0] == '\'') && ([self characterAtIndex:max] == '\'')) {
            int index = max;
            while (--index > 0)
                if ([self characterAtIndex:index] == '\'')
                    if ((index > 1) && ([self characterAtIndex:index-1] != '\\'))
                        return NO;
            return YES;
        }
    }
    return NO;
}


- (BOOL)needsQuoting
{
    static NSCharacterSet *__probChrs;
    
    if (__probChrs == nil) {
        __probChrs = [NSCharacterSet characterSetWithCharactersInString:@"\"&.:+-*/\\^=()"];
        [__probChrs retain];
    }
    
    return ([self rangeOfCharacterFromSet:__probChrs].length == 1);
}


- (NSString*)wrapInSingleQuotes
{
    NSMutableString *result = [NSMutableString stringWithString:self];
    int              index = 1;

    [result insertString:@"'" atIndex:0];
    while (index < [result length]) {
        if ([result characterAtIndex:index] == '\'') {
            [result insertString:@"\\" atIndex:index];
            index++;
        }
        index++;
    }
    
    [result appendString:@"'"];
    return [[result copy] autorelease];
}


- (NSString*)wrapInDoubleQuotes
{
    NSMutableString *result = [NSMutableString stringWithString:self];
    int              index = 1;

    [result insertString:@"\"" atIndex:0];
    while (index < [result length]) {
        if ([result characterAtIndex:index] == '"') {
            [result insertString:@"\\" atIndex:index];
            index++;
        }
        index++;
    }

    [result appendString:@"\""];
    return [[result copy] autorelease];
}


- (NSArray*)valuesFromExcelPasteboard
{
    NSArray *lines = [self componentsSeparatedByString:@"\n"];
    NSString *lineLine = [lines componentsJoinedByString:@"\t"];
    return [lineLine componentsSeparatedByString:@"\t"];
}

@end


@implementation NSMutableArray (FoundationExtentions)

- (void)addObjectIfAbsent:(id)object
{
    if ([self indexOfObject:object] == NSNotFound) {
        [self addObject:object];
    }
}


- (void)removeObjectsNotInArray:(NSArray*)negative
{
    int index = [self count];
    
    while (index-- > 0) {
        if (NO == [negative containsObject:[self objectAtIndex:index]]) {
            [self removeObjectAtIndex:index];
        }
    }
}

@end
