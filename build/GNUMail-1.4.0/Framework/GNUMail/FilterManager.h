/*
**  FilterManager.h
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

#ifndef _GNUMail_H_FilterManager
#define _GNUMail_H_FilterManager

#import <AppKit/AppKit.h>

@class CWMessage;
@class CWURLName;
@class Filter;
@class FilterCriteria;

NSString *PathToFilters();

@interface FilterManager: NSObject <NSCoding>
{
  @private
    NSMutableArray *_filters;
}

- (BOOL) synchronize;


//
// access/mutation methods
//
- (Filter *) filterAtIndex: (int) theIndex;
- (void) addFilter: (Filter *) theFilter;
- (void) addFilter: (Filter *) theFilter
           atIndex: (int) theIndex;
- (void) removeFilter: (Filter *) theFilter;

- (NSArray *) filters;
- (void) setFilters: (NSArray *) theFilters;

- (BOOL) matchExistsForFilter: (Filter *) theFilter
                      message: (CWMessage *) theMessage;

- (Filter *) matchedFilterForMessage: (CWMessage *) theMessage
                                type: (int) theType;

- (Filter *) matchedFilterForMessageAsRawSource: (NSData *) theRawSource
                                           type: (int) theType;

- (NSColor *) colorForMessage: (CWMessage *) theMessage;

- (CWURLName *) matchedURLNameFromMessage: (CWMessage *) theMessage
	      	 		     type: (int) theType
				      key: (NSString *) theKey
                                   filter: (Filter *) theFilter;

- (CWURLName *) matchedURLNameFromMessageAsRawSource: (NSData *) theRawSource
                                                type: (int) theType
                                                 key: (NSString *) theKey
                                              filter: (Filter *) theFilter;

- (void) updateFiltersFromOldPath: (NSString *) theOldPath
                           toPath: (NSString *) thePath;
//
// class methods
//
+ (id) singleInstance;

@end

#endif // _GNUMail_H_FilterManager
