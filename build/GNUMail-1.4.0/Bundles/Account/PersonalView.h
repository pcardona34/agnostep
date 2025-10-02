/*
**  PersonalView.h
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

#ifndef _GNUMail_H_PersonalView
#define _GNUMail_H_PersonalView

#import <AppKit/AppKit.h>

@class LabelWidget;

@interface PersonalView : NSView
{
  @public
    NSTextField *personalAccountNameField;
    NSTextField *personalNameField;
    NSTextField *personalEMailField;
    NSTextField *personalReplyToField;
    NSTextField *personalOrganizationField;

    NSPopUpButton *personalSignaturePopUp;
    NSTextField *personalSignatureField;

    NSButton *personalLocationButton;
    LabelWidget *personalLocationLabel;

  @private
    id parent;
}

- (id) initWithParent: (id) theParent;
- (void) layoutView;
- (void) dealloc;

@end

#endif // _GNUMail_H_PersonalView
