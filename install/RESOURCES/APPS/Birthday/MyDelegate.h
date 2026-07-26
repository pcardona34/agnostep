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
### Birthday.app: date and reminder of Birthdays
### and Feasts
### Header: MyDelegate.h
####################################################
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MyDelegate : NSObject <NSApplicationDelegate>
{
 
}

- (NSInteger) counter;
- (NSString *) currentDate;
- (NSArray *) nameToCelebrate;
- (void) updateBadge;
- (void) who: (id) sender;
- (void) showInfoPanel: (id)sender;

@end
