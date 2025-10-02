/*
**  ConsoleWindowController.h
**
**  Copyright (C) 2001-2006 Ludovic Marcotte
**  Copyright (C) 2015      Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola <rm@gnu.org>
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

#ifndef _GNUMail_H_ConsoleWindowController
#define _GNUMail_H_ConsoleWindowController

#define ADD_CONSOLE_MESSAGE(format, args...) \
  [[ConsoleWindowController singleInstance] addConsoleMessage: [NSString stringWithFormat: format, ##args]];

#import <AppKit/AppKit.h>

@interface ConsoleWindowController: NSWindowController
{
  // Outlets
  IBOutlet NSTableView *tasksTableView;
  IBOutlet NSTableView *messagesTableView;
  IBOutlet NSBox *currentTaskBox;
  IBOutlet NSMenu *menu;
 
  // Other ivars
  NSMutableArray *allMessages;
}


//
// action methods
//
- (IBAction) deleteClicked: (id) sender;
- (IBAction) saveClicked: (id) sender;

//
// access / mutation method
//
- (NSTableView *) tasksTableView;
- (id) progressIndicators;

//
// other methods
//
- (void) addConsoleMessage: (NSString *) theString;
- (void) reload;
- (void) restoreImage;

//
// class methods
//
+ (id) singleInstance;

@end

#endif // _GNUMail_H_ConsoleWindowController


