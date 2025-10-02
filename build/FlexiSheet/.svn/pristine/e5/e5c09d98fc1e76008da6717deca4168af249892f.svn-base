//  $Id: KeysetCreationTest.m,v 1.1 2008/10/14 15:04:42 hns Exp $
//
//  KeysetCreationTest.m
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

#import "KeysetCreationTest.h"


@implementation KeysetCreationTest

// Closure

- (void)setUp
{
    document = [[FSTestDocument setupSingleTableExample] retain];
    table = [[document tableWithName:@"Table"] retain];
}

- (void)tearDown
{
    [table release];
    table = nil;
    [document release];
    document = nil;
}

// tests

- (void)testCreationFails
{
    NSDictionary *noKeys = [NSDictionary dictionary];
    NSDictionary *failKeys = [NSDictionary dictionaryWithObject:@"XXX" forKey:@"X"];

    [self assertNil:[FSKeySet keySetWithKeys:nil inTable:nil]];
    [self assertNil:[FSKeySet keySetWithKeys:nil inTable:table]];
    [self assertNil:[FSKeySet keySetWithKeys:noKeys inTable:nil]];
    [self assertNil:[FSKeySet keySetWithKeys:failKeys inTable:table]];
}

- (void)testSuccessfulCreation
{
    NSDictionary *keys = [NSDictionary dictionaryWithObject:@"A1" forKey:@"A"];
    FSHeader     *aHeader = [table headerWithName:@"A"];
    FSKey        *theRightKey = [aHeader keyWithPath:@"A1"];
    FSKeySet     *keyset;

    keyset = [FSKeySet keySetWithKeys:keys inTable:table];
    [self assertNotNil:theRightKey];
    [self assertNotNil:keyset];
    [self assertInt:[keyset count] equals:1];
    [self assert:[keyset table] equals:table];
    // This is awkward.  There's only one key in the key set...
    [self assert:[[keyset objectEnumerator] nextObject] equals:theRightKey];
}

- (void)testCompleteCreation
{
    NSArray      *headers = [NSArray arrayWithObjects:@"A", @"B", nil];
    NSArray      *items = [NSArray arrayWithObjects:@"A1", @"B1", nil];
    NSDictionary *keys = [NSDictionary dictionaryWithObjects:items forKeys:headers];
    FSKeySet     *set = [FSKeySet keySetWithKeys:keys inTable:table];

    [self assertNotNil:set];
    [self assertTrue:[set isComplete]];
}

- (void)testKeySetEdit
{
    NSDictionary *keys = [NSDictionary dictionaryWithObject:@"A1" forKey:@"A"];
    FSKeySet     *set = [FSKeySet keySetWithKeys:keys inTable:table];
    FSHeader     *aHeader = [table headerWithName:@"B"];
    FSKey        *theBeKey = [aHeader keyWithPath:@"B1"];

    [self assertNotNil:set];
    [self assertFalse:[set isComplete]];
    [set addKey:theBeKey];
    [self assertTrue:[set isComplete]];

    set = [FSKeySet keySet];
    [self assertFalse:[set isComplete]];
    [set addKey:theBeKey];
    [self assertFalse:[set isComplete]];
    [self assertInt:[set count] equals:1];
}

- (void)testAddingCategory
{
    NSArray      *headers = [NSArray arrayWithObjects:@"A", @"B", nil];
    NSArray      *items = [NSArray arrayWithObjects:@"A1", @"B1", nil];
    NSDictionary *keys = [NSDictionary dictionaryWithObjects:items forKeys:headers];
    FSKeySet     *set = [FSKeySet keySetWithKeys:keys inTable:table];
    FSHeader     *newHeader = [FSHeader headerNamed:@"C"];

    [newHeader appendKeyWithLabel:@"NEW"];
    
    [self assertNotNil:set];
    [self assertTrue:[set isComplete]];
    [table addHeader:newHeader];
    [self assertFalse:[set isComplete]];
}

- (void)testKeysetCompare
{
    NSDictionary *keys = [NSDictionary dictionaryWithObject:@"A1" forKey:@"A"];
    FSKeySet     *set1 = [FSKeySet keySetWithKeys:keys inTable:table];
    FSKeySet     *set2 = [FSKeySet keySet];
    FSHeader     *aHeader = [table headerWithName:@"A"];
    FSKey        *theAKey = [aHeader keyWithPath:@"A1"];
    FSHeader     *bHeader = [table headerWithName:@"B"];
    FSKey        *theBeKey = [bHeader keyWithPath:@"B1"];

    [self assertNotNil:set1];
    [self assertFalse:[set1 isComplete]
              message:[NSString stringWithFormat:@"Keyset %@ should not be complete.", set1]];
    
    [set1 addKey:theBeKey];
    [self assertTrue:[set1 isComplete]
             message:[NSString stringWithFormat:@"Keyset %@ should be complete.", set1]];

    [self assertNotNil:set2];
    [set2 addKey:theBeKey];
    [self assertFalse:[set1 isEqual:set2]
              message:[NSString stringWithFormat:@"Keyset %@ shouldn't be equal to %@.", set1, set2]];
    [set2 addKey:theAKey];
    [self assertTrue:[set1 isEqual:set2]
             message:[NSString stringWithFormat:@"Keyset %@ should be equal to %@.", set1, set2]];
}

@end
