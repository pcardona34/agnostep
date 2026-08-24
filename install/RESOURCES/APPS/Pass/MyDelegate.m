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
### Pass.app: model of AppIcon with features
### Implementation: MyDelegate.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "MyDelegate.h"
#import "Search.h"
#import "New.h"

@implementation MyDelegate

- (instancetype) init
{
  if ((self = [super init])) 
      {
        data = [[NSMutableData alloc] init];
        [data setData: nil];
      }
  return self;
}

- (void) updateData: (NSData *) newdata
{
  [data setData: newdata]; 
}

- (NSData *) data
{
 return data; 
}

// Action to launch the Search Panel from menu 
- (IBAction) openSearch:(id)sender 
{    
  [search showSearch:sender];
}

// Action to launch the New Password Panel from menu 
- (IBAction) openNew:(id)sender 
{    
  [newPass showNew:sender];
}

/* **************************************************************************** */
- (void) showInfoPanel:  (id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"PassInfo"
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
  
    search = [[Search alloc] init];
    newPass = [[New alloc] init];
    
    // Create a menu 
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

    [menu setSubmenu: infoMenu forItem: menuItem];
  
    [menu addItemWithTitle:_(@"Search...") 
          action:@selector(openSearch:) 
          keyEquivalent:@""];
  
    [menu addItemWithTitle:_(@"New...") 
          action:@selector(openNew:) 
          keyEquivalent:@""];
  
    [menu addItemWithTitle:_(@"Quit") 
          action:@selector(terminate:) 
          keyEquivalent:@"q"];
    
    // Add the menu to the application
    NSApplication.sharedApplication.mainMenu = menu;  
  
}

@end
