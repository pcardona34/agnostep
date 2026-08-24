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
### Implementation of search: Search.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "Search.h"
#import "ListController.h"
#import "MyDelegate.h"

@implementation Search : NSObject

- (instancetype) init
{
    if ((self = [super init])) 
      {
        
        // Search Panel
        NSRect frame = NSMakeRect(0, 0, 360, 120);
        searchWindow = [[NSWindow alloc] initWithContentRect:frame
           styleMask:(NSTitledWindowMask | NSClosableWindowMask)
           backing:NSBackingStoreBuffered
           defer:NO];
        [searchWindow setTitle: _(@"Search a key")];
        [searchWindow center];

        // The view on the window
        NSView *content = [searchWindow contentView];

        // text field label
        NSTextField *label = [[NSTextField alloc] 
           initWithFrame:NSMakeRect(16, 72, 100, 20)];
        [label setStringValue: _(@"Key:")];
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
        [okButton setTitle: _(@"Search")];
        [okButton setTarget:self];
        [okButton setAction:@selector(performSearch:)];
        [content addSubview:okButton];

        // Cancel Button
        NSButton *cancel = [[NSButton alloc] 
            initWithFrame:NSMakeRect(96, 12, 116, 28)];
        [cancel setTitle: _(@"Cancel")];
        [cancel setTarget:self];
        [cancel setAction:@selector(cancelSearch:)];
        [content addSubview:cancel];
    }
    return self;
}

- (IBAction) showSearch:(id)sender 
{
    // Display the Panel
    [searchWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES]; // bring app to front so window is visible
}

- (IBAction) performSearch:(id)sender
{
    NSString *key = [[keyTextField stringValue] copy];
    if (!key) key = @"";
     
    if ([key length] > 0) {
    // Initializing
    NSLog(@"You searched: %@", key);
    NSString *myCommand = @"/usr/bin/pass";
    NSArray *myArgs = [NSArray arrayWithObjects:
                            @"search",
                            key,
                            nil];
    
    
    // We set the NSTask:
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: myCommand];
    [task setArguments: myArgs];
    
    NSPipe *outpipe = [NSPipe pipe];
    [task setStandardOutput: outpipe];
    NSFileHandle *readHandle = [outpipe fileHandleForReading];
     
    [task launch];
    NSLog(@"Task has been launched");
    [task waitUntilExit];
    
    NSData *output = [readHandle readDataToEndOfFile];
    
    MyDelegate *delegate = (MyDelegate *)[NSApp delegate];
    if (output && [output length] > 0) {
      [delegate updateData: output];
      
      
      
      //NSLog(@"Data in performSearch is: %@", str);
    
      ListController *listController = [ListController new];
      [listController showList: nil];
    }else{
      NSLog(@"Here...failing");
    }
      [task release];
  }   
    [searchWindow orderOut:nil];
    
    
}

- (IBAction) cancelSearch:(id)sender 
{
    [searchWindow orderOut:nil];

}

@end
