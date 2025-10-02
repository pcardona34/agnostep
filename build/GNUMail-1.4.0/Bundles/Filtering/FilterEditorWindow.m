/*
**  FilterEditorWindow.m
**
**  Copyright (c) 2001-2007
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

#include "FilterEditorWindow.h"

#include "Constants.h"
#include "LabelWidget.h"

//
//
//
@implementation FilterEditorWindow

- (void) dealloc
{
  NSDebugLog(@"FilterEditorWindow: -dealloc");
  
  RELEASE(descriptionField);
  RELEASE(activeButton);

  RELEASE(filterTypeMatrix);

  // External program
  RELEASE(externalProgramButton);
  RELEASE(externalProgramField);
  RELEASE(externalProgramPopUpButton);

  RELEASE(criteriaBox);

  // First criteria
  RELEASE(criteriaSourcePopUpButtonA);
  RELEASE(criteriaFindOperationPopUpButtonA);
  RELEASE(criteriaStringFieldA);
  RELEASE(criteriaPopUpButtonA);

  // Second criteria
  RELEASE(criteriaConditionPopUpButtonB);
  RELEASE(criteriaSourcePopUpButtonB);
  RELEASE(criteriaFindOperationPopUpButtonB);
  RELEASE(criteriaStringFieldB);
  RELEASE(criteriaPopUpButtonB);
  
  // Third criteria
  RELEASE(criteriaConditionPopUpButtonC);
  RELEASE(criteriaSourcePopUpButtonC);
  RELEASE(criteriaFindOperationPopUpButtonC);
  RELEASE(criteriaStringFieldC);
  RELEASE(criteriaPopUpButtonC);

  RELEASE(matrix);
  RELEASE(actionColorWell);
  RELEASE(actionFolderNamePopUpButton);
  RELEASE(actionEMailStringPopUpButton);
  RELEASE(actionEMailStringField);
  RELEASE(actionEMailStringButton);

  RELEASE(pathToSoundField);
  RELEASE(chooseFileButton);

  [super dealloc];
}


//
//
//
- (void) layoutWindow
{
  LabelWidget *descriptionLabel, *filterTypeLabel, *externalProgramLabel1, *externalProgramLabel2;
  NSButton *okButton, *cancelButton;
  
  NSButtonCell *cell;
  NSBox *box;

  // Descriction & activate
  descriptionLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,485,80,TextFieldHeight)
				  label: _(@"Description:")];
  [[self contentView] addSubview: descriptionLabel]; 

  descriptionField = [[NSTextField alloc] initWithFrame: NSMakeRect(100,485,290,TextFieldHeight)];
  [[self contentView] addSubview: descriptionField];

  activeButton = [[NSButton alloc] initWithFrame: NSMakeRect(410,485,70,ButtonHeight)];
  [activeButton setButtonType: NSSwitchButton];
  [activeButton setBordered: NO];
  [activeButton setTitle: _(@"Active")];
  [[self contentView] addSubview: activeButton];

  
  // Filter type
  filterTypeLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,455,70,TextFieldHeight)
				 label: _(@"Filter type:")];
  [[self contentView] addSubview: filterTypeLabel];

  cell = [[NSButtonCell alloc] init];
  [cell setButtonType: NSRadioButton];
  [cell setBordered: NO];
  [cell setImagePosition: NSImageLeft];

  filterTypeMatrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(90,453,200,ButtonHeight)
			     mode: NSRadioModeMatrix
			     prototype: cell
			     numberOfRows: 1
			     numberOfColumns: 2];
  [filterTypeMatrix setIntercellSpacing: NSMakeSize(20, 0)];
  [filterTypeMatrix setAutosizesCells: NO];
  [filterTypeMatrix setAllowsEmptySelection: NO];
  RELEASE(cell);
  
  [[filterTypeMatrix cellAtRow: 0  column: 0] setTitle: _(@"Incoming")];
  [[filterTypeMatrix cellAtRow: 0  column: 1] setTitle: _(@"Outgoing")];
  [[self contentView] addSubview: filterTypeMatrix];

  
  // External program
  box = [[NSBox alloc] initWithFrame: NSMakeRect(10,360,480,90)];
  [box setTitle: _(@"External Program")];
  
  externalProgramButton = [[NSButton alloc] initWithFrame: NSMakeRect(10,35,215,TextFieldHeight)];
  [externalProgramButton setButtonType: NSSwitchButton];
  [externalProgramButton setBordered: NO];
  [externalProgramButton setTitle: _(@"Process with external program:")];
  [box addSubview: externalProgramButton];
  
  externalProgramField = [[NSTextField alloc] initWithFrame: NSMakeRect(235,35,230,TextFieldHeight)];
  [box addSubview: externalProgramField];
  
  externalProgramLabel1 = [LabelWidget labelWidgetWithFrame: NSMakeRect(100,0,130,TextFieldHeight)
				      label: _(@"and apply criteria(s)")];
  [box addSubview: externalProgramLabel1];
  
  externalProgramPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(235,0,80,ButtonHeight)];
  [externalProgramPopUpButton setAutoenablesItems: NO];
  [externalProgramPopUpButton addItemWithTitle: _(@"after")];
  [externalProgramPopUpButton addItemWithTitle: _(@"before")];
  [box addSubview: externalProgramPopUpButton];
  
  externalProgramLabel2 = [LabelWidget labelWidgetWithFrame: NSMakeRect(325,0,120,TextFieldHeight)
				       label: _(@"program execution.")];
  [box addSubview: externalProgramLabel2];

  [[self contentView] addSubview: box];
  RELEASE(box);

  //
  // The criteria box
  //
  criteriaBox = [[NSBox alloc] initWithFrame: NSMakeRect(10,225,480,125)];
  [criteriaBox setTitle: _(@"Criteria")];
  
  //
  // First criteria
  //
  criteriaSourcePopUpButtonA = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(60,65,80,ButtonHeight)];
  [criteriaSourcePopUpButtonA addItemWithTitle: _(@"To")];
  [criteriaSourcePopUpButtonA addItemWithTitle: _(@"Cc")];
  [criteriaSourcePopUpButtonA addItemWithTitle: _(@"To or Cc")];
  [criteriaSourcePopUpButtonA addItemWithTitle: _(@"Subject")];
  [criteriaSourcePopUpButtonA addItemWithTitle: _(@"From")];
  [criteriaSourcePopUpButtonA addItemWithTitle: _(@"Expert...")];
  [criteriaSourcePopUpButtonA setTarget: [self windowController]];
  [criteriaSourcePopUpButtonA setAction: @selector(criteriaSourceSelectionHasChanged:)];
  [criteriaBox addSubview: criteriaSourcePopUpButtonA];

  criteriaFindOperationPopUpButtonA = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(150,65,130,ButtonHeight)];
  [criteriaFindOperationPopUpButtonA setAutoenablesItems: NO];
  [criteriaFindOperationPopUpButtonA addItemWithTitle: _(@"Contains")];
  [criteriaFindOperationPopUpButtonA addItemWithTitle: _(@"Is Equal")];
  [criteriaFindOperationPopUpButtonA addItemWithTitle: _(@"Has Prefix")];
  [criteriaFindOperationPopUpButtonA addItemWithTitle: _(@"Has Suffix")];
  [criteriaFindOperationPopUpButtonA addItemWithTitle: _(@"Match Expression")];
  [criteriaFindOperationPopUpButtonA setTarget: [self windowController]];
  [criteriaFindOperationPopUpButtonA setAction: @selector(criteriaFindOperationSelectionHasChanged:)];
  [criteriaBox addSubview: criteriaFindOperationPopUpButtonA];

  criteriaStringFieldA = [[NSTextField alloc] initWithFrame: NSMakeRect(285,65,180,TextFieldHeight)];
  [criteriaStringFieldA setEditable: YES];
  [criteriaBox addSubview: criteriaStringFieldA];

  criteriaPopUpButtonA = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(285,65,180,ButtonHeight)];
  
  //
  // Second criteria
  //
  criteriaConditionPopUpButtonB = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(5,35,50,ButtonHeight)];
  [criteriaConditionPopUpButtonB setAutoenablesItems: NO];
  [criteriaConditionPopUpButtonB addItemWithTitle: _(@"and")];
  [criteriaConditionPopUpButtonB addItemWithTitle: _(@"or")];
  [criteriaBox addSubview: criteriaConditionPopUpButtonB];

  criteriaSourcePopUpButtonB = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(60,35,80,ButtonHeight)];
  [criteriaSourcePopUpButtonB addItemWithTitle: _(@"(none)")];
  [criteriaSourcePopUpButtonB addItemWithTitle: _(@"To")];
  [criteriaSourcePopUpButtonB addItemWithTitle: _(@"Cc")];
  [criteriaSourcePopUpButtonB addItemWithTitle: _(@"To or Cc")];
  [criteriaSourcePopUpButtonB addItemWithTitle: _(@"Subject")];
  [criteriaSourcePopUpButtonB addItemWithTitle: _(@"From")];
  [criteriaSourcePopUpButtonB addItemWithTitle: _(@"Expert...")];
  [criteriaSourcePopUpButtonB setTarget: [self windowController]];
  [criteriaSourcePopUpButtonB setAction: @selector(criteriaSourceSelectionHasChanged:)];
  [criteriaBox addSubview: criteriaSourcePopUpButtonB];

  criteriaFindOperationPopUpButtonB = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(150,35,130,ButtonHeight)];
  [criteriaFindOperationPopUpButtonB setAutoenablesItems: NO];
  [criteriaFindOperationPopUpButtonB addItemWithTitle: _(@"Contains")];
  [criteriaFindOperationPopUpButtonB addItemWithTitle: _(@"Is Equal")];
  [criteriaFindOperationPopUpButtonB addItemWithTitle: _(@"Has Prefix")];
  [criteriaFindOperationPopUpButtonB addItemWithTitle: _(@"Has Suffix")];
  [criteriaFindOperationPopUpButtonB addItemWithTitle: _(@"Match Expression")];
  [criteriaFindOperationPopUpButtonB setTarget: [self windowController]];
  [criteriaFindOperationPopUpButtonB setAction: @selector(criteriaFindOperationSelectionHasChanged:)];
  [criteriaBox addSubview: criteriaFindOperationPopUpButtonB];

  criteriaStringFieldB = [[NSTextField alloc] initWithFrame: NSMakeRect(285,35,180,TextFieldHeight)];
  [criteriaStringFieldB setEditable: YES];
  [criteriaBox addSubview: criteriaStringFieldB];

  criteriaPopUpButtonB = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(285,35,180,ButtonHeight)];


  //
  // Third criteria
  //
  criteriaConditionPopUpButtonC = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(5,5,50,ButtonHeight)];
  [criteriaConditionPopUpButtonC setAutoenablesItems: NO];
  [criteriaConditionPopUpButtonC addItemWithTitle: _(@"and")];
  [criteriaConditionPopUpButtonC addItemWithTitle: _(@"or")];
  [criteriaBox addSubview: criteriaConditionPopUpButtonC];

  criteriaSourcePopUpButtonC = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(60,5,80,ButtonHeight)];
  [criteriaSourcePopUpButtonC addItemWithTitle: _(@"(none)")];
  [criteriaSourcePopUpButtonC addItemWithTitle: _(@"To")];
  [criteriaSourcePopUpButtonC addItemWithTitle: _(@"Cc")];
  [criteriaSourcePopUpButtonC addItemWithTitle: _(@"To or Cc")];
  [criteriaSourcePopUpButtonC addItemWithTitle: _(@"Subject")];
  [criteriaSourcePopUpButtonC addItemWithTitle: _(@"From")];
  [criteriaSourcePopUpButtonC addItemWithTitle: _(@"Expert...")];
  [criteriaSourcePopUpButtonC setTarget: [self windowController]];
  [criteriaSourcePopUpButtonC setAction: @selector(criteriaSourceSelectionHasChanged:)];
  [criteriaBox addSubview: criteriaSourcePopUpButtonC];

  criteriaFindOperationPopUpButtonC = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(150,5,130,ButtonHeight)];
  [criteriaFindOperationPopUpButtonC setAutoenablesItems: NO];
  [criteriaFindOperationPopUpButtonC addItemWithTitle: _(@"Contains")];
  [criteriaFindOperationPopUpButtonC addItemWithTitle: _(@"Is Equal")];
  [criteriaFindOperationPopUpButtonC addItemWithTitle: _(@"Has Prefix")];
  [criteriaFindOperationPopUpButtonC addItemWithTitle: _(@"Has Suffix")];
  [criteriaFindOperationPopUpButtonC addItemWithTitle: _(@"Match Expression")];
  [criteriaFindOperationPopUpButtonC setTarget: [self windowController]];
  [criteriaFindOperationPopUpButtonC setAction: @selector(criteriaFindOperationSelectionHasChanged:)];
  [criteriaBox addSubview: criteriaFindOperationPopUpButtonC];

  criteriaStringFieldC = [[NSTextField alloc] initWithFrame: NSMakeRect(285,5,180,TextFieldHeight)];
  [criteriaStringFieldC setEditable: YES];
  [criteriaBox addSubview: criteriaStringFieldC];

  criteriaPopUpButtonC = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(285,5,180,ButtonHeight)];

  // We add our box
  [[self contentView] addSubview: criteriaBox];

  //
  // The action box
  //
  box = [[NSBox alloc] initWithFrame: NSMakeRect(10,45,480,175)];
  [box setTitle: _(@"Action")];
  
  cell = [[NSButtonCell alloc] init];
  [cell setButtonType: NSRadioButton];
  [cell setBordered: NO];
  [cell setImagePosition: NSImageLeft];

  matrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(5,5,145,120)
			     mode: NSRadioModeMatrix
			     prototype: cell
			     numberOfRows: 5
			     numberOfColumns: 1];
  [matrix setTarget: [self windowController]];
  [matrix setIntercellSpacing: NSMakeSize(0, 5)];
  [matrix setAutosizesCells: NO];
  [matrix setAllowsEmptySelection: NO];
  RELEASE(cell);
  
  [[matrix cellAtRow: 0  column: 0] setTitle: _(@"Set the color to:")];
  [[matrix cellAtRow: 1  column: 0] setTitle: _(@"Transfer to mailbox:")];
  [[matrix cellAtRow: 2  column: 0] setTitle: _(@"Do...")];
  [[matrix cellAtRow: 3  column: 0] setTitle: _(@"Delete the message")];
  [[matrix cellAtRow: 4  column: 0] setTitle: _(@"Play Sound")];
  [box addSubview: matrix];

  actionColorWell = [[NSColorWell alloc] initWithFrame: NSMakeRect(155,120,125,ButtonHeight)];
  [box addSubview: actionColorWell];

  actionFolderNamePopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(155,90,310,ButtonHeight)];
  [box addSubview: actionFolderNamePopUpButton];

  actionEMailStringPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(155,60,90,ButtonHeight)];
  [actionEMailStringPopUpButton setAutoenablesItems: NO];
  [actionEMailStringPopUpButton addItemWithTitle: _(@"Bounce to:")];
  [actionEMailStringPopUpButton addItemWithTitle: _(@"Forward to:")];
  [actionEMailStringPopUpButton addItemWithTitle: _(@"Reply to:")];
  [box addSubview: actionEMailStringPopUpButton];

  actionEMailStringField = [[NSTextField alloc] initWithFrame: NSMakeRect(255,60,100,TextFieldHeight)];
  [actionEMailStringField setEditable: YES];
  [box addSubview: actionEMailStringField];

  actionEMailStringButton = [[NSButton alloc] initWithFrame: NSMakeRect(365,58,100, ButtonHeight)];
  [actionEMailStringButton setTitle: _(@"Set message")];
  [actionEMailStringButton setTarget: [self windowController]];
  [actionEMailStringButton setAction: @selector(setMessage:)];
  [box addSubview: actionEMailStringButton];
  
  //
  // For setting the path to the sound file
  //
  pathToSoundField = [[NSTextField alloc] initWithFrame: NSMakeRect(155,5,200,TextFieldHeight)];
  [pathToSoundField setEditable: YES];
  [box addSubview: pathToSoundField];

  chooseFileButton = [[NSButton alloc] initWithFrame: NSMakeRect(365,3,100,ButtonHeight)];
  [chooseFileButton setTitle: _(@"Choose file")];
  [chooseFileButton setTarget: [self windowController]];
  [chooseFileButton setAction: @selector(chooseFileButtonClicked:)];
  [box addSubview: chooseFileButton];

  [[self contentView] addSubview: box];
  RELEASE(box);

  cancelButton = [[NSButton alloc] initWithFrame: NSMakeRect(320,10,80,ButtonHeight)];;
  [cancelButton setButtonType: NSMomentaryPushButton];
  [cancelButton setKeyEquivalent: @"\e"];
  [cancelButton setTitle: _(@"Cancel")];
  [cancelButton setTarget: [self windowController]];
  [cancelButton setAction: @selector(cancelClicked:) ];
  [[self contentView] addSubview: cancelButton];
  RELEASE(cancelButton);
 
  okButton = [[NSButton alloc] initWithFrame: NSMakeRect(410,10,80,ButtonHeight)];
  [okButton setButtonType: NSMomentaryPushButton];
  [okButton setKeyEquivalent: @"\r"];
  [okButton setImagePosition: NSImageRight];
  [okButton setImage: [NSImage imageNamed: @"common_ret"]];
  [okButton setAlternateImage: [NSImage imageNamed: @"common_retH"]];
  [okButton setTitle: _(@"OK")];
  [okButton setTarget: [self windowController]];
  [okButton setAction: @selector(okClicked:)];
  [[self contentView] addSubview: okButton];
  RELEASE(okButton);
   
  // We set the initial responder and the next key views
  [self setInitialFirstResponder: descriptionField];
  [descriptionField setNextKeyView: activeButton];

  // FIXME
  [activeButton setNextKeyView: criteriaSourcePopUpButtonA];
  [criteriaSourcePopUpButtonA setNextKeyView: criteriaFindOperationPopUpButtonA];
  [criteriaFindOperationPopUpButtonA setNextKeyView: criteriaStringFieldA];
  [criteriaStringFieldA setNextKeyView: descriptionField];
}

@end





