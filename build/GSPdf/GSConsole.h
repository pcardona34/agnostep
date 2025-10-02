 /*
 *  GSConsole.h: Interface and declarations for the GSConsole 
 *  Class of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002-2009 GNUstep Application Project
 *  
 *  Author: Enrico Sersale
 *  Date: July 2002
 *  Author: Riccardo Mottola
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
#import <AppKit/NSTextView.h>

@class NSWindow;
@class NSTextView;

@interface GSConsole : NSObject
{
	IBOutlet NSWindow *window;
	IBOutlet NSTextView *textView;
}

- (NSWindow *)window;

- (NSTextView *)textView;

@end


