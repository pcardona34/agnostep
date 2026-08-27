/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the
    Free Software Foundation, Inc.  
    31 Milk Street #960789 Boston, MA 02196 USA
*/

#ifndef __MAIN_WINDOW_CONTROLLER_H__
#define __MAIN_WINDOW_CONTROLLER_H__

#import "GNUstep.h"
#import "Label.h"
#import "Parser.h"
#import "HandlerStructure.h"
#import "HandlerStructureXLP.h"
#import "TextFormatterXLP.h"
#import "BrowserCell.h"

@interface MainWindowController : NSObject
{
  NSTextView* resultTextView;
  NSBrowser* resultOutlineView;
    
  NSTextView* text;
  //XMLHandler* handler;
  id <HandlerStructure> handler;

  id window;
}

- (id) initWithTextView: (NSTextView*) text andBrowserView: (NSBrowser*) browser;
- (void) dealloc;
- (BOOL) loadFile: (NSString*) fileName;
- (void) setWindow: (id) win;
- (void) browserClick: (id) sender;
- (void) print: (id) sender;

@end;

#endif
