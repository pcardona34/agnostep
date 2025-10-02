/*  -*-objc-*-
 *  GSConsole.m: Implementation of the GSConsole Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: July 2002
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GSConsole.h"
#import "GNUstep.h"

@implementation GSConsole

- (void)dealloc
{
  RELEASE (textView);
  if (window && ([window isVisible]))
    {
      [window close];
    }
  RELEASE (window);
	
  [super dealloc];
}

- (id)init
{
  self = [super init];

  if (self)
    {		
      [NSBundle loadNibNamed: @"GSPdfConsole.gorm" owner: self];
      [window setDelegate: self];
      [window setTitle: @"Console"];
		
      if ([window setFrameUsingName: @"gsconsole"] == NO)
	{
	  [window setFrame: NSMakeRect(300, 200, 500, 333) display: NO];
  	}    	
    }
	
  return self;
}

- (NSWindow *)window
{
  return window;
}

- (NSTextView *)textView
{
  return textView;
}

- (BOOL)windowShouldClose:(id)sender
{
  [window saveFrameUsingName: @"gsconsole"];
  return YES;
}

@end



