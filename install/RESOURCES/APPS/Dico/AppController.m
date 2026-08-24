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
### Dico.app
### A French Dictionary Lookup App and Service
### Application Controller implementation: AppController.m
####################################################
*/

#import "AppController.h"

@implementation AppController

- (void) showInfoPanel: (id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"DicoInfo"
                           ofType: @"plist"];
  NSDictionary *localizedInfo = [NSDictionary 
    dictionaryWithContentsOfFile: path];
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo];
}

@end
