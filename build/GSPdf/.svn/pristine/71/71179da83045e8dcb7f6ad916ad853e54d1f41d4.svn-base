 /*
 *  GSPdfDocWin.h: Interface and declarations for the GSPdfDocWin 
 *  Class of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002-2012
 *  Riccardo Mottola <rm@gnu.org>
 *  Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: February 2002
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */

#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSWindowController.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSStepper.h>
#import <AppKit/NSButton.h>

#import "GSPdfView.h"

#define ANTI_ALIASING_KEY @"UseAntiAliasing"

@interface GSPdfDocWin : NSWindowController
{
  IBOutlet NSWindow *window;
  IBOutlet NSScrollView *scroll;
  IBOutlet NSButton *leftButt;
  IBOutlet NSButton *rightButt;
  IBOutlet NSScrollView *matrixScroll;
  IBOutlet NSTextField *zoomField;
  IBOutlet NSStepper *zoomStepper;
  IBOutlet NSButton *zoomButt;
  IBOutlet NSButton *handButt;
  IBOutlet NSButton *antiAliasSwitch;

  GSPdfView *imageView;
  BOOL isZooming;
  NSPoint zoomPoint;
}

- (GSPdfView *)imageView;
- (NSScrollView *)matrixScroll;

- (void)setImage:(NSImage *)anImage;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;

- (BOOL)antiAlias;
- (void)setBusy:(BOOL)value;

- (IBAction)selectZoomButt:(id)sender;
- (IBAction)selectHandButt:(id)sender;
- (IBAction)nextPage:(id)sender;
- (IBAction)previousPage:(id)sender;
- (IBAction)setAntiAlias:(id)sender;
- (IBAction)setZoomValue:(id)sender;

@end

