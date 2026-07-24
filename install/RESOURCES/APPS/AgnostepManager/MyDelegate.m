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
### AgnostepManager.app: Agnostep Manager
### for the Agnostep Desktop Project
### Implementation: MyDelegate.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "MyDelegate.h"

@implementation MyDelegate


- (BOOL) checkAM  
{
  NSString *userName = NSUserName();
  NSString *homeDir = NSHomeDirectoryForUser(userName);
  NSString *am = [homeDir stringByAppendingString: @"/SOURCES/agnostep-desktop"];
  
  NSFileManager *manager = [NSFileManager defaultManager];  
  BOOL isDirectory;  
  BOOL exists = [manager fileExistsAtPath: am isDirectory: &isDirectory];  
  
  if (exists && isDirectory) {  
    return YES;  
  } else {  
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText: _(@"Agnostep Manager Fatal Error")];
    [alert setInformativeText: [NSString stringWithFormat: _(@"The expected folder: %@ was not found.\nYou must repair it. You should read Help."),  am]];
    [alert runModal];
    [NSApp terminate:nil];
    return NO; // this will never be executed  
  } 
}

- (void) manager: (id) sender
{
  if ([self checkAM]) {
  
  // Initializing
  NSString *myCommand = @"/usr/bin/xterm";
  NSArray *myArgs = [NSArray arrayWithObjects:
                             @"-tn",
                             @"xterm-256color",
                             @"-T",
                             @"AgnostepManager",
                             @"-e",
                             @"/usr/local/bin/AMLauncher.sh",
                              nil];
    
  // We set the NSTask:
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath: myCommand];
  [task setArguments: myArgs];
  
  // We execute the task
  [task launch];
  [task waitUntilExit];
  NSLog(@"Task has been launched");
  } 
}

/* The code below was previously suggested by DeepWiki and then adapted */
- (void) showInfoPanel: (id)sender
{  
  NSBundle *bundle = [NSBundle mainBundle];  
  NSString *path = [bundle pathForResource: @"AgnostepManagerInfo"   
                                   ofType: @"plist"];  
  NSDictionary *localizedInfo = [NSDictionary dictionaryWithContentsOfFile: path];  
    
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo];  
}
/* End of DeepWiki suggest */


/* **************************************************************************** */
/*
 * Standard method to prepare the UI from the delegate: applicationDidFinishLaunching
 *
 */

- (void)applicationDidFinishLaunching:(NSNotification *)notification 
{
    // Menu
    NSMenu *menu;
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
  
    [menu addItemWithTitle: _(@"Manager...")
          action:@selector(manager:) 
          keyEquivalent: @""];
  
    [menu addItemWithTitle: _(@"Quit") 
          action:@selector(terminate:) 
          keyEquivalent:@"q"];
        
    // Add the menu to the application
    NSApplication.sharedApplication.mainMenu = menu;   
}

@end
