#import <AppKit/AppKit.h>

@interface AppController : NSObject
{
  id window;
}

- (id) init;
- (void) dealloc;

- (void) awakeFromNib;

- (void) applicationWillFinishLaunching: (NSNotification *)aNotification;
- (void) applicationDidFinishLaunching: (NSNotification *)aNotif;
- (BOOL) applicationShouldTerminate: (id)sender;
- (void) applicationWillTerminate: (NSNotification *)aNotif;

@end
