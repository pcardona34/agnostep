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
#import "MyDelegate.h"

@implementation ListController

- (instancetype) init 
{
    if ((self = [super init])) 
      {
              
        // List Panel to show results of the Search query
        NSRect frame = NSMakeRect(0, 0, 400, 400);
        listWindow = [[NSWindow alloc] initWithContentRect:frame
           styleMask:(NSTitledWindowMask | NSClosableWindowMask)
           backing:NSBackingStoreBuffered
           defer:NO];
        [listWindow setTitle:@"Available Keys"];
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
        [textView setString: @"Loading..."];
        [textView setEditable:NO];
                       
        // Edit Button
        editButton = [[NSButton alloc] 
            initWithFrame:NSMakeRect(20, 16, 100, 28)];
        [editButton setTitle:@"Edit..."];
        [editButton setTarget:self];
        [editButton setAction:@selector(edit:)];
        [content addSubview: editButton];  
        
        // Pass Button
        passButton = [[NSButton alloc] 
            initWithFrame:NSMakeRect(130, 16, 120, 28)];
        [passButton setTitle:@"Password..."];
        [passButton setTarget:self];
        [passButton setAction:@selector(pass:)];
        [content addSubview: passButton];  
        
        // Close Button
        closeButton = [[NSButton alloc] 
            initWithFrame:NSMakeRect(260, 16, 120, 28)];
        [closeButton setTitle:@"Close"];
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
               afterDelay: 1.0];   
}

/* ******************************************* */
- (void) loadDataSynchronously    
{  
    NSLog(@"Loading data...");
    
    MyDelegate *delegate = (MyDelegate *)[NSApp delegate];  
    NSData *data = [delegate data];
    NSString *str = [[NSString alloc] initWithData: data   
                                             encoding: NSUTF8StringEncoding];
    NSString *list = [[[str stringByReplacingOccurrencesOfString:@"└── [01;34mRoot[0m"
                          withString:@""]
                          stringByReplacingOccurrencesOfString:@"├──"
                          withString:@""]
                          stringByReplacingOccurrencesOfString:@"└──"
                          withString:@""];   
    [textView setString: list];  
    [textView setEditable:NO];  
      
    [str release];  
}


/* ******************************************* */
- (IBAction) closeWindow:(id)sender 
{
    [listWindow orderOut:nil];
}

/* ******************************************* */
- (IBAction) pass:(id)sender 
{
   NSLog(@"Pass query...");
   // Get the selected range  
   NSRange selectedRange = [textView selectedRange];  
  
   // Get the selected text as a plain string  
   NSString *selectedText = [[textView string] substringWithRange:selectedRange];
   if (selectedText && [selectedText length] > 0){
     NSLog(@"You selected: %@", selectedText); 
     // here query pass
     NSString *myCommand = @"/usr/bin/xterm";
     NSArray *myArgs = [NSArray arrayWithObjects:
                            @"-T",
                            @"Password",
                            @"-hold",
                            @"-e",
                            @"/usr/bin/pass",
                            [NSString stringWithFormat:@"/Root/%@", selectedText],
                            nil];
    // We set the NSTask:
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: myCommand];
    [task setArguments: myArgs];
    
    [task launch];
    NSLog(@"Last Task has been launched");
    [task waitUntilExit];
    [task release];

 }else{
   
   NSLog(@"No key was selected");
 }  
     [listWindow orderOut:nil];
  
  
}

/* ******************************************* */
- (IBAction) edit:(id)sender 
{
   NSLog(@"Edit query...");
   // Get the selected range  
   NSRange selectedRange = [textView selectedRange];  
  
   // Get the selected text as a plain string  
   NSString *selectedText = [[textView string] substringWithRange:selectedRange];
   if (selectedText && [selectedText length] > 0){
     NSLog(@"You selected: %@", selectedText); 
     // here query edit
     NSString *myCommand = @"/usr/bin/xterm";
     NSArray *myArgs = [NSArray arrayWithObjects:
                            @"-T",
                            @"Edit",
                            @"-hold",
                            @"-e",
                            @"/usr/bin/pass",
                            @"edit",
                            [NSString stringWithFormat:@"/Root/%@", selectedText],
                            nil];
    // We set the NSTask:
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: myCommand];
    [task setArguments: myArgs];
    
    [task launch];
    NSLog(@"Last Task has been launched");
    [task waitUntilExit];
    [task release];

 }else{
   
   NSLog(@"No key was selected");
 }  
     [listWindow orderOut:nil];
  
  
}

@end
