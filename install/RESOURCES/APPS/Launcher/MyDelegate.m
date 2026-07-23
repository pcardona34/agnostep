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
### Launcher
### Open the Applications folder
### with a built-in filtered view
### inherited from GWorkspace
###
### Implementation: MyDelegate.m
####################################################
*/

#import <AppKit/AppKit.h>

#import "../../../../build/apps-gworkspace/GWMetadata/MDFinder/MDFinder.h"
#import "../../../../build/apps-gworkspace/GWorkspace/GWorkspace.h"

#import "MyDelegate.h"


@implementation MyDelegate


- (void) openAppFolder: (id) sender
{
     
    NSString *appPath = @"/Local/Applications";
    NSLog(@"Path is: %@", appPath);
    NSFileManager *manager = [NSFileManager defaultManager];  
    BOOL isDirectory;  
    BOOL exists = [manager fileExistsAtPath: appPath isDirectory: &isDirectory];  
  
    if (exists && isDirectory) {  
      // Store the workspace connection              
      _workspaceApp = [NSConnection rootProxyForConnectionWithRegisteredName: @"GWorkspace" host: @""];  
    
    if (_workspaceApp == nil) {  
      NSLog(@"Cannot connect to GWorkspace");  
      return;  
    }  
     
    // Set the view type preference for the specific path  
    NSString *prefsKey = [NSString stringWithFormat:@"viewer_at_%@", appPath];  
    NSDictionary *viewPrefs = [NSDictionary dictionaryWithObject:@"Icon"     
                                            forKey:@"viewtype"];  
    [[NSUserDefaults standardUserDefaults] setObject:viewPrefs forKey:prefsKey];  
    // Create the viewer - the viewer will use the Icon view type
    [_workspaceApp newViewerAtPath:appPath];
    // Clean the prefs
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:prefsKey]; 
                
    } else {  
      NSLog(@"Directory does not exist or path is not a directory");
    }  
}

/* The code below was previously suggested by DeepWiki and then adapted */
- (void) showInfoPanel: (id)sender  
{  
  NSBundle *bundle = [NSBundle mainBundle];  
  NSString *path = [bundle pathForResource: @"LauncherInfo"   
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
  
    [menu addItemWithTitle: _(@"Open Applications Folder...")     
          action:@selector(openAppFolder:) 
          keyEquivalent:@""];
    [menu addItemWithTitle:_(@"Quit") 
          action:@selector(terminate:) 
          keyEquivalent:@"q"];
        
    // Add the menu to the application
    NSApplication.sharedApplication.mainMenu = menu;
    [self openAppFolder:nil]; 
}

@end
