/*
**  FilterEditorWindowController.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2019      GNUstep Team
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "FilterEditorWindowController.h"

#include "Filter.h"
#include "FilterHeaderEditorWindowController.h"
#include "FilterManager.h"
#include "FilterMessageWindowController.h"
#include "MailboxManagerController.h"
#include "GNUMail.h"
#include "Constants.h"
#include "Utilities.h"
#include "FolderNode.h"
#include "FolderNodePopUpItem.h"

#include <Pantomime/CWConstants.h>
#include <Pantomime/CWStore.h>
#include <Pantomime/CWLocalStore.h>
#include <Pantomime/NSString+Extensions.h>

#include <AddressBook/AddressBook.h>


#ifndef MACOSX
#include "FilterEditorWindow.h"
#endif


@implementation FilterEditorWindowController

//
//
//
- (id) initWithWindowNibName: (NSString *) windowNibName
{
#ifdef MACOSX
  
  self = [super initWithWindowNibName: windowNibName];
    
  criteriaPopUpButtonA = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(337,60,240,22)];
  criteriaPopUpButtonB = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(337,33,240,22)];
  criteriaPopUpButtonC = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(337,7,240,22)];
  
#else
  FilterEditorWindow *filterEditorWindow;
  
  filterEditorWindow = [[FilterEditorWindow alloc] initWithContentRect: NSMakeRect(300,300,500,520)
						   styleMask: NSTitledWindowMask
						   backing: NSBackingStoreRetained
						   defer: NO];
  
  self = [super initWithWindow: filterEditorWindow];
  
  [filterEditorWindow layoutWindow];
  [filterEditorWindow setDelegate: self];

  // We link our outlets
  descriptionField = filterEditorWindow->descriptionField;
  activeButton = filterEditorWindow->activeButton;

  filterTypeMatrix = filterEditorWindow->filterTypeMatrix;

  externalProgramButton = filterEditorWindow->externalProgramButton;
  externalProgramField = filterEditorWindow->externalProgramField;
  externalProgramPopUpButton = filterEditorWindow->externalProgramPopUpButton;

  criteriaBox = filterEditorWindow->criteriaBox;

  // First criteria
  criteriaSourcePopUpButtonA = filterEditorWindow->criteriaSourcePopUpButtonA;
  criteriaFindOperationPopUpButtonA = filterEditorWindow->criteriaFindOperationPopUpButtonA;
  criteriaStringFieldA = filterEditorWindow->criteriaStringFieldA;
  criteriaPopUpButtonA = filterEditorWindow->criteriaPopUpButtonA;

  // Second criteria
  criteriaConditionPopUpButtonB = filterEditorWindow->criteriaConditionPopUpButtonB;
  criteriaSourcePopUpButtonB = filterEditorWindow->criteriaSourcePopUpButtonB;
  criteriaFindOperationPopUpButtonB = filterEditorWindow->criteriaFindOperationPopUpButtonB;
  criteriaStringFieldB = filterEditorWindow->criteriaStringFieldB;
  criteriaPopUpButtonB = filterEditorWindow->criteriaPopUpButtonB;

  // Third criteria
  criteriaConditionPopUpButtonC = filterEditorWindow->criteriaConditionPopUpButtonC;
  criteriaSourcePopUpButtonC = filterEditorWindow->criteriaSourcePopUpButtonC;
  criteriaFindOperationPopUpButtonC = filterEditorWindow->criteriaFindOperationPopUpButtonC;
  criteriaStringFieldC = filterEditorWindow->criteriaStringFieldC;
  criteriaPopUpButtonC = filterEditorWindow->criteriaPopUpButtonC;

  matrix = filterEditorWindow->matrix;
  actionColorWell = filterEditorWindow->actionColorWell; 
  actionFolderNamePopUpButton = filterEditorWindow->actionFolderNamePopUpButton;
  actionEMailStringPopUpButton = filterEditorWindow->actionEMailStringPopUpButton;
  actionEMailStringField = filterEditorWindow->actionEMailStringField;
  actionEMailStringButton = filterEditorWindow->actionEMailStringButton;
  pathToSoundField = filterEditorWindow->pathToSoundField;
  chooseFileButton = filterEditorWindow->chooseFileButton;

  RELEASE(filterEditorWindow);
#endif

  // This MUST be the first step
  allNodes = RETAIN([Utilities initializeFolderNodesUsingAccounts: [[NSUserDefaults standardUserDefaults] 
								     objectForKey: @"ACCOUNTS"]]);

  [[self window] setTitle: _(@"Add a filter")];
  [Utilities addItemsToPopUpButton: actionFolderNamePopUpButton
	     usingFolderNodes: allNodes];
  
  return self;
}


//
//
//
- (void) dealloc
{
#ifdef MACOSX
  RELEASE(criteriaStringFieldA);
  RELEASE(criteriaStringFieldB);
  RELEASE(criteriaStringFieldC);
  RELEASE(criteriaPopUpButtonA);
  RELEASE(criteriaPopUpButtonB);
  RELEASE(criteriaPopUpButtonC);
#endif
  
  RELEASE(allNodes);

  [super dealloc];
}

//
// delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification
{ 
  RELEASE(filterManager);
  TEST_RELEASE(filter);
}

- (void) windowDidLoad
{
  [super windowDidLoad];
  
  RETAIN(criteriaStringFieldA);
  RETAIN(criteriaStringFieldB);
  RETAIN(criteriaStringFieldC);
}


//
// action methods
//
- (IBAction) okClicked: (id) sender
{
  // CWLocalStore *aStore;
  NSString *aString;  
  Filter *aFilter;
  
  FolderNode *aFolderNode;

  // aStore = [[MailboxManagerController singleInstance] storeForName: @"GNUMAIL_LOCAL_STORE"
  //						      username: NSUserName()];  
  
  // We first synchronize all our popups
  [externalProgramPopUpButton synchronizeTitleAndSelectedItem];

  [criteriaSourcePopUpButtonA synchronizeTitleAndSelectedItem];
  [criteriaFindOperationPopUpButtonA synchronizeTitleAndSelectedItem];

  [criteriaConditionPopUpButtonB synchronizeTitleAndSelectedItem];
  [criteriaSourcePopUpButtonB synchronizeTitleAndSelectedItem];
  [criteriaFindOperationPopUpButtonB synchronizeTitleAndSelectedItem];

  [criteriaConditionPopUpButtonC synchronizeTitleAndSelectedItem];
  [criteriaSourcePopUpButtonC synchronizeTitleAndSelectedItem];
  [criteriaFindOperationPopUpButtonC synchronizeTitleAndSelectedItem];

  [actionFolderNamePopUpButton synchronizeTitleAndSelectedItem];
  [actionEMailStringPopUpButton synchronizeTitleAndSelectedItem];

  //
  // FIXME: We must verify for, at least, local store if the folder is "selectable". 
  //        Also, which value do we put here in case of an error?
  // We verify if the selected folder in actionFolderNamePopUpButton holds message or folders
  aFolderNode = [(FolderNodePopUpItem *)[actionFolderNamePopUpButton selectedItem] folderNode];
  
  if ( [aFolderNode parent] == allNodes )
    {
      NSDebugLog(@"Selected an invalid mailbox, Default to default Inbox folder.");
#warning FIXME - This is wrong
      aString = [[NSUserDefaults standardUserDefaults] objectForKey: @"INBOXFOLDERNAME"];
    }
  else
    {
      aString = [Utilities stringValueOfURLNameFromFolderNode: aFolderNode
			   serverName: nil
			   username: nil];
    }
  // FIXME
  //    if ( [aStore folderTypeForFolderName: aString] == HOLDS_FOLDERS )
  //      {
  //        NSRunInformationalAlertPanel(_(@"Error!"),
  //  				   _(@"The selected target folder (%@) holds folders, not messages."),
  //  				   _(@"OK"),
  //  				   NULL,
  //  				   NULL,
  //  				   aString);
  //        return;
  //      }
  
  if ([externalProgramButton state] == NSOnState && 
       ([matrix selectedRow] + 1 ) == SET_COLOR)
    {
      NSRunInformationalAlertPanel(_(@"Warning!"),
				   _(@"Defining a coloring filter that uses an external program is a BAD idea.\nThis will slow down drastically the application."),
				   _(@"OK"),
				   NULL,
				   NULL,
				   aString);
    } 
  

  aFilter = [self filter];
   
  if (mustAddFilterToFilterManager)
    {
      [filterManager addFilter: aFilter];
    }
  
  // Description
  [aFilter setDescription: [descriptionField stringValue]];
  [aFilter setIsActive: ([activeButton state] == NSOnState ? YES : NO)];
  [aFilter setType: ([filterTypeMatrix selectedColumn] + 1)];
  
  // External program
  [aFilter setUseExternalProgram: ([externalProgramButton state] == NSOnState ? YES : NO)];
  [aFilter setExternalProgramName: [[externalProgramField stringValue] stringByTrimmingWhiteSpaces]];
  [aFilter setExternalProgramOperation: ([externalProgramPopUpButton indexOfSelectedItem] + 1)];

  // First criteria
  [[[aFilter allCriterias] objectAtIndex: 0] setCriteriaSource: ([criteriaSourcePopUpButtonA indexOfSelectedItem] + 1)];
  [[[aFilter allCriterias] objectAtIndex: 0] setCriteriaFindOperation: ([criteriaFindOperationPopUpButtonA indexOfSelectedItem] + 1)];
  
  if ([criteriaFindOperationPopUpButtonA indexOfSelectedItem] == 6) 
    {
      [[[aFilter allCriterias] objectAtIndex: 0] setCriteriaString: [[criteriaPopUpButtonA selectedItem] representedObject]];
    }
  else
    {
      [[[aFilter allCriterias] objectAtIndex: 0] setCriteriaString: [criteriaStringFieldA stringValue]];
    }

  // Second criteria
  [[[aFilter allCriterias] objectAtIndex: 1] setCriteriaCondition: ([criteriaConditionPopUpButtonB indexOfSelectedItem] + 1)];
  [[[aFilter allCriterias] objectAtIndex: 1] setCriteriaSource: [criteriaSourcePopUpButtonB indexOfSelectedItem]];
  [[[aFilter allCriterias] objectAtIndex: 1] setCriteriaFindOperation: ([criteriaFindOperationPopUpButtonB indexOfSelectedItem] + 1)];
  [[[aFilter allCriterias] objectAtIndex: 1] setCriteriaString: [criteriaStringFieldB stringValue]];

  if ([criteriaFindOperationPopUpButtonB indexOfSelectedItem] == 6)
    {
      [[[aFilter allCriterias] objectAtIndex: 1] setCriteriaString: [[criteriaPopUpButtonB selectedItem] representedObject]];
    }
  else
    {
      [[[aFilter allCriterias] objectAtIndex: 1] setCriteriaString: [criteriaStringFieldB stringValue]];
    }
  
  // Third criteria
  [[[aFilter allCriterias] objectAtIndex: 2] setCriteriaCondition: ([criteriaConditionPopUpButtonC indexOfSelectedItem] + 1)];
  [[[aFilter allCriterias] objectAtIndex: 2] setCriteriaSource: [criteriaSourcePopUpButtonC indexOfSelectedItem]];
  [[[aFilter allCriterias] objectAtIndex: 2] setCriteriaFindOperation: ([criteriaFindOperationPopUpButtonC indexOfSelectedItem] + 1)];
  [[[aFilter allCriterias] objectAtIndex: 2] setCriteriaString: [criteriaStringFieldC stringValue]];
 
  if ([criteriaFindOperationPopUpButtonC indexOfSelectedItem] == 6)
    {
      [[[aFilter allCriterias] objectAtIndex: 2] setCriteriaString: [[criteriaPopUpButtonC selectedItem] representedObject]];
    }  
  else
    {
      [[[aFilter allCriterias] objectAtIndex: 2] setCriteriaString: [criteriaStringFieldC stringValue]];
    }

  // Action
  [aFilter setAction: ([matrix selectedRow] + 1)];
  [aFilter setActionColor: [actionColorWell color]];
  [aFilter setActionFolderName: aString];
  [aFilter setActionEMailOperation: ([actionEMailStringPopUpButton indexOfSelectedItem] + 1)];
  [aFilter setActionEMailString: [actionEMailStringField stringValue]];
  [aFilter setPathToSound: [pathToSoundField stringValue]];

  [NSApp stopModal];
  [self close];
}


//
//
//
- (IBAction) cancelClicked: (id) sender
{
  [NSApp stopModalWithCode: NSRunAbortedResponse];
  [self close];
}


//
//
//
- (IBAction) chooseFileButtonClicked: (id) sender
{
  NSOpenPanel *oPanel;
  int result;
  
  oPanel = [NSOpenPanel openPanel];
  [oPanel setAllowsMultipleSelection: NO];
  result = [oPanel runModalForDirectory: [GNUMail currentWorkingPath]
		   file: nil 
		   types: nil];
  
  if (result == NSOKButton)
    {
      NSArray *fileToOpen;
      int count;
      
      fileToOpen = [oPanel filenames];
      count = [fileToOpen count];
      
      if (count > 0)
	{
	  NSString *aString;

	  aString = [fileToOpen objectAtIndex: 0];
	  [pathToSoundField setStringValue: aString];
	  [GNUMail setCurrentWorkingPath: [aString stringByDeletingLastPathComponent]];
	}
    }
}


//
//
//
- (IBAction) setMessage: (id) sender
{
  FilterMessageWindowController *aFilterMessageWindowController;

  aFilterMessageWindowController = [[FilterMessageWindowController alloc]
				     initWithWindowNibName: @"FilterMessageWindow"];

  [aFilterMessageWindowController setMessageString: [[self filter] actionMessageString]];
  [NSApp runModalForWindow: [aFilterMessageWindowController window]];
  
  [[self filter] setActionMessageString: [aFilterMessageWindowController messageString]];
  RELEASE(aFilterMessageWindowController);
}


//
//
//
- (IBAction) criteriaSourceSelectionHasChanged: (id) sender
{
  NSPopUpButton *theCriteriaSourcePopUpButton, *theCriteriaFindOperationPopUpButton;
  NSTextField *theCriteriaStringField; NSPopUpButton *theCriteriaPopUpButton;
  FilterCriteria *aFilterCriteria;

  theCriteriaSourcePopUpButton = sender;

  if ( theCriteriaSourcePopUpButton == criteriaSourcePopUpButtonA )
    {
      theCriteriaFindOperationPopUpButton = criteriaFindOperationPopUpButtonA;
      theCriteriaStringField = criteriaStringFieldA;
      theCriteriaPopUpButton = criteriaPopUpButtonA;
      aFilterCriteria = [[filter allCriterias] objectAtIndex: 0];
    }
  else if ( theCriteriaSourcePopUpButton == criteriaSourcePopUpButtonB )
    {
      theCriteriaFindOperationPopUpButton = criteriaFindOperationPopUpButtonB;
      theCriteriaStringField = criteriaStringFieldB;
      theCriteriaPopUpButton = criteriaPopUpButtonB;
      aFilterCriteria = [[filter allCriterias] objectAtIndex: 1];
    }
  else
    {
      theCriteriaFindOperationPopUpButton = criteriaFindOperationPopUpButtonC;
      theCriteriaStringField = criteriaStringFieldC;
      theCriteriaPopUpButton = criteriaPopUpButtonC;
      aFilterCriteria = [[filter allCriterias] objectAtIndex: 2];
    }


  [theCriteriaSourcePopUpButton synchronizeTitleAndSelectedItem];

  // If we have selected To, Cc, To or Cc, From we add a new item in our Address Book
  if ( [[theCriteriaSourcePopUpButton titleOfSelectedItem] isEqualToString: _(@"To")] ||
       [[theCriteriaSourcePopUpButton titleOfSelectedItem] isEqualToString: _(@"Cc")] ||
       [[theCriteriaSourcePopUpButton titleOfSelectedItem] isEqualToString: _(@"To or Cc")] ||
       [[theCriteriaSourcePopUpButton titleOfSelectedItem] isEqualToString: _(@"From")] )
    {
      if ( ![theCriteriaFindOperationPopUpButton itemWithTitle:  _(@"Is in Address Book")] )
	{
	  [theCriteriaFindOperationPopUpButton addItemWithTitle: _(@"Is in Address Book")];
	  [theCriteriaFindOperationPopUpButton addItemWithTitle: _(@"Is in Group")];
	}
    }
  else
    {
      if ( [[theCriteriaFindOperationPopUpButton titleOfSelectedItem] isEqualToString: _(@"Is in Address Book")] )
	{
	  [theCriteriaFindOperationPopUpButton selectItemAtIndex: 0];
	  [theCriteriaFindOperationPopUpButton synchronizeTitleAndSelectedItem];
	}
      
      // We remove the item, if we need too.
      if ( [theCriteriaFindOperationPopUpButton itemWithTitle:  _(@"Is in Address Book")] )
	{
	  [theCriteriaFindOperationPopUpButton removeItemWithTitle: _(@"Is in Address Book")];
	  [theCriteriaFindOperationPopUpButton removeItemWithTitle: _(@"Is in Group")];
	}
    }
  
  if ( [theCriteriaFindOperationPopUpButton indexOfSelectedItem] == 6 )
    {
      // changing away from the string field? in that case, the string
      // is no longer valid (it's a regular string, not a UID)
      if([theCriteriaStringField superview])
	[aFilterCriteria setCriteriaString: @""];

      [theCriteriaStringField removeFromSuperview];
      [criteriaBox addSubview: theCriteriaPopUpButton];

      [self _setupGroupsPopUpButton: theCriteriaPopUpButton];
      [theCriteriaPopUpButton selectItemAtIndex: [theCriteriaPopUpButton indexOfItemWithRepresentedObject: [aFilterCriteria criteriaString]]];
    }
  else if ([theCriteriaFindOperationPopUpButton indexOfSelectedItem] == 5)
    {
      [theCriteriaStringField removeFromSuperview];
      [theCriteriaPopUpButton removeFromSuperview];
      [aFilterCriteria setCriteriaString: @""];
    }
  else
    {
      // changing away from the popup? in that case, the string is no
      // longer valid (it's a UID, not a regular string)
      if ([theCriteriaPopUpButton superview])
	[aFilterCriteria setCriteriaString: @""];

      [theCriteriaPopUpButton removeFromSuperview];
      [criteriaBox addSubview: theCriteriaStringField];

      [theCriteriaStringField setStringValue: [aFilterCriteria criteriaString]];
    }

  // We verify if it's the last item (Expert...) that has been selected
  if ( [theCriteriaSourcePopUpButton indexOfSelectedItem] == ([theCriteriaSourcePopUpButton numberOfItems] - 1) )
    {
      FilterHeaderEditorWindowController *filterHeaderEditorWindowController;
      int result;

      filterHeaderEditorWindowController = [[FilterHeaderEditorWindowController alloc]
					     initWithWindowNibName: @"FilterHeaderEditorWindow"];

      [filterHeaderEditorWindowController setHeaders: [aFilterCriteria criteriaHeaders]];
      result = [NSApp runModalForWindow: [filterHeaderEditorWindowController window]];
    
      // If "OK" was clicked, we must update our array of headers
      if ( result == NSRunStoppedResponse )
	{
	  [aFilterCriteria setCriteriaHeaders: [NSArray arrayWithArray: [filterHeaderEditorWindowController allHeaders]]];
	}

      RELEASE(filterHeaderEditorWindowController);
    }
} 


//
//
//
- (IBAction) criteriaFindOperationSelectionHasChanged: (id) sender
{
  NSPopUpButton *theCriteriaFindOperationPopUpButton;
  NSTextField *theCriteriaStringField; NSPopUpButton *theCriteriaPopUpButton;
  FilterCriteria *aFilterCriteria;
  int findOperation;

  theCriteriaFindOperationPopUpButton = sender;
  findOperation = [theCriteriaFindOperationPopUpButton indexOfSelectedItem]+1;

  if ( theCriteriaFindOperationPopUpButton == criteriaFindOperationPopUpButtonA )
    {
      theCriteriaStringField = criteriaStringFieldA;
      theCriteriaPopUpButton = criteriaPopUpButtonA;
      aFilterCriteria = [[filter allCriterias] objectAtIndex: 0];
    }
  else if ( theCriteriaFindOperationPopUpButton == criteriaFindOperationPopUpButtonB )
    {
      theCriteriaStringField = criteriaStringFieldB;
      theCriteriaPopUpButton = criteriaPopUpButtonB;
      aFilterCriteria = [[filter allCriterias] objectAtIndex: 1];
    }
  else
    {
      theCriteriaStringField = criteriaStringFieldC;
      theCriteriaPopUpButton = criteriaPopUpButtonC;
      aFilterCriteria = [[filter allCriterias] objectAtIndex: 2];
    }

  if (findOperation == 7)
    {
      // changing away from the string field? in that case, the string
      // is no longer valid (it's a regular string, not a UID)
      if([theCriteriaStringField superview])
	[aFilterCriteria setCriteriaString: @""];

      [theCriteriaStringField removeFromSuperview];
      [criteriaBox addSubview: theCriteriaPopUpButton];

      [self _setupGroupsPopUpButton: theCriteriaPopUpButton];
      [theCriteriaPopUpButton selectItemAtIndex: [theCriteriaPopUpButton indexOfItemWithRepresentedObject: [aFilterCriteria criteriaString]]];
    }
  else if (findOperation == 6)
    {
      [theCriteriaStringField removeFromSuperview];
      [theCriteriaPopUpButton removeFromSuperview];
      [aFilterCriteria setCriteriaString: @""];
    }
  else
    {
      // changing away from the popup? in that case, the string is no
      // longer valid (it's a UID, not a regular string)
      if([theCriteriaPopUpButton superview])
	[aFilterCriteria setCriteriaString: @""];

      [theCriteriaPopUpButton removeFromSuperview];
      [criteriaBox addSubview: theCriteriaStringField];

      [theCriteriaStringField setStringValue: [aFilterCriteria criteriaString]];
    }
}  


//
// access/mutation methods
//
- (FilterManager *) filterManager
{
  return filterManager;
}


//
//
//
- (void) setFilterManager: (FilterManager *) theFilterManager
{
  ASSIGN(filterManager, theFilterManager);
}


//
//
//
- (Filter *) filter
{
  return filter;
}


//
//
//
- (void) setFilter: (Filter *) theFilter
{
  if (theFilter)
    {
      FolderNodePopUpItem *theItem;

      ASSIGN(filter, theFilter);
      mustAddFilterToFilterManager = NO;

      // Description
      [descriptionField setStringValue: [filter description]];
      [activeButton setState: ([filter isActive] ? NSOnState : NSOffState)];
      [filterTypeMatrix selectCellAtRow: 0
			column: ([filter type] - 1)];

      // External program
      [externalProgramButton setState: ([filter useExternalProgram] ? NSOnState : NSOffState)];
      [externalProgramField setStringValue: [filter externalProgramName]];
      [externalProgramPopUpButton selectItemAtIndex: ([filter externalProgramOperation] - 1)];

      // First criteria
      [self _initializeCriteriaSourcePopUpButton: criteriaSourcePopUpButtonA
	    criteriaFindOperationPopUpButton: criteriaFindOperationPopUpButtonA
	    criteriaConditionPopUpButton: nil
	    criteriaStringField: criteriaStringFieldA
	    criteriaPopUpButton: criteriaPopUpButtonA
	    usingFilterCriteria: [[filter allCriterias] objectAtIndex: 0]];
      
      // Second criteria
      [self _initializeCriteriaSourcePopUpButton: criteriaSourcePopUpButtonB
	    criteriaFindOperationPopUpButton: criteriaFindOperationPopUpButtonB
	    criteriaConditionPopUpButton: criteriaConditionPopUpButtonB
	    criteriaStringField: criteriaStringFieldB
	    criteriaPopUpButton: criteriaPopUpButtonB
	    usingFilterCriteria: [[filter allCriterias] objectAtIndex: 1]];
      
      // Third criteria
      [self _initializeCriteriaSourcePopUpButton: criteriaSourcePopUpButtonC
	    criteriaFindOperationPopUpButton: criteriaFindOperationPopUpButtonC
	    criteriaConditionPopUpButton: criteriaConditionPopUpButtonC
	    criteriaStringField: criteriaStringFieldC
	    criteriaPopUpButton: criteriaPopUpButtonC
	    usingFilterCriteria: [[filter allCriterias] objectAtIndex: 2]];
      
      // Action
      [matrix selectCellAtRow: [filter action]-1  column: 0];
      
      [actionColorWell setColor: [filter actionColor]];
      
      // We try to select our folder, if it has been deleted (or renamed), we select Inbox.      
      theItem = [Utilities folderNodePopUpItemForURLNameAsString: [filter actionFolderName]
			   usingFolderNodes: allNodes
			   popUpButton: actionFolderNamePopUpButton
			   account: nil];
      
      if (theItem)
	{
	  [actionFolderNamePopUpButton selectItem: theItem];
	}
      else
	{
	  NSDebugLog(@"Item not found!");
	  //FIXME
	  //acctionFolderNamePopUpButton selectItemWithTitle: [[NSUserDefaults standardUserDefaults] 
	  //objectForKey: @"INBOXFOLDERNAME"]];
	}

      [actionEMailStringPopUpButton selectItemAtIndex: ([filter actionEMailOperation] - 1)];
      [actionEMailStringField setStringValue: [filter actionEMailString]];
      [pathToSoundField setStringValue: ([filter pathToSound] ? (id)[filter pathToSound] : (id)@"")];
    }
  else
    {
      RELEASE(filter);
      
      filter = [[Filter alloc] init];
      mustAddFilterToFilterManager = YES;

      // We set the initial selection of the UI elements
      [externalProgramPopUpButton selectItemAtIndex: 0];

      [criteriaSourcePopUpButtonA selectItemAtIndex: 0];
      [criteriaFindOperationPopUpButtonA selectItemAtIndex: 0];

      [criteriaConditionPopUpButtonB selectItemAtIndex: 0];
      [criteriaSourcePopUpButtonB selectItemAtIndex: 0];
      [criteriaFindOperationPopUpButtonB selectItemAtIndex: 0];

      [criteriaConditionPopUpButtonC selectItemAtIndex: 0];
      [criteriaSourcePopUpButtonC selectItemAtIndex: 0];
      [criteriaFindOperationPopUpButtonC selectItemAtIndex: 0];

      [actionFolderNamePopUpButton selectItemAtIndex: 0];
      [actionEMailStringPopUpButton selectItemAtIndex: 0]; 

      [activeButton setState: NSOnState];
    }
}

@end


//
// private methods
//
@implementation FilterEditorWindowController (Private)

- (void) _initializeCriteriaSourcePopUpButton: (NSPopUpButton *) theCriteriaSourcePopUpButton
	     criteriaFindOperationPopUpButton: (NSPopUpButton *) theCriteriaFindOperationPopUpButton
		 criteriaConditionPopUpButton: (NSPopUpButton *) theCriteriaConditionPopUpButton
			  criteriaStringField: (NSTextField *) theCriteriaStringField
			  criteriaPopUpButton: (NSPopUpButton *) theCriteriaPopUpButton
			  usingFilterCriteria: (FilterCriteria *) theFilterCriteria
{
  if ( theCriteriaConditionPopUpButton )
    {
      [theCriteriaConditionPopUpButton selectItemAtIndex: ([theFilterCriteria criteriaCondition] - 1)];
    }

  if ( theCriteriaSourcePopUpButton == criteriaSourcePopUpButtonA )
    {
      [theCriteriaSourcePopUpButton selectItemAtIndex: ([theFilterCriteria criteriaSource] - 1)];
    }
  else
    {
      [theCriteriaSourcePopUpButton selectItemAtIndex: [theFilterCriteria criteriaSource]];
    }

  // We verify if we need to add the "Is in Address Book" item: TO == 1, CC == 2, TO_OR_CC == 3
  // and FROM == 5
  switch ( [theFilterCriteria criteriaSource] )
    {
    case 1:
    case 2:
    case 3:
    case 5:
      [theCriteriaFindOperationPopUpButton addItemWithTitle: _(@"Is in Address Book")];
      [theCriteriaFindOperationPopUpButton addItemWithTitle: _(@"Is in Group")];
      break;
    default:
      break;
    }

  [theCriteriaFindOperationPopUpButton selectItemAtIndex: ([theFilterCriteria criteriaFindOperation] - 1)];
    
  if ( [theFilterCriteria criteriaFindOperation] == 7 )
    {
      [theCriteriaStringField removeFromSuperview];
      [criteriaBox addSubview: theCriteriaPopUpButton];
      
      [self _setupGroupsPopUpButton: theCriteriaPopUpButton];
      [theCriteriaPopUpButton selectItemAtIndex: [theCriteriaPopUpButton indexOfItemWithRepresentedObject: [theFilterCriteria criteriaString]]];
    }
  else
    {
      [theCriteriaPopUpButton removeFromSuperview];
      [criteriaBox addSubview: theCriteriaStringField];

      [theCriteriaStringField setStringValue: [theFilterCriteria criteriaString]];
    }
}


//
//
//
- (void) _setupGroupsPopUpButton: (NSPopUpButton *) thePopUpButton
{
  NSEnumerator *theEnumerator;
  ABGroup *aGroup;

  [thePopUpButton removeAllItems];
  theEnumerator = [[[ABAddressBook sharedAddressBook] groups] objectEnumerator];
  
  while ((aGroup = [theEnumerator nextObject]))
    {
      [thePopUpButton addItemWithTitle: [aGroup valueForProperty: kABGroupNameProperty]];
      [thePopUpButton setAutoenablesItems: NO];
      [[thePopUpButton itemAtIndex: [thePopUpButton numberOfItems]-1]
      	setRepresentedObject: [aGroup uniqueId]];
    }
}
	       
@end

