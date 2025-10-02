/*
**  FindWindowController.h
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
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

#ifndef _GNUMail_H_FindWindowController
#define _GNUMail_H_FindWindowController

#import <AppKit/AppKit.h>

@class CWFolder;

@interface FindWindowController: NSWindowController
{
  // Outlets
  IBOutlet NSTextField *findField;
  IBOutlet NSTextField *foundLabel;
  IBOutlet NSButton *ignoreCaseButton;
  IBOutlet NSButton *regularExpressionButton;
  IBOutlet NSButton *findAllButton;
  IBOutlet NSButton *previousButton;
  IBOutlet NSButton *nextButton;
  IBOutlet NSMatrix *matrix;

  // Other ivar
  @private
    NSMutableArray *_indexes;
    CWFolder *_folder;
    int _location;
}

//
// action methods
//
- (IBAction) findAll: (id) sender;
- (IBAction) nextMessage: (id) sender;
- (IBAction) previousMessage: (id) sender;


//
// delegate methods
//
- (void) windowDidLoad;


//
// access/mutation methods
//
- (NSTextField *) findField;
- (void) setSearchResults: (NSArray *) theResults  forFolder: (CWFolder *) theFolder;

//
// class methods
//
+ (id) singleInstance;

@end
#endif // _GNUMail_H_FindWindowController
