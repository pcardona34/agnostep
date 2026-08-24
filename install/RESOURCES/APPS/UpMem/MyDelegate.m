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
### UpMem.app: AppIcon to display Uptime and Memory
### 
### Implementation: MyDelegate.m
####################################################
*/

#import "MyDelegate.h"

@implementation MyDelegate


/*
 * getUptime: getting the Uptime
 *
 */
 
- (NSString *) getUptime
{
     NSProcessInfo *processInfo = [NSProcessInfo processInfo];  
     NSUInteger up = [processInfo systemUptime];
     NSString *uptime = [self stringFromSeconds: up];
     //NSLog(@"uptime: %@");   
     return uptime;
}

/* *************************************
 * Convert seconds to a formatted string
 * hh:mm
 *
 */
- (NSString *) stringFromSeconds: (NSInteger) totalSeconds
{    
  //NSInteger seconds = (totalSeconds % 60);
  NSInteger minutes = ((totalSeconds / 60) % 60);
  NSInteger hours = (totalSeconds / 3600);    
  return (hours > 99) ? @"99+ h" : [NSString stringWithFormat:
                                                     _(@"Up/Mem:\n%02ld:%02ld\n"), 
                                                     (long)hours, (long)minutes];
}


/* *************************************
 * getMemoryTotal
 * Getting Total of Memory
 *
 */

- (size_t) getMemoryTotal {
    FILE *file = fopen("/proc/meminfo", "r");
    if (file == NULL) {
        perror("fopen");
        return 0;
    }
    
    size_t memoryTotal = 0;
    char line[256];
    while (fgets(line, sizeof(line), file)) {
        if (sscanf(line, "MemTotal: %lu kB", &memoryTotal) == 1) {
            // Convert kB to bytes
            memoryTotal *= 1024;
            break;
        }
    }
    fclose(file);
    return memoryTotal;
}

/* *************************************
 * getMemoryUsage
 * Getting used memory
 *
 */

- (size_t) getMemoryUsage {
    FILE *file = fopen("/proc/meminfo", "r");
    if (file == NULL) {
        perror("fopen");
        return 0;
    }
    
    size_t memoryUsage = 0;
    char line[256];
    while (fgets(line, sizeof(line), file)) {
        if (sscanf(line, "Active: %lu kB", &memoryUsage) == 1) {
            // Convert kB to bytes
            memoryUsage *= 1024;
            break;
        }
    }
    fclose(file);
    return memoryUsage;
}

/* ************************************* 
 * getMemoryPercent
 * Calculating  the percent of Memory usage
 *
*/
- (NSString *) getMemoryPercent
{
    // Fetch memory usage
    size_t memoryUsage = [self getMemoryUsage];
    
    // Fetch memory Total
    size_t memoryTotal = [self getMemoryTotal];

    // Calculate the percentage of used memory
    double percentageUsed = (double) memoryUsage / memoryTotal * 100.0;

    // Update the label with memory usage
    NSString *displayText = [NSString stringWithFormat:@"%.2f%%", percentageUsed];
    
    return displayText;
}

/* ************************************* */
/*
 * drawRepOnIcon: drawing the getted representation on the App Icon
 *
 */
 
- (void) drawRepOnIcon
{
  // We begin here writing the representation on the Icon...
  // (1) We count previous representation drawn on the Icon
  unsigned int reps = [[iconImage representations] count];
  // (2) We remove it if > 0...
  if (reps)
    {
      NSImageRep *firstRep = [[iconImage representations] firstObject];
      [iconImage removeRepresentation: firstRep];
      reps = [[iconImage representations] count];
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
}

/* ************************************* */
/*
 * Drawing the getted text on the NSImage representation
 *
 */
- (void) drawImageRep
{
    // We retrieve infos
    // uptime
    NSString *uptime = [self getUptime];
    // memory
    NSString *memorypercent = [self getMemoryPercent];
        
    // We join all of them
    NSString *displayedString = [NSString stringWithFormat: @"%@%@", uptime, memorypercent];
      
    // We create a mutable dictionary for text attributes
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
    [attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    // We draw the text with its attributes
    NSAttributedString *attributedText = [[NSAttributedString alloc] 
                  initWithString: [NSString stringWithFormat: @"%@", displayedString] 
                  attributes: attributes];
    // Getting the size of the text
    NSSize textSize = [attributedText size];
    
    // Calculating the position of the text
    NSPoint textPoint = NSMakePoint((48 - textSize.width) / 2, (48 - textSize.height) / 2);
    
    // Drawing the text in the center of the icon...
    [attributedText drawAtPoint:textPoint]; 
}

- (void) showMemory: (id)sender
{
  [memory openMemory: nil];
}

/* **************************************************************************** */
- (void) showInfoPanel: (id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"UpMemInfo"
                           ofType: @"plist"];
  NSDictionary *localizedInfo = [NSDictionary 
     dictionaryWithContentsOfFile: path];
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo]; 
}


/* ********************************************************************* */
/* Standard method to prepare the UI from the delegate: applicationDidFinishLaunching
 *
 */

- (void)applicationDidFinishLaunching:(NSNotification *)notification 
{
    // Create a menu with a "Quit" action
    memory = [Memory new];
  
    NSMenu *menu = AUTORELEASE ([[NSMenu alloc] init]);
    NSMenu *infoMenu = AUTORELEASE ([NSMenu new]);
    NSMenuItem *menuItem;
    
    [infoMenu addItemWithTitle: _(@"Info Panel...") 
            action: @selector (showInfoPanel:) 
            keyEquivalent: @""];
  
    menuItem = [menu addItemWithTitle: _(@"Info...") 
                   action: NULL 
                   keyEquivalent: @""];
  
    [menu setSubmenu: infoMenu forItem: menuItem];
  
    [menu addItemWithTitle: _(@"Show Memory...") 
          action:@selector(showMemory:) 
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
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                      target: self
                      selector:@selector(drawRepOnIcon)
                      userInfo: nil 
                      repeats:YES];
                              
    [timer fire];
    
    
}

@end
