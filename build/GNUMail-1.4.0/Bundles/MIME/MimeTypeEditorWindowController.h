/*
**  MimeTypeEditorWindowController.h
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

#ifndef _GNUMail_H_MimeTypeEditorWindowController
#define _GNUMail_H_MimeTypeEditorWindowController

#import <AppKit/AppKit.h>

@class MimeType;

@interface MimeTypeEditorWindowController: NSWindowController
{
  // Outlets
  IBOutlet NSTextField *mimeTypeField;
  IBOutlet NSTextField *fileExtensionsField;
  IBOutlet NSTextField *descriptionField;
  IBOutlet NSTextField *dataHandlerCommandField;

  IBOutlet NSButton *dataHandlerCommandButton;
  IBOutlet NSButton *iconButton;
  
  IBOutlet NSMatrix *viewMatrix;
  IBOutlet NSMatrix *actionMatrix;
 
  // Other ivar
  MimeType *mimeType;
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

- (IBAction) chooseDataHandlerCommand: (id) sender;
- (IBAction) chooseIcon: (id) sender;

- (IBAction) selectionHasChanged : (id) sender;


//
// access/mutation methods
//
- (void) setMimeType: (MimeType *) theMimeType;
- (MimeType *) mimeType;

@end

#endif // _GNUMail_H_MimeTypeEditorWindowController
