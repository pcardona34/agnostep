/*
**  PreferencesWindowController.m
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "PreferencesWindowController.h"

#import "ConsoleWindowController.h"
#import "Constants.h"
#import "GNUMail.h"
#import "MailWindowController.h"
#import "NSBundle+Extensions.h"
#import "NSUserDefaults+Extensions.h"

#import "GNUMailBundle.h"

static PreferencesWindowController *singleInstance = nil;


//
// Private interface
//
@interface PreferencesWindowController (Private)
- (void) _initializeModuleWithName: (NSString *) theName
                           atIndex: (int) theIndex;
- (void) _releaseLoadedBundles;
- (void) _selectCellWithTitle: (NSString *) theTitle;
@end

//
//
//
@implementation PreferencesWindowController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
  NSDictionary *allPreferences;

  self = [super initWithWindowNibName: windowNibName];

  // We copy the current preferences to a volatile domain
  allPreferences = [NSDictionary dictionaryWithDictionary: [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
 
  // FIXME - This cause a segfault on OS X when reloading a 2nd time the preferences panel
#ifndef MACOSX
  [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName: @"PREFERENCES"];
#endif
  [[NSUserDefaults standardUserDefaults] setVolatileDomain: allPreferences  forName: @"PREFERENCES"];

  // We set our window title
  [[self window] setTitle: _(@"Preferences Panel")];

  // We set our mode
  [self setMode: [[NSUserDefaults standardUserDefaults] integerForKey: @"PREFERENCES_MODE"  default: MODE_STANDARD]];

  // We initialize our matrix with the standard modules
  [self initializeWithStandardModules];

  // We then add our additional modules
  [self initializeWithOptionalModules];

  // We finally set our autosave window frame name and restore the one from the user's defaults.
  [[self window] setFrameAutosaveName: @"PreferencesWindow"];
  [[self window] setFrameUsingName: @"PreferencesWindow"];

  return self;
}


//
//
//
- (void) dealloc
{
  [self _releaseLoadedBundles];
  RELEASE(_allModules);
  [super dealloc];
}


//
// delegate methods
//
- (void) windowDidLoad
{
  // We maintain an array of opened modules
  _allModules = [[NSMutableDictionary alloc] initWithCapacity: 10];
}


//
//
//
- (void) windowWillClose: (NSNotification *) theNotification
{  
  // We save our current preferences setting (expert/normal)
  [[NSUserDefaults standardUserDefaults] setInteger: _mode  forKey: @"PREFERENCES_MODE"];
  AUTORELEASE(self);
  singleInstance = nil;
}


//
//
//
- (void) handleCellAction: (id) sender
{  
  id aModule;
  
  aModule = [_allModules objectForKey: [[matrix selectedCell] title]];

  if (aModule)
    {
      [self addModuleToView: aModule];
    }
  else
    {
      NSLog(@"Unable to load the %@ bundle.", [[matrix selectedCell] title]);
    }
}


//
// action methods
//
- (IBAction) cancelClicked: (id) sender
{
  [self close];
}


//
//
//
- (IBAction) expertClicked: (id) sender
{
  NSString *titleOfSelectedCell;
  
  titleOfSelectedCell = [[matrix selectedCell] stringValue];

  if (_mode == MODE_STANDARD)
    {
      [self setMode: MODE_EXPERT];
    }
  else
    {
      [self setMode: MODE_STANDARD];  
    }

  // We initialize our matrix with the standard modules
  [self initializeWithStandardModules];

  // We then add our additional modules
  [self initializeWithOptionalModules];

  // We reselect the right cell
  [self _selectCellWithTitle: titleOfSelectedCell];
}



//
//
//
- (IBAction) saveAndClose: (id) sender
{
  [self savePreferences: nil];
  [self close];
}


//
//
//
- (IBAction) savePreferences: (id) sender
{
  NSArray *allNames;
  id<PreferencesModule> aModule;
  int i;

  allNames = [_allModules allKeys];

  for (i = 0; i < [allNames count]; i++)
    {
      aModule = [_allModules objectForKey: [allNames objectAtIndex: i]];

      if ( [aModule hasChangesPending] )
	{
	  [aModule saveChanges];
	}
    }
  
  [[NSUserDefaults standardUserDefaults] synchronize];
}


//
// other methods
//
- (void) addModuleToView: (id<PreferencesModule>) aModule
{    
  if (aModule == nil)
    {
      return;
    }

  if ([box contentView] != [aModule view])
    {
#ifdef MACOSX
      NSRect aFrame;
      float delta;
      NSWindow *win = [self window];

      // Compute the height delta between the current module view and the new module view
      delta = [[aModule view] frame].size.height - [[box contentView] frame].size.height;

      [box setContentView: nil];

      // Resize the box
      aFrame = [box frame];
      aFrame.origin.y -= delta;
      aFrame.size.height += delta;

      [box setFrame: aFrame];

      // Resize the window
      aFrame = [win contentRectForFrameRect: [win frame]];

      aFrame.origin.y -= delta;
      aFrame.size.height += delta;

      aFrame = [win frameRectForContentRect: aFrame];
      [win setFrame: aFrame  display: YES  animate: YES];
#endif      
      [box setContentView: [aModule view]];
      [box setTitle: [aModule name]];
    }
}


//
//
//
- (void) initializeWithStandardModules
{
  if (_mode == MODE_STANDARD)
    {
      [matrix renewRows: 1  columns: 6];
      [self _initializeModuleWithName: @"Account"   atIndex: 0];
      [self _initializeModuleWithName: @"Viewing"   atIndex: 1];
      [self _initializeModuleWithName: @"Receiving" atIndex: 2];
      [self _initializeModuleWithName: @"Compose"   atIndex: 3];
      [self _initializeModuleWithName: @"Fonts"     atIndex: 4];
      [self _initializeModuleWithName: @"Colors"    atIndex: 5];
    }
  else
    {
      [matrix renewRows: 1  columns: 10];
      [self _initializeModuleWithName: @"Account"   atIndex: 0];
      [self _initializeModuleWithName: @"Viewing"   atIndex: 1];
      [self _initializeModuleWithName: @"Sending"   atIndex: 2];
      [self _initializeModuleWithName: @"Receiving" atIndex: 3];
      [self _initializeModuleWithName: @"Compose"   atIndex: 4];
      [self _initializeModuleWithName: @"Fonts"     atIndex: 5];
      [self _initializeModuleWithName: @"Colors"    atIndex: 6];
      [self _initializeModuleWithName: @"MIME"      atIndex: 7];
      [self _initializeModuleWithName: @"Filtering" atIndex: 8];
      [self _initializeModuleWithName: @"Advanced"  atIndex: 9];
    }
}


//
//
//
- (void) initializeWithOptionalModules
{
  int i;
  
  for (i = 0; i < [[GNUMail allBundles] count]; i++)
    {
      id<GNUMailBundle> aBundle;
      
      aBundle = [[GNUMail allBundles] objectAtIndex: i];
      
      if ( [aBundle hasPreferencesPanel] )
	{
	  id<PreferencesModule> aModule;
	  NSButtonCell *aButtonCell;
	  int column;

	  // We add our column
	  [matrix addColumn];
	  column = ([matrix numberOfColumns] - 1);

	  // We get our Preferences module and we add it to our matrix.
	  aModule = (id<PreferencesModule>)[aBundle preferencesModule];

	  [_allModules setObject: aModule  forKey: [aModule name]];
	  
	  aButtonCell = [matrix cellAtRow: 0
				column: column];
	  
	  [aButtonCell setTag: column];
	  [aButtonCell setTitle: [aModule name]];
#ifdef MACOSX
	  [aButtonCell setFont: [NSFont systemFontOfSize: 10]];
          [aButtonCell setButtonType: NSOnOffButton];
          [aButtonCell setBezelStyle: 0]; // not documented but I assume it means None :)
          [aButtonCell setBordered: NO];
          [aButtonCell setGradientType: NSGradientNone];
#else
	  [aButtonCell setFont: [NSFont systemFontOfSize: 8]];
#endif
	  [aButtonCell setImage: [aModule image]];
	}
    }

  [matrix sizeToCells];
  [matrix setNeedsDisplay: YES];
}


//
// access/mutation methods
//
- (NSMatrix *) matrix
{
  return matrix;
}


//
//
//
- (int) mode
{
  return _mode;
}


//
//
//
- (void) setMode: (int) theMode 
{
  _mode = theMode;
  
  if (_mode == MODE_EXPERT)
    {
      [expert setTitle: _(@"Standard")];
    }
  else
    {
      [expert setTitle: _(@"Expert")];
    }
}



//
// class methods
//
+ (id) singleInstance
{
  if ( !singleInstance )
    {
      singleInstance = [[PreferencesWindowController alloc] initWithWindowNibName: @"PreferencesWindow"];

      // We select the first cell in our matrix
      [[singleInstance matrix] selectCellAtRow: 0  column: 0];
      [singleInstance handleCellAction: [singleInstance matrix]];
    }
  else
    {
      return nil;
    }

  return singleInstance;
}

@end


//
// Private interface
//
@implementation PreferencesWindowController (Private)

- (void) _initializeModuleWithName: (NSString *) theName
			   atIndex: (int) theIndex
{
  id<PreferencesModule> aModule;
  NSButtonCell *aButtonCell;

  aModule = [NSBundle instanceForBundleWithName: theName];

  if (!aModule)
    {
      NSLog(@"Unable to initialize module %@", theName);
      return;
    }

  [_allModules setObject: aModule  forKey: _(theName)];
  
  aButtonCell = [matrix cellAtRow: 0  column: theIndex];
  [aButtonCell setTag: theIndex];
  [aButtonCell setTitle: [aModule name]];
#ifdef MACOSX
  [aButtonCell setFont: [NSFont systemFontOfSize: 10]];
#else
  [aButtonCell setFont: [NSFont systemFontOfSize: 8]];
#endif
  [aButtonCell setImage: [aModule image]];
}


//
//
//
- (void) _releaseLoadedBundles
{
  NSEnumerator *aEnumerator;
  id aModule;
  
  aEnumerator = [_allModules objectEnumerator];
 
  while ((aModule = [aEnumerator nextObject]))
    {
      RELEASE(aModule);
    }
}


//
//
//
- (void) _selectCellWithTitle: (NSString *) theTitle
{
  int i;

  for (i = 0; i < [matrix numberOfColumns]; i++)
    {
      if ( [theTitle isEqualToString: [[matrix cellAtRow: 0  column: i] stringValue]] )
        {
          [matrix selectCellAtRow: 0  column: i];
          [self addModuleToView: [_allModules objectForKey: theTitle]];
          return;
        }
    }

  // No cell found, we select the first one and perform the action
  [[singleInstance matrix] selectCellAtRow: 0  column: 0];
  [singleInstance handleCellAction: matrix];
  [self addModuleToView: [_allModules objectForKey: [[matrix selectedCell] title]]];
}


@end
