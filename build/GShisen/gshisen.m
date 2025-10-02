/* 
 Project: GShisen
 
 Copyright (C) 2003-2015 The GNUstep Application Project
 
 Author: Enrico Sersale, Riccardo Mottola
 
 Main Application
 
 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.
 
 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */

#import "gshisen.h"

static GShisen *sharedshisen = nil;

@implementation GShisen

+ (GShisen *)sharedshisen
{
    if(!sharedshisen) {
        NS_DURING
            {
                sharedshisen = [[self alloc] init];
            }
        NS_HANDLER
            {
                [localException raise];
            }
        NS_ENDHANDLER
            }
    return sharedshisen;
}

- (id)init
{
  sharedshisen = self;
  return sharedshisen;
}

- (void)dealloc
{
    [board release];
    [win release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [win center];
    [win display];
    [win orderFront:nil];
}

- (BOOL)applicationShouldTerminate:(id)sender 
{
    return YES;
}

- (void)newGame:(id)sender
{
    [board newGame];
}

- (void)pause:(id)sender
{
    [board pause];
}

- (void)undo:(id)sender
{
    [board undo];
}

- (void)getHint:(id)sender
{
    [board getHint];
}

- (NSString *)getUserName
{
  NSString *username;

  username = [nameField stringValue];
  if (!username || [username length] == 0)
    [nameField setStringValue:NSUserName()];
  
  [nameField selectText:self];
  [[NSApplication sharedApplication] runModalForWindow:askNamePanel];
  username = [nameField stringValue];
  
  return username;
}

- (IBAction)buttonOk:(id)sender
{	
  [askNamePanel orderOut: self];
  [[NSApplication sharedApplication] stopModal];
}

- (void)showHallOfFame:(id)sender
{
  NSMutableArray *scores;
  NSDictionary *scoresEntry;
  NSString *userName, *minutes, *seconds, *totTime;
  unsigned i;
  NSButtonCell *buttonCell;
  NSScrollView *scoresScroll;
  
  scores = [board scores];

  [hallOfFamePanel makeKeyAndOrderFront:self];


  buttonCell = [[NSButtonCell new] autorelease];
  [buttonCell setButtonType: NSPushOnPushOffButton];
  [buttonCell setBordered:NO];
  [buttonCell setAlignment:NSLeftTextAlignment];
											
  scoresScroll = [[NSScrollView alloc] initWithFrame: [[hallOfFamePanel contentView] frame]];
  [scoresScroll setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
  [scoresScroll setHasVerticalScroller: YES];
  [scoresScroll setHasHorizontalScroller: NO];
  [hallOfFamePanel setContentView: scoresScroll];
  [scoresScroll release];

  scoresMatrix = [[NSMatrix alloc] initWithFrame: NSMakeRect(0, 0, [[hallOfFamePanel contentView] frame].size.width, [scores count] * 18) mode:NSListModeMatrix
                                       prototype: buttonCell 
                                    numberOfRows: [scores count] 
                                 numberOfColumns: 3];
  
  [scoresMatrix setAutoresizingMask: NSViewWidthSizable];
  [scoresMatrix setAutosizesCells: YES];
  
  [scoresScroll setDocumentView: scoresMatrix];
  [scoresMatrix release];
		
  for(i = 0; i < [scores count]; i++)
  {
    NSString *dateOfGame;
    NSDate *date;
    NSCalendarDate *calDate;
    
    scoresEntry = [scores objectAtIndex: i];
    userName = [scoresEntry objectForKey: @"username"];
    minutes = [scoresEntry objectForKey: @"minutes"];
    seconds = [scoresEntry objectForKey: @"seconds"];
    date = [scoresEntry objectForKey: @"date"];
    if (date != nil)
      {
        calDate = [date dateWithCalendarFormat:nil timeZone:nil];
        dateOfGame = [calDate descriptionWithCalendarFormat:@"%Y-%m-%d"  locale: [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
        NSLog(@"date: %@", dateOfGame);
      }
    else
      {
        dateOfGame = @"";
      }
    totTime = [NSString stringWithFormat:@"%@:%@", minutes, seconds];
    //		[scoresMatrix addRow];
    [[scoresMatrix cellAtRow:i column:0] setTitle: dateOfGame];
    [[scoresMatrix cellAtRow:i column:1] setTitle: userName];
    [[scoresMatrix cellAtRow:i column:2] setTitle: totTime];
  }
	
  [hallOfFamePanel makeKeyAndOrderFront:self];
}


@end

