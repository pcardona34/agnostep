/*
**  SendingViewController.h
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

#ifndef _GNUMail_H_SendingViewController
#define _GNUMail_H_SendingViewController

#import <AppKit/AppKit.h>

#include "PreferencesModule.h"

@interface SendingViewController : NSObject <PreferencesModule>
{
  // Outlets
  IBOutlet id view;

  IBOutlet NSTableView *headerTableView;
  IBOutlet NSTableColumn *headerKeyColumn;
  IBOutlet NSTableColumn *headerValueColumn;

  IBOutlet NSTextField *headerKeyField;
  IBOutlet NSTextField *headerValueField;

  // Values
  struct {
    NSMutableDictionary *allAdditionalHeaders;
  } _values;
}


//
// action methods
//
- (IBAction) addHeader: (id) sender;
- (IBAction) removeHeader: (id) sender;

@end


#endif // _GNUMail_H_SendingViewController
