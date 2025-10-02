//
//  FSTableTabs.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableTabs.h,v 1.1 2008/10/14 15:03:48 hns Exp $

#import "FlexiSheet.h"
#import <AppKit/NSControl.h>
#import <FSFirstResponder.h>

@class FSKeySet;

typedef enum _FSTabOrientation {
    FSOnTop = 0,
    FSLeftSide = 1,
    FSRightSide = 3,
    FSAtBottom = 2
} FSTabOrientation;

@interface FSTableTabs : NSControl {
    NSArray         *_items;
    NSRange          _visibleRange;
    int              _selectedItem;
    int             *_widths;
    NSButtonCell    *_backButton;
    NSButtonCell    *_foreButton;
    NSRect           _backRect;
    NSRect           _foreRect;
    NSBezierPath    *_backPath;
    NSBezierPath    *_forePath;
    FSTabOrientation _orientation;
    BOOL             _isEditing;
    FSHeader        *_editHeader;
}

- (NSArray*)keySets;
- (void)setKeySets:(NSArray*)keySets;

- (FSKeySet*)selectedKeySet;

- (FSTabOrientation)orientation;
- (void)setOrientation:(FSTabOrientation)newOrientation;

@end
