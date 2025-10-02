/*
**  ReceivingViewController.m
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

#include "ReceivingViewController.h"

#include "GNUMail.h"
#include "Constants.h"
#include "NSUserDefaults+Extensions.h"

#ifndef MACOSX
#include "ReceivingView.h"
#endif


static ReceivingViewController *singleInstance = nil;


//
//
//
@implementation ReceivingViewController

- (id) initWithNibName: (NSString *) theName
{
  self = [super init];

#ifdef MACOSX
  if (![NSBundle loadNibNamed: theName  owner: self] )
    {
      AUTORELEASE(self);
      return nil;
    }
  RETAIN(view);
#else
  // We link our views and our outlets
  view = [[ReceivingView alloc] initWithParent: self];
  [view layoutView];
  showFilterPanelButton = ((ReceivingView *)view)->showFilterPanelButton;
  showNoNewMessagesPanelButton = ((ReceivingView *)view)->showNoNewMessagesPanelButton;
  openMailboxAfterTransfer = ((ReceivingView *)view)->openMailboxAfterTransfer;
  playSoundButton = ((ReceivingView *)view)->playSoundButton;
  pathToSoundField = ((ReceivingView *)view)->pathToSoundField;
  chooseFileButton = ((ReceivingView *)view)->chooseFileButton;
#endif
    
  // We get our defaults for this panel
  [self initializeFromDefaults];

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
- (IBAction) chooseFileButtonClicked: (id) sender
{
  NSOpenPanel *oPanel;
  int result;
  
  oPanel = [NSOpenPanel openPanel];
  [oPanel setAllowsMultipleSelection: NO];
  result = [oPanel runModalForDirectory: [GNUMail currentWorkingPath]
		   file: nil 
		   types: nil];
  
  if (result == NSOKButton)
    {
      NSArray *fileToOpen;
      int count;
      
      fileToOpen = [oPanel filenames];
      count = [fileToOpen count];
      
      if (count > 0)
	{
	  NSString *aString;

	  aString = [fileToOpen objectAtIndex: 0];
	  [pathToSoundField setStringValue: aString];
	  [GNUMail setCurrentWorkingPath: [aString stringByDeletingLastPathComponent]];
	}
    }
}


//
//
//
- (IBAction) playSoundButtonClicked: (id) sender
{
  BOOL aBOOL;
 
  aBOOL = NO;

  if ([playSoundButton state] == NSOnState)
    {
      aBOOL = YES;
    }

  [pathToSoundField setEditable: aBOOL];
  [chooseFileButton setEnabled: aBOOL];
}


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"MailIcon_retrieve" ofType: @"tiff"]]);
}


//
//
//
- (NSString *) name
{
  return _(@"Receiving");
}


//
//
//
- (NSView *) view
{
  return view;
}


//
//
//
- (BOOL) hasChangesPending
{
  return YES;
}


//
//
//
- (void) initializeFromDefaults
{
  NSUserDefaults *aUserDefaults;

  aUserDefaults = [NSUserDefaults standardUserDefaults];
  [showFilterPanelButton setState: [aUserDefaults integerForKey: @"SHOW_FILTER_PANEL"  default: NSOnState]];
  [showNoNewMessagesPanelButton setState: [aUserDefaults integerForKey: @"SHOW_NO_NEW_MESSAGES_PANEL"  default: NSOnState]];
  [openMailboxAfterTransfer setState: [aUserDefaults integerForKey: @"OPEN_MAILBOX_AFTER_TRANSFER"  default: NSOffState]];
  
  if ([aUserDefaults objectForKey: @"PLAY_SOUND"])
    {
      [playSoundButton setState: [aUserDefaults integerForKey: @"PLAY_SOUND"]];
      [pathToSoundField setStringValue: [aUserDefaults stringForKey: @"PATH_TO_SOUND"]];
    }
  else
    {
      [playSoundButton setState: NSOffState];
      [pathToSoundField setStringValue: @""];
    }

  [self playSoundButtonClicked: self];
}


//
//
//
- (void) saveChanges
{  
  NSUserDefaults *aUserDefaults;

  aUserDefaults = [NSUserDefaults standardUserDefaults];
  [aUserDefaults setInteger: [showFilterPanelButton state] forKey: @"SHOW_FILTER_PANEL"];
  [aUserDefaults setInteger: [showNoNewMessagesPanelButton state]  forKey: @"SHOW_NO_NEW_MESSAGES_PANEL"];
  [aUserDefaults setInteger: [openMailboxAfterTransfer state]  forKey: @"OPEN_MAILBOX_AFTER_TRANSFER"];
  [aUserDefaults setInteger: [playSoundButton state]  forKey: @"PLAY_SOUND"];
  [aUserDefaults setObject: [pathToSoundField stringValue]  forKey: @"PATH_TO_SOUND"];
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[ReceivingViewController alloc] initWithNibName: @"ReceivingView"];
    }

  return singleInstance;
}

@end
