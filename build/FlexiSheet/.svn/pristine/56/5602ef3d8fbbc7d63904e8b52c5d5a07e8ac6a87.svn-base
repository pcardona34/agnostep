//  $Id: FSEqualOperator.m,v 1.2 2009/01/25 15:10:00 rmottola Exp $
//
//  FSEqualOperator.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 05-OCT-2001.
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

#import <FSCore/FSFormulaSpace.h>
#import "FSEqualOperator.h"
#import "FSLog.h"

@implementation FSEqualOperator

+ (void)initialize
{
    [FSOperator registerOperator:self];
}

+ (NSString*)operatorSymbol
{
    return @"=";
}

- (int)compareForKeySet:(FSKeySet*)ks
{
    id first = [_firstArgument formulaValueForKeySet:ks];
    id second = [_secondArgument formulaValueForKeySet:ks];
    int result;
    /*
     [FSLog logDebug:@"%@(%@) vs %@(%@)",
         [first description], [first className],
         [second description], [second className]];
     */
    NS_DURING
        result = [(NSNumber*)first compare:second];
    NS_HANDLER
        result = -2;
    NS_ENDHANDLER
    return result;
}


- (id)formulaValueForKeySet:(FSKeySet*)ks
{
    return [NSNumber numberWithBool:([self compareForKeySet:ks] == 0)];
}

@end


@implementation FSLTEqualOperator

+ (void)initialize
{
    [FSOperator registerOperator:self];
}

+ (NSString*)operatorSymbol
{
    return @"<=";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
{
    int comp = [self compareForKeySet:ks];
    return [NSNumber numberWithBool:(comp == 0)||(comp == -1)];
}

@end


@implementation FSGTEqualOperator

+ (void)initialize
{
    [FSOperator registerOperator:self];
}

+ (NSString*)operatorSymbol
{
    return @">=";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
{
    return [NSNumber numberWithBool:([self compareForKeySet:ks] > -1)];
}

@end


@implementation FSLTOperator

+ (void)initialize
{
    [FSOperator registerOperator:self];
}

+ (NSString*)operatorSymbol
{
    return @"<";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
{
    return [NSNumber numberWithBool:([self compareForKeySet:ks] == -1)];
}

@end


@implementation FSGTOperator

+ (void)initialize
{
    [FSOperator registerOperator:self];
}

+ (NSString*)operatorSymbol
{
    return @">";
}

- (id)formulaValueForKeySet:(FSKeySet*)ks
{
    return [NSNumber numberWithBool:([self compareForKeySet:ks] == 1)];
}

@end
