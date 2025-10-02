/* 
   Copyright (C) 2010, 2011, 2012, 2013 German A. Arias <german@xelalug.org>

   This file is part of Gemas application

   Gemas is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import <AppKit/AppKit.h>

#import <Foundation/NSRange.h>
#import <Foundation/NSString.h>

@class NSNotification,
       NSString,
       NSFont,
       NSColor;

#define CodeEditorDefaultsDidChangeNotification @"CodeEditorDefaultsChanged"

@interface GemasDocument : NSDocument
{
  id textView;
  id numberLine;
  id numberColumn;
  id documentWindow;

  NSString *string;
  NSColor *textColor;

  // Autocomplete  
  NSUInteger length;
}
- (void) goToLineNumber: (int)number;
- (void) textViewDidChangeSelection: (NSNotification *) notification;
- (NSColor *) textColor;
- (void) defaultsChanged: (NSNotification *) notif;
- (void) windowDidBecomeMain: (NSNotification*)aNotification;
- (void) windowWillClose: (NSNotification*)aNotification;
- (NSArray *) textView: (NSTextView *)aTextView completions: (NSArray *)words
  forPartialWordRange: (NSRange)range indexOfSelectedItem: (NSInteger *)index;

@end
