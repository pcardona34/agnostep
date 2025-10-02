/*
**  FolderNode.h
**
**  Copyright (C) 2001-2004 Ludovic Marcotte
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

#ifndef _GNUMail_H_FolderNode
#define _GNUMail_H_FolderNode

#import <Foundation/Foundation.h>


#if defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#ifndef NSUInteger
#define NSUInteger unsigned int
#endif
#ifndef NSInteger
#define NSInteger int
#endif
#endif


@interface FolderNode : NSObject <NSCopying>
{
  @private
    FolderNode *_parent;
    NSString *_name;
    NSString *_path;
  
    BOOL _subscribed;
    NSMutableArray *_children;
}

//
// access / mutation methods
//
- (NSString *) name;
- (void) setName: (NSString *) theName;

- (NSString *) path;
- (void) setPath: (NSString *) thePath;

- (FolderNode *) parent;
- (void) setParent: (FolderNode *) theParent;


- (BOOL) subscribed;
- (void) setSubscribed: (BOOL) theBOOL;

- (NSArray *) children;
- (void) setChildren: (NSArray *) theChildren;

- (void) addChild: (FolderNode *) theChild;
- (void) removeChild: (FolderNode *) theChild;

- (FolderNode *) childAtIndex: (NSUInteger) theIndex;
- (FolderNode *) childWithName: (NSString *) theName;

- (NSUInteger) childCount;


//
// Comparison
//
- (NSComparisonResult) compare: (FolderNode *) theFolderNode;


//
// class methods
//
+ (FolderNode *) folderNodeWithName: (NSString *) theName
                             parent: (FolderNode *) theParent;

@end

#endif // _GNUMail_H_FolderNode
