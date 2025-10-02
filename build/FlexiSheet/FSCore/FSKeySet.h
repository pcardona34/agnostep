//  $Id: FSKeySet.h,v 1.2 2014/01/26 09:23:53 buzzdee Exp $
//
//  FSKeySet.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-JAN-2001.
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

#import <FSCore/FSTypes.h>

@class FSValue, FSKey, FSKeyGroup, FSHeader, FSTable;


@interface FSKeySet : NSObject {
    @public
    FSkeyset          _data;

    @private
        FSTable          *_cachedTable;
    NSArray          *_cachedAllKeys;
}

// Creating and building FSKeySet objects
+ (FSKeySet*)keySet;
+ (FSKeySet*)keySet:(FSkeyset*)keyset;
+ (FSKeySet*)keySetWithKey:(FSKey*)key;
+ (FSKeySet*)keySetWithKeys:(NSArray*)keys;

+ (FSKeySet*)keySetWithKeys:(NSDictionary*)keys inTable:(FSTable*)table;

- (void)addKey:(FSKey*)aKey;
- (void)addKeys:(FSKeySet*)keys;
- (void)addKeysFromArray:(NSArray*)keys;

- (void)copyKeys:(FSKeySet*)otherSet;

- (FSKeySet*)setByAddingKey:(FSKey*)aKey;
- (FSKeySet*)setBySubstitutingKey:(FSKey*)aKey;
- (FSKeySet*)setBySubstitutingKeys:(FSKeySet*)keySet;
- (FSKeySet*)setByAddingKeys:(FSKeySet*)otherKeys;

// Attributes
- (BOOL)isValid;
- (BOOL)isComplete;
- (FSHashKey)hashcode;
- (NSUInteger)count;
- (NSEnumerator*)objectEnumerator;

// Convenience methods
- (FSTable*)table;
- (FSKey*)keyForHeader:(FSHeader*)header;
- (FSKey*)keyForGroup:(FSKeyGroup*)group;
- (FSValue*)value;

// Misc
- (NSString*)description;
- (FSKeySet*)setInLinkedTable:(FSTable*)table;

@end

@interface FSKeySet (Archiving)

- (NSDictionary*)dictionaryForArchiving;

@end

//
// FSkeyset functions
//

void FSkeysetAddKey(FSkeyset *ks, FSKey *key);
void FSkeysetCopyKeys(FSkeyset *ks, FSkeyset *otherSet);
void FSkeysetRevalidate(FSkeyset *ks);
void FSkeysetGenerateHashcode(FSkeyset *ks);
void FSkeysetDealloc(FSkeyset *ks);
