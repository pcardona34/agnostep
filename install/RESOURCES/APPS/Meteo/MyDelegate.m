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
### Implementation: MyDelegate.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "MyDelegate.h"
#import "PreferencesController.h"
#import "PredictionController.h"


@implementation MyDelegate

- (instancetype) init 
{    
  if ((self = [super init])) 
    {        
      currentLocation = nil;
      }    
    return self;
}

- (void) dealloc 
{    
  [currentLocation release];
  [super dealloc];
}

- (void) setCurrentLocation: (NSString *)location 
{    
  if (location == currentLocation) 
    return;    
  
  [currentLocation release];
  currentLocation = [location copy];
   
  // Persist to defaults (optional if saved elsewhere)    
  NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
  [defs setObject:currentLocation forKey: @"LocationName"];    
  [defs synchronize];
  
}

- (NSString *) currentLocation 
{
  return [[currentLocation retain] autorelease];
}


// Action to launch the prefs Panel from menu 
- (IBAction) openPreferences:(id)sender 
{    
  [prefsController showPreferences:sender];
}


- (NSString *) getDate
{
  // We declare an NSCalendarDate to retrieve the current date
     NSCalendarDate *date = [NSCalendarDate calendarDate];
  /* We expect  a date formatted as: '25 mar.' by example
     But this seems buggy...*/
     NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     /* We want a consistent date format with historic Birthday date format
      * Thanks to Richard FM for the following ref:
      * See: https://unicode-org.github.io/icu/userguide/format_parse/datetime/
      * And also: 
      * https://packages.debian.org/en/stable/misc/birthday
     */
     [dateFormat setDateFormat: @"dd/MM"];
     NSString *info = [dateFormat stringFromDate: date];
     [dateFormat release];
      //NSLog(@"This is My Text Info: %@", info);
      return info;
}


/*
 * getInfo: getting the text Info to put on the Icon
 *
 */
- (NSString *) getTemp
{
  // Initializing
  NSString *myCommand = @"/usr/bin/curl";
  NSString *query = @"wttr.in/";
  NSArray *myArgs = [NSArray arrayWithObjects: 
                             [[query stringByAppendingString: currentLocation] stringByAppendingString:@"?format=1"],
                              nil];
    
  // We set the NSTask
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath: myCommand];
  [task setArguments: myArgs];
  
  // We set an NSPipe to retrieve output
  NSPipe *outpipe = [NSPipe pipe];
  [task setStandardOutput: outpipe];
  
   // We set a FileHandle
  NSFileHandle *readHandle = [outpipe fileHandleForReading];
   
  // We execute the task
  [task launch];
  [task waitUntilExit];
  NSLog(@"Task has been launched"); 
  
  //We retrieve the data from the ouptut
  NSData *output = [readHandle readDataToEndOfFile];
  if (output && [output length] > 0) 
    {
      NSString *info = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
      NSString *temp = [info substringFromIndex: 4];
      
      NSLog(@"This is My Text Info: %@", temp);
      //  We close the FileHandle to prevent "Too many open files"
     [readHandle closeFile];
     [outpipe release];  
     return temp;
    }
  else
    {
      [NSApp terminate:nil];
      return nil;
    }
}

/*
 * drawRepOnIcon: drawing the getted representation on the App Icon
 *
 */
 
- (void) drawRepOnIcon
{
  //NSLog(@"Enter in drawRepOnIcon...");
  
  // We begin here writing the representation on the Icon...
  // (1) We count previous representation drawn on the Icon
  unsigned int reps = [[iconImage representations] count];
  // (2) We remove it if > 0...
  if (reps) {
      //NSLog(@"reps: %u", reps);
      NSImageRep *firstRep = [[iconImage representations] firstObject];
      [iconImage removeRepresentation: firstRep];
      reps = [[iconImage representations] count];
      //NSLog(@"After removing of reps: %u",  reps);
    }
  // We initiate and put the new representation on the Icon
  NSImageRep *rep = [[NSCustomImageRep alloc] 
                            initWithDrawSelector: @selector(drawImageRep) 
                            delegate:self];
  
  [rep setSize: NSMakeSize(48, 48)];
  [rep draw];
  
  [iconImage addRepresentation: rep];
  
  // Set the custom icon image for the app
  [NSApp setApplicationIconImage: iconImage];
  
  [rep release];
  //NSLog(@"End of drawRepOnIcon");
}




/*
 * Drawing the getted infos on the NSImage representation
 *
 */
- (void) drawImageRep
{
    //NSLog(@"Enter in drawImageRep...");
     
    // We retrieve infos
      
    NSString *currentDate = [self getDate];
    NSString *currentTemp = [self getTemp];
    
        
    // We join all of them
    NSString *displayedString = [NSString stringWithFormat: @"\n%@\n%@", 
                                          currentDate,
                                          currentTemp];

    // Create a mutable dictionary for text attributes
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSFont systemFontOfSize:14] forKey:NSFontAttributeName];
    [attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    // Draw the text with its attributes
    NSAttributedString *attributedText = [[NSAttributedString alloc] 
                  initWithString: [NSString stringWithFormat: @"%@", displayedString] 
                  attributes: attributes];
    
    // Get the size of the text 
    NSSize textSize = [attributedText size];
    
    // Uncomment to Debug and log Text Size
    //NSLog(@"Text size: %@", NSStringFromSize(textSize));

    // Calculate the position of the text
    NSPoint textPoint = NSMakePoint((48 - textSize.width) / 2, (48 - textSize.height) / 2);
    
    // Draw the text in the center of the icon and check if successful
    [attributedText drawAtPoint:textPoint];
    
  //NSLog(@"End of drawImageRep...");
    
}

/* **************************************************************************** */
/*
 * showPrediction: performed from menu
 *
 */
 
- (void) showPrediction: (id) sender
{
  [predictionController openPrediction: nil];
}

/* The code below was previously suggested by DeepWiki and then adapted */
- (void) showInfoPanel: (id)sender  
{  
  NSBundle *bundle = [NSBundle mainBundle];  
  NSString *path = [bundle pathForResource: @"MeteoInfo"   
                                   ofType: @"plist"];  
  NSDictionary *localizedInfo = [NSDictionary dictionaryWithContentsOfFile: path];  
    
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo];  
}
/* End of DeepWiki suggest */

/* **************************************************************************** */
/*
 * Standard method to prepare the UI from the delegate: applicationDidFinishLaunching
 *
 */

- (void)applicationDidFinishLaunching:(NSNotification *)notification 
{
    // Uncomment to debug
    //NSLog(@"Application did finish launching");
  
    prefsController = [[PreferencesController alloc] init];
    predictionController = [PredictionController new];  
  
    // We retrieve default pref: location
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *location = [defaults stringForKey:@"LocationName"];
      if (location == nil) 
        {
          location = @"Grandrieu"; // default
          [defaults setObject:location forKey:@"LocationName"];
          [defaults synchronize];    
        }    // use location: set model, fetch weather, update UI...    
    [self setCurrentLocation:location];
    
    // Create a menu with a "quit" action and a "doIt" action
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenu *infoMenu;
    NSMenuItem *menuItem;
    
    menu = AUTORELEASE ([NSMenu new]);
    infoMenu = AUTORELEASE ([NSMenu new]);
  
    [infoMenu addItemWithTitle: _(@"Info Panel...") 
            action: @selector (showInfoPanel:) 
            keyEquivalent: @""];
  
    [infoMenu addItemWithTitle: _(@"Preferences...") 
            action: @selector (openPreferences:)
            keyEquivalent: @""];


    [infoMenu addItemWithTitle: _(@"Help...") 
            action: @selector (orderFrontHelpPanel:)
            keyEquivalent: @"?"];

    menuItem = [menu addItemWithTitle: _(@"Info...") 
                   action: NULL 
                   keyEquivalent: @""];

    [menu setSubmenu: infoMenu forItem: menuItem];
  
    [menu addItemWithTitle: _(@"Prediction") 
          action:@selector(showPrediction:) 
          keyEquivalent:@""];
  
    [menu addItemWithTitle: _(@"Quit") 
          action:@selector(terminate:) 
          keyEquivalent:@"q"];
    
    // Add the menu to the application
    NSApplication.sharedApplication.mainMenu = menu;  
  
    // Create a custom icon image with 48x48 dimensions
    iconImage = [[NSImage alloc] initWithSize:NSMakeSize(48, 48)];
    // We set the image to never be cached
    [iconImage setCacheMode: NSImageCacheNever];
 
   // Timer to call drawRepOnIcon every n sec. 
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 1800.0
                      target: self
                      selector:@selector(drawRepOnIcon)
                      userInfo: nil 
                      repeats:YES];
                              
    [timer fire];
    
     
}

@end
