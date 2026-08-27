/* AppDelegate.m Application delegate for Ink application

   Copyright (C) 2011 Free Software Foundation, Inc.

   Author:  Wolfgang Lux <wolfgang.lux@gmail.com>
   Date: 2011
   
   This file is part of GNUstep.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSDocumentController.h>
#import <AppKit/NSDocument.h>
#import <AppKit/NSPasteboard.h>
#import "AppDelegate.h"

@implementation AppDelegate

/* Allowing Localized Info Panel */
- (void) showInfoPanel: (id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"InkInfo"
                           ofType: @"plist"];
  NSDictionary *localizedInfo = [NSDictionary 
     dictionaryWithContentsOfFile: path];
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo]; 
}

- (void) applicationDidFinishLaunching: (NSNotification *)not
{
  NS_DURING
    [NSApp setServicesProvider: self];
  NS_HANDLER
    NSLog(@"Caught exception in setServicesProvider: %@", localException);
  NS_ENDHANDLER
}

- (void) openSelection: (NSPasteboard *)pb
	      userData: (NSString *)userData
		 error: (NSString **)error
{
  NSArray *types = [pb types];
  NSDocument *doc =
    [[NSDocumentController sharedDocumentController]
       openUntitledDocumentAndDisplay: YES
				error: NULL];
  if (doc)
    {
      if ([types containsObject: NSRTFDPboardType])
	{
	  [doc loadDataRepresentation: [pb dataForType: NSRTFDPboardType]
			       ofType: @"rtfd"];
	}
      else if ([types containsObject: NSRTFPboardType])
	{
	  [doc loadDataRepresentation: [pb dataForType: NSRTFPboardType]
			       ofType: @"rtf"];
	}
      else if ([types containsObject: NSStringPboardType])
	{
	  [doc loadDataRepresentation: [pb dataForType: NSStringPboardType]
			       ofType: @"text"];
	}
      [doc updateChangeCount: NSChangeDone];
    }
}

- (void) openFile: (NSPasteboard *)pb
	 userData: (NSString *)userData
	    error: (NSString **)error
{
  int i, n;
  NSArray *files;
  NSArray *types = [pb types];
  NSDocumentController *sdc = [NSDocumentController sharedDocumentController];

  if ([types containsObject: NSFilenamesPboardType])
    {
      files = [pb propertyListForType: NSFilenamesPboardType];
    }
  else if ([types containsObject: NSStringPboardType])
    {
      files = [NSArray arrayWithObject: [pb stringForType: NSStringPboardType]];
    }
  else
    {
      files = nil;
    }

  for (i = 0, n = [files count]; i < n; i++)
    {
      NSString *filename = [files objectAtIndex: i];
      [sdc openDocumentWithContentsOfURL: [NSURL fileURLWithPath: filename]
				 display: YES
				   error: NULL];
    }
}

@end
