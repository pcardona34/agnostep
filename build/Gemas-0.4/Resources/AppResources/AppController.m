#import "AppController.h"

@implementation AppController

- (id) init
{
  self = [super init];

  if(!self)
    return nil;
  
  //Add here your initializations

  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (void) awakeFromNib
{
}

- (void)applicationWillFinishLaunching: (NSNotification *)aNotification
{
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotif
{
}

- (BOOL) applicationShouldTerminate: (id)sender
{
  return YES;
}

- (void) applicationWillTerminate: (NSNotification *)aNotif
{
}

@end
