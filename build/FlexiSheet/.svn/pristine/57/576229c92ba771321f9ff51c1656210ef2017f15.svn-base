//  $Id: CellTest.m,v 1.1 2008/10/14 15:04:39 hns Exp $
//
//  CellTest.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 22-FEB-2002.
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

#import "CellTest.h"


@implementation CellTest

// Closure

- (void)setUp
{
    NSMutableDictionary *keys = [NSMutableDictionary dictionary];

    document = [[FSTestDocument setupSingleTableExample] retain];
    table = [[document tableWithName:@"Table"] retain];
    //
    // Create all the keysets
    //
    [keys setObject:@"A1" forKey:@"A"];
    [keys setObject:@"B1" forKey:@"B"];
    a1b1 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    [keys setObject:@"B2" forKey:@"B"];
    a1b2 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    [keys setObject:@"B3" forKey:@"B"];
    a1b3 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    [keys setObject:@"A2" forKey:@"A"];
    a2b3 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    [keys setObject:@"B2" forKey:@"B"];
    a2b2 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    [keys setObject:@"B1" forKey:@"B"];
    a2b1 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    [keys setObject:@"A3" forKey:@"A"];
    a3b1 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    [keys setObject:@"B2" forKey:@"B"];
    a3b2 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    [keys setObject:@"B3" forKey:@"B"];
    a3b3 = [[FSKeySet keySetWithKeys:keys inTable:table] retain];
    //
    // Fill in the values
    //
    [[a1b1 value] setValue:@"Hallo"];
    [[a1b2 value] setValue:@"Alpha"];
    [[a2b1 value] setValue:[NSNumber numberWithDouble:-1]];
    [[a2b2 value] setValue:[NSNumber numberWithDouble:+1]];
    [[a3b1 value] setValue:[NSNumber numberWithDouble:+1]];
    [[a3b2 value] setValue:[NSNumber numberWithDouble:+1]];
}

- (void)tearDown
{
    [a1b1 release];
    a1b1 = nil;
    [a1b2 release];
    a1b2 = nil;
    [a1b3 release];
    a1b3 = nil;
    [a2b1 release];
    a2b1 = nil;
    [a2b2 release];
    a2b2 = nil;
    [a2b3 release];
    a2b3 = nil;
    [a3b1 release];
    a3b1 = nil;
    [a3b2 release];
    a3b2 = nil;
    [a3b3 release];
    a3b3 = nil;
    [table release];
    table = nil;
    [document release];
    document = nil;
}

- (void)testEverythingSetupRight
{
    [self assertNotNil:a1b1];
    [self assertNotNil:a1b2];
    [self assertNotNil:a1b3];
    [self assertNotNil:a2b1];
    [self assertNotNil:a2b2];
    [self assertNotNil:a2b3];
    [self assertNotNil:a3b1];
    [self assertNotNil:a3b2];
    [self assertNotNil:a3b3];
}

@end
