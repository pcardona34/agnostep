/*
 Project: Graphos
 GRDocument.h

 Copyright (C) 2000-2011 GNUstep Application Project

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

#import <AppKit/AppKit.h>
#import "GRDocView.h"

@interface GRDocument : NSDocument
{
  IBOutlet GRDocView *docView;
  NSDictionary *documentDictionary;
}

/** accessor to the current View of the document */
- (GRDocView *)docView;

@end
