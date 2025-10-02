/*
**  ColorsViewController.h
**
**  Copyright (c) 2003 Ludovic Marcotte
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

#ifndef _GNUMail_H_ColorsViewController
#define _GNUMail_H_ColorsViewController

#import <AppKit/AppKit.h>

#include "PreferencesModule.h"


//
//
//
@interface ColorsViewController : NSObject <PreferencesModule>
{
  // Outlets
  IBOutlet id view;
  IBOutlet NSColorWell *level1ColorWell;
  IBOutlet NSColorWell *level2ColorWell;
  IBOutlet NSColorWell *level3ColorWell;
  IBOutlet NSColorWell *level4ColorWell;
  IBOutlet NSColorWell *mailHeaderCellColorWell;
  IBOutlet NSButton *colorQuoteLevelButton;

  // Other ivars
}


//
// action methods
//
- (IBAction) colorQuoteLevelButtonClicked: (id) sender;

@end

#endif // _GNUMail_H_ColorsViewController
