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
### Implementation: ListController.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "PredictionController.h"

@implementation PredictionController : NSObject

- (IBAction) openPrediction: (id)sender 
{
  /*  Wttr.in query does not render if using an NSPipe:do not! */
  
  // Initializing
  NSString *myCommand = @"/usr/bin/xterm";
  NSString *query = @"wttr.in/";
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *location = [defaults stringForKey:@"LocationName"];
  
  /* Setting lang prefix */
  NSArray *languages = [[NSUserDefaults standardUserDefaults]   
              stringArrayForKey:@"NSLanguages"];  
  NSString *firstLanguage = [languages firstObject];  
  NSString *languagePrefix = [[firstLanguage substringToIndex: 2] lowercaseString];
  NSLog(@"Prefix Language: %@", languagePrefix);
  NSString *langOption = [NSString stringWithFormat: @"?lang=%@", languagePrefix];
  
  // We set the NSTask:
  NSArray *myArgs = [NSArray arrayWithObjects:
                             @"-T",
                             _(@"Weather Prediction"),
                             @"-hold",
                             @"-geometry",
                             @"130x42+100+66",
                             @"-e",
                             @"/usr/bin/curl",
                            [[query stringByAppendingString: location]
                                    stringByAppendingString: langOption],
                            nil];
    
  
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath: myCommand];
  [task setArguments: myArgs];
  
  [task launch];
  [task waitUntilExit];
  //NSLog(@"Task has been launched");
    
  [task release];   
}

@end
