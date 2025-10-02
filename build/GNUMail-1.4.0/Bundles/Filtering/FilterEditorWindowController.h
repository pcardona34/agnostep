/*
**  FilterEditorWindowController.h
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
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

#ifndef _GNUMail_H_FilterEditorWindowController
#define _GNUMail_H_FilterEditorWindowController

#import <AppKit/AppKit.h>

@class Filter;
@class FilterCriteria;
@class FilterManager;
@class FolderNode;
@class FolderNodePopUpItem;

//
//
//
@interface FilterEditorWindowController: NSWindowController
{
  // Outlets
  IBOutlet NSTextField *descriptionField;
  IBOutlet NSButton *activeButton;
  
  IBOutlet NSMatrix *filterTypeMatrix;

  IBOutlet NSButton *externalProgramButton;
  IBOutlet NSTextField *externalProgramField;
  IBOutlet NSPopUpButton *externalProgramPopUpButton;

  // First criteria
  IBOutlet NSPopUpButton *criteriaSourcePopUpButtonA;
  IBOutlet NSPopUpButton *criteriaFindOperationPopUpButtonA;
  IBOutlet NSTextField *criteriaStringFieldA;
  IBOutlet NSPopUpButton *criteriaPopUpButtonA;

  // Second criteria
  IBOutlet NSPopUpButton *criteriaConditionPopUpButtonB;
  IBOutlet NSPopUpButton *criteriaSourcePopUpButtonB;
  IBOutlet NSPopUpButton *criteriaFindOperationPopUpButtonB;
  IBOutlet NSTextField *criteriaStringFieldB;
  IBOutlet NSPopUpButton *criteriaPopUpButtonB;

  // Third criteria
  IBOutlet NSPopUpButton *criteriaConditionPopUpButtonC;
  IBOutlet NSPopUpButton *criteriaSourcePopUpButtonC;
  IBOutlet NSPopUpButton *criteriaFindOperationPopUpButtonC;
  IBOutlet NSTextField *criteriaStringFieldC;
  IBOutlet NSPopUpButton *criteriaPopUpButtonC;

  // Other UI elements
  IBOutlet NSMatrix *matrix;
  IBOutlet NSBox *criteriaBox;
  IBOutlet NSColorWell *actionColorWell;
  IBOutlet NSPopUpButton *actionFolderNamePopUpButton;
  IBOutlet NSPopUpButton *actionEMailStringPopUpButton;
  IBOutlet NSTextField *actionEMailStringField;
  IBOutlet NSButton *actionEMailStringButton;
  IBOutlet NSTextField *pathToSoundField;
  IBOutlet NSButton *chooseFileButton;

  // Other ivar
  Filter *filter;
  FilterManager *filterManager;

  FolderNode *allNodes;

  BOOL mustAddFilterToFilterManager;
}

- (id) initWithWindowNibName: (NSString *) windowNibName;
- (void) dealloc;


//
// delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification;
- (void) windowDidLoad;


//
// action methods
//
- (IBAction) okClicked: (id) sender;
- (IBAction) cancelClicked: (id) sender;
- (IBAction) chooseFileButtonClicked: (id) sender;
- (IBAction) setMessage: (id) sender;
- (IBAction) criteriaFindOperationSelectionHasChanged: (id) sender;
- (IBAction) criteriaSourceSelectionHasChanged: (id) sender;

//
// access/mutation methods
//
- (FilterManager *) filterManager;
- (void) setFilterManager: (FilterManager *) theFilterManager;

- (Filter *) filter;
- (void) setFilter: (Filter *) theFilter;

@end


//
// private methods
//
@interface FilterEditorWindowController (Private)

- (void) _initializeCriteriaSourcePopUpButton: (NSPopUpButton *) theCriteriaSourcePopUpButton
             criteriaFindOperationPopUpButton: (NSPopUpButton *) theCriteriaFindOperationPopUpButton
                 criteriaConditionPopUpButton: (NSPopUpButton *) theCriteriaConditionPopUpButton
                          criteriaStringField: (NSTextField *) theCriteriaStringField
			  criteriaPopUpButton: (NSPopUpButton *) theCriteriaPopUpButton
                          usingFilterCriteria: (FilterCriteria *) theFilterCriteria;

- (void) _setupGroupsPopUpButton: (NSPopUpButton *) button;

@end

#endif // _GNUMail_H_FilterEditorWindowController
