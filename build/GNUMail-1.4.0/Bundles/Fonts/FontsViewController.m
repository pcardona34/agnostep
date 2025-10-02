/*
**  FontsViewController.m
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

#include "FontsViewController.h"

#include "Constants.h"
#include "NSFont+Extensions.h"

#ifndef MACOSX
#include "FontsView.h"
#endif

static FontsViewController *singleInstance = nil;

//
//
//
@implementation FontsViewController

- (id) initWithNibName: (NSString *) theName
{
  self = [super init];

#ifdef MACOSX
  if ( ![NSBundle loadNibNamed: theName
		  owner: self] )
    {
      AUTORELEASE(self);
      return nil;
    }
  RETAIN(view);
#else
  // We link our view
  view = [[FontsView alloc] initWithParent: self];
  [view layoutView];

  headerNamePopUp = ((FontsView *)view)->headerNamePopUp;
  headerNameSizePopUp = ((FontsView *)view)->headerNameSizePopUp;
  headerValuePopUp = ((FontsView *)view)->headerValuePopUp;
  headerValueSizePopUp = ((FontsView *)view)->headerValueSizePopUp;
  messagePopUp = ((FontsView *)view)->messagePopUp;
  messageSizePopUp = ((FontsView *)view)->messageSizePopUp;
  checkbox = ((FontsView *)view)->checkbox;
  plainTextMessagePopUp = ((FontsView *)view)->plainTextMessagePopUp;
  plainTextMessageSizePopUp = ((FontsView *)view)->plainTextMessageSizePopUp;
  previewLabel = (NSTextField *)((FontsView *)view)->previewLabel;
  previewTextField = ((FontsView *)view)->previewTextField;
#endif
    
  // We get our defaults for this panel
  [self _initializePopUpButtons];
  [self initializeFromDefaults];

  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"FontsViewController: -dealloc");

  singleInstance = nil;
  RELEASE(view);

  [super dealloc];
}


//
// action methods
//
- (IBAction) checkboxClicked: (id) sender
{
  if ( [checkbox state] == NSOnState )
    {
      [plainTextMessagePopUp setEnabled: YES];
      [plainTextMessageSizePopUp setEnabled: YES];
    }
  else
    {
      [plainTextMessagePopUp setEnabled: NO];
      [plainTextMessageSizePopUp setEnabled: NO];
    }
}


//
//
//
- (IBAction) selectionInPopUpHasChanged: (id) sender
{
  NSString *aLabel, *aFontName;
  NSFont *aFont;
  int aSize, aTrait;

  if ( ![sender isKindOfClass: [NSPopUpButton class]] )
    {
      return;
    }

  [self _synchronizePopUpButtons];
  
  if (sender == headerNamePopUp || sender == headerNameSizePopUp)
    {
      aLabel = _(@"Font preview for the header name:");
      aFontName = [headerNamePopUp titleOfSelectedItem];
      aSize = [[headerNameSizePopUp titleOfSelectedItem] intValue];
      aTrait = NSBoldFontMask;
    }
  else if (sender == headerValuePopUp || sender == headerValueSizePopUp)
    {
      aLabel = _(@"Font preview for the header value:");
      aFontName = [headerValuePopUp titleOfSelectedItem];
      aSize = [[headerValueSizePopUp titleOfSelectedItem] intValue];
      aTrait = NSUnboldFontMask;
    }
  else if (sender == messagePopUp || sender == messageSizePopUp)
    {
      aLabel = _(@"Font preview for the content of message:");
      aFontName = [messagePopUp titleOfSelectedItem];
      aSize = [[messageSizePopUp titleOfSelectedItem] intValue];
      aTrait = NSUnboldFontMask;
    }
#ifdef MACOSX
  else if (sender == messageListPopUp || sender == messageListSizePopUp)
    {
      aLabel = _(@"Font preview for the message list:");
      aFontName = [messageListPopUp titleOfSelectedItem];
      aSize = [[messageListSizePopUp titleOfSelectedItem] intValue];
      aTrait = NSUnboldFontMask;
    }
#endif
  else
    {
      aLabel = _(@"Font preview for the plain text:");
      aFontName = [plainTextMessagePopUp titleOfSelectedItem];
      aSize = [[plainTextMessageSizePopUp titleOfSelectedItem] intValue];
      aTrait = NSFixedPitchFontMask;
    }

  [previewLabel setStringValue: aLabel];
  
  aFont = [NSFont fontFromFamilyName: aFontName
		  trait: aTrait
		  size: aSize];
  
  [previewTextField setFont: aFont];

  [previewLabel setNeedsDisplay: YES];
  [previewTextField setNeedsDisplay: YES];
}


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"fonts" ofType: @"tiff"]]);
}


//
//
//
- (NSString *) name
{
  return _(@"Fonts");
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
  int aFontSize;

#ifdef MACOSX
  aFontSize = 13;
#else
  aFontSize = 0;
#endif

  //
  // Header name
  //
  if ( [[NSUserDefaults standardUserDefaults] objectForKey: @"HEADER_NAME_FONT_NAME"] )
    {
      [headerNamePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey: @"HEADER_NAME_FONT_NAME"]];
      [headerNameSizePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey: @"HEADER_NAME_FONT_SIZE"]];
    }
  else
    {
      NSFont *aFont;

      aFont = [NSFont systemFontOfSize: aFontSize];
      [headerNamePopUp selectItemWithTitle: [aFont familyName]];
      [headerNameSizePopUp selectItemWithTitle: [NSString stringWithFormat: @"%d", (int)[aFont pointSize]]];
    }
  
  //
  // Header value
  //
  if ( [[NSUserDefaults standardUserDefaults] objectForKey: @"HEADER_VALUE_FONT_NAME"] )
    {
      [headerValuePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey: @"HEADER_VALUE_FONT_NAME"]];
      [headerValueSizePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey: @"HEADER_VALUE_FONT_SIZE"]];
    }
  else
    {
      NSFont *aFont;
      
      aFont = [NSFont systemFontOfSize: aFontSize];
      [headerValuePopUp selectItemWithTitle: [aFont familyName]];
      [headerValueSizePopUp selectItemWithTitle: [NSString stringWithFormat: @"%d", (int)[aFont pointSize]]];
    }
  
  //
  // Message font
  //
  if ( [[NSUserDefaults standardUserDefaults] objectForKey: @"MESSAGE_FONT_NAME"] )
    {
      [messagePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey: @"MESSAGE_FONT_NAME"]];
      [messageSizePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey: @"MESSAGE_FONT_SIZE"]];
    }
  else
    {
      NSFont *aFont;
      
      aFont = [NSFont systemFontOfSize: aFontSize];
      [messagePopUp selectItemWithTitle: [aFont familyName]];
      [messageSizePopUp selectItemWithTitle: [NSString stringWithFormat: @"%d", (int)[aFont pointSize]]];
    }
  
  //
  // Plain text message font
  //
  if ( [[NSUserDefaults standardUserDefaults] objectForKey: @"USE_FIXED_FONT_FOR_TEXT_PLAIN_MESSAGES"] &&
       [[NSUserDefaults standardUserDefaults] integerForKey: @"USE_FIXED_FONT_FOR_TEXT_PLAIN_MESSAGES"] == NSOnState )
    {
      [checkbox setState: NSOnState];
      [plainTextMessagePopUp setEnabled: YES];
      [plainTextMessageSizePopUp setEnabled: YES];
    }
  else
    {
      [checkbox setState: NSOffState];
      [plainTextMessagePopUp setEnabled: NO];
      [plainTextMessageSizePopUp setEnabled: NO];
    }
  
  if ( [[NSUserDefaults standardUserDefaults] objectForKey: @"PLAIN_TEXT_MESSAGE_FONT_NAME"] )
    {
      [plainTextMessagePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] 
						    stringForKey: @"PLAIN_TEXT_MESSAGE_FONT_NAME"]];
      [plainTextMessageSizePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults]
							stringForKey: @"PLAIN_TEXT_MESSAGE_FONT_SIZE"]];
    }
  else
    {
      NSFont *aFont;
      
      aFont = [NSFont systemFontOfSize: aFontSize]; 
      [plainTextMessagePopUp selectItemWithTitle: [aFont familyName]];
      [plainTextMessageSizePopUp selectItemWithTitle: [NSString stringWithFormat: @"%d", (int)[aFont pointSize]]];
    }

#ifdef MACOSX
  //
  // Message list font
  //
  if ( [[NSUserDefaults standardUserDefaults] objectForKey: @"MESSAGE_LIST_FONT_NAME"] )
    {
      [messageListPopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey: @"MESSAGE_LIST_FONT_NAME"]];
      [messageListSizePopUp selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey: @"MESSAGE_LIST_FONT_SIZE"]];
    }
  else
    {
      NSFont *aFont;
      
      aFont = [NSFont systemFontOfSize: aFontSize];
      [messageListPopUp selectItemWithTitle: [aFont familyName]];
      [messageListSizePopUp selectItemWithTitle: [NSString stringWithFormat: @"%d", (int)[aFont pointSize]-2]];
    }
#endif
    

  // We 'select' the first popup button (so that the correct font is set in the label)
  [self selectionInPopUpHasChanged: headerNamePopUp];
}


//
//
//
- (void) saveChanges
{
  // We synchronize our popup buttons
  [self _synchronizePopUpButtons];

  [[NSUserDefaults standardUserDefaults] setObject: [headerNamePopUp titleOfSelectedItem]
                                         forKey: @"HEADER_NAME_FONT_NAME"];
  [[NSUserDefaults standardUserDefaults] setObject: [headerNameSizePopUp titleOfSelectedItem]
                                         forKey: @"HEADER_NAME_FONT_SIZE"];
  
  [[NSUserDefaults standardUserDefaults] setObject: [headerValuePopUp titleOfSelectedItem]
                                         forKey: @"HEADER_VALUE_FONT_NAME"];
  [[NSUserDefaults standardUserDefaults] setObject: [headerValueSizePopUp titleOfSelectedItem]
					 forKey: @"HEADER_VALUE_FONT_SIZE"];

  [[NSUserDefaults standardUserDefaults] setObject: [messagePopUp titleOfSelectedItem]
                                         forKey: @"MESSAGE_FONT_NAME"];
  [[NSUserDefaults standardUserDefaults] setObject: [messageSizePopUp titleOfSelectedItem]
                                         forKey: @"MESSAGE_FONT_SIZE"];

  [[NSUserDefaults standardUserDefaults] setInteger: [checkbox state]
					 forKey: @"USE_FIXED_FONT_FOR_TEXT_PLAIN_MESSAGES"];

  [[NSUserDefaults standardUserDefaults] setObject: [plainTextMessagePopUp titleOfSelectedItem]
					 forKey: @"PLAIN_TEXT_MESSAGE_FONT_NAME"];
  [[NSUserDefaults standardUserDefaults] setObject: [plainTextMessageSizePopUp titleOfSelectedItem]
                                         forKey: @"PLAIN_TEXT_MESSAGE_FONT_SIZE"];

#ifdef MACOSX
  [[NSUserDefaults standardUserDefaults] setObject: [messageListPopUp titleOfSelectedItem]
                                         forKey: @"MESSAGE_LIST_FONT_NAME"];
  [[NSUserDefaults standardUserDefaults] setObject: [messageListSizePopUp titleOfSelectedItem]
                                         forKey: @"MESSAGE_LIST_FONT_SIZE"];
#endif

  [NSFont updateCache];

  // FIXME - do not post if the fonts haven't changed
  [[NSNotificationCenter defaultCenter]
    postNotificationName: FontValuesHaveChanged
    object: nil
    userInfo: nil];
}


//
// class methods
//
+ (id) singleInstance
{
  if ( !singleInstance )
    {
      singleInstance = [[FontsViewController alloc] initWithNibName: @"FontsView"];
    }

  return singleInstance;
}

@end


//
// FontsViewController's private interface
//
@implementation FontsViewController (Private)

//
//
//
- (void) _initializePopUpButtons
{
  NSMutableArray *availableFontFamilies;

  availableFontFamilies = [[NSMutableArray alloc] initWithArray: [[NSFontManager sharedFontManager] availableFontFamilies]];
  [availableFontFamilies sortUsingSelector: @selector(compare:)];

  [headerNamePopUp removeAllItems];
  [headerNamePopUp addItemsWithTitles: availableFontFamilies];

  [headerValuePopUp removeAllItems];
  [headerValuePopUp addItemsWithTitles: availableFontFamilies];

  [messagePopUp removeAllItems];
  [messagePopUp addItemsWithTitles: availableFontFamilies];
  
  [plainTextMessagePopUp removeAllItems];
  [plainTextMessagePopUp addItemsWithTitles: availableFontFamilies];

#ifdef MACOSX
  [messageListPopUp removeAllItems];
  [messageListPopUp addItemsWithTitles: availableFontFamilies];
#endif

  RELEASE(availableFontFamilies);
}


//
//
//
- (void) _synchronizePopUpButtons
{
  [headerNamePopUp synchronizeTitleAndSelectedItem];
  [headerNameSizePopUp synchronizeTitleAndSelectedItem];
  [headerValuePopUp synchronizeTitleAndSelectedItem];
  [headerValueSizePopUp synchronizeTitleAndSelectedItem];
  [messagePopUp synchronizeTitleAndSelectedItem];
  [messageSizePopUp synchronizeTitleAndSelectedItem];
  [plainTextMessagePopUp synchronizeTitleAndSelectedItem];
  [plainTextMessageSizePopUp synchronizeTitleAndSelectedItem];
}

@end
