//  $Id: FSExpression.h,v 1.2 2014/01/26 22:32:43 rmottola Exp $
//
//  FSExpression.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 17-MAY-2001.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//                2014, GNUstep Application Team
//  Authors: Stefan Leuker, Riccardo Mottola
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

#import <Foundation/Foundation.h>

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#if !defined(NSUInteger)
#define NSUInteger unsigned
#endif
#if !defined(NSInteger)
#define NSInteger int
#endif
#if !defined(CGFloat)
#define CGFloat float
#endif
#endif

@class FSFormulaSpace, FSTable, FSSelection, FSKeySet;

@interface FSExpression : NSObject 
{
}

// Creation
+ (FSExpression*)expressionWithString:(NSString*)exprString inTable:(FSTable*)table;

- (NSString*)creatorString;

// Evaluation
- (id)formulaValueForKeySet:(FSKeySet*)keySet;

- (FSSelection*)referencedSelectionInFormulaSpace:(FSFormulaSpace*)fs;

@end
