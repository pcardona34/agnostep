/*
 Project: Graphos
 GRTools.m

 Copyright (C) 2000-2018 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */


#import "GRTools.h"
#import "Graphos.h"

@implementation GRToolButton

- (id)initWithFrame:(NSRect)rect toolType:(int)type
{
    self = [super initWithFrame: rect];
    if(self) {
        tooltype = type;
    }
    return self;
}

- (int)tooltype
{
    return tooltype;
}

@end

@implementation GRToolsView

- (id)initWithFrame:(NSRect)rect
{
    self = [super initWithFrame: rect];
    if(self)
    {
        buttons = [[NSMutableArray alloc] initWithCapacity: 14];

        barrowButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(0, 120, 25, 20)
                                                toolType: blackarrowtool];
        [barrowButt setButtonType: NSOnOffButton];
        [barrowButt setImage: [NSImage imageNamed: @"blackarrow.tiff"]];
        [barrowButt setImagePosition: NSImageOnly];
        [barrowButt setTarget:self];
        [barrowButt setAction:@selector(buttonPressed:)];
        [self addSubview: barrowButt];
        [buttons addObject: barrowButt];
        [barrowButt release];

        warrowButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(25, 120, 25, 20)
                                                toolType: whitearrowtool];
        [warrowButt setButtonType: NSOnOffButton];
        [warrowButt setImage: [NSImage imageNamed: @"whitearrow.tiff"]];
        [warrowButt setImagePosition: NSImageOnly];
        [warrowButt setTarget:self];
        [warrowButt setAction:@selector(buttonPressed:)];
        [self addSubview: warrowButt];
        [buttons addObject: warrowButt];
        [warrowButt release];

        bezierButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(0, 100, 25, 20)
                                                toolType: beziertool];
        [bezierButt setButtonType: NSOnOffButton];
        [bezierButt setImage: [NSImage imageNamed: @"bezier.tiff"]];
        [bezierButt setImagePosition: NSImageOnly];
        [bezierButt setTarget:self];
        [bezierButt setAction:@selector(buttonPressed:)];
        [self addSubview: bezierButt];
        [buttons addObject: bezierButt];
        [bezierButt release];

        textButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(25, 100, 25, 20)
                                              toolType: texttool];
        [textButt setButtonType: NSOnOffButton];
        [textButt setImage: [NSImage imageNamed: @"text.tiff"]];
        [textButt setImagePosition: NSImageOnly];
        [textButt setTarget:self];
        [textButt setAction:@selector(buttonPressed:)];
        [self addSubview: textButt];
        [buttons addObject: textButt];
        [textButt release];

        circleButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(0, 80, 25, 20)
                                                toolType: circletool];
        [circleButt setButtonType: NSOnOffButton];
        [circleButt setImage: [NSImage imageNamed: @"circle.tiff"]];
        [circleButt setImagePosition: NSImageOnly];
        [circleButt setTarget:self];
        [circleButt setAction:@selector(buttonPressed:)];
        [self addSubview: circleButt];
        [buttons addObject: circleButt];
        [circleButt release];

        rectangleButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(25, 80, 25, 20)
                                                   toolType: rectangletool];
        [rectangleButt setButtonType: NSOnOffButton];
        [rectangleButt setImage: [NSImage imageNamed: @"rectangle.tiff"]];
        [rectangleButt setImagePosition: NSImageOnly];
        [rectangleButt setTarget:self];
        [rectangleButt setAction:@selector(buttonPressed:)];
        [self addSubview: rectangleButt];
        [buttons addObject: rectangleButt];
        [rectangleButt release];

        paintButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(0, 60, 25, 20)
                                               toolType: painttool];
        [paintButt setButtonType: NSOnOffButton];
        [paintButt setImage: [NSImage imageNamed: @"paint.tiff"]];
        [paintButt setImagePosition: NSImageOnly];
        [paintButt setTarget:self];
        [paintButt setAction:@selector(buttonPressed:)];
        [self addSubview: paintButt];
        [buttons addObject: paintButt];
        [paintButt release];
        [paintButt setEnabled:NO];


        pencilButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(25, 60, 25, 20)
                                                toolType: penciltool];
        [pencilButt setButtonType: NSOnOffButton];
        [pencilButt setImage: [NSImage imageNamed: @"pencil.tiff"]];
        [pencilButt setImagePosition: NSImageOnly];
        [pencilButt setTarget:self];
        [pencilButt setAction:@selector(buttonPressed:)];
        [self addSubview: pencilButt];
        [buttons addObject: pencilButt];
        [pencilButt release];
        [pencilButt setEnabled:NO];

        rotateButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(0, 40, 25, 20)
                                                toolType: rotatetool];
        [rotateButt setButtonType: NSOnOffButton];
        [rotateButt setImage: [NSImage imageNamed: @"rotate.tiff"]];
        [rotateButt setImagePosition: NSImageOnly];
        [rotateButt setTarget:self];
        [rotateButt setAction:@selector(buttonPressed:)];
        [self addSubview: rotateButt];
        [buttons addObject: rotateButt];
        [rotateButt release];
        [rotateButt setEnabled:NO];

        reduceButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(25, 40, 25, 20)
                                                toolType: reducetool];
        [reduceButt setButtonType: NSOnOffButton];
        [reduceButt setImage: [NSImage imageNamed: @"reduce.tiff"]];
        [reduceButt setImagePosition: NSImageOnly];
        [reduceButt setTarget:self];
        [reduceButt setAction:@selector(buttonPressed:)];
        [self addSubview: reduceButt];
        [buttons addObject: reduceButt];
        [reduceButt release];
        [reduceButt setEnabled:NO];

        reflectButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(0, 20, 25, 20)
                                                 toolType: reflecttool];
        [reflectButt setButtonType: NSOnOffButton];
        [reflectButt setImage: [NSImage imageNamed: @"reflect.tiff"]];
        [reflectButt setImagePosition: NSImageOnly];
        [reflectButt setTarget:self];
        [reflectButt setAction:@selector(buttonPressed:)];
        [self addSubview: reflectButt];
        [buttons addObject: reflectButt];
        [reflectButt release];
        [reflectButt setEnabled:NO];

        scissorsButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(25, 20, 25, 20)
                                                  toolType: scissorstool];
        [scissorsButt setButtonType: NSOnOffButton];
        [scissorsButt setImage: [NSImage imageNamed: @"shissors.tiff"]];
        [scissorsButt setImagePosition: NSImageOnly];
        [scissorsButt setTarget:self];
        [scissorsButt setAction:@selector(buttonPressed:)];
        [self addSubview: scissorsButt];
        [buttons addObject: scissorsButt];
        [scissorsButt release];

        handButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(0, 0, 25, 20)
                                              toolType: handtool];
        [handButt setButtonType: NSOnOffButton];
        [handButt setImage: [NSImage imageNamed: @"hand.tiff"]];
        [handButt setImagePosition: NSImageOnly];
        [handButt setTarget:self];
        [handButt setAction:@selector(buttonPressed:)];
        [self addSubview: handButt];
        [buttons addObject: handButt];
        [handButt release];
        [handButt setEnabled:NO];

        magnifyButt = [[GRToolButton alloc] initWithFrame: NSMakeRect(25, 0, 25, 20)
                                                 toolType: magnifytool];
        [magnifyButt setButtonType: NSOnOffButton];
        [magnifyButt setImage: [NSImage imageNamed: @"magnify.tiff"]];
        [magnifyButt setImagePosition: NSImageOnly];
        [magnifyButt setTarget:self];
        [magnifyButt setAction:@selector(buttonPressed:)];
        [self addSubview: magnifyButt];
        [buttons addObject: magnifyButt];
        [magnifyButt release];

        [barrowButt setState: NSOnState];
        [[NSApp delegate] setToolType: blackarrowtool];
    }
    return self;
}

- (void)dealloc
{
    [buttons release];
    [super dealloc];
}

- (void)buttonPressed:(id)sender
{
    ToolType type;

    type = [(GRToolButton *)sender tooltype];
    [[NSApp delegate] setToolType: type];
}

- (void)setButtonsPositions:(int)ptype
{
    GRToolButton *butt;
    int i;

    for(i = 0; i < [buttons count]; i++)
    {
        butt = [buttons objectAtIndex: i];
        if([butt tooltype] != ptype)
            [butt setState: NSOffState];
        else
            [butt setState: NSOnState];
    }
}

@end


@implementation GRToolsWindow

- (id)init
{
    unsigned int style = NSTitledWindowMask;

    self = [super initWithContentRect: NSMakeRect(10, 400, 50, 140)
                            styleMask: style
                              backing: NSBackingStoreBuffered
                                defer: NO];
    if(self)
    {
        [self setTitle: @" "];
        [self setFloatingPanel:YES];
        toolsView = [[GRToolsView alloc] initWithFrame: NSMakeRect(0, 0, 50, 140)];
        [[self contentView] addSubview: toolsView];
        [self setFrameAutosaveName:@"Draw_Tools"];
    }
    return self;
}

- (void)dealloc
{
    [toolsView release];
    [super dealloc];
}

- (void)setButtonsPositions:(int)ptype
{
    [toolsView setButtonsPositions: ptype];
}


- (BOOL) canBecomeKeyWindow
{
    return NO;
}
@end

