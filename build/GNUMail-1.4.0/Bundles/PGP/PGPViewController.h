/*
**  PGPViewController.h
**
**  Copyright (c) 2001-2005 Ludovic Marcotte
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

#ifndef _GNUMail_H_PGPViewController
#define _GNUMail_H_PGPViewController

#import <AppKit/AppKit.h>

#include "PreferencesModule.h"

@interface PGPViewController : NSObject <PreferencesModule>
{
  // Outlets
  IBOutlet id view;
  IBOutlet NSTextField *versionLabel;
  IBOutlet NSTextField *gpgPathField;
  IBOutlet NSTextField *userEMailAddressField;
  IBOutlet NSButton *useFromForSigning;
  IBOutlet NSButton *alwaysSign;
  IBOutlet NSButton *alwaysEncrypt;
  IBOutlet NSButton *alwaysUseMultipartPGP;
  IBOutlet NSButton *removePassphraseFromCacheButton;
  IBOutlet NSButton *usePinentryLoopback;
  IBOutlet NSTextField *removePassphraseFromCacheField;
}

//
// action methods
//
- (IBAction) removePassphraseFromCacheButtonClicked: (id) sender;

@end

#endif // _GNUMail_H_PGPViewController
