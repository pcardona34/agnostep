/*
**  Filter.m
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
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

#import "Filter.h"

#import "Constants.h"

static int currentFilterVersion = 4;

//
//
//
@implementation Filter

- (id) init
{
  FilterCriteria *aFilterCriteria;

  self = [super init];
  if (self)
    {
      [Filter setVersion: currentFilterVersion];

      [self setIsActive: YES];
      [self setDescription: @""];
      [self setType: TYPE_INCOMING];

      // We initialize our 3 filter criterias
      _allCriterias = [[NSMutableArray alloc] init];
  
      aFilterCriteria = [[FilterCriteria alloc] init];
      [_allCriterias addObject: aFilterCriteria];
      RELEASE(aFilterCriteria);

      aFilterCriteria = [[FilterCriteria alloc] init];
      [aFilterCriteria setCriteriaSource: NONE];
      [_allCriterias addObject: aFilterCriteria];
      RELEASE(aFilterCriteria);

      aFilterCriteria = [[FilterCriteria alloc] init];
      [aFilterCriteria setCriteriaSource: NONE];
      [_allCriterias addObject: aFilterCriteria];
      RELEASE(aFilterCriteria);

  
      // We initialize the rest of our ivars
      [self setAction: SET_COLOR];
      [self setActionColor: [NSColor lightGrayColor]];
      [self setActionFolderName: @""];
      [self setActionEMailOperation: BOUNCE];
      [self setActionEMailString: @""];
      [self setActionMessageString: @""];
      [self setExternalProgramName: @""];
      [self setPathToSound: @""];
    }
  
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_description);
  RELEASE(_externalProgramName);
  RELEASE(_allCriterias);
  RELEASE(_actionColor);
  RELEASE(_actionFolderName);
  RELEASE(_actionEMailString);
  RELEASE(_actionMessageString);
  RELEASE(_pathToSound);  
  [super dealloc];
}


//
// NSCoding protocol
//
- (void) encodeWithCoder: (NSCoder *) theCoder
{
  [Filter setVersion: currentFilterVersion];

  [theCoder encodeObject: [NSNumber numberWithBool: [self isActive]]];
  [theCoder encodeObject: [self description] ];

  [theCoder encodeObject: [NSNumber numberWithInt: [self type]]];

  [theCoder encodeObject: [NSNumber numberWithBool: [self useExternalProgram]]];
  [theCoder encodeObject: [self externalProgramName] ];
  [theCoder encodeObject: [NSNumber numberWithInt: [self externalProgramOperation]]];

  [theCoder encodeObject: [self allCriterias]];
  
  [theCoder encodeObject: [NSNumber numberWithInt: [self action]]];
  [theCoder encodeObject: [self actionColor]];
  [theCoder encodeObject: [self actionFolderName]];
  [theCoder encodeObject: [NSNumber numberWithInt: [self actionEMailOperation]]];
  [theCoder encodeObject: [self actionEMailString]];
  [theCoder encodeObject: [self actionMessageString]];

  [theCoder encodeObject: [self pathToSound]];
}

- (id) initWithCoder: (NSCoder *) theCoder
{
  int version;
  
  version = [theCoder versionForClassName: NSStringFromClass([self class])];
  //NSDebugLog(@"Filter's Version number = %d", version);

  self = [super init];

  // NOTE: After Version 1.0.1 of GNUMail, we removed the support for version 0 and 1
  //       of the filters.
  //       After 1.1.0pre1, we removed support for version 2.
  if (version >= 3)
    {
      [self setIsActive: [[theCoder decodeObject] boolValue]];
      [self setDescription: [theCoder decodeObject]];

      [self setType: [[theCoder decodeObject] intValue]];

      [self setUseExternalProgram: [[theCoder decodeObject] boolValue]];
      [self setExternalProgramName: [theCoder decodeObject]];
      [self setExternalProgramOperation: [[theCoder decodeObject] intValue]];
      
      [self setCriterias: [theCoder decodeObject]];
      
      [self setAction: [[theCoder decodeObject] intValue]];
      [self setActionColor: [theCoder decodeObject]];
      [self setActionFolderName: [theCoder decodeObject]];
      [self setActionEMailOperation: [[theCoder decodeObject] intValue]];
      [self setActionEMailString: [theCoder decodeObject]];
      [self setActionMessageString: [theCoder decodeObject]];

      if (version == 4)
	{
	  [self setPathToSound: [theCoder decodeObject]];
	}
    }
  else
    {
      [NSException raise: NSInternalInconsistencyException
		   format: @"Filter cache error. Ignoring all entries."];
    }

  return self;
}


//
// NSCopying protocol
//
- (id) copyWithZone: (NSZone *) zone
{
  NSArray *criterias;
  Filter *aFilter;

  aFilter = [[Filter allocWithZone:zone] init];

  [aFilter setIsActive: [self isActive]];
  [aFilter setDescription: [self description]];

  [aFilter setType: [self type]];

  [aFilter setUseExternalProgram: [self useExternalProgram]];
  [aFilter setExternalProgramName: [self externalProgramName]];
  [aFilter setExternalProgramOperation: [self externalProgramOperation]];
  
  // We MUST copy all criterias
  criterias = [[NSArray alloc] initWithArray: [self allCriterias]
			       copyItems: YES];
  [aFilter setCriterias: criterias];
  RELEASE(criterias);

  [aFilter setAction: [self action]];
  [aFilter setActionColor: [self actionColor]];
  [aFilter setActionFolderName: [self actionFolderName]];
  [aFilter setActionEMailOperation: [self actionEMailOperation]];
  [aFilter setActionEMailString: [self actionEMailString]];
  [aFilter setActionMessageString: [self actionMessageString]];
  [aFilter setPathToSound: [self pathToSound]];
  
  return aFilter;
}


//
// access/mutation methods
//
- (BOOL) isActive
{
  return _isActive;
}


- (void) setIsActive: (BOOL) theBOOL
{
  _isActive = theBOOL;
}


//
//
//
- (NSString *) description
{
  return _description;
}

- (void) setDescription: (NSString *) theDescription
{
  ASSIGN(_description, theDescription);
}


//
//
//
- (int) type
{
  return _type;
}

- (void) setType: (int) theType
{
  _type = theType;
}


//
//
//
- (BOOL) useExternalProgram
{
  return _useExternalProgram;
}

- (void) setUseExternalProgram: (BOOL) theBOOL
{
  _useExternalProgram = theBOOL;
}


//
//
//
- (NSString *) externalProgramName
{
  return _externalProgramName;
}

- (void) setExternalProgramName: (NSString *) theExternalProgramName
{
  ASSIGN(_externalProgramName, theExternalProgramName);
}


//
//
//
- (int) externalProgramOperation
{
  return _externalProgramOperation;
}

- (void) setExternalProgramOperation: (int) theExternalProgramOperation
{
  _externalProgramOperation = theExternalProgramOperation;
}


//
//
//
- (NSArray *) allCriterias
{
  return [NSArray arrayWithArray: _allCriterias];
}

- (void) setCriterias: (NSArray *) theCriterias
{
  RELEASE(_allCriterias);
  _allCriterias = [[NSMutableArray alloc] initWithArray: theCriterias];
}


//
//
//
- (int) action
{
  return _action;
}

- (void) setAction: (int) theAction
{
  _action = theAction;
}


//
//
//
- (NSColor *) actionColor
{
  return _actionColor;
}

- (void) setActionColor: (NSColor *) theActionColor
{
  ASSIGN(_actionColor, theActionColor);
}


//
//
//
- (NSString *) actionFolderName
{
  return _actionFolderName;
}

- (void) setActionFolderName: (NSString *) theActionFolderName
{
  ASSIGN(_actionFolderName, theActionFolderName);
}


//
//
//
- (int) actionEMailOperation
{
  return _actionEMailOperation;
}

- (void) setActionEMailOperation: (int) theActionEMailOperation
{
  _actionEMailOperation = theActionEMailOperation;
}


//
//
//
- (NSString *) actionEMailString
{
  return _actionEMailString;
}

- (void) setActionEMailString: (NSString *) theActionEMailString
{
  ASSIGN(_actionEMailString, theActionEMailString);
}


//
//
//
- (NSString *) actionMessageString
{
  return _actionMessageString;
}

- (void) setActionMessageString: (NSString *) theActionMessageString
{
  ASSIGN(_actionMessageString, theActionMessageString);
}


//
//
//
- (NSString *) pathToSound
{
  return _pathToSound;
}

- (void) setPathToSound: (NSString *) thePath
{
  ASSIGN(_pathToSound, thePath);
}

@end



//
//
//
@implementation FilterCriteria

- (id) init
{
  self = [super init];
  
  [self setCriteriaCondition: AND];
  [self setCriteriaSource: NONE];
  [self setCriteriaHeaders: [NSArray array]];
  [self setCriteriaFindOperation: CONTAINS];
  [self setCriteriaString: @""];

  return self;
}

- (void) dealloc
{
  RELEASE(_criteriaHeaders);
  RELEASE(_criteriaString);
  [super dealloc];
}


//
// NSCoding protocol
//
- (void) encodeWithCoder: (NSCoder *) theCoder
{
  [theCoder encodeObject: [NSNumber numberWithInt: [self criteriaCondition]]];
  [theCoder encodeObject: [NSNumber numberWithInt: [self criteriaSource]]];
  [theCoder encodeObject: [self criteriaHeaders]];
  [theCoder encodeObject: [NSNumber numberWithInt: [self criteriaFindOperation]]];
  [theCoder encodeObject: [self criteriaString]];
}


- (id) initWithCoder: (NSCoder *) theCoder
{
  self = [super init];
  
  [self setCriteriaCondition: [[theCoder decodeObject] intValue]];
  [self setCriteriaSource: [[theCoder decodeObject] intValue]];
  [self setCriteriaHeaders: [theCoder decodeObject]];
  [self setCriteriaFindOperation: [[theCoder decodeObject] intValue]];
  [self setCriteriaString: [theCoder decodeObject] ];

  return self;
}


//
// NSCopying protocol
//
- (id) copyWithZone: (NSZone *) zone
{
  FilterCriteria *aFilterCriteria;
  NSArray *headers;

  aFilterCriteria = [[FilterCriteria alloc] init];

  [aFilterCriteria setCriteriaCondition: [self criteriaCondition]];
  [aFilterCriteria setCriteriaSource: [self criteriaSource]];

  // We MUST copy the headers
  headers = [[NSArray alloc] initWithArray: [self criteriaHeaders]
			     copyItems: YES];
  [aFilterCriteria setCriteriaHeaders: headers];
  RELEASE(headers);

  [aFilterCriteria setCriteriaFindOperation: [self criteriaFindOperation]];
  [aFilterCriteria setCriteriaString: AUTORELEASE([[self criteriaString] copy]) ];

  return aFilterCriteria;
}



//
// access / mutation methods
//
- (int) criteriaCondition
{
  return _criteriaCondition;
}

- (void) setCriteriaCondition: (int) theCriteriaCondition
{
  _criteriaCondition = theCriteriaCondition;
}


//
//
//
- (int) criteriaSource
{
  return _criteriaSource;
}

- (void) setCriteriaSource: (int) theCriteriaSource
{
  _criteriaSource = theCriteriaSource;
}


//
//
//
- (NSArray *) criteriaHeaders
{
  return _criteriaHeaders;
}

- (void) setCriteriaHeaders: (NSArray *) theCriteriaHeaders
{
  ASSIGN(_criteriaHeaders, theCriteriaHeaders);
}


//
//
//
- (int) criteriaFindOperation
{
  return _criteriaFindOperation;
}

- (void) setCriteriaFindOperation: (int) theCriteriaFindOperation
{
  _criteriaFindOperation = theCriteriaFindOperation;
}


//
//
//
- (NSString *) criteriaString
{
  return _criteriaString;
}

- (void) setCriteriaString: (NSString *) theCriteriaString
{
  ASSIGN(_criteriaString, theCriteriaString);
}

@end
