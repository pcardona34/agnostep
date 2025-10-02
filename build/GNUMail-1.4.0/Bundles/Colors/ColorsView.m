/*
**  ColorsView.m
**
**  Copyright (c) 2002, 2003 Ludovic Marcotte
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

#include "ColorsView.h"

#include "Constants.h"
#include "LabelWidget.h"

@implementation ColorsView

- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;
  [self setFrame:NSMakeRect(0,0,450,240)];

  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"ColorsView: -dealloc");

  RELEASE(colorQuoteLevelButton);

  RELEASE(level1ColorWell);
  RELEASE(level2ColorWell);
  RELEASE(level3ColorWell);
  RELEASE(level4ColorWell);

  RELEASE(mailHeaderCellColorWell);

  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *label;

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,195,430,35)
		       label: _(@"In this panel, you can set the colors used by GNUMail. For\nexample, you can set the colors used for the various quoting levels.")];
  [self addSubview: label];

  //
  // Our checkbox
  //
  colorQuoteLevelButton = [[NSButton alloc] initWithFrame: NSMakeRect(5,160,420,ButtonHeight)];
  [colorQuoteLevelButton setButtonType: NSSwitchButton];
  [colorQuoteLevelButton setBordered: NO];
  [colorQuoteLevelButton setTitle: _(@"Color quoted text")];
  [colorQuoteLevelButton setTarget: parent];
  [colorQuoteLevelButton setAction: @selector(colorQuoteLevelButtonClicked:)];
  [self addSubview: colorQuoteLevelButton ];

  //
  // Quote Level 1
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,130,70,TextFieldHeight)
		       label: _(@"Level One")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  level1ColorWell = [[NSColorWell alloc] initWithFrame: NSMakeRect(85,125,75,30)];
  [self addSubview: level1ColorWell];

  //
  // Quote Level 2
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,90,70,TextFieldHeight)
		       label: _(@"Level Two")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  level2ColorWell = [[NSColorWell alloc] initWithFrame: NSMakeRect(85,85,75,30)];
  [self addSubview: level2ColorWell];

  
  //
  // Quote Level 3
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(190,130,80,TextFieldHeight)
		       label: _(@"Level Three")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  level3ColorWell = [[NSColorWell alloc] initWithFrame: NSMakeRect(280,125,75,30)];
  [self addSubview: level3ColorWell];
  

  //
  // Quote Level 4
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(190,90,80,TextFieldHeight)
		       label: _(@"Level Four")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  level4ColorWell = [[NSColorWell alloc] initWithFrame: NSMakeRect(280,85,75,30)];
  [self addSubview: level4ColorWell];


  //
  // Mail Header cell
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,25,265,TextFieldHeight)
		       label: _(@"Color used in the message headers cell")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  mailHeaderCellColorWell = [[NSColorWell alloc] initWithFrame: NSMakeRect(280,20,75,30)];
  [self addSubview: mailHeaderCellColorWell];
  
}

@end
