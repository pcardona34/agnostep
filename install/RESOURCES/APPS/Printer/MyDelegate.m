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
### Printer.app: Printer Manager
### for the Agnostep Desktop Project
### Implementation: MyDelegate.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "MyDelegate.h"


@implementation MyDelegate


- (void) manager: (id) sender
{
    NSTask *task = [[NSTask alloc] init];
    NSString *url = @"http://localhost:631/printers/";
    [task setLaunchPath: @"/usr/bin/surf"];
    [task setArguments: [NSArray arrayWithObjects: url, nil]];
    [task launch];
}

/* **************************************************************************** */
- (void) showInfoPanel: (id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"PrinterInfo"
                           ofType: @"plist"];
  NSDictionary *localizedInfo = [NSDictionary dictionaryWithContentsOfFile: path];
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo];
}

/* **************************************************************************** */
/*
 * Standard method to prepare the UI from the delegate: applicationDidFinishLaunching
 *
 */

- (void)applicationDidFinishLaunching:(NSNotification *)notification 
{
    // Create a menu with a "quit" ...
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
  
    [menu addItemWithTitle: _(@"Printer Manager...") 
          action:@selector(manager:) 
          keyEquivalent:@""];
  
    [menu addItemWithTitle: _(@"Quit") 
          action:@selector(terminate:) 
          keyEquivalent:@"q"];
        
    // Add the menu to the application
    NSApplication.sharedApplication.mainMenu = menu;   
}

@end
