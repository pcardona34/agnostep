/*
**  Filter.h
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_Filter
#define _GNUMail_H_Filter

#import <AppKit/AppKit.h>

// criteria source
#define NONE     0
#define TO       1
#define CC       2
#define TO_OR_CC 3
#define SUBJECT  4
#define FROM     5
#define EXPERT   6

// External program operation
#define AFTER_CRITERIA  1
#define BEFORE_CRITERIA 2

// Criteria condition
#define AND 1
#define OR  2

// Criteria find operations
#define CONTAINS                 1
#define IS_EQUAL                 2
#define HAS_PREFIX               3
#define HAS_SUFFIX               4
#define MATCH_REGEXP             5
#define IS_IN_ADDRESS_BOOK       6
#define IS_IN_ADDRESS_BOOK_GROUP 7

// Actions
#define SET_COLOR                  1
#define TRANSFER_TO_FOLDER         2
#define BOUNCE_OR_FORWARD_OR_REPLY 3
#define DELETE                     4
#define PLAY_SOUND                 5

// E-Mail operations
#define BOUNCE  1
#define FORWARD 2
#define REPLY   3

// Filter type
#define TYPE_INCOMING 1
#define TYPE_OUTGOING 2
#define TYPE_INCOMING_QUICK 3 /* For matchedFilterForMessage:type: only */


@interface Filter: NSObject <NSCoding, NSCopying>
{
  @private
    BOOL _isActive;
    NSString *_description;
  
    int _type;

    BOOL _useExternalProgram;
    NSString *_externalProgramName;
    int _externalProgramOperation;

    NSMutableArray *_allCriterias;

    int _action;
    NSColor *_actionColor;
    NSString *_actionFolderName;
    int _actionEMailOperation;
    NSString *_actionEMailString;
    NSString *_actionMessageString;

    NSString *_pathToSound;
}

//
// access/mutation methods
//
- (BOOL) isActive;
- (void) setIsActive: (BOOL) theBOOL;

- (NSString *) description;
- (void) setDescription: (NSString *) theDescription;

- (int) type;
- (void) setType: (int) theType;

- (BOOL) useExternalProgram;
- (void) setUseExternalProgram: (BOOL) theBOOL;

- (NSString *) externalProgramName;
- (void) setExternalProgramName: (NSString *) theExternalProgramName;

- (int) externalProgramOperation;
- (void) setExternalProgramOperation: (int) theExternalProgramOperation;

- (NSArray *) allCriterias;
- (void) setCriterias: (NSArray *) theCriterias;

- (int) action;
- (void) setAction: (int) theAction;

- (NSColor *) actionColor;
- (void) setActionColor: (NSColor *) theActionColor;

- (NSString *) actionFolderName;
- (void) setActionFolderName: (NSString *) theActionFolderName; 

- (int) actionEMailOperation;
- (void) setActionEMailOperation: (int) theActionEMailOperation;

- (NSString *) actionEMailString;
- (void) setActionEMailString: (NSString *) theActionEMailString;

- (NSString *) actionMessageString;
- (void) setActionMessageString: (NSString *) theActionMessageString;

- (NSString *) pathToSound;
- (void) setPathToSound: (NSString *) thePath;

@end


//
//
//
@interface FilterCriteria : NSObject <NSCoding, NSCopying>
{
  @private
    NSArray *_criteriaHeaders;
    NSString *_criteriaString;

    int _criteriaFindOperation;
    int _criteriaCondition;
    int _criteriaSource;
}

//
// access / mutation methods
//
- (int) criteriaCondition;
- (void) setCriteriaCondition: (int) theCriteriaCondition;

- (int) criteriaSource;
- (void) setCriteriaSource: (int) theCriteriaSource;

- (NSArray *) criteriaHeaders;
- (void) setCriteriaHeaders: (NSArray *) theCriteriaHeaders;

- (int) criteriaFindOperation;
- (void) setCriteriaFindOperation: (int) theCriteriaFindOperation;

- (NSString *) criteriaString;
- (void) setCriteriaString: (NSString *) theCriteriaString;

@end

#endif // _GNUMail_H_Filter
