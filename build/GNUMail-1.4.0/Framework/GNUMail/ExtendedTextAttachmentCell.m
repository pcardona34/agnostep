/*
**  ExtendedTextAttachmentCell.m
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
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


#include "ExtendedTextAttachmentCell.h"

#include "Constants.h"

#include <Pantomime/CWPart.h>

//
//
//
@implementation ExtendedTextAttachmentCell

- (id) initWithFilename: (NSString *) theFilename
		   size: (int) theSize
{
  NSMutableDictionary *attributes;
  NSString *aString;

  self = [super init];
  _part = nil;
  
  // We create our string that we'll display under the attachment cell
  if ( (theSize / 1024) == 0 )
    {
      aString = [NSString stringWithFormat: _(@"%@ (%d bytes)"), theFilename, theSize];
    }
  else
    {
      aString = [NSString stringWithFormat: _(@"%@ (%d KB)"), theFilename, theSize/1024];
    }
  
  // We create a set of attributes (base font, color red)
  attributes = [[NSMutableDictionary alloc] init];
  [attributes setObject: [NSColor redColor]
	      forKey: NSForegroundColorAttributeName];
  
#ifdef MACOSX
  [attributes setObject: [NSFont systemFontOfSize: 10]
	      forKey: NSFontAttributeName];
#else
  [attributes setObject: [NSFont systemFontOfSize: 0]
	      forKey: NSFontAttributeName];
#endif

  _attributedString = [[NSAttributedString alloc] initWithString: aString
						  attributes: attributes];
  
  RELEASE(attributes);

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_attributedString);
  TEST_RELEASE(_part);
  [super dealloc];
}


//
//
//
- (NSSize) cellSize
{
  NSSize aSize;
  
  aSize = [super cellSize];
  
  aSize.height += 15;
  
  if (aSize.width < [_attributedString size].width)
    {
      aSize.width = [_attributedString size].width;
    }

  return aSize;
}


//
//
//
- (void) drawWithFrame: (NSRect) cellFrame 
		inView: (NSView *) controlView
{
  int delta;
  
  cellFrame.origin.y -= 7.5;
  [super drawWithFrame: cellFrame inView: controlView];
  
  if ([self cellSize].width > [_attributedString size].width)
    {
      delta = ([self cellSize].width/2) - ([_attributedString size].width/2);
    }
  else
    {
      delta = 0;
    }

  [_attributedString drawInRect: NSMakeRect(cellFrame.origin.x + delta, 
					    cellFrame.origin.y + 
					    cellFrame.size.height - 5,
					    cellFrame.size.width,
					    15) ];
}


//
// access/mutation methods
//
- (CWPart *) part
{
  return _part;
}

- (void) setPart: (CWPart *) thePart
{
  ASSIGN(_part, thePart);
}

@end
