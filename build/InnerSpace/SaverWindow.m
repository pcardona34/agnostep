/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "SaverWindow.h"

@implementation SaverWindow
- (void) setAction: (SEL)a forTarget: (id)t
{
  action = a;
  target = t;
}

- (void) _triggerAction
{
  if([self level] != NSDesktopWindowLevel)
    {
      [NSApp sendAction: action to: target from: self];
    }
}

- (void) keyDown: (NSEvent *)theEvent
{
  [self _triggerAction];
}

- (void) mouseMoved: (NSEvent *)theEvent
{
  [self _triggerAction];
}

- (void) mouseUp: (NSEvent *)theEvent
{
  [self _triggerAction];
}

- (BOOL) canBecomeKeyWindow
{
  return YES;
}

- (BOOL) canBecomeMainWindow
{
  return YES;
}

- (void) hide: (id)sender
{
  // Don't react to hide.  This window cannot be hidden.
}

@end
