/*
**  LabelWidget.m
**
**  Copyright (c) 2001, 2002, 2003 Ludovic Marcotte, Jonathan B. Leffert
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

#include "LabelWidget.h"

#include "Constants.h"

@implementation LabelWidget

- (id) initWithFrame: (NSRect) theFrame
{
  self = [super initWithFrame: theFrame];

  [self setEditable: NO];
  [self setSelectable: NO];
  [self setBezeled: NO];
  [self setDrawsBackground: NO];

  return self;
}

- (id) initWithFrame: (NSRect) theFrame label: (NSString *) theLabel
{
  self = [self initWithFrame: theFrame];
  
  if ( theLabel )
    {
      [self setStringValue: theLabel];
    }
  else
    {
      [self setStringValue: @""];
    }

  return self;
}

+ (id) labelWidgetWithFrame: (NSRect) theFrame label: (NSString *) theLabel
{
  LabelWidget *lw = [[self alloc] initWithFrame: theFrame
				  label: theLabel];

  return AUTORELEASE(lw);
}

+ (id) labelWidgetWithFrame: (NSRect) theFrame label: (NSString *) theLabel alignment: (int) theAlignment
{
  LabelWidget *lw = [[self alloc] initWithFrame: theFrame
				  label: theLabel];
  
  [lw setAlignment: theAlignment];
  
  return AUTORELEASE(lw);
}

@end
