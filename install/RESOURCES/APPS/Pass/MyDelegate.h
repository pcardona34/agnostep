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
### Pass.app
### Header: MyDelegate.h
####################################################
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Search.h"
#import "New.h"


@interface MyDelegate : NSObject <NSApplicationDelegate>
{
 Search *search;
 New *newPass;
 NSMutableData *data;
}

- (instancetype) init;
- (IBAction) openSearch: (id)sender;
- (void) updateData: (NSData *) newdata;
- (NSData *) data;
- (void) showInfoPanel:  (id) sender;

@end
