/* Document.h Subclass of NSDocument for Ink application

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Fred Kiefer <fredkiefer@gmx.de>
   Date: 2000
   
   This file is part of GNUstep.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
#include <Foundation/NSData.h>
#include <Foundation/NSAttributedString.h>
#include <AppKit/NSDocument.h>
#include <AppKit/NSTextView.h>

@interface Document : NSDocument
{
    NSMutableAttributedString *ts;
    NSTextView *tv;
}

- (void)insertFile: (id)sender;

@end
