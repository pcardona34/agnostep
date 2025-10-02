/*
 Project: Graphos
 GRTextEditor.m

 Copyright (C) 2000-2015 GNUstep Application Project

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


#import "GRTextEditor.h"

@implementation GRTextEditor

- (id)initEditor:(GRDrawableObject *)anObject
{
    unsigned int style = NSTitledWindowMask | NSResizableWindowMask;

    self = [super initEditor:anObject];

    if(self)
    {
        myWindow = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 500, 300)
                                styleMask: style
                                  backing: NSBackingStoreBuffered
                                    defer: NO];
        isSelect = NO;
        [myWindow setMaxSize: NSMakeSize(500, 2000)];
        [myWindow setMinSize: NSMakeSize(500, 300)];
        [myWindow setTitle: @"Text Editor"];
        object = anObject;
        myView = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  GRTextEditor *objCopy;
  
  objCopy = (GRTextEditor *)[super copyWithZone:zone];
  
  objCopy->myWindow = [myWindow retain];
  objCopy->myView = nil;
  objCopy->isSelect = isSelect;
  
  return objCopy;
}


- (void)setPoint:(NSPoint)p
      withString:(NSString *)string
      attributes:(NSDictionary *)attributes
{
  if (myView == nil)
    {
      myView = [[GRTextEditorView alloc] initWithFrame: [myWindow frame] withString: string attributes: attributes];
      [myWindow setContentView: myView];
    }
  [myWindow center];
}

- (int) runModal
{
  NSApplication *app = [NSApplication sharedApplication];
  [myView setFirstResponder];
  [app runModalForWindow: myWindow];
  return [myView result];
}

- (void)dealloc
{
  [myView release];
  [super dealloc];
}

- (GRTextEditorView *)editorView
{
    return myView;
}


- (void)selectAsGroup
{
    if([object locked])
        return;
    isSelect = YES;
}

- (void)unselect
{
    isSelect = NO;
}

- (BOOL)isSelected
{
    return isSelect;
}

- (BOOL)isGroupSelected
{
    return isSelect;
}


@end
