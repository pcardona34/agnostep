#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Functions.h"

id <NSMenuItem> addItemToMenu(NSMenu *menu, NSString *str, 
			  NSString *comm, NSString *sel, NSString *key)
{
  id<NSMenuItem> item = [menu addItemWithTitle: NSLocalizedString(str, comm)
			   action: NSSelectorFromString(sel) keyEquivalent: key]; 
  return item;
}
