/*
 Project: Graphos
 Graphos.h

 Copyright (C) 2000-2018 GNUstep Application Project

 Author: Enrico Sersale (original implementation)
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

#import "GRTools.h"
#import "GRPropsEditor.h"


#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#define sel_isEqual(selector1, selector2) (selector1 ==  selector2)
#else
#include <objc/runtime.h>
#endif

/* change this if the new file format becomes incompatible */
#define FILE_FORMAT_VERSION 0.6

/**
 * tool types structure
 */
typedef enum
{
    blackarrowtool,
    whitearrowtool,
    beziertool,
    texttool,
    circletool,
    rectangletool,
    painttool,
    penciltool,
    rotatetool,
    reducetool,
    reflecttool,
    scissorstool,
    handtool,
    magnifytool
} ToolType;

/**
 * Application Controller
 */
@interface Graphos : NSObject
{
    GRToolsWindow *tools;
    ToolType tooltype;
    GRPropsEditor *objectInspector;
}

- (IBAction)showObjectInspector: (id)sender;

- (GRPropsEditor *)objectInspector;

- (void)setToolType:(ToolType)type;

- (ToolType)currentToolType;

- (void)updateCurrentWindow;


@end

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)

@interface NSString (TigerExtensions)
- (BOOL) boolValue;
@end


#endif
