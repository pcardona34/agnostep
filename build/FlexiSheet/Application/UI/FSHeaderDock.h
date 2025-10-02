//
//  FSHeaderDock.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 04-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSHeaderDock.h,v 1.1 2008/10/28 13:10:31 hns Exp $

#import <AppKit/NSControl.h>
#import <FSFirstResponder.h>

@class FSHeader;

@interface FSHeaderDock : NSControl <FSEditableSelection> {
    NSMutableArray       *_headers;
    BOOL                  _isDragging;
    BOOL                  _isDropping;
    BOOL                  _isLinking;
    int                   _dragIndex;
    int                   _dropIndex;
    NSImage              *_emptyImage;
#ifndef __mySTEP__
    id                    _delegate;
#endif
    int                   _selection;
    BOOL                  _isEditing;
    FSHeader             *_editHeader;
    int                  *_sizeCache;
}

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (NSArray*)headers;
- (void)setHeaders:(NSArray*)headers;

- (FSHeader*)removeDraggedHeader;

- (BOOL)_endEditing;

@end

extern NSString *FSHeadersChangedInDockNotification;
