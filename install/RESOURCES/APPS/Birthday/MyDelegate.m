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
### Birthday.app
### Implementation: MyDelegate.m
####################################################
*/

#import <AppKit/AppKit.h>
#import "DockTile.h"
#import "MyDelegate.h"

@implementation MyDelegate

/*
 * currentDate: getting the current Date
 *
 */
- (NSString *) currentDate
{
  // We declare an NSCalendarDate to retrieve the current date
     NSCalendarDate *date = [NSCalendarDate calendarDate];
  /* We expect  a date formatted as: '25/03' (dd/mm) */
     NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     /* We want a consistent date format with historic Birthday date format
      * Thanks to Richard FM for the following ref:
      * See: https://unicode-org.github.io/icu/userguide/format_parse/datetime/
      * And also: 
      * https://packages.debian.org/en/stable/misc/birthday
     */
     [dateFormat setDateFormat: @"dd/MM"];
     NSString *currentDate = [dateFormat stringFromDate: date];
     [dateFormat release];
      //NSLog(@"This is My Text Info: %@", info);
      return currentDate;
}

- (NSArray *) nameToCelebrate
{
    // We use an NSTask: setting
  NSString *command = @"/usr/bin/grep";
  NSString *userName = NSUserName();
  NSString *homeDir = NSHomeDirectoryForUser(userName);
  NSString *path = [homeDir stringByAppendingString: @"/Documents/Private/Birthdays"];
  NSTask *task = [[NSTask alloc] init];
  NSString *currentDate = [self currentDate];
  [task setLaunchPath: command];
  [task setArguments: [NSArray arrayWithObjects: @"-e", currentDate, path, nil]];
  
  // We prepare retrieving of the data with an NSPipe
  NSPipe *outpipe = [NSPipe pipe];
  [task setStandardOutput: outpipe];
  // We set a File Handle to read output
  NSFileHandle *readHandle = [outpipe fileHandleForReading];
  
  // We launch the task
  [task launch];
  [task waitUntilExit];
  
  // We retrieve the Data
  NSData *output = [readHandle readDataToEndOfFile];
  if (output && [output length] > 0)
    {
      NSString *str = [[NSString alloc] initWithData: output
                                        encoding: NSUTF8StringEncoding];
      // Where is the equal separator?
      NSRange searchResult = [str rangeOfString:@"="];
      if (searchResult.location == NSNotFound)
        {
          NSLog(@"The line format is invalid: check your Birthdays file.");
          [readHandle closeFile];
          return nil;
        }
      else
        {
          NSString *name = [str substringToIndex: searchResult.location];
          //NSLog(@"Name: %@", name);
          
          // Type of event?
          [readHandle closeFile];
          NSArray *info = [NSArray arrayWithObjects: name, str, nil];
          return info;
        }
    } 
  else
    {
    return nil;
    }
}

- (NSInteger) counter
{
  // how we get counter value
  NSInteger counter = 0;
  NSString *str = [[self nameToCelebrate] firstObject];   
  if (str && [str length] > 0)
    {  
      if([[str substringToIndex:1] isEqualToString: @"#"])
        {
          counter = 0;
        }
        else
        {
          counter = 1;
        }
    }
  return counter;
}

/* **************************************************************************** */
/*
 * who: display an info panel about the event
 *
 */
 
- (void) who: (id) sender
{
  //NSLog(@"You do it...");
  NSString *thename = (NSString *)[[self nameToCelebrate] firstObject];
  NSString *theevent = (NSString *)[[self nameToCelebrate] lastObject];
  NSLog(@"event:%@", theevent);
  NSMutableString *title = [NSMutableString stringWithString: _(@"Event: ")];
 
  if (theevent && [theevent length] > 0)
    {
      if ([theevent containsString:@"bd"])
        {
          [title appendString: _(@"Birthday")];
        }
      else
        {
          if ([theevent containsString:@"st"])
          {
            [title appendString: _(@"Feast")];
          }
          else
          {
             [title appendString: _(@"Unknown")];
          }
        }
    }
  
  NSString *message;
  if (thename && [thename length] > 0)
    { 
      message = [NSString stringWithFormat: _(@"Today, we celebrate: %@!"), thename];
    }
  else
    {
      message = [NSString stringWithFormat: _(@"Nobody to celebrate today.")];
    }
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert setMessageText: title];
  [alert setInformativeText: message];
  [alert runModal];
}

/* **************************************************************************** */

- (void) updateBadge  
{    
  NSInteger counter = [self counter];    
      
  // Update the dock tile badge    
  NSDockTile *dockTile = [NSApp dockTile];  
    
  if (counter) {
    NSString *str = (counter > 99) ? @"99+" : [NSString stringWithFormat:@"%ld", 
           (long)counter]; 
    [dockTile setBadgeLabel: str];  
    [dockTile setShowsApplicationBadge: YES];  
  } else {  
    [dockTile setBadgeLabel: nil];  
    [dockTile setShowsApplicationBadge: NO];  
  }  
    
  // Force the application icon to redraw 
  NSImage *currentIcon = [NSApp applicationIconImage];  
  [NSApp setApplicationIconImage: currentIcon];   
}


/* The code below was previously suggested by DeepWiki and then adapted */
- (void) showInfoPanel: (id)sender
{  
  NSBundle *bundle = [NSBundle mainBundle];  
  NSString *path = [bundle pathForResource: @"BirthdayInfo"   
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
    // Create a menu
    NSMenu *menu;
    NSMenu *infoMenu;
    NSMenuItem *menuItem;
    menu = AUTORELEASE ([NSMenu new]);
    infoMenu = AUTORELEASE ([NSMenu new]);
  
    [infoMenu addItemWithTitle: _(@"Info Panel...") 
          action: @selector (showInfoPanel:) 
          keyEquivalent: @""];

    [infoMenu addItemWithTitle: _(@"Help...") 
          action: @selector (orderFrontHelpPanel:)
          keyEquivalent: @"?"];

    menuItem = [menu addItemWithTitle: _(@"Info...") 
          action: NULL 
          keyEquivalent: @""];

    [menu setSubmenu: infoMenu  forItem: menuItem];
  
    [menu addItemWithTitle: _(@"Who...")
          action:@selector(who:)
          keyEquivalent:@""];
  
    [menu addItemWithTitle: _(@"Quit")
          action:@selector(terminate:)
          keyEquivalent:@"q"];
  
    // Add the menu to the application
    NSApplication.sharedApplication.mainMenu = menu;
    
    
   // Timer to call Update Badge method every n sec. 
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 3600.0
                      target: self
                      selector:@selector(updateBadge)
                      userInfo: nil 
                      repeats:YES];
    
    // run timer now                         
    [timer fire];
  
}

@end
