/*
**  AboutPanelController.m
**
**  Copyright (c) 2002-2005 Ludovic Marcotte
**  Copyright (c) 2017      Riccardo Mottola
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

#import "AboutPanelController.h"

#import "Utilities.h"
#import "Constants.h"

static AboutPanelController *singleInstance = nil;

//
//
//
@implementation AboutPanelController

- (id) initWithWindowNibName: (NSString *) windowNibName
{ 
  self = [super initWithWindowNibName: windowNibName];

  [[self window] setTitle: _(@"About GNUMail")];
  
  // We finally set our autosave window frame name and restore the one from the user's defaults.
  [[self window] setFrameAutosaveName: @"AboutPanel"];
  [[self window] setFrameUsingName: @"AboutPanel"];
 
  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"AboutPanelController: -dealloc");
  singleInstance = nil;
  [super dealloc];
}


//
// action methods
//


//
// delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification
{
  AUTORELEASE(self);
}

//
//
//
- (void) windowDidLoad
{
  [(NSPanel *)[self window] setFloatingPanel: YES];
  [versionLabel setStringValue: [NSString stringWithFormat: _(@"GNUMail Version %@  - %@"), GNUMailVersion(), GNUMailBaseURL()]];
  [copyrightLabel setStringValue: GNUMailCopyrightInfo()];
}


//
// class methods
//
+ (id) singleInstance
{
  if ( !singleInstance )
    {
      singleInstance = [[AboutPanelController alloc] initWithWindowNibName: @"AboutPanel"];
    }

  return singleInstance;
}

@end
