/*
**  ExtendedTableView.h
**
**  Copyright (c) 2002-2006 Ludovic Marcotte, Francis Lachapelle
**
**  Author: Francis Lachapelle <francis@Sophos.ca>
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

#ifndef _GNUMail_H_ExtendedTableView
#define _GNUMail_H_ExtendedTableView

#import <AppKit/AppKit.h>

@interface ExtendedTableView : NSTableView
{
  NSMutableString *_typedString;
  NSString *_previousSortOrder;
  NSString *_currentSortOrder;
  BOOL _reverseOrder;
  BOOL _reloading;
}

- (NSImage *) dragImageForRows: (NSArray *) dragRows
                         event: (NSEvent *) dragEvent 
               dragImageOffset: (NSPointPointer) dragImageOffset;

- (void) setDropRow: (int) row
      dropOperation: (NSTableViewDropOperation) operation;

- (void) scrollIfNeeded;

- (void) setReverseOrder: (BOOL) theBOOL;
- (BOOL) isReverseOrder;

- (void) setReloading: (BOOL) theBOOL;
- (BOOL) isReloading;

- (NSString *) currentSortOrder;
- (void) setCurrentSortOrder: (NSString *) theCurrentOrder;

- (NSString *) previousSortOrder;
- (void) setPreviousSortOrder: (NSString *) thePreviousOrder;
@end

#endif // _GNUMail_H_ExtendedTableView
