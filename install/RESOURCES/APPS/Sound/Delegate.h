/* 
####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### (c) 2026 - pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### Sound: a little app to test and help to set sound...
### Delegate: Interface
####################################################
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MyDelegate : NSObject
{
  NSWindow *myWindow;
}

- (void) createMenu;
- (void) createWindow;
- (void) showInfoPanel: (id) sender;
- (void) applicationWillFinishLaunching: (NSNotification *)notification;
- (void) applicationDidFinishLaunching: (NSNotification *)notification;

// Actions
- (void) testCuckoo: (id)sender;

@end
