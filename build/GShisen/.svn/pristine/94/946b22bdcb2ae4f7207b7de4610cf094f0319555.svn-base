/* 
 Project: GShisen
 
 Copyright (C) 2003-2009 The GNUstep Application Project
 
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "board.h"

@interface GShisen : NSObject
{
  IBOutlet NSWindow *win;
  IBOutlet GSBoard *board;
  IBOutlet NSPanel *askNamePanel;
  IBOutlet NSTextField *nameField;
  IBOutlet NSPanel *hallOfFamePanel;
  IBOutlet NSMatrix *scoresMatrix;
  NSView *myView;
}

+ (GShisen *)sharedshisen;


- (BOOL)applicationShouldTerminate:(id)sender;

- (IBAction)newGame:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)getHint:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)showHallOfFame:(id)sender;
- (IBAction)buttonOk:(id)sender;

- (NSString *)getUserName;

@end

