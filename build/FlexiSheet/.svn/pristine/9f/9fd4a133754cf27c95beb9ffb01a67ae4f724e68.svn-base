//
//  FSPreferences.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 20-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSPreferences.m,v 1.1 2008/10/14 15:03:46 hns Exp $

#import "FlexiSheet.h"
#import "FSPreferences.h"


@implementation FSPreferences

- (void)showPreferences:(id)sender
{
    if (prefPanel == nil) {
        [NSBundle loadNibNamed:@"Preferences" owner:self];
        _defaults = [NSUserDefaults standardUserDefaults];
        
        // Set defaults for General
        [showInspectorSwitch setState:[_defaults boolForKey:FSShowInspectorPreference]];
        
        // Set defaults for Document
        [saveCompressedSwitch setState:[_defaults boolForKey:FSSaveCompressedPreference]];
    }
    
    [prefPanel makeKeyAndOrderFront:sender];
}

//
//
//

- (void)toggleShowInspector:(id)sender
{
    [_defaults setBool:[sender state] forKey:FSShowInspectorPreference];
}

//
// Document callbacks
//

- (void)toggleSaveCompressed:(id)sender
{
    [_defaults setBool:[sender state] forKey:FSSaveCompressedPreference];
}

@end
