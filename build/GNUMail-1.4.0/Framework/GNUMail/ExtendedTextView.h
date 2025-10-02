/*
**  ExtendedTextView.h
**
**  Copyright (c) 2002-2006 Ludovic Marcotte, Ujwal S. Sathyam
**
**  Author: Ujwal S. Sathyam <ujwal@setlurgroup.com>
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

#ifndef _GNUMail_H_ExtendedTextView
#define _GNUMail_H_ExtendedTextView

#import <AppKit/AppKit.h>

@class EditWindowController;

@interface ExtendedTextView : NSTextView
{
  NSCursor *cursor;
}


//
// Other methods
//
- (void) insertFile: (NSString *) theFilename;
- (void) insertImageData: (NSData *) theData
                filename: (NSString *) theFilename;
- (void) pasteAsQuoted: (id) sender;
- (void) updateCursorForLinks;

@end

#endif // _GNUMail_H_ExtendedTextView
