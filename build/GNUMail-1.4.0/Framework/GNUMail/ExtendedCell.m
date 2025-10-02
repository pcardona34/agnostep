/*
**  ExtendedCell.m
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
**                2020      Riccardo Mottola
**
**  Authors: Ludovic Marcotte <ludovic@Sophos.ca>
**           Riccardo Mottola
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

#include "ExtendedCell.h"

#include "Constants.h"

#include <Pantomime/CWConstants.h>
#include <Pantomime/CWFlags.h>

@implementation ExtendedCell

//
//
//
- (id) init
{
  self = [super init];
  if (self != nil)
    {
      _answered_flag = RETAIN([NSImage imageNamed: @"answered-flag.tiff"]);
      _recent_flag = RETAIN([NSImage imageNamed: @"recent-flag.tiff"]);
      _flagged_flag = RETAIN([NSImage imageNamed: @"flagged-flag.tiff"]);
      _flags = 0;
    }
  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"ExtendedCell: -dealloc");

  RELEASE(_answered_flag);
  RELEASE(_recent_flag);
  RELEASE(_flagged_flag);
    
  [super dealloc];
}


//
//
//
- (id) copyWithZone: (NSZone *) theZone 
{
  ExtendedCell *aCell;
  aCell = [[ExtendedCell alloc] init];
  [aCell setFlags: _flags];
  return aCell;
}


//
//
//
- (void) setFlags: (int) theFlags
{
  _flags = theFlags;
}


//
//
//
- (void) drawWithFrame: (NSRect) cellFrame 
		inView: (NSView *) controlView
{
  [super drawInteriorWithFrame: cellFrame 
	 inView: controlView];

  if ((_flags&PantomimeSeen) != PantomimeSeen) 
    {
      [_recent_flag compositeToPoint: NSMakePoint(cellFrame.origin.x+4,cellFrame.origin.y + 12)
		    operation: NSCompositeSourceAtop];
      return;
    }
  
  if ((_flags&PantomimeAnswered) == PantomimeAnswered)
    {
      [_answered_flag compositeToPoint: NSMakePoint(cellFrame.origin.x+4,cellFrame.origin.y + 12)
		      operation: NSCompositeSourceAtop];
      return;
    }

  if ((_flags&PantomimeFlagged) == PantomimeFlagged)
    {
      [_flagged_flag compositeToPoint: NSMakePoint(cellFrame.origin.x+4,cellFrame.origin.y + 12)
		     operation: NSCompositeSourceAtop];
      return;
    }
}

@end

