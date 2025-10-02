/*
**  FontsViewController.h
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

#ifndef _GNUMail_H_FontsViewController
#define _GNUMail_H_FontsViewController

#import <AppKit/AppKit.h>

#include "PreferencesModule.h"

@interface FontsViewController : NSObject <PreferencesModule>
{
  // Outlets
  IBOutlet id view;

  IBOutlet NSPopUpButton *headerNamePopUp;
  IBOutlet NSPopUpButton *headerNameSizePopUp;

  IBOutlet NSPopUpButton *headerValuePopUp;
  IBOutlet NSPopUpButton *headerValueSizePopUp;

  IBOutlet NSPopUpButton *messagePopUp;
  IBOutlet NSPopUpButton *messageSizePopUp;

  IBOutlet NSButton *checkbox;

  IBOutlet NSPopUpButton *plainTextMessagePopUp;
  IBOutlet NSPopUpButton *plainTextMessageSizePopUp;

#ifdef MACOSX 
  IBOutlet NSPopUpButton *messageListPopUp;
  IBOutlet NSPopUpButton *messageListSizePopUp;
#endif
 
  IBOutlet NSTextField *previewLabel;
  IBOutlet NSTextField *previewTextField;
}


//
// action methods
//
- (IBAction) checkboxClicked: (id) sender;
- (IBAction) selectionInPopUpHasChanged: (id) sender;

@end

//
// FontsViewController's private interface
//
@interface FontsViewController (Private)

- (void) _initializePopUpButtons;
- (void) _synchronizePopUpButtons;

@end

#endif // _GNUMail_H_FontsViewController
