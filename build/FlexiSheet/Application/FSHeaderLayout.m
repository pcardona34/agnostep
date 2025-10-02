//
//  FSHeaderLayout.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 08-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//  2008-2010 GNUstep Application Project, Riccardo Mottola
//  
//  $Id: FSHeaderLayout.m,v 1.3 2010/09/22 21:59:32 rmottola Exp $

#import "FlexiSheet.h"

@implementation FSHeaderLayout

- (id)initWithHeader:(FSHeader*)header
{
    self = [super init];
    if (self)
      {
        _header = [header retain];
        _dict = [[NSMutableDictionary alloc] init];
        _keys = nil;
        _keyCount = 0;
        _itemDepth = 1;
        _sizeCache = NULL;
        _defaultHeight = 20;
        [FSLog logDebug:@"Default cell height is %i pixels.", _defaultHeight];
        _globalSize = NSMakeSize(80, _defaultHeight);
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(itemDidCangeName:)
            name:FSItemDidChangeNotification object:[_header table]];
      [FSLog logDebug:@"FSHeaderLayout created for header %@.", [_header label]];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[_header table] undoManager] removeAllActionsWithTarget:self];
    if (_sizeCache) free (_sizeCache);
    [_keys release];
    [_dict release];
    [_header release];
    [FSLog logDebug:@"FSHeaderLayout deallocated."];
    [super dealloc];
}


- (void)itemDidCangeName:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    id<FSItem>    item = [dict objectForKey:@"FSKey"];
    NSString     *oldPath = [dict objectForKey:FSOldPathUserInfo];
    id            value;
        
    if (item == nil) {
        // item is not a key.  Is it a group?
        item = [dict objectForKey:@"FSKeyGroup"];
        if (item) {
            NSArray  *keys = [_dict allKeys];
            int       idx = [keys count];
            NSString *pfx = [oldPath stringByAppendingString:@"."];
            NSString *key;
            NSString *path = [item fullPath];
            NSString *newKey;
            
            while (idx-- > 0) {
                key = [keys objectAtIndex:idx];
                if ([key hasPrefix:pfx]) {
                    value = [_dict objectForKey:key];
                    newKey = [path stringByAppendingString:
                        [key substringFromIndex:[oldPath length]]];
                    [value retain];
                    [_dict removeObjectForKey:key];
                    [_dict setObject:value forKey:newKey];
                    [value release];
                }
            }
        }
    }
    if (item) {
        if ((value = [_dict objectForKey:oldPath])) {
            [value retain];
            [_dict removeObjectForKey:oldPath];
            [_dict setObject:value forKey:[item fullPath]];
            [value release];
        }
    }
}


- (void)_cacheKeys
{
    int    idx;
    FSKey *key;
    int    depth;

    if (_sizeCache) free (_sizeCache);
    [_keys release];
    _keys = [[_header keys] retain];
    _keyCount = idx = [_keys count];
    _sizeCache = malloc(idx*sizeof(NSSize));
    _totalSize.width = 0;
    _totalSize.height = 0;
    while (idx-- > 0) {
        key = [_keys objectAtIndex:idx];
        depth = [[key groups] count]+1;
        if (depth > _itemDepth)
            _itemDepth = depth;
        _sizeCache[idx] = [self sizeForItem:key];
        _totalSize.width += _sizeCache[idx].width;
        _totalSize.height += _sizeCache[idx].height;
    }
    [FSLog logDebug:@"Header '%@' has depth %i.", [_header label], _itemDepth];
}


- (int)itemDepth
{
    return _itemDepth;
}


- (int)keyCount
{
    return _keyCount;
}


- (void)setWindow:(NSWindow*)window
{
    _window = window;
}

//
// Global size methods
//

- (NSSize)globalSize
{
    NSString *strg = [_dict objectForKey:@"__GLOBAL__"];
    if (strg)
        return NSSizeFromString(strg);
    return NSMakeSize(100, _defaultHeight);
}


- (float)globalWidth
{
    return _globalSize.width;
}


- (float)globalHeight
{
    return _globalSize.height;
}


- (void)setGlobalSize:(NSSize)size
{
    [_dict setObject:NSStringFromSize(size) forKey:@"__GLOBAL__"];
    _globalSize = size;
}


- (void)setGlobalWidth:(float)width
{
    if (width != _globalSize.width) {
        _globalSize.width = width;
        [_dict setObject:NSStringFromSize(_globalSize)
            forKey:@"__GLOBAL__"];        
    }
}


- (void)setGlobalHeight:(float)height
{
    if (height != _globalSize.height) {
        _globalSize.height = height;
        [_dict setObject:NSStringFromSize(_globalSize)
            forKey:@"__GLOBAL__"];        
    }
}


- (void)undoableSetGlobalWidth:(float)width
{
    float currentWidth = _globalSize.width;
    BOOL  post = (currentWidth != width);
    
    [[[[_header table] undoManager] prepareWithInvocationTarget:self]
        undoableSetGlobalWidth:currentWidth];
    [self setGlobalWidth:width];

    if (post) {
        [_window makeKeyAndOrderFront:nil];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:FSTableDidChangeNotification
            object:[_header table]];
    }
}


- (void)undoableSetGlobalHeight:(float)height
{
    float currentHeight = _globalSize.height;
    BOOL  post = (currentHeight != height);
    
    [[[[_header table] undoManager] prepareWithInvocationTarget:self]
        undoableSetGlobalHeight:currentHeight];
    [self setGlobalHeight:height];

    if (post) {
        [_window makeKeyAndOrderFront:nil];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:FSTableDidChangeNotification
            object:[_header table]];
    }
}

//
// Item size methods
//

- (NSSize)sizeForItem:(id)item
{
    NSString *strg = [_dict objectForKey:[item fullPath]];
    if (strg)
        return NSSizeFromString(strg);
    return NSMakeSize(80, _defaultHeight);
}


- (void)setSize:(NSSize)size forItem:(id)item
{
    [_dict setObject:NSStringFromSize(size) forKey:[item fullPath]];
}


- (NSSize)sizeAtIndex:(int)index
{
    return _sizeCache[index];
}


- (void)setSize:(NSSize)size atIndex:(int)index
{
    _sizeCache[index] = size;
    [self setSize:size forItem:[_keys objectAtIndex:index]];
}


- (float)widthAtIndex:(int)index
{
    return _sizeCache[index].width;
}


- (float)heightAtIndex:(int)index
{
    return _sizeCache[index].height;
}


- (void)setWidth:(float)width atIndex:(int)index
{
    if (_sizeCache[index].width != width) {
        _sizeCache[index].width = width;
        [self setSize:_sizeCache[index]
            forItem:[_keys objectAtIndex:index]];
    }
}


- (void)setHeight:(float)height atIndex:(int)index
{
    if (_sizeCache[index].height != height) {
        _sizeCache[index].height = height;
        [self setSize:_sizeCache[index]
            forItem:[_keys objectAtIndex:index]];
    }
}


- (void)undoableSetWidth:(float)width atIndex:(int)index
{
    float   currentWidth = _sizeCache[index].width;
    BOOL    post = (currentWidth != width);
    
    [[[[_header table] undoManager] prepareWithInvocationTarget:self]
        undoableSetWidth:currentWidth atIndex:index];
    
    [self setWidth:width atIndex:index];
    
    if (post) {
        [_window makeKeyAndOrderFront:nil];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:FSTableDidChangeNotification
            object:[_header table]];
    }
}


- (void)undoableSetHeight:(float)height atIndex:(int)index
{
    float   currentHeight = _sizeCache[index].height;
    BOOL    post = (currentHeight != height);
    
    [[[[_header table] undoManager] prepareWithInvocationTarget:self]
        undoableSetHeight:currentHeight atIndex:index];
    
    [self setHeight:height atIndex:index];
    
    if (post) {
        [_window makeKeyAndOrderFront:nil];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:FSTableDidChangeNotification
            object:[_header table]];
    }
}


- (void)undoableSetSize:(NSSize)size forItem:(id<FSItem>)item
/*" This should be used only for FSKeyGroup items, because
    it is a lot less efficient than the
    -undoable...:forIndex: methods. "*/
{
    NSSize currentSize = [self sizeForItem:item];
    BOOL    post = (NSEqualSizes(size, currentSize) == NO);
    
    [[[[_header table] undoManager] prepareWithInvocationTarget:self]
        undoableSetSize:currentSize forItem:item];

    
    if (post) {
        [self setSize:size forItem:item];
        [_window makeKeyAndOrderFront:nil];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:FSTableDidChangeNotification
            object:[_header table]];
    }
}


- (float)xOffsetForItem:(id<FSItem>)item
{
    NSArray    *groups = [item groups];
    float       offset = 0;
    int         idx = [groups count];
    FSKeyGroup *grp;
    
    while (idx-- > 0) {
        grp = [groups objectAtIndex:idx];
        offset += [self sizeForItem:grp].width;
    }
    
    return offset;
}


- (float)yOffsetForItem:(id<FSItem>)item
{
    NSArray    *groups = [item groups];
    float       offset = 0;
    int         idx = [groups count];
    FSKeyGroup *grp;
    
    while (idx-- > 0) {
        grp = [groups objectAtIndex:idx];
        offset += [self sizeForItem:grp].height;
    }
    
    return offset;
}


- (void)ensureSpaceForItem:(FSKey*)item
{
    float   xOffset = [self xOffsetForItem:item];
    float   yOffset = [self yOffsetForItem:item];

    if (xOffset+10 > [self globalWidth]) {
        [self setGlobalWidth:xOffset+10];
    }
    if (yOffset+10 > [self globalHeight]) {
        [self setGlobalHeight:yOffset+10];
    }
}

//
// Layout dictionary load/save methods
//

- (NSDictionary*)layoutDictionary
{
    return _dict;
}

- (void)setLayoutDictionary:(NSDictionary*)dictionary
{
    [_dict addEntriesFromDictionary:dictionary];
    _globalSize = [self globalSize];
    [self _cacheKeys];
}

//
// Total size of area
//

- (NSSize)horizontalSize
{
    NSSize   size = _globalSize;
    size.width = _totalSize.width;

    return size;
}

- (NSSize)verticalSize
{
    NSSize   size = _globalSize;
    size.height = _totalSize.height;
    
    return size;
}

@end
