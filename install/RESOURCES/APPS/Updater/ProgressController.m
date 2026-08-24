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
### Updater.app: Debian packages updater
### Implementation: ProgressController.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "ProgressController.h"
#import "MyDelegate.h"

@implementation ProgressController

- (instancetype) init 
{
    if ((self = [super init])) 
      {
        // Progress Panel to show upgrade
        NSRect frame = NSMakeRect(0, 0, 400, 120);
        progressWindow = [[NSWindow alloc] initWithContentRect:frame
           styleMask:(NSTitledWindowMask | NSClosableWindowMask)
           /* backing:NSBackingStoreBuffered */
           backing:NSBackingStoreNonretained
           defer:NO];
        [progressWindow setTitle: _(@"Upgrading Debian packages")];
        [progressWindow center];

        // The view on the window
        NSView *content = [progressWindow contentView];

        // text field label
        label = [[NSTextField alloc] 
           initWithFrame:NSMakeRect(20, 84, 360, 20)];
        [label setBezeled:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setSelectable:NO];
        [content addSubview:label];
        
        // Create progress indicator (bar style)  
        progressBar = [[NSProgressIndicator alloc] 
          initWithFrame:NSMakeRect(20, 60, 360, 20)];  
        [progressBar setStyle:NSProgressIndicatorBarStyle];  
        [progressBar setMinValue:0.0];  
        [progressBar setMaxValue:1.0];  
        [progressBar setDoubleValue:0.0];  
        [progressBar setBezeled:YES]; 
          
        // Add to window  
        [content addSubview:progressBar];
        
        // Close Button
        closeButton = [[NSButton alloc] 
            initWithFrame:NSMakeRect(260, 16, 120, 28)];
        [closeButton setTitle: _(@"Close")];
        [closeButton setTarget:self];
        [closeButton setAction:@selector(closeWindow:)];
        [closeButton setEnabled:NO];
        [content addSubview:closeButton]; 

    }
    return self;
}

/* **************************************** */
- (IBAction) showProgress: (id)sender 
{
    // Display the Panel
    [progressWindow display];  
    [progressWindow orderFront:nil];  
    [progressWindow makeKeyWindow];
    //[progressWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES]; // bring app to front so window is visible
  
    NSLog(@"Performing Upgrade...");
  
    // Initializing
    // We retrieve the data
        
    MyDelegate *delegate = (MyDelegate *)[NSApp delegate];
    NSData *output = [delegate updateData];
    
    if (output && [output length] > 0)
    {
     NSString *str = [[NSString alloc] initWithData: output
                                      encoding: NSUTF8StringEncoding]; 
      
      instanceLines = [[str componentsSeparatedByString: @"\n"] retain];  
      currentIndex = 0;  
      totalItems = [delegate counter]; 
      
      [progressBar setDoubleValue: 0.0];
      [progressBar setIndeterminate:NO];
      [progressBar setNeedsDisplay:YES];
      [label setStringValue: _(@"Upgrading...")];   
  
      // Start timer 
      [NSTimer scheduledTimerWithTimeInterval: 0.05  
                                 target: self  
                               selector: @selector(processNextLineSimple:)  
                               userInfo: nil  
                                repeats: NO];   
       
     [str release];
    }
}


/* **************************************** */
- (IBAction) closeWindow:(id)sender 
{
    [progressWindow orderOut:nil];
    MyDelegate *delegate = (MyDelegate *)[NSApp delegate];  
    [delegate updateCounter: 0];
}

/* **************************************** */
- (void) performUpgrade: (NSString *) packageName
{
   NSArray *myArgs = [NSArray arrayWithObjects: 
                             packageName,
                             nil];
  

  // We set the NSTask:
  NSTask *task = [[NSTask alloc] init];
  NSString *myCommand = [NSTask launchPathForTool: @"upgrade_unit.sh"];  
  if (myCommand) {  
    [task setLaunchPath: myCommand];
  }
  
  [task setArguments: myArgs];
  
  [task launch];
  [task waitUntilExit];
 
}

/* **************************************** */
- (void) processNextLineSimple: (NSTimer *)timer 
{  
    if (currentIndex >= [instanceLines count]) {  
        [closeButton setEnabled:YES];  
        [instanceLines release];  
        instanceLines = nil;  
        return;  
    }    
      
    NSString *line = [instanceLines objectAtIndex: currentIndex];  
    NSRange range = [line rangeOfString:@"/"];  
      
    if (range.location != NSNotFound) {
        NSString *package = [line substringToIndex: range.location];
        NSString *completeLabel = [[NSString stringWithFormat: @"%u - ", currentIndex]  
                                stringByAppendingString: package];
        // NSLog(@"Package: %@", package);
        // NSLog(@"Complete Label: %@", completeLabel);
        
        [label setStringValue: completeLabel]; 
        [self performUpgrade: package];
                
        float progress = ((float)(currentIndex) / (float)totalItems);
        [progressBar setDoubleValue: (double)progress];
        [progressBar setIndeterminate:NO];
        [progressBar setNeedsDisplay:YES];
    } 
       
    // Schedule next update  
    [NSTimer scheduledTimerWithTimeInterval: 0.05  
                                     target: self  
                                   selector: @selector(processNextLineSimple:)  
                                   userInfo: nil  
                                    repeats: NO];
  
  currentIndex++;
  
    
}

/* **************************************** */
- (void) dealloc  
{  
    [instanceLines release];  
    [progressWindow release];  
    [label release];  
    [progressBar release];  
    [closeButton release];  
    [super dealloc];  
}

@end
