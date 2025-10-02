//  $Id: FSGlobalHeader.m,v 1.1 2008/10/14 15:04:19 hns Exp $
//
//  FSGlobalHeader.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 19-OCT-2001.
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

#import "FSGlobalHeader.h"
#import "FSHeader.h"
#import "FoundationExtentions.h"

NSString     *FSHeaderDidChangeNotification = @"FSHeaderDidChange";

@implementation FSGlobalHeader
/*" FSGlobalHeader is a means to group headers of different tables so that
    they appear as one.  Changes in one header are automatically reflected
    in the other headers. 
    "*/

- (id)init
{
    self = [super init];
    if (self) {
        _headers = [[NSMutableArray alloc] init];
        _propagating = NO;
    }
    return self;
}


- (void)headerDidChange:(NSNotification*)notification
{
    FSHeader      *changedHeader = [notification object];
    NSInvocation  *invocation = [[notification userInfo] objectForKey:@"Invoke"];
    NSEnumerator  *cursor;
    FSHeader      *header;
    
    if (_propagating) return;
    _propagating = YES;
    cursor = [_headers objectEnumerator];
    while ((header = [cursor nextObject])) {
        if (header != changedHeader) {
            [invocation setTarget:header];
            [invocation invoke];
        }
    }
    _propagating = NO;
}


- (void)addHeader:(FSHeader*)aHeader
/*" This method adds aHeader to the list of grouped headers. "*/
{
    [_headers addObject:aHeader];
    [aHeader setGlobalHeader:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(headerDidChange:)
        name:FSHeaderDidChangeNotification
        object:aHeader];
}


- (void)removeHeader:(FSHeader*)aHeader
/*" This method removes aHeader from the list of grouped headers. "*/
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:FSHeaderDidChangeNotification object:aHeader];
    [aHeader setGlobalHeader:nil];
    [_headers removeObject:aHeader];
}


- (void)removeAllHeaders
/*" This method removes all headers from this group.
    Should be called before releasing to break retain cycles."*/
{
    [_headers iteratePerformSelector:@selector(removeHeader:) target:self];
}


- (FSHeader*)linkedHeaderInTable:(FSTable*)table
{
    int idx = [_headers count];
    id  hdr;
    
    while (idx-- > 0) {
        hdr = [_headers objectAtIndex:idx];
        if ([hdr table] == table)
            return hdr;
    }
    
    return nil;
}


- (void)dealloc
{
    [_headers release];
    [super dealloc];
}

@end
