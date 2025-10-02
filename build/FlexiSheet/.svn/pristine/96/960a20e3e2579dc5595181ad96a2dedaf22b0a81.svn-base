//
//  SLSplashScreen.m
//
//  Created by Stefan Leuker on Fri Sep 07 2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  Don't put it in an NSWindow.  It will be unhappy there.
//  SLSplashScreen creates it's own environment.
//

#import "SLSplashScreen.h"


@implementation SLSplashScreen

- (id)initWithName:(NSString*)imageName
{
    NSWindow *window;
    NSRect    cRect = {{0,0},{100,100}};

    image = [NSImage imageNamed:imageName];
    cRect.size = [image size];
    self = [super initWithFrame:cRect];
    window = [[NSWindow alloc] initWithContentRect:cRect
                                         styleMask:NSBorderlessWindowMask|NSResizableWindowMask
                                           backing:NSBackingStoreBuffered defer:YES];
    [window setContentView:self];
    [window setOpaque:NO];
    [window setHasShadow:YES];
    [window center];
    [window setLevel:NSFloatingWindowLevel];
    [window orderFrontRegardless];
    [window makeKeyWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:NSApplicationDidFinishLaunchingNotification
                                               object:NSApp];
    return self;
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)drawRect:(NSRect)rect
{
    [[NSColor clearColor] set];
    NSRectFill(rect);
    [image compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
}

- (void)fadeOut:(id)sender
{
    float i, max = 200.0;
    for (i = 0.0; i < max; i += 1+i/2) {
        [[self window] setAlphaValue:(max-i)/max];
    }
    [[self window] orderOut:sender];
    [[self window] setAlphaValue:1.0];
}

- (void)mouseDown:(NSEvent*)event
{
    [self fadeOut:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self fadeOut:nil];
}

@end
