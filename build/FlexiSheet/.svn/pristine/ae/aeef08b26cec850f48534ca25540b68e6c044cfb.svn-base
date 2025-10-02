//
//  FSFunctionHelp.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 17-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSFunctionHelp.h,v 1.1 2008/10/14 15:03:45 hns Exp $

#import <AppKit/AppKit.h>

@class WebView;

@interface FSFunctionHelp : NSObject
{
    IBOutlet NSBrowser     *groups;
    IBOutlet NSBrowser     *functions;
    IBOutlet WebView       *helpView;
    
    NSArray                *fNames;
}

- (void)showPanel:(id)sender;

- (void)selectGroup:(id)sender;
- (void)selectFunction:(id)sender;

@end
