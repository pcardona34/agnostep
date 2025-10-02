//
//  FSTableView+Layout.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 09-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableView+Layout.m,v 1.2 2014/01/26 09:23:53 buzzdee Exp $

#import "FSTableView.h"
#import "FSHeaderLayout.h"
#import <FlexiSheet.h>

#define TAB_HEIGHT   22
#define TABLE_PAD    3
#define LEFT_WIDTH   100

// Keys used in layout dictionary
NSString  *FSLayoutSizesKey    = @"Sizes";
NSString  *FSLayoutStylesKey   = @"Styles";


@implementation FSTableView (Layout)

- (int)_factorForSideCol:(int)col
{
    int result = 1;
    while (++col < _nHSide)
        result *= [[self _hloSide:col] keyCount];
    return result;
}


- (int)_factorForTopRow:(int)row
{
    int result = 1;
    while (++row < _nHTop)
        result *= [[self _hloTop:row] keyCount];
    return result;
}


- (void)_releaseCellAreaInformation
{
    int i;
    
    if (_topCA) {
        for (i = 0; i < _nHTop; i++) {
            free(_topCA[i]);
        }
        free(_topCA);
        _topCA = NULL;
    }
    if (_topNCA) {
        free(_topNCA);
        _topNCA = NULL;
    }
    
    if (_sideCA) {
        for (i = 0; i < _nHSide; i++) {
            free(_sideCA[i]);
        }
        free(_sideCA);
        _sideCA = NULL;
    }
    if (_sideNCA) {
        free(_sideNCA);
        _sideNCA = NULL;
    }
}


- (void)_createCellAreaInformation
{
    NSArray    *headers;
    int         hix;
    FSHeader   *hdr;
    id          hlo;
    NSArray    *groups;
    FSKeyGroup *group;
    NSArray    *hKeys;
    NSArray    *gKeys;
    int         idx;
    int         cnt;
    int         mult;

    // Top:
    headers = [dataSource topHeadersForTableView:self];
    hix = [headers count];
    if (hix > 0) {
        _topCA = malloc(sizeof(void*) * hix);
        _topNCA = malloc(sizeof(int) * hix);
        while (hix-- > 0) {
            hdr = [headers objectAtIndex:hix];
            hlo = [self _hloTop:hix];
            groups = [hdr subgroups];
            hKeys = [hdr keys];
            idx = [groups count];
            cnt = idx;
            mult = [self _factorForTopRow:hix];
            if (cnt > 0) {
                _topCA[hix] = malloc(sizeof(CellArea)*cnt);
                _topNCA[hix] = cnt;
                while (idx-- > 0) {
                    group = [groups objectAtIndex:idx];
                    gKeys = [group keys];
                    _topCA[hix][idx].range = NSMakeRange([hKeys indexOfObject:[gKeys objectAtIndex:0]]*mult, [gKeys count]*mult);
                    _topCA[hix][idx].offset = [hlo yOffsetForItem:group];
                    _topCA[hix][idx].length = [hlo sizeForItem:group].height;
                    _topCA[hix][idx].label = [group label];
                }
            } else {
                _topCA[hix] = malloc(1);
                _topNCA[hix] = 0;
            }
        }
    }
    // Side:
    headers = [dataSource sideHeadersForTableView:self];
    hix = [headers count];
    if (hix > 0) {
        _sideCA = malloc(sizeof(void*) * hix);
        _sideNCA = malloc(sizeof(int) * hix);
        while (hix-- > 0) {
            hdr = [headers objectAtIndex:hix];
            hlo = [self _hloSide:hix];
            groups = [hdr subgroups];
            hKeys = [hdr keys];
            idx = [groups count];
            cnt = idx;
            mult = [self _factorForSideCol:hix];
            if (cnt > 0) {
                _sideCA[hix] = malloc(sizeof(CellArea)*cnt);
                _sideNCA[hix] = cnt;
                while (idx-- > 0) {
                    group = [groups objectAtIndex:idx];
                    gKeys = [group keys];
                    _sideCA[hix][idx].range = NSMakeRange([hKeys indexOfObject:[gKeys objectAtIndex:0]]*mult, [gKeys count]*mult);
                    _sideCA[hix][idx].offset = [hlo xOffsetForItem:group];
                    _sideCA[hix][idx].length = [hlo sizeForItem:group].width;
                    _sideCA[hix][idx].label = [group label];
                }
            } else {
                _sideCA[hix] = malloc(1);
                _sideNCA[hix] = 0;
            }
        }
    }
}


- (void)adjustSizes
{
    float    sw = [NSScroller scrollerWidth];
    NSRect   controlFrame;
    NSSize   size = [self frame].size;
    float    bts = (_pageTabCount > 0)?TAB_HEIGHT:0;  // bottom tab size
    float    rts = (_rightTabCount > 0)?TAB_HEIGHT:0; // right tab size
    float    side = 0;
    float    top = 0;
    int      idx;
    NSArray *tH = [dataSource topHeadersForTableView:self];
    NSArray *sH = [dataSource sideHeadersForTableView:self];
    
    [self _releaseCellAreaInformation];
    
    _uniqueCols = [[[tH lastObject] keys] count];
    if ((idx = _nHTop = [tH count])) {
        while (idx-- > 0) {
            top += [[self _hloTop:idx] globalHeight];
        }
    } else top = 10;

    _uniqueRows = [[[sH lastObject] keys] count];
    if ((idx = _nHSide = [sH count])) {
        while (idx-- > 0) {
            side += [[self _hloSide:idx] globalWidth];
        }
    } else side = 10;
    
    // Scrollview
    controlFrame = NSMakeRect(side+TABLE_PAD, TABLE_PAD+bts,
        size.width-rts-side-2*TABLE_PAD, size.height-top-2*TABLE_PAD-bts);
    [_dataSV setFrame:controlFrame];

    // bottom page tabs
    if (_pageTabCount == 0) {
        [_pageTabs removeFromSuperview];
    } else {
        controlFrame = NSMakeRect(TABLE_PAD,0,size.width-2*TABLE_PAD-rts,TAB_HEIGHT);
        [_pageTabs setFrame:controlFrame];
        [self addSubview:_pageTabs];
    }

    // right page tabs
    if (_rightTabCount == 0) {
        [_rightTabs removeFromSuperview];
    } else {
        controlFrame = NSMakeRect(size.width-TAB_HEIGHT,TABLE_PAD+bts,TAB_HEIGHT,size.height-bts-2*TABLE_PAD);
        [_rightTabs setFrame:controlFrame];
        [self addSubview:_rightTabs];
    }

    // Header view
    controlFrame = NSMakeRect(side+TABLE_PAD, size.height-top-TABLE_PAD,
        size.width-side-sw-rts-2*TABLE_PAD, top);
    [_topClip setFrame:controlFrame];
    
    // Left view
    controlFrame = NSMakeRect(TABLE_PAD, sw+TABLE_PAD+bts,
        side, size.height-sw-top-2*TABLE_PAD-bts);
    [_sideClip setFrame:controlFrame];
    
    // Cache new additional cell area information
    [self _createCellAreaInformation];
    
    [self setNeedsDisplay:YES];
}


- (void)ensureSpaceForNewGroup:(FSKeyGroup*)group
{
    FSHeaderLayout *hlo = [_hlObjects objectForKey:[[group header] label]];
    [hlo ensureSpaceForItem:[[group items] lastObject]];
    [self cacheLayout];
}


/*" Sets the width property "*/
- (void)adjustWidthForKey:(FSKey*)item
{
    FSHeaderLayout *hlo = [_hlObjects objectForKey:[[item header] label]];
    NSSize size = [hlo sizeForItem:item];
    size.width = 55;
    [hlo setSize:size forItem:item];
    [self cacheLayout];
}


- (void)adjustAllCells
{
    FSHeader       *header = [[dataSource topHeadersForTableView:self] lastObject];
    FSHeaderLayout *hlo = [_hlObjects objectForKey:[header label]];
    NSUInteger      index;

    index = [header count];
    while (index-- > 0) {
        [hlo setWidth:55 atIndex:index];
    }

    [self cacheLayout];
}


- (NSDictionary*)layoutDictionary
{
    NSEnumerator        *cursor = [[[dataSource table] headers] objectEnumerator];
    FSHeader            *header;
    FSHeaderLayout      *hlo;
    NSMutableDictionary *sizes = [NSMutableDictionary dictionary];
    NSMutableDictionary *styles = [NSMutableDictionary dictionary];
    NSMutableDictionary *layout = [NSMutableDictionary dictionary];

    [self storeLayout];
    
    while (header = [cursor nextObject]) {
        hlo = [_hlObjects objectForKey:[header label]];
        if (hlo) {
            [sizes setObject:[hlo layoutDictionary]
                forKey:[header label]];
        }
    }
    [layout setObject:sizes forKey:FSLayoutSizesKey];
    [layout setObject:styles forKey:FSLayoutStylesKey];
    return layout;
}


- (FSHeaderLayout*)_hloTop:(int)idx
{
    NSArray  *tH = [dataSource topHeadersForTableView:self];
    FSHeader *hdr = (idx==-1)?[tH lastObject]:[tH objectAtIndex:idx];
    NSString *name = [hdr label];
    id        hlo = [_hlObjects objectForKey:name];
    
    if (hlo == nil) {
        hlo = [[FSHeaderLayout alloc] initWithHeader:hdr];
        [_hlObjects setObject:hlo forKey:name];
        [hlo _cacheKeys];
        [hlo setWindow:[self window]];
        [hlo release];
    }
    
    return hlo;
}


- (FSHeaderLayout*)_hloSide:(int)idx
{
    NSArray  *sH = [dataSource sideHeadersForTableView:self];
    FSHeader *hdr = (idx==-1)?[sH lastObject]:[sH objectAtIndex:idx];
    NSString *name = [hdr label];
    id        hlo = [_hlObjects objectForKey:name];
    
    if (hlo == nil) {
        hlo = [[FSHeaderLayout alloc] initWithHeader:hdr];
        [_hlObjects setObject:hlo forKey:name];
        [hlo _cacheKeys];
        [hlo setWindow:[self window]];
        [hlo release];
    }
    
    return hlo;
}


- (void)applyLayoutDictionary:(NSDictionary*)dict
{
    NSEnumerator   *cursor = [[[dataSource table] headers] objectEnumerator];
    FSHeader       *header;
    FSHeaderLayout *hlo;
    NSDictionary   *sizes = [dict objectForKey:FSLayoutSizesKey];
    //NSDictionary   *styles = [dict objectForKey:FSLayoutStylesKey];
    NSDictionary   *lDict;

    if (sizes == nil) {
        // files prior to version 5 stored hlo objects in the main
        // layout dictionary.  find them there.
        sizes = dict;
    }

    while (header = [cursor nextObject]) {
        hlo = [[FSHeaderLayout alloc] initWithHeader:header];
        lDict = [sizes objectForKey:[header label]];
        if (lDict) {
            [hlo setLayoutDictionary:lDict];
        }
        [_hlObjects setObject:hlo forKey:[header label]];
        [hlo setWindow:[self window]];
        [hlo release];
    }
    [self cacheLayout];
}


- (void)cacheLayout
/*" Calls reloadData afterwards. "*/
{
    _pageTabCount = [[dataSource pageHeadersForTableView:self] count];
    [_pageTabs setKeySets:[dataSource pageKeySetsForTableView:self]];

    _rightTabCount = [[dataSource rightHeadersForTableView:self] count];
    [_rightTabs setKeySets:[dataSource rightKeySetsForTableView:self]];
    
    _numberOfRows = [[dataSource sideKeySetsForTableView:self] count];
    _numberOfCols = [[dataSource topKeySetsForTableView:self] count];
    
    if (_cachedValues) free(_cachedValues);
    _cachedValues = malloc(sizeof(id) * _numberOfCols * _numberOfRows);
    bzero(_cachedValues, sizeof(id) * _numberOfCols * _numberOfRows);
    
    [self reloadData];
}


- (void)storeLayout
{
}


- (void)renameLayoutHintsForHeader:(FSHeader*)header newName:(NSString*)newName
{
    id value;
    if ((value = [_hlObjects objectForKey:[header label]])) {
        [_hlObjects setObject:value forKey:newName];
        [_hlObjects removeObjectForKey:[header label]];
    }
}


- (void)drawRect:(NSRect)rect
// -drawRect is located here because it needs layout information do do the propper drawing.
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect        b = [self bounds];
    float         bts = (_pageTabCount > 0)?TAB_HEIGHT:0;
    float         rts = (_rightTabCount > 0)?TAB_HEIGHT:0;
    NSPoint       corner;
    float         pad = 4*TABLE_PAD;
    float         sub = 2*pad;
    id            fresp = [[self window] firstResponder];
    
    NSDrawWindowBackground(rect);
    if ([fresp isKindOfClass:[NSTextView class]]) {
        if ([fresp isFieldEditor])
            fresp = [fresp delegate];
    }

    if ((fresp == _pageTabs) || (fresp == _rightTabs)) {
        [[NSColor selectedControlColor] set];
    } else {
        [[NSColor secondarySelectedControlColor] set];
    }

#if 1
    // Up
    [path moveToPoint:NSMakePoint(0, pad+bts)];
    [path relativeLineToPoint:NSMakePoint(0, b.size.height-bts-sub)];
    corner = NSMakePoint(0, pad);
    [path relativeCurveToPoint:NSMakePoint(pad, pad)
        controlPoint1:corner controlPoint2:corner];
    // Right
    [path relativeLineToPoint:NSMakePoint(b.size.width-sub-rts, 0)];
    corner = NSMakePoint(pad, 0);
    [path relativeCurveToPoint:NSMakePoint(pad, -pad)
        controlPoint1:corner controlPoint2:corner];
    // Down
    [path relativeLineToPoint:NSMakePoint(0, bts+sub-b.size.height)];
    corner = NSMakePoint(0, -pad);
    [path relativeCurveToPoint:NSMakePoint(-pad, -pad)
        controlPoint1:corner controlPoint2:corner];
    // Left
    [path relativeLineToPoint:NSMakePoint(-b.size.width+sub+rts, 0)];
    corner = NSMakePoint(-pad, 0);
    [path relativeCurveToPoint:NSMakePoint(-pad, pad)
        controlPoint1:corner controlPoint2:corner];
    [path closePath];
    [path fill];
#else
    b.origin.x += bts;
    b.size.width -= rts;
    NSRectFill(b);
#endif
}

@end
