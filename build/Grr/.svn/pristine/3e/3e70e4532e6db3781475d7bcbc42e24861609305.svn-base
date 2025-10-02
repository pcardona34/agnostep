/*
   ImageTextCell.h
   
   Copyright (c) 2003-2004
   Author: Ludovic Marcotte <ludovic@Sophos.ca>

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA. 
*/


#ifndef _GNUMail_H_ImageTextCell
#define _GNUMail_H_ImageTextCell

#import <AppKit/AppKit.h>

@interface ImageTextCell : NSTextFieldCell
{
  NSImage *_image;
}

- (void) setImage: (NSImage *) theImage;
- (void) drawWithFrame: (NSRect) theFrame 
               inView: (NSView *) theView;
- (NSSize) cellSize;

@end

#endif // _GNUMail_H_ImageTextCell
