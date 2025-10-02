//  $Id: LinkedCategoriesTest.m,v 1.1 2008/10/14 15:04:42 hns Exp $
//
//  LinkedCategoriesTest.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 14-MAR-2003.
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

#import "LinkedCategoriesTest.h"

@implementation LinkedCategoriesTest

- (void)setUp
{
    document = [[FSTestDocument setupLinkedTableExample] retain];
    table = [document tableWithName:@"Table"];
    clone = [document tableWithName:@"Clone"];
    groupA = [table headerWithName:@"Linked"];
    groupB = [table headerWithName:@"B"];
    linkedHeader = [clone headerWithName:@"Linked"];
}

- (void)tearDown
{
    table = nil;
    clone = nil;
    groupA = nil;
    groupB = nil;
    linkedHeader = nil;
    [document release];
    document = nil;
}

- (void)testBasicLinkingWorks
{
    [groupA setLabel:@"Test"];
    [self assert:[linkedHeader label] equals:@"Test"];
    [groupA appendKeyWithLabel:@"TestLabel"];
    [self assertNotNil:[linkedHeader keyWithLabel:@"TestLabel"]];
}

- (void)testGroupsInLinkedHeaders
{
    FSKeyGroup *testGroupA;
    FSKeyGroup *testGroupLinked;
    NSRange groupRange = NSMakeRange(0,2);
    int gAKeyCount = [[groupA items] count];
    [self assertInt:gAKeyCount equals:[[linkedHeader items] count]];
    testGroupA = [groupA groupItemsInRange:groupRange withLabel:@"TestGroup"];
    testGroupLinked = [linkedHeader itemWithLabel:@"TestGroup"];
    [self assertNotNil:testGroupLinked];
    // now modify the new group
    [testGroupA appendKeyWithLabel:@"NEW"];
    [self assertNotNil:[testGroupLinked keyWithLabel:@"NEW"]];
    // group rename
    [testGroupA setLabel:@"CHANGED"];
    [self assert:[testGroupLinked label] equals:@"CHANGED"];
}

@end
