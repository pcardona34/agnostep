/*
**  ReceivingViewController.h
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_ReceivingViewController
#define _GNUMail_H_ReceivingViewController

#import <AppKit/AppKit.h>

#include "PreferencesModule.h"

@interface ReceivingViewController : NSObject <PreferencesModule>
{
  // Outlets
  IBOutlet id view;
  
  IBOutlet NSButton *showFilterPanelButton;
  IBOutlet NSButton *showNoNewMessagesPanelButton;
  IBOutlet NSButton *openMailboxAfterTransfer;
  IBOutlet NSButton *playSoundButton;
  IBOutlet NSTextField *pathToSoundField;
  IBOutlet NSButton *chooseFileButton;
}


//
// action methods
//
- (IBAction) chooseFileButtonClicked: (id) sender;
- (IBAction) playSoundButtonClicked: (id) sender;

@end

#endif // _GNUMail_H_ReceivingViewController
