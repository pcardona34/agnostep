// ####################################################
// ### A G N o S t e p  -  Desktop - by Patrick Cardona
// ### pcardona34 @ Github
// ###
// ### Thanks for the GNUstep Developers Community
// ### This is Free and Open Source software.
// ### Read License in the root directory.
// ####################################################

// ################################
// ### UpMem.app
// ### Memory
// ################################

#import "Memory.h"
#include <stdio.h>

@implementation Memory

- (instancetype) init 
{
    if ((self = [super init])) 
      {

       // Create a window to display memory usage
       NSRect frame = NSMakeRect(100, 100, 300, 120);
       window = [[NSWindow alloc] initWithContentRect:frame
                                           styleMask:(NSWindowStyleMaskTitled |
                                                      NSWindowStyleMaskClosable |
                                                      NSWindowStyleMaskResizable)
                                             backing:NSBackingStoreBuffered
                                               defer:NO];
      [window setTitle: _(@"Memory Usage")];

       // Create a label to display memory usage
      memoryUsageLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 60, 280, 40)];
      [memoryUsageLabel setEditable:NO];
      [memoryUsageLabel setBezeled:NO];
      [memoryUsageLabel setDrawsBackground:NO];
      [memoryUsageLabel setFont:[NSFont systemFontOfSize:14]];
      [[window contentView] addSubview:memoryUsageLabel];

    // Create a progress indicator to show memory usage as a bar graph
    NSProgressIndicator *memoryBar = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, 40, 280, 20)];
    [memoryBar setIndeterminate:NO];
    [memoryBar setMinValue:0.0];
    [memoryBar setMaxValue:100.0]; // Maximum percentage
    [memoryBar setUsesThreadedAnimation:YES];
    [[window contentView] addSubview:memoryBar];
        
    // Create a timer to periodically update memory usage
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(updateMemoryUsage:)
                                   userInfo:memoryBar  // Pass the memoryBar to update it later
                                   repeats:YES];
      }
    return self;
}


- (void) openMemory: (id) sender
{
    [window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)updateMemoryUsage:(NSTimer *)timer {
    NSProgressIndicator *memoryBar = (NSProgressIndicator *)timer.userInfo; // Get the progress indicator from the timer

    // Fetch memory usage
    size_t memoryUsage = [self getMemoryUsage];
    
    // Fetch memory Total
    size_t memoryTotal = [self getMemoryTotal];

    double percentageUsed = (double)memoryUsage / memoryTotal * 100.0;

    // Update the label with memory usage
    NSString *displayText = [NSString stringWithFormat: _(@"Memory Usage: %lu MB (%.2f%%)"), memoryUsage / (1024 * 1024), percentageUsed];
    [memoryUsageLabel setStringValue:displayText];

    // Update the progress bar
    [memoryBar setDoubleValue:percentageUsed];
}

- (size_t)getMemoryTotal {
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

- (size_t)getMemoryUsage {
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

@end
