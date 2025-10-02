/*
**  MimeTypeEditorWindow.m
**
**  Copyright (c) 2001, 2002, 2003 Ludovic Marcotte
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

#include "MimeTypeEditorWindow.h"

#include "Constants.h"
#include "LabelWidget.h"

@implementation MimeTypeEditorWindow

- (void) dealloc
{
  NSDebugLog(@"MimeTypeEditorWindow: -dealloc");
  
  RELEASE(mimeTypeField);
  RELEASE(fileExtensionsField);
  RELEASE(descriptionField);
  RELEASE(viewMatrix);
  RELEASE(actionMatrix);
  RELEASE(dataHandlerCommandField);
  
  RELEASE(iconButton);
  RELEASE(dataHandlerCommandButton);
 
  [super dealloc];
}

- (void) layoutWindow
{
  LabelWidget *mimeTypeLabel, *fileExtensionsLabel, *descriptionLabel, *viewLabel, *actionLabel, *iconLabel;
  NSButton *okButton, *cancelButton;
  NSButtonCell *cell;
  
  mimeTypeLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,385,200,TextFieldHeight)
			       label: _(@"MIME type (ex: image/jpeg):")];
  [[self contentView] addSubview: mimeTypeLabel];

  mimeTypeField = [[NSTextField alloc] initWithFrame: NSMakeRect(10,360,200,TextFieldHeight)];
  [[self contentView] addSubview: mimeTypeField];
  
  fileExtensionsLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(220,385,200,TextFieldHeight)
			       label: _(@"File extensions (ex: jpeg,jpg):")];
  [[self contentView] addSubview: fileExtensionsLabel];

  fileExtensionsField = [[NSTextField alloc] initWithFrame: NSMakeRect(220,360,200,TextFieldHeight)];
  [[self contentView] addSubview: fileExtensionsField];
  
  descriptionLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,330,80,TextFieldHeight)
				  label: _(@"Description:")];
  [[self contentView] addSubview: descriptionLabel]; 

  descriptionField = [[NSTextField alloc] initWithFrame: NSMakeRect(100,330,320,TextFieldHeight)];
  [[self contentView] addSubview: descriptionField];

  viewLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,300,200,TextFieldHeight)
  			   label: _(@"View:")];
  [[self contentView] addSubview: viewLabel];
  
  cell = [[NSButtonCell alloc] init];
  [cell setButtonType: NSSwitchButton];
  [cell setBordered: NO];
  [cell setImagePosition: NSImageLeft];

  viewMatrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(10,250,400,45)
				 mode: NSRadioModeMatrix
				 prototype: cell
				 numberOfRows: 2
				 numberOfColumns: 1];
  [viewMatrix setTarget: [self windowController]];
  [viewMatrix setIntercellSpacing: NSMakeSize(0, 5)];
  [viewMatrix setAutosizesCells: NO];
  [viewMatrix setAllowsEmptySelection: NO];
  RELEASE(cell);
  
  cell = [viewMatrix cellAtRow: 0 column: 0];
  [cell setTitle: _(@"Display if possible (as icon if it is not possible)")];

  cell = [viewMatrix cellAtRow: 1 column: 0];
  [cell setTitle: _(@"Always display as icon")];
  [[self contentView] addSubview: viewMatrix];


  actionLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,220,200,TextFieldHeight)
			     label: _(@"Action:")];
  [[self contentView] addSubview: actionLabel];

  cell = [[NSButtonCell alloc] init];
  [cell setButtonType: NSSwitchButton];
  [cell setBordered: NO];
  [cell setImagePosition: NSImageLeft];

  actionMatrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(10,155,400,45)
				 mode: NSRadioModeMatrix
				 prototype: cell
				 numberOfRows: 3
				 numberOfColumns: 1];

  [actionMatrix setTarget: [self windowController]];
  [actionMatrix setIntercellSpacing: NSMakeSize(0, 10)];
  [actionMatrix setAutosizesCells: NO];
  [actionMatrix setAllowsEmptySelection: NO];
  RELEASE(cell);

  cell = [actionMatrix cellAtRow: 0 column: 0];
  [cell setTitle: _(@"Prompt save panel")];
  [cell setAction:@selector(selectionHasChanged:)];

  cell = [actionMatrix cellAtRow: 1 column: 0];
  [cell setTitle: _(@"Open with Workspace")];
  
  cell = [actionMatrix cellAtRow: 2 column: 0];
  [cell setTitle: _(@"Open with external program:")];
  [cell setAction: @selector(selectionHasChanged:)];
  //[matrix sizeToFit];
  [[self contentView] addSubview: actionMatrix];


  dataHandlerCommandField = [[NSTextField alloc] initWithFrame: NSMakeRect(10,120,330,TextFieldHeight)];
  [[self contentView] addSubview: dataHandlerCommandField];
  
  dataHandlerCommandButton = [[NSButton alloc] initWithFrame: NSMakeRect(350,120,65,ButtonHeight)];
  [dataHandlerCommandButton setTitle: _(@"Choose")];
  [dataHandlerCommandButton setTarget: [self windowController]];
  [dataHandlerCommandButton setAction: @selector(chooseDataHandlerCommand:)];
  [[self contentView] addSubview: dataHandlerCommandButton];
 
  iconLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,80,410,TextFieldHeight)
			   label: _(@"Please choose an icon to represent this MIME type (tiff file only):")];
  [[self contentView] addSubview: iconLabel];
  
  iconButton = [[NSButton alloc] initWithFrame: NSMakeRect(25,10,64,64)];
  [iconButton setTitle: @""];
  [iconButton setTarget: [self windowController]];
  [iconButton setAction: @selector(chooseIcon:)];
  [iconButton setImagePosition: NSImageOnly];
  [iconButton setImage: [NSImage imageNamed: @"common_Unknown.tiff"]];
  [[self contentView] addSubview: iconButton];

  cancelButton = [[NSButton alloc] initWithFrame: NSMakeRect(255,10,75,ButtonHeight)];;
  [cancelButton setButtonType: NSMomentaryPushButton];
  [cancelButton setKeyEquivalent: @"\e"];
  [cancelButton setTitle: _(@"Cancel")];
  [cancelButton setTarget: [self windowController]];
  [cancelButton setAction: @selector(cancelClicked:) ];
  [[self contentView] addSubview: cancelButton];
  RELEASE(cancelButton);
 
  okButton = [[NSButton alloc] initWithFrame: NSMakeRect(340,10,75,ButtonHeight)];
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
  
  //
  // We set the initial responder and the next key views
  //
  [self setInitialFirstResponder: mimeTypeField];
  [mimeTypeField setNextKeyView: fileExtensionsField];
  [fileExtensionsField setNextKeyView: descriptionField];
  [descriptionField setNextKeyView: viewMatrix];
  [viewMatrix setNextKeyView: actionMatrix];
  [actionMatrix setNextKeyView: dataHandlerCommandField];
  [dataHandlerCommandField setNextKeyView: iconButton];
  [iconButton setNextKeyView: cancelButton];
  [cancelButton setNextKeyView: okButton];
  [okButton setNextKeyView: mimeTypeField];
}


//
// access/mutation methods
//

- (NSTextField *) mimeTypeField
{
  return mimeTypeField;
}

- (NSTextField *) fileExtensionsField
{
  return fileExtensionsField;
}

- (NSTextField *) descriptionField
{
  return descriptionField;
}

- (NSTextField *) dataHandlerCommandField
{
  return dataHandlerCommandField;
}

- (NSButton *) dataHandlerCommandButton
{
  return dataHandlerCommandButton;
}

- (NSButton *) iconButton
{
  return iconButton;
}

- (NSMatrix *) viewMatrix
{
  return viewMatrix;
}

- (NSMatrix *) actionMatrix
{
  return actionMatrix;
}

@end





