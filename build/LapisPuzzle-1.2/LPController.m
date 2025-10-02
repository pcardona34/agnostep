/*
 * LPController.m
 
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
#import "LPController.h"

#define ROUND_TIME 0.8
#define AI_SPEED 0.1
#define REFRESH_RATE 0.2

@implementation LPController

- (void) applicationWillFinishLaunching: (NSNotification*)aNotification
{
	NSTimer *tickr = nil;
	attackArray = [NSMutableArray new];

	srandom([[NSCalendarDate date] timeIntervalSince1970]);
	[lpview1 setBackgroundImage:[NSImage imageNamed:@"bg1.jpg"]];
	[lpview2 setBackgroundImage:[NSImage imageNamed:@"bg2.jpg"]];
	[lpview2 toggleAI];
	[next1 setBackgroundImage:[NSImage imageNamed:@"bg1.jpg"]];
	[next2 setBackgroundImage:[NSImage imageNamed:@"bg2.jpg"]];

	ASSIGN(tick, [NSTimer scheduledTimerWithTimeInterval:ROUND_TIME
												  target:self
												selector:@selector(round)
												userInfo:nil
												 repeats:YES]);


	ASSIGN(tickr, [NSTimer scheduledTimerWithTimeInterval:REFRESH_RATE
												   target:self
												 selector:@selector(refresh)
												 userInfo:nil
												  repeats:YES]);
	ASSIGN(tickr, [NSTimer scheduledTimerWithTimeInterval:AI_SPEED
												   target:self
												 selector:@selector(AIMove)
												 userInfo:nil
												  repeats:YES]);
	[[lpview1 window] makeFirstResponder:lpview1];
}

- (void) simpleAI:(id)view
{
	if ([view currentUnit] == nil)
	{
		return;
	}

	if ([[view currentUnit] X] > 3)
	{
		if (![view processDir:LP_MOVE_RIGHT])
		{
			[view processDir:LP_MOVE_FALL];
		}
	}
	else if(![view processDir:LP_MOVE_LEFT])
	{
		if ([[view currentUnit] X] < 3)
		{
			[view processDir:LP_MOVE_FALL];
		}
		else if (![view processDir:LP_MOVE_RIGHT])
		{
			[view processDir:LP_MOVE_FALL];
		}
	}
}

- (void) player:(id)pl processStone:(int)num
{
	if (pl == lpview1)
	{
		[attackArray addObject:[NSString stringWithFormat:@"<--[%d]---",num]];
	}
	else
	{
		[attackArray addObject:[NSString stringWithFormat:@"---[%d]-->",num]];
	}
	[attackList reloadColumn:0];
}

- (void) player:(id)pl addStoneToOp:(int)num
{
	if (pl == lpview1)
	{
		pl = lpview2;
	}
	else
	{
		pl = lpview1;
	}
	[pl addStone:num];
}

- (void) op:(id)pl processDir:(LPDirType)dir
{
	if (pl == lpview1)
	{
		[lpview2 processDir:dir];
	}
	else
	{
		[lpview1 processDir:dir];
	}
}



- (void) refresh
{
	[lpview1 refresh];
	[lpview2 refresh];
	[next1 refresh];
	[next2 refresh];
}

- (void) AIMove
{
	if ([lpview1 useAI])
	{
		[self simpleAI:lpview1];
	}
	if ([lpview2 useAI])
	{
		[self simpleAI:lpview2];
	}

}

- (void) round
{
	[lpview1 round];
	[lpview2 round];
}

- (void) lapisPuzzleView:(LapisPuzzleView *)sender
 didFinishUnitWithResult:(LPResultType)result
{
	id unit;
	switch(result)
	{
		case LP_RESULT_REQUEST:
			if (sender == lpview1)
			{
				[next1 fallEmDown];
				[next1 addJewelUnit];
				unit = [next1 getUnitAtX:0 Y:0];
				if (unit)
				{
					[unit setOwner:lpview1];
					[unit rMoveX:3 Y:14];
					[lpview1 addUnit:unit];
					[next1 removeUnit:unit];
				}
				[next1 fallEmDown];
				[next1 setNeedsDisplay:YES];
			}
			else
			{
				[next2 fallEmDown];
				[next2 addJewelUnit];
				unit = [next2 getUnitAtX:0 Y:0];
				if (unit)
				{
					[unit setOwner:lpview2];
					[unit rMoveX:3 Y:14];
					[lpview2 addUnit:unit];
					[next2 removeUnit:unit];
				}
				[next2 fallEmDown];
				[next2 setNeedsDisplay:YES];
			}

			break;
		case LP_RESULT_GAMEOVER:
			[tick invalidate];
			tick = nil;
			/* demo mode auto restart */
			if ([lpview1 useAI] && [lpview2 useAI])
			{
				[NSTimer scheduledTimerWithTimeInterval:10
												 target:self
											   selector:@selector(restart:)
											   userInfo:nil
												repeats:NO];
			}
			break;
	}
}

- (IBAction) restart:(id)sender
{
	[tick invalidate];
	tick = nil;

	[attackArray removeAllObjects];
	[attackList reloadColumn:0];
	[lpview1 restart];
	[lpview2 restart];

	ASSIGN(tick, [NSTimer scheduledTimerWithTimeInterval:ROUND_TIME
												  target:self
												selector:@selector(round)
												userInfo:nil
												 repeats:YES]);
}

- (int) browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
	return [attackArray count];
}

- (void) browser: (NSBrowser *)sender
 willDisplayCell: (NSBrowserCell *)cell
		   atRow: (int)row
		  column: (int)column
{
	[cell setTitle:[attackArray objectAtIndex:row]];
	[cell setLeaf:YES];
}
@end

