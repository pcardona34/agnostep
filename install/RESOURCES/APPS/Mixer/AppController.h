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
### Mixer.app
### This is a forked and simplified release
### of the native VolumeControl by Alex Myczko...
### AppController.h
####################################################
*/

#include <AppKit/AppKit.h>

@interface AppController : NSObject
{
  NSTimer *timer;

  id pcmL;
  id pcmR;
  id pcmLock;
  id pcmMute;
  
  
}
- (void) awakeFromNib;
- (void) setVolume: (id)sender;
- (void) showInfoPanel:(id) sender;
@end
