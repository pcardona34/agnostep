/*
**  Views.h
**
**  Copyright (c) 2003-2004 Ludovic Marcotte
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

#ifndef _GNUMail_H_Views
#define _GNUMail_H_Views

#import <AppKit/AppKit.h>

@class LabelWidget;

//
// ChooseTypeView
//
@interface ChooseTypeView : NSView
{
  @public
    NSMatrix *matrix;

  @private;
  id owner;
}

- (id) initWithOwner: (id) theOwner;
- (void) layoutView;

@end


//
// ExplanationView
//
@interface ExplanationView : NSView
{
  @public
    NSButton *chooseButton;
    LabelWidget *explanationLabel;

  @private
    id owner;
}

- (id) initWithOwner: (id) theOwner;
- (void) layoutView;

@end


//
// ChooseMailboxView
//
@interface ChooseMailboxView : NSView
{
  @public
    NSTableView *tableView;

  @private
    id owner;
}

- (id) initWithOwner: (id) theOwner;
- (void) layoutView;

@end

#endif //  _GNUMail_H_Views
