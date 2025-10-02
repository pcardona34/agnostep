/*
**  MimeTypeEditorWindowController.m
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**  Copyright (C) 2014      Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola <rm@gnu.org>
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

#import "MimeTypeEditorWindowController.h"

#import "Constants.h"
#import "MimeType.h"

#ifndef MACOSX
#import "MimeTypeEditorWindow.h"
#endif

#import "MimeTypeManager.h"

@implementation MimeTypeEditorWindowController

//
//
//
- (id) initWithWindowNibName: (NSString *) windowNibName
{
#ifdef MACOSX
  
  self = [super initWithWindowNibName: windowNibName];
  
#else
  MimeTypeEditorWindow *mimeTypeEditorWindow;

  mimeTypeEditorWindow = [[MimeTypeEditorWindow alloc] initWithContentRect: NSMakeRect(300,300,430,420)
						       styleMask: NSTitledWindowMask
						       backing: NSBackingStoreRetained
						       defer: NO];
 
  self = [super initWithWindow: mimeTypeEditorWindow];
  
  [mimeTypeEditorWindow layoutWindow];
  [mimeTypeEditorWindow setDelegate: self];

  // We link our outlets
  mimeTypeField = [mimeTypeEditorWindow mimeTypeField];
  fileExtensionsField = [mimeTypeEditorWindow fileExtensionsField];
  descriptionField = [mimeTypeEditorWindow descriptionField];
  dataHandlerCommandField = [mimeTypeEditorWindow dataHandlerCommandField];

  dataHandlerCommandButton = [mimeTypeEditorWindow dataHandlerCommandButton];
  iconButton = [mimeTypeEditorWindow iconButton];
  
  viewMatrix = [mimeTypeEditorWindow viewMatrix];
  actionMatrix = [mimeTypeEditorWindow actionMatrix];

  RELEASE(mimeTypeEditorWindow);
#endif

  [[self window] setTitle: _(@"Add a MIME type")];
  
  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"MimeTypeEditorWindowController: -dealloc");

  TEST_RELEASE(mimeType);
  
  [super dealloc];
}


//
// delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification
{
  //NSDebugLog(@"MimeTypeEditorWindowController: -windowWillClose");
  
  //AUTORELEASE(self);
}


//
//
//
- (void) windowDidLoad
{
  [self selectionHasChanged: nil];
}


//
// action methods
//
- (IBAction) okClicked: (id) sender
{
  MimeType *aMimeType;

  if ( [self mimeType] )
    {
      aMimeType = [self mimeType];
 
      [aMimeType setMimeType: [mimeTypeField stringValue] ];
      [aMimeType setFileExtensions: [fileExtensionsField stringValue] ];
      [aMimeType setDescription: [descriptionField stringValue] ];
      [aMimeType setView: [viewMatrix selectedRow] ];
      [aMimeType setAction: [actionMatrix selectedRow] ];
      [aMimeType setDataHandlerCommand: [dataHandlerCommandField stringValue] ];
      [aMimeType setIcon: [iconButton image] ];
    }
  else
    {
      aMimeType = [[MimeType alloc] init];
      
      [aMimeType setMimeType: [mimeTypeField stringValue] ];
      [aMimeType setFileExtensions: [fileExtensionsField stringValue] ];
      [aMimeType setDescription: [descriptionField stringValue] ];
      [aMimeType setView: [viewMatrix selectedRow] ];
      [aMimeType setAction: [actionMatrix selectedRow] ];
      [aMimeType setDataHandlerCommand: [dataHandlerCommandField stringValue] ];
      [aMimeType setIcon: [iconButton image] ];
      
      [[MimeTypeManager singleInstance] addMimeType: aMimeType];
      RELEASE(aMimeType);
    }

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
- (IBAction) chooseDataHandlerCommand: (id) sender
{
  NSArray *filesToOpen;
  NSOpenPanel *anOpenPanel;
  NSString *fileName;
  int count, result;
  
  anOpenPanel = [NSOpenPanel openPanel];
  [anOpenPanel setAllowsMultipleSelection:NO];
  result = [anOpenPanel runModalForDirectory:NSHomeDirectory() file:nil types:nil];
  
  if (result == NSOKButton)
    {
      filesToOpen = [anOpenPanel filenames];
      count = [filesToOpen count];
      
      if (count > 0)
	{
	  fileName = [filesToOpen objectAtIndex:0];
	  [dataHandlerCommandField setStringValue: fileName];
	}
    }
}


//
//
//
- (IBAction) chooseIcon: (id) sender
{
  NSArray *filesToOpen;
  NSOpenPanel *anOpenPanel;
  NSString *fileName;
  int count, result;

  anOpenPanel = [NSOpenPanel openPanel];
  [anOpenPanel setAllowsMultipleSelection:NO];
  result = [anOpenPanel runModalForDirectory:NSHomeDirectory() file:nil types:nil];
  
  if (result == NSOKButton)
    {
      filesToOpen = [anOpenPanel filenames];
      count = [filesToOpen count];
      
      if (count > 0)
	{
	  NSImage *anImage;

	  fileName = [filesToOpen objectAtIndex:0];

	  anImage = [[NSImage alloc] initWithContentsOfFile: fileName];

	  if (anImage)
	    {
	      [anImage setDataRetained: YES];
	      [iconButton setImage: anImage];
              [anImage release];
	    }
	}
    }
}


//
//
//
- (IBAction) selectionHasChanged : (id) sender
{
  switch ( [actionMatrix selectedRow] )
    {

    case 0:
    case 1:
      [dataHandlerCommandField setEditable: NO];
      [dataHandlerCommandButton setEnabled: NO];
      break;
      
    case 2:
      [dataHandlerCommandField setEditable: YES];
      [dataHandlerCommandButton setEnabled: YES];
      break;
      
    default:
      break;
    } 
}


//
// access/mutation methods
//
- (void) setMimeType: (MimeType *) theMimeType
{
  if ( theMimeType )
    {
      RETAIN(theMimeType);
      RELEASE(mimeType);
      mimeType = theMimeType;
    
      [mimeTypeField setStringValue: ([mimeType mimeType] ? (id)[mimeType mimeType] : (id)@"")];
      [fileExtensionsField setStringValue: ([mimeType stringValueOfFileExtensions] ? (id)[mimeType stringValueOfFileExtensions] : (id)@"")];
      [descriptionField setStringValue: ([mimeType description] ? (id)[mimeType description] : (id)@"")];
      [viewMatrix selectCellAtRow: [mimeType view] column: 0];
      [actionMatrix selectCellAtRow: [mimeType action] column: 0];
      [dataHandlerCommandField setStringValue: ([mimeType dataHandlerCommand] ? (id)[mimeType dataHandlerCommand] : (id)@"")];
      [iconButton setImage: [mimeType icon]];

      [[self window] setTitle: _(@"Edit a MIME type")];
    }
  else
    {
      RELEASE(mimeType);
      mimeType = nil;
    }
}

- (MimeType *) mimeType
{
  return mimeType;
}

@end
