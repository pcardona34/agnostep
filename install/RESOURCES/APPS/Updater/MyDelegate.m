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
### Implementation: MyDelegate.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "DockTile.h"
#import "MyDelegate.h"
#import "ListController.h"

@implementation MyDelegate


/*
 * Check Operating system
 *
 */

- (NSString *) operatingSystem
{
  NSProcessInfo *processInfo = [NSProcessInfo processInfo];
  NSString *os = [processInfo operatingSystemName];
  NSString *path = @"/etc/debian_version";
  //NSLog(@"OS: %@", os);
  NSString *expected = @"Debian";
  if ([os containsString: @"Linux"]) {
      NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath: path];
      if (readHandle){
        NSString *version = [NSString stringWithContentsOfFile: path];
        [readHandle closeFile];
        return [NSString stringWithFormat: @"%@\n%@", expected, version];
       } else {
        NSLog(@"Error: your GNU/Linux System is not compatible with Updater.");
        [readHandle closeFile];  
        [NSApp terminate: nil];
        return nil;
       }
  } else {
     NSLog(@"Error: your Operating System is not compatible with Updater.");
      [NSApp terminate: nil];
      return nil;
  }  
}

/* ****************************************************************** */
// Action to launch the Updates List Panel from menu 
- (IBAction) openList:(id)sender 
{    
  [listController showList:sender];
}

/* **************************************************************************** */
- (NSUInteger) counter
{
  return counter;  
}

- (void) setCounter: (NSUInteger) newValue
{
  counter = newValue;
}

/* *********************************** */
- (void) setCounterWithData
{
  NSUInteger mycounter = 0;
  NSData *data = [self updateData];
  NSString *str = [[NSString alloc] initWithData: data
                                      encoding: NSUTF8StringEncoding];
  NSArray *lines = [str componentsSeparatedByString: @"\n"];
  for(id line in lines) 
    {
      NSRange range = [line rangeOfString:@"/"];
      if (range.location != NSNotFound) 
        {  
          mycounter = (mycounter + 1);
          //NSLog(@"Counter: %u", mycounter);
            
         }
     }

  [self updateCounter: mycounter];
}


/* **************************************************************************** */
- (void) autoUpdateCounter   
{    
  [self setCounterWithData];   
}

/* **************************************************************************** */

- (void) updateCounter: (NSUInteger)newValue    
{    
  [self setCounter: newValue];    
      
  // Update the dock tile badge    
  NSDockTile *dockTile = [NSApp dockTile];  
    
  if (newValue > 0) {
    NSString *str = (newValue > 99) ? @"99+" : [NSString stringWithFormat:@"%u", newValue];  
    [dockTile setBadgeLabel: str];  
    [dockTile setShowsApplicationBadge: YES];  
  } else {  
    [dockTile setBadgeLabel: nil];  
    [dockTile setShowsApplicationBadge: NO];  
  }  
    
  // Force the application icon to redraw 
  NSImage *currentIcon = [NSApp applicationIconImage];  
  [NSApp setApplicationIconImage: currentIcon];   
}

/* **************************************************************************** */

- (NSData *) updateData
{
   
   // We set the NSTask:
   NSString *myCommand = @"/usr/bin/apt";
   NSArray *myArgs = [NSArray arrayWithObjects: 
                             @"list",
                             @"--upgradable",
                             nil];

  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath: myCommand];
  [task setArguments: myArgs];
  
  // We set an NSPipe to retrieve output data
  NSPipe *outpipe = [NSPipe pipe];
  [task setStandardOutput: outpipe];
  
  // We set an NSFileHandle to read output
  NSFileHandle *readHandle = [outpipe fileHandleForReading];
  [task launch];
  [task waitUntilExit];
  
  // We retrieve the data
  NSData *output = [readHandle readDataToEndOfFile];
    
  [readHandle closeFile];
  [outpipe release];
  
  return output;
}

/* **************************************************************************** */
- (void) showInfoPanel: (id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"UpdaterInfo"
                           ofType: @"plist"];
  NSDictionary *localizedInfo = [NSDictionary 
     dictionaryWithContentsOfFile: path];
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo]; 
}


/* **************************************************************************** */
/*
 * Standard method to prepare the UI from the delegate: applicationDidFinishLaunching
 *
 */

- (void)applicationDidFinishLaunching:(NSNotification *)notification 
{
    // Uncomment to debug
    //NSLog(@"Application did finish launching");
    NSString *os = [self operatingSystem];
    NSLog(@"Operating  System: %@", os);
    
    [self setCounterWithData];
    listController = [[ListController alloc] init];
    
    // Create a menu with a "quit" action and a "doIt" action
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenu *infoMenu;
    NSMenuItem *menuItem;
    menu = AUTORELEASE ([NSMenu new]);
    infoMenu = AUTORELEASE ([NSMenu new]);
    
  
    [infoMenu addItemWithTitle: _(@"Info Panel...") 
            action: @selector (showInfoPanel:) 
            keyEquivalent: @""];

    [infoMenu addItemWithTitle: _(@"Help...") 
            action: @selector (orderFrontHelpPanel:)
            keyEquivalent: @"?"];

    menuItem = [menu addItemWithTitle: _(@"Info...") 
                   action: NULL 
                   keyEquivalent: @""];

    [menu setSubmenu: infoMenu  forItem: menuItem];
  
    [menu addItemWithTitle: _(@"List Updates...") 
                    action:@selector(openList:)     
                    keyEquivalent:@""];
  
    [menu addItemWithTitle: _(@"Quit") 
                    action:@selector(terminate:) 
                    keyEquivalent:@"q"];
    
    NSApplication.sharedApplication.mainMenu = menu;
    
   //Timer to call drawRepOnIcon every n sec. 
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 3600.0
                      target: self
                      selector:@selector(autoUpdateCounter)
                      userInfo: nil 
                      repeats:YES];
                              
    [timer fire];
     
}
     
@end
