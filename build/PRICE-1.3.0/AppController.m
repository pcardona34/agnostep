//
//  AppController.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 12 2002.
//  Copyright (c) 2002-2005 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "AppController.h"
#import "MyDocument.h"


@implementation AppController

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication
{
    return NO;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
  NSDocumentController *dc;
  MyDocument *doc;
    
  dc = [NSDocumentController sharedDocumentController];
#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
  doc = [dc openDocumentWithContentsOfFile:filename display:YES];
#else
  doc = [dc openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename] display:YES error:nil];
#endif
    
  return (doc != nil);
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSUserDefaults *defaults;
    NSDictionary   *defDic;

    previewController = [[PRPreviewController alloc] init];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    /* we register default settings */
    defDic = [NSDictionary dictionaryWithObjectsAndKeys: (prefEnlargeWindowsDefault ? @"YES" : @"NO"), prefEnlargeWindowsKey, (prefClosePanelsDefault ? @"YES" : @"NO"), prefClosePanelsKey, nil];
    [defaults registerDefaults: defDic];
    
    /* we read the last recorded value in the user defaults */
    
    prefEnlargeWindows = [defaults boolForKey:prefEnlargeWindowsKey];
    prefClosePanels = [defaults boolForKey:prefClosePanelsKey];
}

- (PRPreviewController *) previewController
{
  return previewController;
}

- (IBAction)showPreferences:(id)sender
{
    [prefPanel makeKeyAndOrderFront:self];

    if(prefEnlargeWindows == YES)
        [enlargeWindowsCheck setState:NSOnState];
    else
        [enlargeWindowsCheck setState:NSOffState];

    if(prefClosePanels == YES)
        [closePanelsCheck setState:NSOnState];
    else
        [closePanelsCheck setState:NSOffState];
}

- (IBAction)savePreferences:(id)sender
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];

    prefEnlargeWindows = [enlargeWindowsCheck state];
    [defaults setBool:prefEnlargeWindows forKey:prefEnlargeWindowsKey];

    prefClosePanels = [closePanelsCheck state];
    [defaults setBool:prefClosePanels forKey:prefClosePanelsKey];

    [prefPanel performClose:nil];
}

- (IBAction) cancelPreferences:(id)sender
{
    [prefPanel performClose:nil];
}

- (BOOL) prefClosePanels
{
    return prefClosePanels;
}

- (BOOL) prefEnlargeWindows
{
    return prefEnlargeWindows;
}

@end
