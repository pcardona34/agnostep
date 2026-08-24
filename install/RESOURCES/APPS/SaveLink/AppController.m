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
### SaveLink: an Internet Shortcuts Manager
### AppController.m: Implementation
####################################################
*/

#import "AppController.h"

@implementation AppController

- (void) showInfoPanel: (id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"SaveLinkInfo"
                           ofType: @"plist"];
  NSDictionary *localizedInfo = [NSDictionary dictionaryWithContentsOfFile: path];
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo];
}

@end
