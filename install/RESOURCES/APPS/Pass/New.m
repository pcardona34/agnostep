/* 
####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### (c) 2026 - pcardona34 @ Github
### Author: Patrick Cardona
###
### Thanks for the GNUstep Developers Community.
### This application is free software.
### Read complete License in the root directory.
####################################################

####################################################
### Pass.app
### Implementation of search: New.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "New.h"

@implementation New : NSObject

- (instancetype) init
{
    if ((self = [super init])) 
      {
        
        // New Password Panel
        NSRect frame = NSMakeRect(0, 0, 360, 120);
        newWindow = [[NSWindow alloc] initWithContentRect:frame
           styleMask:(NSTitledWindowMask | NSClosableWindowMask)
           backing:NSBackingStoreBuffered
           defer:NO];
        [newWindow setTitle: _(@"New Password")];
        [newWindow center];

        // The view on the window
        NSView *content = [newWindow contentView];

        // text field label
        NSTextField *label = [[NSTextField alloc] 
           initWithFrame:NSMakeRect(16, 72, 100, 20)];
        [label setStringValue: _(@"New Key:")];
        [label setBezeled:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setSelectable:NO];
        [content addSubview:label];

         // text field to get the key
         // It is an outlet
        keyTextField = [[NSTextField alloc] 
            initWithFrame:NSMakeRect(120, 68, 216, 24)];
        [content addSubview: keyTextField];

        // ok Button
        NSButton *okButton = [[NSButton alloc] 
            initWithFrame:NSMakeRect(220, 12, 116, 28)];
        [okButton setTitle: _(@"Create")];
        [okButton setTarget:self];
        [okButton setAction:@selector(create:)];
        [content addSubview:okButton];

        // Cancel Button
        NSButton *cancel = [[NSButton alloc] 
            initWithFrame:NSMakeRect(96, 12, 116, 28)];
        [cancel setTitle: _(@"Cancel")];
        [cancel setTarget:self];
        [cancel setAction:@selector(cancelCreate:)];
        [content addSubview:cancel];
    }
    return self;
}

- (IBAction) showNew:(id)sender 
{
    // Display the Panel
    [newWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES]; // bring app to front so window is visible
}

- (IBAction) create:(id)sender
{
    NSString *key = [[keyTextField stringValue] copy];
    if (!key) key = @"";
     
    if ([key length] > 0) {
    // Initializing
    NSLog(@"You are adding: %@", key);
    NSString *myCommand = @"/usr/bin/xterm";
    NSArray *myArgs = [NSArray arrayWithObjects:
                               @"-T",
                               [NSString stringWithFormat: @"New password for %@", key],
                               @"-hold",
                               @"-e",
                               @"/usr/bin/pass",
                               @"insert",
                               @"--echo",
                               [NSString stringWithFormat: @"/Root/%@", key],
                            nil];
       
    // We set the NSTask:
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: myCommand];
    [task setArguments: myArgs];
    NSLog(@"Command: %@", myCommand);
    NSLog(@"Args: %@", myArgs);
    [task launch];
    NSLog(@"Task has been launched: new password");
    [task waitUntilExit];
    [task release];
    [newWindow orderOut:nil];
  }else{
      NSLog(@"The key field is empty!");
    }
      
}

- (IBAction) cancelCreate:(id)sender 
{
    [newWindow orderOut:nil];
}

@end
