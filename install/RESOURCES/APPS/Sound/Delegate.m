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
### Sound: a little app to test and help to set sound...
### Delegate: Implementation
####################################################
*/

#import "Delegate.h"

@implementation MyDelegate : NSObject

- (void) testCuckoo: (id)sender
{
  NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"cuckoo" ofType:@"wav"];
  NSLog(@"Path: %@", soundPath);
    
  NSSound *cuckoo;
  AUTORELEASE(cuckoo = [[NSSound alloc] initWithContentsOfFile:soundPath byReference:NO]);
  
  if (!cuckoo) {
     NSLog(@"Failed to load sound!");
  } else {
     [cuckoo play];
     NSLog(@"Playing sound...");
  }
}

- (void) createMenu
{
  NSMenu *menu;
  NSMenu *infoMenu;
  NSMenuItem *menuItem;
  
  menu = [NSMenu new];
  infoMenu = [NSMenu new];
  menuItem = [NSMenuItem new];
  
  [infoMenu addItemWithTitle: _(@"Info Panel...") 
          action: @selector (showInfoPanel:) 
          keyEquivalent: @""];
  
  [infoMenu addItemWithTitle: _(@"Help...") 
          action: @selector (orderFrontHelpPanel:)
          keyEquivalent: @"?"];
  
  menuItem = [menu addItemWithTitle: _(@"Info...") 
                 action: NULL 
                 keyEquivalent: @""];
  [menu setSubmenu: infoMenu forItem: menuItem];
  
  [menu addItemWithTitle: _(@"Test Sound...")  
        action: @selector (testCuckoo:)  
        keyEquivalent: @"t"];

  [menu addItemWithTitle: _(@"Quit")  
        action: @selector (terminate:)  
        keyEquivalent: @"q"];

  [NSApp setMainMenu: menu];
}

- (void) createWindow
{
  NSRect rect;
  unsigned int styleMask = NSTitledWindowMask 
                           | NSMiniaturizableWindowMask;
  NSButton *myButton;
  NSSize buttonSize;

  myButton = [NSButton new];
  [myButton setTitle: _(@"Test of Sound")];
  [myButton sizeToFit];
  [myButton setTarget: self];
  [myButton setAction: @selector (testCuckoo:)];

  buttonSize = [myButton frame].size;
  rect = NSMakeRect (100, 100, 
                     buttonSize.width, 
                     buttonSize.height);

  myWindow = [NSWindow alloc];
  myWindow = [myWindow initWithContentRect: rect
                       styleMask: styleMask
                       backing: NSBackingStoreBuffered
                       defer: NO];
  [myWindow setTitle: _(@"Sound Test")];
  [myWindow setContentView: myButton];
}

- (void) applicationWillFinishLaunching: (NSNotification *)notification
{
  [self createMenu];
  [self createWindow];
}

/* **************************************************************************** */
- (void) showInfoPanel: (id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"SoundInfo"
                           ofType: @"plist"];
  NSDictionary *localizedInfo = [NSDictionary 
     dictionaryWithContentsOfFile: path];
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo]; 
}

- (void) applicationDidFinishLaunching: (NSNotification *)notification;
{
  [myWindow makeKeyAndOrderFront: nil];
}

@end
