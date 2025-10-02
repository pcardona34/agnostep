//  $Id: FSFinancialFunctions.h,v 1.1 2008/10/14 15:04:26 hns Exp $
//
//  FSFinancialFunctions.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 20-OCT-2001.
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

@class FSVariable;

@interface FSPaymentFunction : FSFunction
{
    FSVariable     *_principal;
    FSVariable     *_interest;
    FSVariable     *_term;
}
@end


@interface FSCtermFunction : FSFunction
{
    FSVariable     *_interest;
    FSVariable     *_fVal;
    FSVariable     *_pVal;
}
@end


@interface FSDdbFunction : FSFunction
{
}

@end


@interface FSFvFunction : FSFunction
{
    FSVariable     *_payment;
    FSVariable     *_interest;
    FSVariable     *_term;
}
@end


@interface FSIrrFunction : FSFunction
{
}

@end


@interface FSNpvFunction : FSFunction
{
    FSVariable     *_interest;
    FSVariable     *_range;
}
@end


@interface FSRateFunction : FSFunction
{
    FSVariable     *_fVal;
    FSVariable     *_pVal;
    FSVariable     *_term;
}
@end


@interface FSSlnFunction : FSFunction
{
}

@end


@interface FSSydFunction : FSFunction
{
}

@end


@interface FSTermFunction : FSFunction
{
}

@end
