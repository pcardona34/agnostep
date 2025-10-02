//  $Id: FSTable.h,v 1.1 2008/10/14 15:04:23 hns Exp $
//
//  FSTable.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 10-SEP-2001.
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

#import <Foundation/Foundation.h>
#import <FSCore/FSDocumentProtocol.h>
#import <FSCore/FSTypes.h>

@class FSHashMap;
@class FSHeader, FSKey, FSKeySet, FSValue;
@class FSSelection, FSFormula, FSFormulaSpace;

@interface FSTable : NSObject
{
@private
    NSMutableArray      *_headers;   /*" The categories. Type: FSHeader "*/
    FSHashMap           *_values;    /*" All values in the sheet. Type: FSValue "*/
    FSFormulaSpace      *_formulaSpace;  /*" Storage for formulae "*/

    id<FSDocument>       _document;  /*" Description forthcoming. "*/
    NSString            *_name;      /*" The table's name. "*/
    NSData              *_comment;   /*" An RTF comment entered by the user. "*/
    BOOL                 _postNotifications;

    NSMutableArray      *_keysets;   /*" used for scripting "*/
}

// Attributes
- (NSString*)name;
- (void)setName:(NSString*)name;

- (NSData*)comment;
- (void)setComment:(NSData*)comment;

- (id<FSDocument>)document;
- (void)setDocument:(id<FSDocument>)document;

- (NSUndoManager*)undoManager;
- (NSNotificationCenter*)notificationCenter;
- (BOOL)shouldPostNotifications;
- (void)setShouldPostNotifications:(BOOL)flag;

// Header management
- (NSArray*)headers;
- (int)indexOfHeader:(FSHeader*)header;
- (void)addHeader:(FSHeader*)newHeader;
- (void)removeHeader:(FSHeader*)aHeader;
- (NSString*)nextAvailableHeaderName;

- (FSHeader*)headerWithName:(NSString*)name;
- (NSArray*)headersWithNames:(NSArray*)names;

- (NSArray*)keySetsForHeaders:(NSArray*)headers;

// Value management
- (FSValue*)valueForKeySet:(FSKeySet*)keySet;
- (FSValue*)setValue:(id)value forKeySet:(FSKeySet*)keySet;
- (void)_revalidateAllExistingValues;

// Copy/Paste
- (NSArray*)valuesInSelection:(FSSelection*)selection;
- (void)setValues:(NSArray*)values inSelection:(FSSelection*)selection;

@end

@interface FSTable (Formula)

// Formula Methods
- (NSArray*)formulae;
- (void)addFormula:(NSString*)aFormula;
- (void)insertFormula:(NSString*)aFormula atIndex:(int)index;
- (void)removeFormula:(FSFormula*)aFormula;
- (void)moveFormulaAtIndex:(int)idx1 toIndex:(int)idx2;
- (void)recalculateFormulaSpace;
- (void)disableRecalculation;
- (void)enableRecalculation;
- (void)setCreator:(NSString*)creator forFormula:(FSFormula*)formula;

@end

@interface FSTable (ParsingAdditions)

- (NSArray*)groupsForString:(NSString*)string;
- (NSArray*)keysForString:(NSString*)string;

@end

@interface FSTable (Find)

- (NSArray*)keysetsContainingStringValue:(NSString*)value;

@end

@interface FSTable (Archiving)

- (NSDictionary*)dictionaryForArchiving;
- (BOOL)loadFromDictionary:(NSDictionary*)dictionary;

@end

//
// Notification names
//

extern NSString* FSTableWillChangeNotification;
extern NSString* FSTableDidChangeNotification;
extern NSString* FSItemWillChangeNotification;
extern NSString* FSItemDidChangeNotification;
extern NSString* FSValueDidChangeNotification;
extern NSString* FSEditRevertedNotification;

extern NSString* FSNewNameUserInfo;
extern NSString* FSOldPathUserInfo;
