//
//  FSInspector.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 14-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSInspector.h,v 1.1 2008/10/28 13:10:28 hns Exp $

#import <AppKit/AppKit.h>
#import <FSInspection.h>

@class FSInspectorPane;

@interface FSInspector : NSObject
{
    IBOutlet NSPanel      *infoPanel;
    IBOutlet NSBox        *paneContainer;
    FSInspectorPane       *activePane;
    id<FSInspectable>      selection;
}

- (void)showInspector:(id)sender;

- (void)selectPaneWithIdentifier:(NSString*)identifier;

@end
