/*
**  PGPViewController.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (c) 2017-2020 Riccardo Mottola
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

#include "PGPViewController.h"

#include "Constants.h"
#include "NSUserDefaults+Extensions.h"
#include "PGPController.h"

#ifndef MACOSX
#include "PGPView.h"
#endif

static PGPViewController *singleInstance = nil;

@implementation PGPViewController

- (id) initWithNibName: (NSString *) theName
{
  self = [super init];

#ifdef MACOSX
  
  if (![NSBundle loadNibNamed: theName  owner: self])
    {
      AUTORELEASE(self);
      return nil;
    }

  RETAIN(view);

#else
  // We link our view
  view = [[PGPView alloc] initWithParent: self];
  [view layoutView];

  // We link our outlets
  versionLabel = ((PGPView *)view)->versionLabel;
  gpgPathField = ((PGPView *)view)->gpgPathField;
  userEMailAddressField = ((PGPView *)view)->userEMailAddressField;
  useFromForSigning = ((PGPView *)view)->useFromForSigning;
  alwaysSign = ((PGPView *)view)->alwaysSign;
  alwaysEncrypt = ((PGPView *)view)->alwaysEncrypt;
  alwaysUseMultipartPGP = ((PGPView *)view)->alwaysUseMultipartPGP;
  removePassphraseFromCacheButton = ((PGPView *)view)->removePassphraseFromCacheButton;
  removePassphraseFromCacheField = ((PGPView *)view)->removePassphraseFromCacheField;
  usePinentryLoopback = ((PGPView *)view)->usePinentryLoopback;
#endif

  // We get our defaults for this panel
  [self initializeFromDefaults];

  // We set the version label value
  [versionLabel setStringValue: [NSString stringWithFormat: _(@"Version: %@"),
					  [[PGPController singleInstance] gnumailBundleVersion]]];

  return self;
}


//
//
//
- (void) dealloc
{
  singleInstance = nil;
  RELEASE(view);

  [super dealloc];
}


//
// action methods
//


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"pgp-mail" ofType: @"tiff"]]);
}

- (NSString *) name
{
  return _(@"PGP");
}

- (NSView *) view
{
  return view;
}

- (BOOL) hasChangesPending
{
  return YES;
}


//
//
//
- (void) initializeFromDefaults
{
  NSString *aString;

  //
  // GPG/PGP path
  //
  aString = [[NSUserDefaults standardUserDefaults] stringForKey: @"PGPBUNDLE_GPG_PATH"];
  
  if ( aString )
    {
      [gpgPathField setStringValue: aString];
    }
  else
    {
#ifdef MACOSX
      [gpgPathField setStringValue: @"/usr/local/bin/gpg"];
#else
      [gpgPathField setStringValue: @"/usr/bin/gpg"];
#endif
    }

  //
  // User's E-Mail address
  //
  aString = [[NSUserDefaults standardUserDefaults] stringForKey: @"PGPBUNDLE_USER_EMAIL_ADDRESS"];

  if (aString)
    {
      [userEMailAddressField setStringValue: aString];
    }
  else
    {
      [userEMailAddressField setStringValue: @""];
    }

  
  [useFromForSigning setState: [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_USE_FROM_FOR_SIGNING"
								      default: NSOnState]];
  
  [alwaysSign setState: [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_ALWAYS_SIGN"
							       default: NSOffState]];
  [alwaysEncrypt setState: [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_ALWAYS_ENCRYPT"
								  default: NSOffState]];

  [alwaysUseMultipartPGP setState: [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_ALWAYS_MULTIPART"
									  default: NSOffState]];
  
  [removePassphraseFromCacheButton setState: [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_PASSPHRASE_EXPIRY"
										    default: NSOffState]];
  [removePassphraseFromCacheField setIntValue: [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_PASSPHRASE_EXPIRY_VALUE"
										      default: 5]];

  [usePinentryLoopback setState: [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_GPG_PINELOOP"
								        default: NSOnState]];

  [self removePassphraseFromCacheButtonClicked: nil];
}


//
//
//
- (void) saveChanges
{
  int aValue;

  [[NSUserDefaults standardUserDefaults] setObject: [gpgPathField stringValue]
					 forKey: @"PGPBUNDLE_GPG_PATH"];
  
  [[NSUserDefaults standardUserDefaults] setObject: [userEMailAddressField stringValue]
					 forKey: @"PGPBUNDLE_USER_EMAIL_ADDRESS"];
  
  [[NSUserDefaults standardUserDefaults] setInteger: [useFromForSigning state]
					 forKey:  @"PGPBUNDLE_USE_FROM_FOR_SIGNING"];

  [[NSUserDefaults standardUserDefaults] setInteger: [alwaysUseMultipartPGP state]
					 forKey: @"PGPBUNDLE_ALWAYS_MULTIPART"];

  [[NSUserDefaults standardUserDefaults] setInteger: [removePassphraseFromCacheButton state]
					 forKey: @"PGPBUNDLE_PASSPHRASE_EXPIRY"];

  [[NSUserDefaults standardUserDefaults] setInteger: [alwaysSign state]
					 forKey: @"PGPBUNDLE_ALWAYS_SIGN"];

  [[NSUserDefaults standardUserDefaults] setInteger: [alwaysEncrypt state]
					 forKey: @"PGPBUNDLE_ALWAYS_ENCRYPT"];

  [[NSUserDefaults standardUserDefaults] setInteger: [usePinentryLoopback state]
					     forKey: @"PGPBUNDLE_GPG_PINELOOP"];

  aValue = [removePassphraseFromCacheField intValue];

  if (aValue <= 0) aValue = 5;

  //
  // We restart our timer if the value has changed
  //
  if (aValue != [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_PASSPHRASE_EXPIRY_VALUE"])
    {
      [[NSUserDefaults standardUserDefaults] setInteger: aValue
					     forKey: @"PGPBUNDLE_PASSPHRASE_EXPIRY_VALUE"];
      [[PGPController singleInstance] updateAndRestartTimer];
    }
}


//
// action methods
//
- (IBAction) removePassphraseFromCacheButtonClicked: (id) sender
{
  if ([removePassphraseFromCacheButton state] == NSOnState)
    {
      [removePassphraseFromCacheField setEditable: YES];
    }
  else
    {
      [removePassphraseFromCacheField setEditable: NO];
    }
}


//
// Dumb impementation to keep the compiler quiet.
//
- (int) mode { return MODE_STANDARD; };
- (void) setMode: (int) theMode { }


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[self alloc] initWithNibName: @"PGPView"];
    }

  return singleInstance;
}

@end
