//
//  FSPreferences.h
//  FlexiSheet
//
//  Created by Stefan Leuker on Thu Sep 20 2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSPreferences.h,v 1.1 2008/10/14 15:03:46 hns Exp $

#import <AppKit/AppKit.h>


@interface FSPreferences : NSObject {
    NSUserDefaults        *_defaults;
    IBOutlet NSPanel      *prefPanel;
    IBOutlet NSTabView    *tabView;
    
    // General preferences
    IBOutlet NSButton     *showInspectorSwitch;
    
    // Document preferences
    IBOutlet NSButton     *saveCompressedSwitch;
}

- (void)showPreferences:(id)sender;

// General preferences callbacks
- (void)toggleShowInspector:(id)sender;

// Document preferences callbacks
- (void)toggleSaveCompressed:(id)sender;

@end
