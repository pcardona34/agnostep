/* PreferencesController implementation */

#import <AppKit/AppKit.h>
#import "PreferencesController.h"

@implementation PreferencesController

- (instancetype) init 
{
    if ((self = [super init])) 
      {
        // Preferences Panel to set the location default
        NSRect frame = NSMakeRect(0, 0, 360, 120);
        prefsWindow = [[NSWindow alloc] initWithContentRect:frame
           styleMask:(NSTitledWindowMask | NSClosableWindowMask)
           backing:NSBackingStoreBuffered
           defer:NO];
        [prefsWindow setTitle: _(@"Preferences")];
        [prefsWindow center];
 
        // The view on the window
        NSView *content = [prefsWindow contentView];

        // text field label
        NSTextField *label = [[NSTextField alloc] 
           initWithFrame:NSMakeRect(16, 72, 100, 20)];
        [label setStringValue: _(@"Location:")];
        [label setBezeled:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setSelectable:NO];
        [content addSubview:label];

         // text field to get the location name: expected a city name like 'Paris'
         // It is an outlet
        locationTextField = [[NSTextField alloc] 
            initWithFrame:NSMakeRect(120, 68, 216, 24)];
        [content addSubview:locationTextField];

        // ok Button
        NSButton *okButton = [[NSButton alloc] 
            initWithFrame:NSMakeRect(220, 12, 116, 28)];
        [okButton setTitle:@"OK"];
        [okButton setTarget:self];
        [okButton setAction:@selector(saveLocation:)];
        [content addSubview:okButton];

        // Cancel Button
        NSButton *cancel = [[NSButton alloc] 
            initWithFrame:NSMakeRect(96, 12, 116, 28)];
        [cancel setTitle: _(@"Cancel")];
        [cancel setTarget:self];
        [cancel setAction:@selector(cancelPreferences:)];
        [content addSubview:cancel];

        // Load saved value (or default)
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        NSString *loc = [defs stringForKey:@"LocationName"];
        if (!loc) loc = @"Grandrieu";
        [locationTextField setStringValue:loc];
    }
    return self;
}

- (IBAction) showPreferences:(id)sender 
{
    // Refresh current value each time
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *loc = [defs stringForKey:@"LocationName"];
    if (!loc) loc = @"Grandrieu";
    [locationTextField setStringValue:loc];

    // Display the Panel
    [prefsWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES]; // bring app to front so window is visible
}

- (IBAction) saveLocation:(id)sender
{
    NSString *location = [[locationTextField stringValue] copy];
    if (!location) location = @"";
      
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:location forKey:@"LocationName"];
    [defs synchronize];
    [prefsWindow orderOut:nil];
}

- (IBAction) cancelPreferences:(id)sender 
{
    [prefsWindow orderOut:nil];
}

@end
