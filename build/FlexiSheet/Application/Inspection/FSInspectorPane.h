//
//  FSInspectorPane.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 15-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSInspectorPane.h,v 1.1 2008/10/28 13:10:29 hns Exp $

#import <AppKit/AppKit.h>
#import <FSInspection.h>

@class FSWorksheet;

@interface FSInspectorPane : NSObject
{
    IBOutlet NSView       *paneView;  // The pane view for this inspector.

    // Private
    FSWorksheet           *_activeWorksheet;
    FSTableView           *_activeTableView;
}

+ (void)registerInspectorPane:(Class)aPane;
+ (FSInspectorPane*)inspectorPaneForIdentifier:(NSString*)identifier;

- (NSString*)paneIdentifier;
- (NSString*)paneNibName;
- (NSString*)inspectorName;
- (NSView*)paneView;

- (FSWorksheet*)activeWorksheet;
- (void)setActiveWorksheet:(FSWorksheet*)ws;

- (FSTableView*)activeTableView;
- (void)setActiveTableView:(FSTableView*)ws;

- (void)updateWithSelection:(id<FSInspectable>)selection;

@end
