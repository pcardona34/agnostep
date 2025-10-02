//
//  FSTableView.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 24-AUG-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableView.m,v 1.1 2008/10/28 13:10:31 hns Exp $

#import "FlexiSheet.h"
#import <FSCore/FSHashMap.h>

@implementation FSTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float   sw = [NSScroller scrollerWidth];
        NSRect  controlFrame;
        NSSize  size = frame.size;
        
        _styles = [[FSHashMap alloc] init];
        _defaultStyle = [[FSCellStyle alloc] init];
        _headerStyle = [[FSCellStyle alloc] init];
        [_headerStyle setAlignment:NSLeftTextAlignment];

        _hlObjects = [[NSMutableDictionary alloc] init];
        _cachedValues = malloc(sizeof(id));
        _topCA = NULL;
        _sideCA = NULL;
        
        // Tab structures
        _pageTabCount = 0;
        _numberOfRows = 1;
        _numberOfCols = 1;
        
        // Create data view (the scrollview)
        controlFrame = NSMakeRect(100, 0, size.width-100, size.height-20);
        _dataSV = [[NSClassFromString(@"_FSScrollView") alloc] 
            initWithFrame:controlFrame];
        _dataMatrix = [[FSMatrix alloc] initWithFrame:NSMakeRect(0,0,200,200)];
        [_dataSV setDocumentView:_dataMatrix];
        [_dataSV setBackgroundColor:[NSColor whiteColor]];
        [_dataSV setBorderType:NSNoBorder];
        [_dataSV setHasHorizontalScroller:YES];
        [_dataSV setHasVerticalScroller:YES];
        [_dataSV setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
        [self addSubview:_dataSV];

        // Create bottom page tabs
        controlFrame = NSMakeRect(0, 0, 100, 20);
        _pageTabs = [[FSTableTabs alloc] initWithFrame:controlFrame];
        [_pageTabs setOrientation:FSAtBottom];
        [_pageTabs setAutoresizingMask:NSViewWidthSizable|NSViewMaxYMargin];

        // Create right page tabs
        controlFrame = NSMakeRect(0, 0, 20, 100);
        _rightTabs = [[FSTableTabs alloc] initWithFrame:controlFrame];
        [_rightTabs setOrientation:FSRightSide];
        [_rightTabs setAutoresizingMask:NSViewHeightSizable|NSViewMinXMargin];

        // Create header view
        controlFrame = NSMakeRect(100, size.height-20, size.width-100-sw, 20);
        _topClip = [[NSClipView alloc] initWithFrame:controlFrame];
        _topMatrix = [[FSVarioMatrix alloc] initWithFrame:NSMakeRect(0,0,200,200)];
        [_topMatrix setHeaderMatrix:YES];
        [_topClip setDocumentView:_topMatrix];
        [_topClip setDrawsBackground:NO];
        [_topClip setCopiesOnScroll:YES];
        [_topClip setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
        [self addSubview:_topClip];

        // Create left view
        controlFrame = NSMakeRect(0, sw, 100, size.height-sw-20);
        _sideClip = [[NSClipView alloc] initWithFrame:controlFrame];
        _sideMatrix = [[FSVarioMatrix alloc] initWithFrame:NSMakeRect(0,0,200,200)];
        [_sideMatrix setHeaderMatrix:YES];
        [_sideClip setDocumentView:_sideMatrix];
        [_sideClip setDrawsBackground:NO];
        [_sideClip setCopiesOnScroll:YES];
        [_sideClip setAutoresizingMask:NSViewHeightSizable];
        [self addSubview:_sideClip];

        // Set selection
        _cellSelection = FSMakeCell(-1,-1);
                
        [self adjustSizes];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_cachedValues) free(_cachedValues);
    [_pageTabs release];
    [_rightTabs release];
    [_topMatrix release];
    [_sideMatrix release];
    [_dataMatrix release];
    [_dataSV release];
    [_topClip release];
    [_sideClip release];
    [_styles release];
    [_defaultStyle release];
    [_headerStyle release];
    [_hlObjects release];
    [_selection release];
    [_selRange release];
    [super dealloc];
}


- (void)reflectPageTabChange
{
    [[self window] endEditingFor:nil];
    if (_cachedValues) free(_cachedValues);
    _cachedValues = malloc(sizeof(id) * _numberOfCols * _numberOfRows);
    bzero(_cachedValues, sizeof(id) * _numberOfCols * _numberOfRows);
    [_dataMatrix reloadData];
    [self setNeedsDisplay:YES];
}


- (FSKeySet*)keySetForTabSelection
{
    FSKeySet *pageKS = [_pageTabs selectedKeySet];
    FSKeySet *rightKS = [_rightTabs selectedKeySet];

    if (pageKS == nil)  return rightKS;
    if (rightKS == nil) return nil;
    return [pageKS setByAddingKeys:rightKS];
}


- (void)keyDown:(NSEvent*)event
{
    if (_dataSelected) { // Do we have a cell selection?
        switch ([[event characters] characterAtIndex:0]) {
            case NSUpArrowFunctionKey:
            case NSDownArrowFunctionKey:
            case NSLeftArrowFunctionKey:
            case NSRightArrowFunctionKey:
                [self interpretKeyEvents:[NSArray arrayWithObject:event]];
                break;
            case 3:
            case 13:
                event = nil;
                // fall-thru
            default:
                [_dataMatrix startEditingCell:_cellSelection withEvent:event];
        }
    } else {
        [super keyDown:event];
    }
}


- (void)_internalReload
{
    [self adjustSizes];
    [_topMatrix reloadData];
    [_sideMatrix reloadData];
    // reload the _dataMatrix last because
    // it posts some ugly notifications.
    [_dataMatrix reloadData];
    [self setNeedsDisplay:YES];
}


- (void)reloadData
/*" Called when data outside of the table view changes.
    Addition of a key, creation of a group, etc."*/
{
    NSArray  *keys = [_hlObjects allKeys];
    int       idx = [keys count];
    NSString *key;
    FSTable  *table = [dataSource table];

    [[self window] endEditingFor:nil];
    while (idx-- > 0) {
        key = [keys objectAtIndex:idx];
        if ([table headerWithName:key] == nil) {
            [_hlObjects removeObjectForKey:key];
        }
    }
    [[_hlObjects allValues]
        makeObjectsPerformSelector:@selector(_cacheKeys)];
    [self _internalReload];
}


- (void)setDataSource:(id)aDataSource
{
    dataSource = aDataSource;
    if (dataSource) {
        // Since we have a data source now,
        // we can act as data source
        // for our subviews.
        [_dataMatrix setDataSource:self];
        [_topMatrix setDataSource:self];
        [_sideMatrix setDataSource:self];
    } else {
        // break retain cycles
        dataSource = nil;
        [_dataMatrix setDataSource:nil];
        [_topMatrix setDataSource:nil];
        [_sideMatrix setDataSource:nil];
    }
    [self cacheLayout];
}
- (id)dataSource { return dataSource; }

// This is a hack for the responder chain...
- (id)delegate { return dataSource; }

@end

