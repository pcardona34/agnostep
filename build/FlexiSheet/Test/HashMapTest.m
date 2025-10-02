//  $Id: HashMapTest.m,v 1.1 2008/10/14 15:04:41 hns Exp $
//
//  HashMapTest.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-APR-2002.
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

#import "HashMapTest.h"
#import <FSHashMap.h>

@implementation HashMapTest

- (void)setUp
{
    map = [[FSHashMap alloc] init];
    [map setObject:@"this" forKey:"this"];
    [map setObject:@"that" forKey:"that"];
    [map setObject:@"one"  forKey:"1"];
    [map setObject:@"twos" forKey:"2222222222"];
}

- (void)tearDown
{
    [map release];
    map = nil;
}

//
//
//

- (void)testReturnsNilForUnboundKey
{
    FSHashMap *mymap = [FSHashMap hashMap];

    [self assertNil:[mymap objectForKey:"00000000"]];
}


- (void)testReturnsCorrectObject
{
    NSDictionary  *someObject = [NSDictionary dictionary];
    FSHashKey      key = "00000000";

    [self assertTrue:([[map allObjects] count] == 4)];
    
    [map setObject:someObject forKey:key];

    [self assertTrue:([[map allObjects] count] == 5)];

    [self assertNotNil:[map objectForKey:key]];

    [self assert:[map objectForKey:"1"] equals:@"one"];
}


- (void)testDeletionWorks
{
    FSHashKey key = "1";
    
    [self assertTrue:([[map allObjects] count] == 4)];
    [self assert:[map objectForKey:key] equals:@"one"];
    [map removeObjectForKey:key];
    [self assertNil:[map objectForKey:key]];
    [self assertTrue:([[map allObjects] count] == 3)];
}


- (void)testPerformance
{
    int       i;
    char      key[33];
    NSString *value =  [NSMutableString stringWithString:@"bla"];

    for (i = 0; i < 2000; i++) {
        sprintf(key, "%16lX", random());
        [map setObject:value forKey:key];
    }

    //printf("[Elements in hashmap: %i]", [map count]);

    [map removeAllObjects];
    [self assertTrue:([map count] == 0)];
}

@end
