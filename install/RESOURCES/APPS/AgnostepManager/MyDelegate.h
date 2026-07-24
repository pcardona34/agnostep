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
### Header: MyDelegate.h
####################################################
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MyDelegate : NSObject <NSApplicationDelegate>
{

}

- (void) manager: (id) sender;
- (BOOL) checkAM;
- (void) showInfoPanel: (id)sender;

@end
