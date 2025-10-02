/*
**  PreferencesWindowController.h
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

#ifndef _GNUMail_H_PreferencesWindowController
#define _GNUMail_H_PreferencesWindowController

#import <AppKit/AppKit.h>

#import "PreferencesModule.h"

@interface PreferencesWindowController: NSWindowController
{
  // Outlets
  IBOutlet NSMatrix *matrix;
  IBOutlet NSScrollView *scrollView;
  IBOutlet NSBox *box;
  IBOutlet NSButton *expert;

  // Other ivars
  @private
    NSMutableDictionary *_allModules;
    int _mode;
}

//
// action methods
//
- (IBAction) cancelClicked: (id) sender;
- (IBAction) expertClicked: (id) sender;
- (IBAction) saveAndClose: (id) sender;
- (IBAction) savePreferences: (id) sender;
- (void) handleCellAction: (id) sender;

//
// other methods
//
- (void) addModuleToView: (id<PreferencesModule>) aModule;
- (void) initializeWithStandardModules;
- (void) initializeWithOptionalModules;


//
// access/mutation methods
//
- (NSMatrix *) matrix;
- (int) mode;
- (void) setMode: (int) theMode;


//
// class methods
//
+ (id) singleInstance;

@end

#endif // _GNUMail_H_PreferencesWindowController
