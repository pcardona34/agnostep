/*
 Project: Graphos
 GRTools.h

 Copyright (C) 2000-2008 GNUstep Application Project

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

/**
 * Toolbox
 */

@interface GRToolButton : NSButton
{
    int tooltype;
}

- (id)initWithFrame:(NSRect)rect toolType:(int)type;
- (int)tooltype;

@end

@interface GRToolsView : NSView
{
    NSMutableArray *buttons;
    GRToolButton *barrowButt, *warrowButt, *bezierButt, *textButt;
    GRToolButton *circleButt, *rectangleButt, *paintButt, *pencilButt;
    GRToolButton *rotateButt, *reduceButt, *reflectButt, *scissorsButt;
    GRToolButton *handButt, *magnifyButt;
}

- (id)initWithFrame:(NSRect)rect;
- (void)buttonPressed:(id)sender;
- (void)setButtonsPositions:(int)ptype;

@end

@interface GRToolsWindow : NSPanel
{
    GRToolsView *toolsView;
}

- (id)init;
- (void)setButtonsPositions:(int)ptype;

@end
