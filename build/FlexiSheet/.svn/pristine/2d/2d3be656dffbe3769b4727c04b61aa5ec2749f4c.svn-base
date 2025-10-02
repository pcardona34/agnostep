//
//  SLFloatingMark.m
//  FlexiSheet
//
//  Created by Stefan Leuker on Sun Sep 09 2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//

#import "SLFloatingMark.h"


@implementation SLFloatingMark
/*" SLFloatingMark is something like a tool tip.  It can be with an image or a text string.
Floating marks are semi transparent and overall look like tool tips. "*/

- (void)_createWindow:(NSRect)cRect
{
    NSWindow *window;

    window = [[NSWindow alloc] initWithContentRect:cRect
                                         styleMask:NSBorderlessWindowMask
                                           backing:NSBackingStoreBuffered defer:YES];
    [window setContentView:self];
    [window setOpaque:NO];
    [window setHasShadow:YES];
    [window setLevel:NSFloatingWindowLevel];
    [window orderFrontRegardless];
}

- (id)initWithImage:(NSString*)imageName
{
    NSRect    cRect;

    image = [NSImage imageNamed:imageName];
    [image retain];
    cRect.origin.x = 0;
    cRect.origin.y = 0;
    cRect.size = [image size];

    self = [super initWithFrame:cRect];
    [self _createWindow:cRect];
    return self;
}

- (id)initWithLabel:(NSString*)label
{
    NSRect    cRect;

    image = nil;
    text = [label copy];
    cRect.origin.x = 0;
    cRect.origin.y = 0;
    cRect.size = [label sizeWithAttributes:nil];
    cRect.size.width += 4;
    cRect.size.height += 2;

    self = [super initWithFrame:cRect];
    [self _createWindow:cRect];
    return self;
}

- (void)dealloc
{
    [text release];
    [super dealloc];
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)drawRect:(NSRect)rect
{
    [[NSColor colorWithDeviceRed:.98 green:.98 blue:0.8 alpha:.9] set];
    NSRectFill(rect);
    if (image) {
        [image compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
    } else {
        [[NSColor lightGrayColor] set];
        NSFrameRectWithWidth([self bounds], .1);
        [text drawInRect:NSInsetRect([self bounds],2,1) withAttributes:nil];
    }
}

- (void)setLabel:(NSString*)label
    /*" Sets a new label.  Setting a label removes a prior set image.  The size changes also. "*/
{
    NSSize size;
    [image release];
    image = nil;
    [text release];
    text = [label copy];
    size = [text sizeWithAttributes:nil];
    size.width += 4;
    size.height += 2;
    [self setFrameSize:size];
    [[self window] setContentSize:size];
    [self setNeedsDisplay:YES];
}

- (void)positionAt:(NSPoint)screenPoint
    /*" Positions the floating mark on screen. "*/
{
    [[self window] setFrameOrigin:screenPoint];
}

- (void)close:(id)sender
    /*" Closes the floating window.  There is no way to bring it back. "*/
{
    [[self window] close];
}

- (void)fadeOut:(id)sender
    /*" Fades the window before closing it. "*/
{
    float i, max = 150.0;
    for (i = 0.0; i < max; i += 1) {
        [[self window] setAlphaValue:(max-i)/max];
    }
    [[self window] close];
}

@end
