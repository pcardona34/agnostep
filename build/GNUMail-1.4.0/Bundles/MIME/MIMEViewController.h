/*
**  MIMEViewController.h
**
**  Copyright (c) 2001, 2002, 2003 Ludovic Marcotte
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

#ifndef _GNUMail_H_MIMEViewController
#define _GNUMail_H_MIMEViewController

#import <AppKit/AppKit.h>

#include "PreferencesModule.h"

@interface MIMEViewController : NSObject <PreferencesModule>
{
  // Outlets
  IBOutlet id view;
  
  IBOutlet NSTableView *tableView;
  IBOutlet NSTableColumn *mimeTypesColumn;
  IBOutlet NSTableColumn *fileExtensionsColumn;
  IBOutlet NSButton *add;
  IBOutlet NSButton *delete;
  IBOutlet NSButton *edit;
  
  // Other ivars
}


//
// Data Source methods
//
- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView;
- (id)                      tableView: (NSTableView *)aTableView
 objectValueForTableColumn: (NSTableColumn *)aTableColumn 
                       row: (NSInteger)rowIndex;

//
// action methods
//
- (IBAction) add: (id) sender;
- (IBAction) delete: (id) sender;
- (IBAction) edit: (id) sender;

@end

#endif // _GNUMail_H_MIMEViewController
