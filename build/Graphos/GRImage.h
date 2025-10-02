/*
 Project: Graphos
 GRImage.h
 
 Copyright (C) 2015 GNUstep Application Project
 
 Author: Ing. Riccardo Mottola
 
 Created: 2015-01-16
 
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
#import <AppKit/NSImage.h>

#import "GRBox.h"

@interface GRImage : GRBox
{
  NSString *name;
  NSImage *image;
  NSSize originalSize;
  float originalRatio;
}

- (NSImage *)image;
- (void)setImage:(NSImage *)img;
- (float)originalRatio;

@end
