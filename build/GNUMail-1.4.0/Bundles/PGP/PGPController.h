/*
**  PGPController.h
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
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

#ifndef _GNUMail_H_PGPController
#define _GNUMail_H_PGPController

#import <AppKit/AppKit.h>

#include "GNUMailBundle.h"
#include "PreferencesModule.h"

#define NOT_ENCRYPTED 0
#define ENCRYPTED 1

#define NOT_SIGNED 0
#define SIGNED 2

#define SIGNED_AND_ENCRYPTED 3

@class CWMessage;
@class PGPImageView;

//
// PGPController class;
//
@interface PGPController : NSObject <GNUMailBundle>
{
  // UI elements for our viewing and compose view
  NSButton *encrypt, *sign;  
  NSView *superview;

  NSImage *sImage, *eImage, *seImage;
  PGPImageView *view;

  // ivars
  NSMutableDictionary *passphraseCache;
  NSString *resourcePath;
  NSTimer *timer;
  id owner;
}


//
// action methods
//
- (IBAction) encryptClicked: (id) sender;
- (IBAction) signClicked: (id) sender;

//
// other methods
//
- (NSString *) gnumailBundleVersion;
- (void) updateAndRestartTimer;

@end

#endif // _GNUMail_H_PGPController
