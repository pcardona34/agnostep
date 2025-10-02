//  $Id: FSFunction.m,v 1.1 2008/10/14 15:04:19 hns Exp $
//
//  FSFunction.m
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

#import <FSCore/FSFunction.h>
#import <FSCore/FSCore.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSAttributedString.h>

static NSMutableDictionary *__FSFunctionSubclasses;
static NSMutableDictionary *__FSFunctionGroupStore;
static NSMutableDictionary *__FSFunctionHelpStore;
static NSURL               *__FSFunctionBaseURL;

@implementation FSFunction
/*" FSFunction is an abstract superclass for all FSExpression elements 
    that represent a function, ie a name with arguments in parenthesis. "*/

+ (void)initialize
{
    if (__FSFunctionSubclasses == nil) {
        __FSFunctionSubclasses = [[NSMutableDictionary alloc] init];
    }
    if (__FSFunctionGroupStore == nil) {
        __FSFunctionGroupStore = [[NSMutableDictionary alloc] init];
    }
    if (__FSFunctionHelpStore == nil) {
        __FSFunctionHelpStore = [[NSMutableDictionary alloc] init];
    }
}


+ (NSURL*)helpBaseURL
{
    if (__FSFunctionBaseURL == nil)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *base = [NSString stringWithFormat:@"%@/FlexiSheet Help/Functions",
            [bundle resourcePath]];
        __FSFunctionBaseURL = [[NSURL fileURLWithPath:base] retain];
    }
    return __FSFunctionBaseURL;
}


+ (void)registerFunction:(Class)functionClass
{
    NSString *symbol = [functionClass functionName];
    if ([__FSFunctionSubclasses objectForKey:symbol] == nil) {
        NSString       *groupName = [functionClass functionGroup];
        NSMutableArray *elements = [__FSFunctionGroupStore objectForKey:groupName];

        [__FSFunctionSubclasses setObject:functionClass forKey:symbol];
        if (elements == nil) {
            elements = [NSMutableArray array];
            [__FSFunctionGroupStore setObject:elements forKey:groupName];
        }
        [elements addObject:[functionClass functionName]];
    } else {
        [FSLog logError:@"Class for operator symbol '%@' is already registered.", symbol];
    }
}


+ (NSArray*)allFunctionNames
{
    return [__FSFunctionSubclasses allKeys];
}


+ (NSArray*)allFunctionNamesInGroup:(NSString*)group
{
    return [__FSFunctionGroupStore objectForKey:group];
}


+ (NSArray*)allGroupNames
{
    return [__FSFunctionGroupStore allKeys];
}


+ (Class)functionClassForName:(NSString*)name
{
    return [__FSFunctionSubclasses objectForKey:name];
}


+ (NSString*)htmlHelpData
{
    NSString  *classname = [self description];
    NSString  *help = [__FSFunctionHelpStore objectForKey:classname];
    
    if (help == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *name = [classname substringFromIndex:2];
        NSString *base = [NSString stringWithFormat:@"%@/FlexiSheet Help/Functions",
            [bundle resourcePath]];
        NSString *path = [NSString stringWithFormat:@"%@/%@.html", base, name];
        NSString *contents = [NSString stringWithContentsOfFile:path];
        
        if (contents != nil) {
            help = contents;
        } else {
            help = @"Description forthcoming...";
            TEST_DBG [FSLog logDebug:@"Help for %@ not found.", name];
        }
        [__FSFunctionHelpStore setObject:help forKey:classname];
    }
    return help;
}


+ (NSString*)functionName
/*" Must be overwritten in subclasses.  FSOperator's implementation raises,
    so don't call it in the subclass implementation! "*/
{
    [NSException raise:@"FSFunctionSubclassingException" 
        format:@"+[FSFunction operatorSymbol] must be overwritten!"];
    return @"";
}


+ (NSString*)functionGroup
{
    return @"Unsorted";
}


+ (int)numberOfOperands
/*" Must be overwritten in subclasses.  FSOperator's implementation raises,
    so don't call it in the subclass implementation! "*/
{
    [NSException raise:@"FSFunctionSubclassingException"
        format:@"+[FSFunction numberOfOperands] must be overwritten!"];
    return 0;
}


+ (FSFunction*)functionWithArguments:(NSArray*)arguments
/*" Must be overwritten in subclasses.  FSOperator's implementation raises,
    so don't call it in the subclass implementation! "*/
{
    [NSException raise:@"FSFunctionSubclassingException"
        format:@"+[FSFunction functionWithArguments:] must be overwritten!"];
    return nil;
}


- (NSString*)creatorString
/*" Must be overwritten in subclasses if the function takes any arguments. "*/
{
    return [[self class] functionName];
}

@end

@implementation FSSimpleFunction

- (id)initWithArgument:(FSExpression*)argument
{
    self = [super init];
    if (self) {
        _argument = [argument retain];
    }
    return self;
}


- (void)dealloc
{
    [_argument release];
    [super dealloc];
}


+ (FSFunction*)functionWithArguments:(NSArray*)arguments
{
    return [[[self alloc] initWithArgument:[arguments objectAtIndex:0]]
        autorelease];
}


+ (int)numberOfOperands
{
    return 1;
}


+ (NSString*)functionGroup
{
    return @"Math";
}


- (FSSelection*)referencedSelectionInFormulaSpace:(FSFormulaSpace*)fs
    /*" This implementation is sufficient for most single argument functions. "*/
{
    NSArray *keySets = [[_argument referencedSelectionInFormulaSpace:fs] completeKeySets];
    return [FSSelection selectionWithKeySets:keySets];
}


- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@)",
        [[self class] functionName], [_argument creatorString]];
}

@end
