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
### Meteo.app: model of AppIcon with features
### Header: MyDelegate.h
####################################################
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "PreferencesController.h"
#import "PredictionController.h"

@interface MyDelegate : NSObject <NSApplicationDelegate>
{
 // An NSImage for the Icon
 NSImage *iconImage;
 NSString *currentLocation;
 PreferencesController *prefsController;
 PredictionController *predictionController;
}

- (instancetype) init;
- (void) dealloc;
- (NSString *)currentLocation;
- (IBAction) openPreferences: (id)sender;
- (void) setCurrentLocation:(NSString *)location;
- (NSString *) getDate;
- (NSString *) getTemp;
- (void) drawImageRep;
- (void) drawRepOnIcon;
- (IBAction) showPrediction: (id) sender;
- (void) showInfoPanel: (id)sender;

@end
