/*
 * LPController.h

 * Copyright 2004-2011 The Free Software Foundation
 *
 * Copyright (C) 2004 Banlu Kemiyatorn.
 * July 19, 2004
 * Written by Banlu Kemiyatorn <object at gmail dot com>
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.

 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
 */

#import <AppKit/AppKit.h>
#import "LapisPuzzleView.h"

@interface LPController : NSObject <LPViewOwner>
{
	IBOutlet LapisPuzzleView *lpview1;
	IBOutlet LapisPuzzleView *lpview2;

	IBOutlet id attackList;
	IBOutlet id next1;
	IBOutlet id next2;

	NSMutableArray *attackArray;
	NSTimer *tick;
}
- (IBAction) restart:(id)sender;
- (void) player:(id)pl processStone:(int)num;
@end
