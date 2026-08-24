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
### Application Controller interface: AppController.h
####################################################
*/
   
#ifndef _PCAPPPROJ_APPCONTROLLER_H
#define _PCAPPPROJ_APPCONTROLLER_H

#import <AppKit/AppKit.h>

@interface AppController : NSObject
{
  IBOutlet NSWindow *_window;
}

- (void) showInfoPanel: (id)sender;

@end

#endif
