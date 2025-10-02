//  $Id: FSKey.m,v 1.1 2008/10/14 15:04:20 hns Exp $
//
//  FSKey.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-JAN-2001.
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

#import "FSKey.h"
#import "FSGlobalHeader.h"
#import "FSHeader.h"
#import "FSTable.h"
#import "FSLog.h"
#import "FoundationExtentions.h"


@implementation FSKey

/*" An FSKey is a header instance. "*/

+ (FSKey*)keyWithLabel:(NSString*)label forGroup:(FSKeyGroup*)group
{
    return [group keyWithLabel:label];
}


- (id)init
{
    self = [super init];
    [self release];
    [NSException raise:@"FSException" format:@"Cannot init an FSKey without given FSHeader."];
    return nil;
}


- (id)initWithGroup:(FSKeyGroup*)group
{
    self = [super init];
    if (self) {
        _group = group; // group is not retained by key!
        _label = @"";
        TEST_DBG [FSLog logDebug:@"FSKey %X allocated.", self];
    }
    return self;
}


- (void)dealloc
{
    [_label release];
    TEST_DBG [FSLog logDebug:@"FSKey %X deallocated.", self];
    [super dealloc];
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@: %@", [self className], _label];
}


- (FSKeyGroup*)group
{
    return _group;
}


- (void)setGroup:(FSKeyGroup*)group
{
    // A key can only be reassigned to a group within the same header.
    if (group && _group) {
        NSAssert([group header] == [self header],
            @"Setting key's group to an invalid object.");
    }
    _group = group;
}


- (FSTable*)table
{
    return [_group table];
}


- (FSHeader*)header
{
    FSKeyGroup *header = _group;
    while ([header group])
        header = [header group];
    if ([header isKindOfClass:[FSHeader class]])
        return (FSHeader*)header;
    return nil;
}


- (void)removeFromHeader
{
    [self setGroup:nil];
}


- (NSArray*)groups
{
    NSMutableArray *groups = [NSMutableArray array];
    FSKeyGroup     *group = _group;
    
    if (group == nil) return nil;
    
    while ([group group]) {
        [groups addObject:group];
        group = [group group];
    }
    
    return groups;
}


- (NSString*)fullPath
{
    NSString   *result = _label;
    FSKeyGroup *group = _group;
    NSString   *label;
    
    if ([result needsQuoting])
        result = [_label wrapInSingleQuotes];
    
    while ([group group]) {
        label = [group label];
        if ([label needsQuoting])
            result = [NSString stringWithFormat:@"'%@'.%@", label, result];
        else
            result = [NSString stringWithFormat:@"%@.%@", label, result];
        group = [group group];
    }
    
    return result;
}


- (NSString*)label
{
    return _label;
}


- (void)setLabel:(NSString*)newLabel
{
    if (newLabel == nil) {
        return;
    }
    if (NO == [newLabel isEqualToString:_label]) {
        FSTable              *table = [[self header] table];
        NSNotificationCenter *nc = [table notificationCenter];

        if ([_group item:self willBeLabeled:newLabel]) {
            NSString             *path = [self fullPath];

            if (nc) {
                SEL                   selector;
                NSMethodSignature    *signature;
                NSInvocation         *invocation;

                selector = @selector(setLabel:forItemWithPath:);
                signature = [FSHeader instanceMethodSignatureForSelector:selector];
                invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setSelector:selector];
                [invocation setArgument:&newLabel atIndex:2];
                [invocation setArgument:&path atIndex:3];
                [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
                                userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];
            }

            [[table undoManager] 
                registerUndoWithTarget:self selector:@selector(setLabel:) object:_label];
            if (nc) {
                [nc postNotificationName:FSTableWillChangeNotification object:table];
                [nc postNotificationName:FSItemWillChangeNotification object:[[self header] table]
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                    self, [self className], newLabel, FSNewNameUserInfo, nil]];
            }
            [newLabel retain];
            [_label release];
            _label = newLabel;
            if (nc) {
                [nc postNotificationName:FSItemDidChangeNotification object:[[self header] table]
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                    self, [self className], path, FSOldPathUserInfo, nil]];
                [nc postNotificationName:FSTableDidChangeNotification object:table];
            }
        } else {
            [nc postNotificationName:FSEditRevertedNotification object:self];
        }
    }
}

//
// Sorting
//

- (NSComparisonResult)smartCompare:(id<FSItem>)otherObject
{
    return [[self label] compare:[otherObject label] options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)smartCompareReverse:(id<FSItem>)otherObject
{
    return -[self smartCompare:otherObject];
}


@end

@implementation FSKey (Archiving)

- (NSDictionary*)dictionaryForArchiving
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[self className] forKey:@"Class"];
    [dict setObject:[self label] forKey:@"Label"];
    
    return dict;
}

@end

