/*
**  FilteringViewController.h
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_FilteringViewController
#define _GNUMail_H_FilteringViewController

#import <AppKit/AppKit.h>

#include "PreferencesModule.h"

@class FilterManager;

@interface FilteringViewController : NSObject <PreferencesModule>
{
  // Outlets
  IBOutlet id view;
  
  IBOutlet NSTableView *tableView;
  IBOutlet NSTableColumn *rulesColumn;
  IBOutlet NSTableColumn *activeColumn;
  IBOutlet NSButton *add;
  IBOutlet NSButton *delete;
  IBOutlet NSButton *edit;
  IBOutlet NSButton *duplicate;
  
  // Other ivars
  FilterManager *filterManager;
}


//
// action methods
//
- (IBAction) add: (id) sender;
- (IBAction) delete: (id) sender;
- (IBAction) duplicate: (id) sender;
- (IBAction) edit: (id) sender;
- (IBAction) moveDown: (id) sender;
- (IBAction) moveUp: (id) sender;

//
// other methods
//
- (NSNumber *) editFilter: (NSNumber *) theIndex;
@end


//
// Custom NSButton cell
//
@interface ExtendedButtonCell : NSButtonCell
{
  NSColor* color;
}
- (void) setColor: (NSColor *) theColor;
@end

#endif // _GNUMail_H_FilteringViewController
