/*
**  LabelWidget.h
**
**  Copyright (c) 2001-2007 Ludovic Marcotte, Jonathan B. Leffert
**
**  Author: Jonathan B. Leffert <jonathan@leffert.net>
**          Ludovic Marcotte <ludovic@Sophos.ca>
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

#ifndef _GNUMail_H_LabelWidget
#define _GNUMail_H_LabelWidget

#import <AppKit/AppKit.h>

@interface LabelWidget: NSTextField

- (id) initWithFrame: (NSRect) theFrame;
- (id) initWithFrame: (NSRect) theFrame  label: (NSString *) theLabel;

+ (id) labelWidgetWithFrame: (NSRect) theFrame  label: (NSString *) theLabel;
+ (id) labelWidgetWithFrame: (NSRect) theFrame  label: (NSString *) theLabel  alignment: (int) theAlignment;

@end

#endif // _GNUMail_H_LabelWidget
