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
### OpenDisk
### Open the media folder where removable disks are mounted.
### Header: MyDelegate.h
####################################################
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MyDelegate : NSObject <NSApplicationDelegate>
{

}

- (void) openMedia: (id) sender;
- (void) showInfoPanel: (id) sender;

@end
