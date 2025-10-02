/*
**  NavigationToolbarItem.m
**
**  Copyright (c) 2004 Ludovic Marcotte
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

#include "NavigationToolbarItem.h"

#include "Constants.h"
#include "MailWindowController.h"
#include "MessageViewWindowController.h"

//
//
//
@interface NavigationView: NSView
{
  @public
    NSButton *up, *down;
}
@end

@implementation NavigationView

- (id) init
{
  self = [super init];

  [self setFrame: NSMakeRect(0,0,15,32)];

  up = [[NSButton alloc] initWithFrame: NSMakeRect(0,17,15,15)];
  [up setImagePosition: NSImageOnly];
  [up setBordered: NO];
  [up setImage: [NSImage imageNamed: @"up_15.tiff"]];
  [self addSubview: up];
  RELEASE(up);

  down = [[NSButton alloc] initWithFrame: NSMakeRect(0,0,15,15)];
  [down setImagePosition: NSImageOnly];
  [down setBordered: NO];
  [down setImage: [NSImage imageNamed: @"down_15.tiff"]];
  [self addSubview: down];
  RELEASE(down);

  return self;
}

@end



//
//
//
@implementation NavigationToolbarItem: NSToolbarItem

- (id) initWithItemIdentifier: (id) theIdentifier
{
  self = [super initWithItemIdentifier: theIdentifier];

  [self setView: AUTORELEASE([[NavigationView alloc] init])];

  return self;
}

- (void) setDelegate: (id) theDelegate
{
  _delegate = theDelegate;

  [((NavigationView *)[self view])->up setTarget: theDelegate];
  [((NavigationView *)[self view])->up setAction: @selector(previousMessage:)];
  [((NavigationView *)[self view])->down setTarget: theDelegate];
  [((NavigationView *)[self view])->down setAction: @selector(nextMessage:)];
}


- (void) validate
{
  id aController;
  int index;
 
  if ([_delegate isKindOfClass: [MessageViewWindowController class]])
    {
      aController = [(MessageViewWindowController *)_delegate mailWindowController];
#warning FIXME fix when MessageViewWindowController gets rewritten
      index = 1;
    }
  else
    {
      aController = _delegate;
      index = [[aController dataView] selectedRow];
    }

  [((NavigationView *)[self view])->up setEnabled: (index > 0)];
  [((NavigationView *)[self view])->down setEnabled: (index < ([[aController dataView] numberOfRows]-1))];
}

@end
