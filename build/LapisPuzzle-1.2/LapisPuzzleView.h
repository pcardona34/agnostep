/*
 * LapisPuzzleView.h

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

#import <Foundation/NSCalendarDate.h>
#import <AppKit/AppKit.h>
#import "LapisPuzzle.h"

typedef enum _LPUnitColorType
{
	LP_COLOR_BLUE,
	LP_COLOR_RED,
	LP_COLOR_GREEN,
	LP_COLOR_YELLOW,
	LP_COLOR_ALL
} LPUnitColorType;

typedef enum _LPDirType
{
	LP_MOVE_UP, // for sokoban mode
	LP_MOVE_LEFT,
	LP_MOVE_RIGHT,
	LP_MOVE_DOWN,
	LP_MOVE_FALL,
	LP_MOVE_CW,
	LP_MOVE_CCW
} LPDirType;

@class LPUnit;

@protocol LPUnitOwner
- (NSArray *) allUnits;
- (NSSize) gridSize;
- (id) getUnitAtX:(int)x
                Y:(int)y;
/*
- (unsigned int) numberOfSteps;
- (BOOL) unit:(LPUnit *)sender
 canMoveToDir:(LPDirType)dir;
 */
@end

@interface LPUnit:NSObject
{
    id <LPUnitOwner> __owner;
	LPUnitColorType _color;
	LPDirType _d;
	BOOL _isBlowing;

@public
	float alpha; //hack
}

- (float) alpha;
- (void) setAlpha:(float)a;
- (id) initWithOwner:(id <LPUnitOwner>)owner
			   color:(LPUnitColorType)color;
- (void) setX:(unsigned int)x
			Y:(unsigned int)y;
- (void) round;
- (void) explode; // release self
- (void) draw;
- (LPUnitColorType) unitColor;
- (BOOL) isBlowing;
- (void) blow;
- (void) setUnitColor:(LPUnitColorType)color;
- (int) rows;
- (int) columns;
- (void) changePhase;
- (int) X;
- (int) Y;
- (float) phase;
- (void) setOwner:(id <LPUnitOwner>)owner;
- (void) fallToBottom;
- (BOOL) moveInDir:(LPDirType)dir;
- (BOOL) canMoveInDir:(LPDirType)dir;
- (BOOL) canRMoveX:(int)rx Y:(int)ry;
- (BOOL) rMoveX:(int)rx Y:(int)ry;
- (BOOL) hasPartAtX:(int)x Y:(int)y;
- (void) softBlow;
@end

@interface LPJewelUnit:LPUnit
{
	int _x;
	int _y;
	int _rows;
	int _columns;
	float z;
}
- (id) initWithOwner:(id <LPUnitOwner>)owner
			   color:(LPUnitColorType)color
				   X:(int)x
				   Y:(int)y;

- (void) addRows:(int)r;
- (void) addColumns:(int)c;
@end

@interface LPSparkerUnit:LPJewelUnit
- (void) spark;
@end

@interface LPStoneUnit:LPJewelUnit
{
	int _count;
	/*
	NSMutableAttributedString *str[6];
	NSSize strSize[6];
	*/
}
- (void) countDown;
- (int) count;
@end

@interface LPGroupUnit:LPUnit <LPUnitOwner>
{
	LPDirType _laydir;
	NSArray *_units;
}

- (id) initWithOwner:(id <LPUnitOwner>)owner
			   atoms:(NSArray *)unitList;
- (int) X;
- (int) Y;
@end

@class LapisPuzzleView;

typedef enum _LPResultType
{
	LP_RESULT_REQUEST,
	LP_RESULT_GAMEOVER
} LPResultType;

@protocol LPViewOwner
- (void) lapisPuzzleView:(LapisPuzzleView *)sender
 didFinishUnitWithResult:(LPResultType)result;
- (void) op:(id)pl processDir:(LPDirType)dir;
- (void) player:(id)pl addStoneToOp:(int)num;
@end

#define LP_FALLING_ITEMS 2
@interface LapisPuzzleView:NSView <LPUnitOwner>
{
	BOOL _gameOver;
	IBOutlet id <LPViewOwner> __owner;

	float _stepHeight;
	float _stepWidth;
	int _stepsInUnit;
	NSImage *_background;

	int _numberOfRows;
	int _numberOfColumns;

	id __currentUnit;

	NSMutableArray *_units;
	NSMutableArray *_blowing;

	int chain;
	int stone;
	int trip;
	int chaintrip;
	int maxchain;
	BOOL _useAI;
	BOOL _lockControl;
}

- (void) setBackgroundImage:(NSImage *)image;
- (void) gameOver;

- (void) addJewelUnit;
- (void) round;
- (void) addUnit:(id)newUnit;
- (void) addStone:(int)num;
- (void) refresh;
- (void) restart;
- (void) blowIt;
- (void) packCell;
- (void) fallEmDown;
- (void) runStone;

- (BOOL) processDir:(LPDirType)dir;
- (id) currentUnit;
- (void) toggleAI;
- (BOOL) useAI;


@end

@interface LapisNextView:LapisPuzzleView
- (void) removeUnit:(id)unit;
@end
