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
### Implementation: ListController.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "ListController.h"
#import "ProgressController.h"
#import "MyDelegate.h"
//#import "Counter.h"

@implementation ListController

- (instancetype) init 
{
    if ((self = [super init])) 
      {
        
        //aCounter = [[Counter alloc] init];
        
        // List Panel to show updates
        NSRect frame = NSMakeRect(0, 0, 400, 400);
        listWindow = [[NSWindow alloc] initWithContentRect:frame
           styleMask:(NSTitledWindowMask | NSClosableWindowMask)
           backing:NSBackingStoreBuffered
           defer:NO];
        [listWindow setTitle: _(@"Debian upgradable packages")];
        [listWindow center];

        // The view on the window
        NSView *content = [listWindow contentView];

        // Create a scroll view  
        scrollView = [[NSScrollView alloc] initWithFrame: 
                                                      NSMakeRect(16, 60, 364, 320)];  
 
        // Configure scroll view  
       [scrollView setHasVerticalScroller: YES];  
       [scrollView setHasHorizontalScroller: NO];  
       [scrollView setAutohidesScrollers: NO]; // Hide when not needed  
       
       /* Text View: where the list of packages will be displayed
        * The following way of initializing was found thanks to DeepWiki help
        *  Then successfully tested.
        */
        textView = [[NSTextView alloc] 
            initWithFrame: NSMakeRect(0, 0, [scrollView contentSize].width, 0)];
         
        [scrollView setDocumentView: textView];
        // Add to parent view  
        [content addSubview: scrollView];  
        
        // Set text placeholder only
        [textView setString: _(@"Loading...")];
        [textView setEditable:NO];
                       
        // Upgrade Button
        upgradeButton = [[NSButton alloc] 
            initWithFrame:NSMakeRect(130, 16, 120, 28)];
        [upgradeButton setTitle: _(@"Upgrade")];
        [upgradeButton setTarget:self];
        [upgradeButton setAction:@selector(upgrade:)];
        
        // Close Button
        closeButton = [[NSButton alloc] 
            initWithFrame:NSMakeRect(260, 16, 120, 28)];
        [closeButton setTitle: _(@"Close")];
        [closeButton setTarget:self];
        [closeButton setAction:@selector(closeWindow:)];
        [content addSubview:closeButton];  

    }
    return self;
}


/* ******************************************* */
- (IBAction) showList: (id)sender 
{
    // Display the Panel
    [listWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES]; // bring app to front so window is visible
  
    // Load data asynchronously  
    [self performSelector: @selector(loadDataSynchronously)   
               withObject: nil   
               afterDelay: 5.0];   
}

/* ******************************************* */
- (void) loadDataSynchronously    
{  
    NSLog(@"Loading data...");
    MyDelegate *delegate = (MyDelegate *)[NSApp delegate];
    NSData *data = [delegate updateData];    
    NSString *str = [[NSString alloc] initWithData: data   
                                             encoding: NSUTF8StringEncoding];    
    
    NSString *header = _(@"List of Upgradable Packages:\n\n"); 
    NSMutableString *list = [NSMutableString stringWithString: header];  
    NSArray *lines = [str componentsSeparatedByString: @"\n"];    
    for(id line in lines) {    
        NSRange range = [line rangeOfString:@"/"];    
        if (range.location != NSNotFound) {      
            NSUInteger index = range.location;    
            [list appendString:     
                [[line substringToIndex: index]     
                    stringByAppendingString: @"\n"]];
              
        }    
    }    
    [textView setString: list];  
    [textView setEditable:NO];  
      
    // Add upgrade button if there are packages
    NSLog(@"Counter state in listController: %u", [delegate counter]);    
    if ([delegate counter] > 0) {    
        [[listWindow contentView] addSubview: upgradeButton];    
    }  
      
    [str release];  
}


/* ******************************************* */
- (IBAction) closeWindow:(id)sender 
{
    [listWindow orderOut:nil];
}

/* ******************************************* */
- (IBAction) upgrade:(id)sender 
{
   NSLog(@"Begining upgrade...");
  [listWindow orderOut:nil];
  progressController = [[ProgressController alloc] init];
  [progressController showProgress:nil];
  
}


@end
