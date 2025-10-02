//
//  FSHeaderLayout.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 08-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSHeaderLayout.h,v 1.1 2008/10/14 15:03:45 hns Exp $

#import <Foundation/Foundation.h>
#import <FSCore/FSKeyGroup.h>

@class FSHeader, FSKeyGroup, FSKey;
@class NSWindow;

@interface FSHeaderLayout : NSObject
{
    NSMutableDictionary    *_dict;
    FSHeader               *_header;
    NSArray                *_keys;
    NSSize                 *_sizeCache;
    NSSize                  _globalSize;
    NSSize                  _totalSize;
    int                     _keyCount;
    int                     _itemDepth;
    NSWindow               *_window;
    int                     _defaultHeight;
}

- (id)initWithHeader:(FSHeader*)header;
- (void)_cacheKeys;
- (void)setWindow:(NSWindow*)window;

// Item depth
- (int)itemDepth;
- (int)keyCount;

// Global size is the height of top and width of left.
- (NSSize)globalSize;
- (float)globalWidth;
- (float)globalHeight;
- (void)setGlobalSize:(NSSize)size;
- (void)setGlobalWidth:(float)width;
- (void)setGlobalHeight:(float)height;

// Individual item sizes.  Item can be key or group.
// For keys: width is for top, height is for left.
// For groups: height is for top, width is for left.
- (NSSize)sizeForItem:(id)item;
- (void)setSize:(NSSize)size forItem:(id)item;

- (float)xOffsetForItem:(id<FSItem>)item;
- (float)yOffsetForItem:(id<FSItem>)item;

- (void)ensureSpaceForItem:(FSKey*)item;

// Cached values for keys
- (NSSize)sizeAtIndex:(int)index;
- (void)setSize:(NSSize)size atIndex:(int)index;
- (float)widthAtIndex:(int)index;
- (float)heightAtIndex:(int)index;
- (void)setWidth:(float)width atIndex:(int)index;
- (void)setHeight:(float)height atIndex:(int)index;

// For load/save, the complete layout dictionary
- (NSDictionary*)layoutDictionary;
- (void)setLayoutDictionary:(NSDictionary*)dictionary;

// Total size for a vertical/horizontal layout
- (NSSize)horizontalSize;
- (NSSize)verticalSize;

// Undo
- (void)undoableSetGlobalWidth:(float)width;
- (void)undoableSetGlobalHeight:(float)height;
- (void)undoableSetWidth:(float)width atIndex:(int)index;
- (void)undoableSetHeight:(float)height atIndex:(int)index;
- (void)undoableSetSize:(NSSize)size forItem:(id<FSItem>)item;

@end
