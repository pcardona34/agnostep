//  $Id: SortingTests.m,v 1.1 2008/10/14 15:04:43 hns Exp $
//
//  SortingTests.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 27-APR-2002.
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

#import "SortingTests.h"


@implementation SortingTests

// Closure

- (void)setUp
{
    document = [[FSTestDocument setupSingleTableExample] retain];
    header = [[[document tableWithName:@"Table"] headerWithName:@"A"] retain];
    [header setLabel:@"TestLabel"];
    zzz = [header appendKeyWithLabel:@"ZZZ"];
    ccc1 = [header appendKeyWithLabel:@"ccc1"];
    ccc2 = [header appendKeyWithLabel:@"CcC2"];
    ddd = [header appendKeyWithLabel:@"DDD"];
}

- (void)tearDown
{
    [header release];
    header = nil;
    [document release];
    document = nil;
}

// tests

- (void)testItemSorting
{
    NSArray *items;
    
    [header sortItemsByName];

    items = [header items];
    [self assert:[[items lastObject] label] equals:@"ZZZ"];
    [self assertTrue:([items indexOfObject:ccc1] < [items indexOfObject:ccc2])];
    [self assertTrue:([items indexOfObject:zzz] > [items indexOfObject:ddd])];
}

- (void)testReverseItemSorting
{
    NSArray *items;
    
    [header sortItemsByName:NO];

    items = [header items];
    [self assert:[[items lastObject] label] equals:@"A1"];
    [self assertFalse:([items indexOfObject:ccc1] < [items indexOfObject:ccc2])];
    [self assertTrue:([items indexOfObject:ddd] > [items indexOfObject:zzz])];
}

@end
