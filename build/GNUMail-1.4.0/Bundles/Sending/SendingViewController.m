/*
**  SendingViewController.m
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

#include "SendingViewController.h"

#include "Constants.h"

#ifndef MACOSX
#include "SendingView.h"
#endif

#include <Pantomime/NSString+Extensions.h>

static SendingViewController *singleInstance = nil;


//
//
//
@implementation SendingViewController

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
  // We link our view and our outlets
  view = [[SendingView alloc] initWithParent: self];
  [view layoutView];

  headerTableView = ((SendingView *)view)->headerTableView;
  headerKeyColumn = ((SendingView *)view)->headerKeyColumn;
  headerValueColumn = ((SendingView *)view)->headerValueColumn;
  headerKeyField = ((SendingView *)view)->headerKeyField;
  headerValueField = ((SendingView *)view)->headerValueField;
#endif


  // We first initialize our dictionary of additional headers
  _values.allAdditionalHeaders = [[NSMutableDictionary alloc] init];

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

  RELEASE(_values.allAdditionalHeaders);
  RELEASE(view);

  [super dealloc];
}


//
// delegage/datasource methods
//
- (id)           tableView: (NSTableView *) aTableView
 objectValueForTableColumn: (NSTableColumn *) aTableColumn
                       row:(NSInteger) rowIndex
{
  NSArray *anArray;
  
  anArray = [[_values.allAdditionalHeaders allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
  
  if (aTableColumn == headerKeyColumn)
    {
      return [anArray objectAtIndex: rowIndex];
    }
  else
    {
      return [_values.allAdditionalHeaders objectForKey: [anArray objectAtIndex: rowIndex]];
    }

  // Never reached
  return @"";
}


//
//
//
- (void) tableViewSelectionDidChange:(NSNotification *) aNotification
{
  if ( [aNotification object] == headerTableView &&
       [headerTableView selectedRow] >= 0 )
    {
      NSArray *anArray;
      
      anArray = [[_values.allAdditionalHeaders allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
      
      [headerKeyField setStringValue: [anArray objectAtIndex: [headerTableView selectedRow]]];
      [headerValueField setStringValue:
			  [_values.allAdditionalHeaders objectForKey: [anArray objectAtIndex: 
									 [headerTableView selectedRow]]]];
    }
}


//
//
//
- (NSInteger) numberOfRowsInTableView: (NSTableView *) aTableView
{
  return [_values.allAdditionalHeaders count];
}


//
//
//
- (void) tableView: (NSTableView *) aTableView
    setObjectValue: (id) anObject
    forTableColumn: (NSTableColumn *) aTableColumn
	       row: (NSInteger) rowIndex
{
  NSArray *anArray;
  
  anArray = [[_values.allAdditionalHeaders allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
  
  if ( aTableColumn == headerKeyColumn )
    {
      NSString *aKey, *aValue;
      
      aKey =  [anArray objectAtIndex: rowIndex];
      aValue = [_values.allAdditionalHeaders objectForKey: aKey];
      RETAIN(aValue);
      [_values.allAdditionalHeaders removeObjectForKey: aKey];
      [_values.allAdditionalHeaders setObject: aValue forKey: anObject];
      RELEASE(aValue);
      
      [headerTableView reloadData];
      [headerTableView setNeedsDisplay: YES];
    }
  else if ( aTableColumn == headerValueColumn )
    {
      [_values.allAdditionalHeaders setObject: anObject forKey: [anArray objectAtIndex: rowIndex]];
    }
}


//
// Action methods
//
- (IBAction) addHeader: (id) sender
{
  NSString *aKey, *aValue;

  aKey = [[headerKeyField stringValue] stringByTrimmingWhiteSpaces];
  aValue = [[headerValueField stringValue] stringByTrimmingWhiteSpaces];

  if ( [aKey length] == 0 || [aValue length] == 0 )
    {
      NSBeep();
      return;
    }
  else
    {
      [_values.allAdditionalHeaders setObject: aValue forKey: aKey];
      
      [headerKeyField setStringValue: @""];
      [headerValueField setStringValue: @""];
      [headerTableView reloadData];
    }
}


//
//
//
- (IBAction) removeHeader: (id) sender
{
  if ([headerTableView selectedRow] >= 0)
    {
      NSArray *anArray;
      NSString *aKey;
      
      anArray = [[_values.allAdditionalHeaders allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
      aKey = [anArray objectAtIndex: [headerTableView selectedRow]];
      
      if ( aKey )
	{
	  [_values.allAdditionalHeaders removeObjectForKey: aKey];
	  [headerTableView reloadData];
	  [headerTableView setNeedsDisplay:YES];
	}
    }
  else
    {
      NSBeep();
    }
}


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"MailIcon_send" ofType: @"tiff"]]);
}


//
//
//
- (NSString *) name
{
  return _(@"Sending");
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
  // For the additional headers (ADDITIONALOUTGOINGHEADERS)  
  if ( [[NSUserDefaults standardUserDefaults] objectForKey: @"ADDITIONALOUTGOINGHEADERS"] )
    {
      [_values.allAdditionalHeaders addEntriesFromDictionary:
		[[NSUserDefaults standardUserDefaults] objectForKey: @"ADDITIONALOUTGOINGHEADERS"] ];
    
      [headerTableView reloadData];
    }
}


//
//
//
- (void) saveChanges
{
  // For the additional headers
  [[NSUserDefaults standardUserDefaults] setObject: _values.allAdditionalHeaders 
					 forKey: @"ADDITIONALOUTGOINGHEADERS"];
}


//
// class methods
//
+ (id) singleInstance
{
  if ( !singleInstance )
    {
      singleInstance = [[SendingViewController alloc] initWithNibName: @"SendingView"];
    }

  return singleInstance;
}

@end
