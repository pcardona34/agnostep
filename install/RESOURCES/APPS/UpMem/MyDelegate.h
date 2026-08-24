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
### UpMem.app: AppIcon to display Uptime and Memory
###
### Header: MyDelegate.h
####################################################
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <stdio.h>
#import "Memory.h"

@interface MyDelegate : NSObject <NSApplicationDelegate>
{
 // An NSImage for the Icon
 NSImage *iconImage;
  Memory *memory;
}

/* Method related to uptime */
- (NSString *) getUptime;
- (NSString *) stringFromSeconds: (NSInteger) totalSeconds;

/* Method to get memory usage*/
- (size_t) getMemoryUsage;
- (size_t) getMemoryTotal;
- (NSString *) getMemoryPercent;

/* Displaying the Icon part */
- (void) drawImageRep;
- (void) drawRepOnIcon;

/* Show localized infos */
- (void) showInfoPanel: (id) sender;

@end
