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
### Updater.app: Debian packages updater
### Interface: MyDelegate.h
####################################################
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ListController.h"

@interface MyDelegate : NSObject <NSApplicationDelegate>
{
 NSUInteger counter; // upgradable packages count
 NSString *currentPackageName;
 ListController *listController;

}

- (NSString *) operatingSystem;
- (void) updateCounter: (NSUInteger) newValue;
- (void) autoUpdateCounter;
- (void) setCounterWithData;
- (void) setCounter: (NSUInteger) newValue;
- (NSUInteger) counter;
- (NSData *) updateData; // return data containing the list of upgradable packages
- (void) showInfoPanel: (id) sender;

@end
