//  $Id: FSHeader.h,v 1.1 2008/10/14 15:04:20 hns Exp $
//
//  FSHeader.h
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

#import <FSCore/FSKeyGroup.h>

@class FSDocument, FSTable, FSGlobalHeader, FSKey;

@interface FSHeader : FSKeyGroup
{
    FSTable         *_table;     /*" The table this header belongs to.  Not retained! "*/
    FSGlobalHeader  *_global;    /*" The global header this one belongs to.  Usually nil. "*/
}

// Creation
+ (FSHeader*)headerNamed:(NSString*)aName;

// Attributes
- (void)setTable:(FSTable*)table;

// Cloning
- (FSHeader*)cloneForTable:(FSTable*)otherTable;
- (FSHeader*)linkedHeaderInTable:(FSTable*)table;
- (FSGlobalHeader*)globalHeader;
- (void)setGlobalHeader:(FSGlobalHeader*)globalHeader;

@end

@interface FSKeyGroup (Archiving)

- (NSDictionary*)dictionaryForArchiving;

@end
