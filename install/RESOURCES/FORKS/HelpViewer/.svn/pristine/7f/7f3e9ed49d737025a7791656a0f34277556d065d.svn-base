/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>
                  2025-2026 Riccardo Mottola <rm@gnu.org>
 
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

#ifndef __HELP_DOCUMENT_H__
#define __HELP_DOCUMENT_H__

#import <AppKit/NSDocument.h>

#import "GNUstep.h"
#import "Label.h"
#import "Parser.h"
#import "HandlerStructure.h"
#import "HandlerStructureXLP.h"
#import "TextFormatterXLP.h"
#import "BrowserCell.h"

@interface HelpDocument : NSDocument
{
  id query;
  id search;
  id index;
  id back;
  id bookshelf;
 
  IBOutlet NSTextView *textView;
  IBOutlet NSBrowser *tocBrowser;

  //XMLHandler* handler;
  id <HandlerStructure> handler;
  TextFormatterXLP *_textFormatter;
  NSBundle *_bundle;
}

- (void) dealloc;
- (void) browserClick: (id) sender;
- (void) print: (id) sender;
- (NSBundle *) bundle;
- (TextFormatterXLP *) textFormatter;

@end;

#endif
