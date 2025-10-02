/*
 * LapisPuzzleView.m
 
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

#import "LapisPuzzleView.h"
#import "LPController.h"
#include <math.h>

static float _grid_height;

#define MATCH_COLOR(a,b) ((a == b))

@implementation LPUnit

- (id) description
{
	return [NSString stringWithFormat:@"<%@: %p %d>",[self className], self, _color];
}

+ (void) setGridHeight:(float)points
{
	_grid_height = points;
}

- (id) initWithOwner:(id <LPUnitOwner>)owner
			   color:(LPUnitColorType)color
{
	alpha = 1.0;
	__owner = owner;
	_color = color;
	_isBlowing = NO;
	return self;
}

- (void) setOwner:(id <LPUnitOwner>)owner
{
	__owner = owner;
}

- (float) alpha
{
	return alpha;
}

- (void) setAlpha:(float)a
{
  if (a < 0)
    a = 0;
  alpha = a;
}

- (LPUnitColorType) unitColor
{
	return _color;
}

- (void) setUnitColor:(LPUnitColorType)color
{
	_color = color;
}

- (int) rows
{
	return 0;
}

- (int) columns
{
	return 0;
}

- (BOOL) hasPartAtX:(int)x
				  Y:(int)y
{
	return NO;
}

- (void) fallToBottom
{
	while ([self moveInDir:LP_MOVE_DOWN]);
}

- (BOOL) isBlowing
{
	return _isBlowing;
}

- (void) softBlow
{
	_isBlowing = YES;
}

- (void) blow
{
	int unit_x, unit_y, unit_rows, unit_columns;
	int i;
	id m;

	if (_isBlowing)
	{
		return;
	}

	_isBlowing = YES;

	unit_x = [self X];
	unit_y = [self Y];
	unit_rows = [self rows];
	unit_columns = [self columns];

	for (i = 0; i < unit_columns; i++)
	{
		m = [__owner getUnitAtX:unit_x + i
			     Y:unit_y - 1];

		if (m && (MATCH_COLOR([m unitColor], _color) || [m isMemberOfClass:[LPStoneUnit class]]))
		{
			[m blow];
		}

		m = [__owner getUnitAtX:unit_x + i
			     Y:unit_y + unit_rows];
		if (m && (MATCH_COLOR([m unitColor], _color) || [m isMemberOfClass:[LPStoneUnit class]]))
		{
			[m blow];
		}

	}

	for (i = 0; i < unit_rows; i++)
	{
		m = [__owner getUnitAtX:unit_x - 1
			     Y:unit_y + i];
		if (m && (MATCH_COLOR([m unitColor], _color) || [m isMemberOfClass:[LPStoneUnit class]]))
		{
			[m blow];
		}

		m = [__owner getUnitAtX:unit_x + unit_columns
			     Y:unit_y + i];
		if (m && (MATCH_COLOR([m unitColor], _color) || [m isMemberOfClass:[LPStoneUnit class]]))
		{
			[m blow];
		}

	}
}

/** subclass responsibility **/

- (BOOL) moveInDir:(LPDirType)dir
{
  return NO;
}

- (BOOL) rMoveX:(int)rx Y:(int)ry
{
  return NO;
}

- (void) changePhase
{
}

- (int) X
{
  return 0;
}

- (int) Y
{
  return 0;
}

- (float) phase
{
  return 0.0;
}

- (void) explode
{
}

- (void) draw
{
}

- (void) round
{
}

- (void) setX:(unsigned int)x Y:(unsigned int)y
{
}

- (BOOL) canMoveInDir:(LPDirType)dir
{
  return NO;
}

- (BOOL) canRMoveX:(int)rx Y:(int)ry
{
  return NO;
}

@end

@implementation LPStoneUnit;
- (id) initWithOwner:(id <LPUnitOwner>)owner
			   color:(LPUnitColorType)color
				   X:(int)x
				   Y:(int)y
{
	_count = 5;

	return [super initWithOwner:owner
						  color:color
							  X:x
							  Y:y];
}

- (int) count
{
	return _count;
}

- (void) countDown
{
	_count--;
}


- (void) draw
{
	int i;
	NSColor *tcolor;
	NSMutableAttributedString *str;
	NSSize strSize;
	NSSize gz = [__owner gridSize];
	float border = gz.width/6;

	[super draw];

	PSsetrgbcolor(0.7,0.7,0.7);
	PSsetalpha(alpha);
	PSrectfill(_x * gz.width , _y *gz.height, _columns * gz.width, _rows * gz.height);
	PSsetrgbcolor(1,1,1);

	PSsetalpha(alpha/3);
	PSsetlinewidth(0);
	PSmoveto(_x * gz.width, _y * gz.height);
	PSlineto(_x * gz.width + gz.width/4, _y * gz.height + gz.width/4);
	PSlineto(_x * gz.width + gz.width/4, (_y+_rows) * gz.height - gz.width/4);
	PSlineto(_x * gz.width, (_y+_rows) * gz.height);
	PSfill();

	PSsetalpha(alpha);
	PSsetlinewidth(0);
	PSmoveto(_x * gz.width, (_y+_rows) * gz.height);
	PSlineto(_x * gz.width + gz.width/4, (_y+_rows) * gz.height - gz.width/4);
	PSlineto((_x+_columns) * gz.width - gz.width/4, (_y+_rows) * gz.height - gz.width/4);
	PSlineto((_x+_columns) * gz.width, (_y+_rows) * gz.height);
	PSfill();

	for (i = 0; i <_rows; i+=2)
	{
		PSgsave();
			PSsetlinecap(1);
			PSsetalpha(alpha/10);
			PSsetlinewidth(_columns * border * 4);
			PSrectclip(_x * gz.width + gz.width/4, _y *gz.height + gz.height/4, _columns * gz.width - gz.width/2, _rows * gz.height - gz.height/2);

			PSmoveto(_x * gz.width, (_y + i) * gz.height);
			PSlineto((_x + _columns) * gz.width, (_y + i + _columns) * gz.height);
			PSstroke();
		PSgrestore();
	}

	for (i = 0; i <_rows; i++)
	{
		PSgsave();
			PSsetlinecap(1);
			PSsetlinewidth(_columns * border * 2);
			PSrectclip(_x * gz.width + gz.width/4, _y *gz.height + gz.height/4, _columns * gz.width - gz.width/2, _rows * gz.height - gz.height/2);

			PSsetalpha(alpha/4);
			PSmoveto(_x * gz.width, (_y + i*4) * gz.height + (i + _rows) * 10);
			PSlineto((_x + _columns) * gz.width, (_y + i*4 + _columns) * gz.height + (i + _rows) * 10);
			PSstroke();
		PSgrestore();
	}

	PSsetrgbcolor(0.3,0.3,0.3);

	PSsetalpha(alpha/2);
	PSsetlinewidth(0);
	PSmoveto(_x * gz.width, _y * gz.height);
	PSlineto(_x * gz.width + gz.width/4, _y * gz.height + gz.width/4);
	PSlineto((_x+_columns) * gz.width - gz.width/4, _y * gz.height + gz.width/4);
	PSlineto((_x+_columns) * gz.width, _y * gz.height);
	PSfill();
	
	PSsetalpha(alpha/3);
	PSsetlinewidth(0);
	PSmoveto((_x+_columns) * gz.width, _y * gz.height);
	PSlineto((_x+_columns) * gz.width - gz.width/4, _y * gz.height + gz.width/4);
	PSlineto((_x+_columns) * gz.width - gz.width/4, (_y+_rows) * gz.height - gz.width/4);
	PSlineto((_x+_columns) * gz.width, (_y+_rows) * gz.height);
	PSfill();


	/****/

	PSsetrgbcolor(0,0,0);
	PSsetalpha(0.8);
	PSrectfill(_x * gz.width + gz.width/8, _y *gz.height + gz.height/8, gz.width - gz.width/4, gz.height - gz.height/4);

	switch (_color)
	{
		case LP_COLOR_YELLOW:
			tcolor = [NSColor yellowColor];
			break;
		case LP_COLOR_GREEN:
			tcolor = [NSColor greenColor];
			break;
		case LP_COLOR_RED:
			tcolor = [NSColor redColor];
			break;
		case LP_COLOR_BLUE:
			tcolor = [NSColor blueColor];
			break;
		default:
			tcolor = [NSColor grayColor];
	}

	str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",_count]];
	[str addAttribute:NSForegroundColorAttributeName
				value:tcolor
				range:NSMakeRange(0,1)];
	[str addAttribute:NSFontAttributeName
				value:[NSFont boldSystemFontOfSize:gz.height/1.5]
				range:NSMakeRange(0,1)];
	strSize = [str size];

	PSsetalpha(alpha);
	[str drawAtPoint:NSMakePoint(_x * gz.width + gz.width/2 - strSize.width/2, _y * gz.height + gz.height/2 - strSize.height/2)];

}

- (void) blow
{
	_isBlowing = YES;
}
@end

@implementation LPSparkerUnit
- (void) spark
{
	int unit_x, unit_y, unit_rows, unit_columns;
	int i;
	id m;

	unit_x = [self X];
	unit_y = [self Y];
	unit_rows = [self rows];
	unit_columns = [self columns];

	for (i = 0; i < unit_columns; i++)
	{
		m = [__owner getUnitAtX:unit_x + i
							  Y:unit_y - 1];

		if (m && MATCH_COLOR([m unitColor],_color) && ![m isMemberOfClass:[LPStoneUnit class]])
		{
			[self blow];
		}

		m = [__owner getUnitAtX:unit_x + i
							  Y:unit_y + unit_rows];
		if (m && MATCH_COLOR([m unitColor],_color) && ![m isMemberOfClass:[LPStoneUnit class]])
		{
			[self blow];
		}

	}

	for (i = 0; i < unit_rows; i++)
	{
		m = [__owner getUnitAtX:unit_x - 1
							  Y:unit_y + i];
		if (m && MATCH_COLOR([m unitColor], _color) && ![m isMemberOfClass:[LPStoneUnit class]])
		{
			[self blow];
		}

		m = [__owner getUnitAtX:unit_x + unit_columns
							  Y:unit_y + i];
		if (m && MATCH_COLOR([m unitColor], _color) && ![m isMemberOfClass:[LPStoneUnit class]])
		{
			[self blow];
		}

	}
}

- (void) draw
{
	NSSize gz = [__owner gridSize];
	float border = gz.width/7;

	switch (_color)
	{
		case LP_COLOR_BLUE:
			PSsetrgbcolor(0,0,0.5);
			break;
		case LP_COLOR_RED:
			PSsetrgbcolor(0.5,0,0);
			break;
		case LP_COLOR_GREEN:
			PSsetrgbcolor(0,0.5,0);
			break;
		case LP_COLOR_YELLOW:
			PSsetrgbcolor(0.5,0.5,0);
			break;
		default:
			PSsetrgbcolor(0.5,0.5,0.5);
			break;
	}
	PSmoveto(_x * gz.width + gz.width/2, _y * gz.height);
	PSlineto(_x * gz.width + border, _y * gz.height + border);
	PSlineto(_x * gz.width, _y * gz.height + gz.height/2);
	PSlineto(_x * gz.width + border, (_y+1) * gz.height - border);
	PSlineto(_x * gz.width + gz.width/2, (_y+1) * gz.height);
	PSlineto((_x+1) * gz.width - border, (_y+1) * gz.height - border);
	PSlineto((_x+1) * gz.width, _y * gz.height + gz.height/2);
	PSlineto((_x+1) * gz.width - border, _y * gz.height + border);

	PSclosepath();
	PSsetalpha(alpha);
	PSfill();

	switch (_color)
	{
		case LP_COLOR_BLUE:
			PSsetrgbcolor(0,0,1.0-z);
			break;
		case LP_COLOR_RED:
			PSsetrgbcolor(1.0-z,0,0);
			break;
		case LP_COLOR_GREEN:
			PSsetrgbcolor(0,1.0-z,0);
			break;
		case LP_COLOR_YELLOW:
			PSsetrgbcolor(1.0-z,1.0-z,0);
			break;
		default:
			PSsetrgbcolor(1.0-z,1.0-z,1.0-z);
			break;
	}

	PSmoveto(_x * gz.width + gz.width/2, _y * gz.height);
	PSrlineto(gz.width/2, gz.height/2);
	PSrlineto(-gz.width/2, gz.height/2);
	PSrlineto(-gz.width/2, -gz.height/2);
	PSclosepath();
	PSsetalpha(alpha);
	PSfill();

	switch (_color)
	{
		case LP_COLOR_BLUE:
			PSsetrgbcolor(0,0,0.5+z);
			break;
		case LP_COLOR_RED:
			PSsetrgbcolor(0.5+z,0,0);
			break;
		case LP_COLOR_GREEN:
			PSsetrgbcolor(0,0.5+z,0);
			break;
		case LP_COLOR_YELLOW:
			PSsetrgbcolor(0.5+z,0.5+z,0);
			break;
		default:
			PSsetrgbcolor(0.5+z,0.5+z,0.5+z);
			break;
	}

	PSsetalpha(alpha/1.5);
	PSrectfill(_x * gz.width + border , _y *gz.height + border, _columns * gz.width - border*2, _rows * gz.height - border*2);



	switch (_color)
	{
		case LP_COLOR_BLUE:
			PSsetrgbcolor(0,0,1.0-z);
			break;
		case LP_COLOR_RED:
			PSsetrgbcolor(1.0-z,0,0);
			break;
		case LP_COLOR_GREEN:
			PSsetrgbcolor(0,1.0-z,0);
			break;
		case LP_COLOR_YELLOW:
			PSsetrgbcolor(1.0-z,1.0-z,0);
			break;
		default:
			PSsetrgbcolor(1.0-z,1.0-z,1.0-z);
			break;
	}


	PSsetalpha(alpha/2);
	PSmoveto(_x * gz.width + gz.width/2, _y * gz.height);
	PSlineto(_x * gz.width + border, _y * gz.height + border);
	PSlineto(_x * gz.width, _y * gz.height + gz.height/2);
	PSlineto(_x * gz.width + border, (_y+1) * gz.height - border);
	PSlineto(_x * gz.width + gz.width/2, (_y+1) * gz.height);
	PSlineto((_x+1) * gz.width - border, (_y+1) * gz.height - border);
	PSlineto((_x+1) * gz.width, _y * gz.height + gz.height/2);
	PSlineto((_x+1) * gz.width - border, _y * gz.height + border);

	PSlineto(_x * gz.width + gz.width/2, _y * gz.height);
	PSlineto((_x+1) * gz.width, _y * gz.height + gz.height/2);
	PSlineto(_x * gz.width + gz.width/2, (_y+1) * gz.height);
	PSlineto(_x * gz.width, _y * gz.height + gz.height/2);

	PSclosepath();
	PSfill();
}

@end

@implementation LPJewelUnit
- (id) initWithOwner:(id <LPUnitOwner>)owner
			   color:(LPUnitColorType)color
				   X:(int)x
				   Y:(int)y
{
	[super initWithOwner:owner
				   color:color];

	_x = x;
	_y = y;
	_rows = 1;
	_columns = 1;
	z = random()%5;
	z/= 10;
	[self changePhase];
	return self;
}

- (float) phase
{
	return z;
}

- (void) changePhase
{
	z += 0.1;
	if (z > 0.5)
	{
		z = 0;
	}
}

- (int) rows
{
	return _rows;
}

- (int) columns
{
	return _columns;
}

- (int) X
{
	return _x;
}

- (int) Y
{
	return _y;
}

- (void) draw
{
	NSSize gz = [__owner gridSize];
	float border = gz.width/6;

	switch (_color)
	{
		case LP_COLOR_BLUE:
			PSsetrgbcolor(0,0,0.7);
			break;
		case LP_COLOR_RED:
			PSsetrgbcolor(0.7,0,0);
			break;
		case LP_COLOR_GREEN:
			PSsetrgbcolor(0,0.7,0);
			break;
		case LP_COLOR_YELLOW:
			PSsetrgbcolor(0.7,0.7,0);
			break;
		default:
			PSsetrgbcolor(0.7,0.7,0.7);
			break;
	}
	PSsetalpha(alpha);
	PSrectfill(_x * gz.width , _y *gz.height, _columns * gz.width, _rows * gz.height);
	switch (_color)
	{
		case LP_COLOR_BLUE:
			PSsetrgbcolor(0,0,0.6);
			break;
		case LP_COLOR_RED:
			PSsetrgbcolor(0.6,0,0);
			break;
		case LP_COLOR_GREEN:
			PSsetrgbcolor(0,0.6,0);
			break;
		case LP_COLOR_YELLOW:
			PSsetrgbcolor(0.6,0.6,0);
			break;
		default:
			PSsetrgbcolor(0.6,0.6,0.6);
			break;
	}
	PSsetalpha(alpha);
	//PSrectfill(_x * gz.width + border, _y *gz.height + border, _columns * gz.width - 2*border, _rows * gz.height - 2*border);

	switch (_color)
	{
		case LP_COLOR_BLUE:
			PSsetrgbcolor(0,0.5,1);
			break;
		case LP_COLOR_RED:
			PSsetrgbcolor(1,0.2,0.2);
			break;
		case LP_COLOR_GREEN:
			PSsetrgbcolor(0.5,1,0);
			break;
		case LP_COLOR_YELLOW:
			PSsetrgbcolor(1,1,0.0);
			break;
		default:
			PSsetrgbcolor(1,1,1);
			break;
	}

	PSsetalpha(alpha/3);
	PSsetlinewidth(0);
	PSmoveto(_x * gz.width, _y * gz.height);
	PSlineto(_x * gz.width + gz.width/4, _y * gz.height + gz.width/4);
	PSlineto(_x * gz.width + gz.width/4, (_y+_rows) * gz.height - gz.width/4);
	PSlineto(_x * gz.width, (_y+_rows) * gz.height);
	PSfill();

	PSsetalpha(alpha);
	PSsetlinewidth(0);
	PSmoveto(_x * gz.width, (_y+_rows) * gz.height);
	PSlineto(_x * gz.width + gz.width/4, (_y+_rows) * gz.height - gz.width/4);
	PSlineto((_x+_columns) * gz.width - gz.width/4, (_y+_rows) * gz.height - gz.width/4);
	PSlineto((_x+_columns) * gz.width, (_y+_rows) * gz.height);
	PSfill();

	if (_rows > 1)
	{
		int i;
		for (i = 0; i <_rows; i+=2)
		{
			PSgsave();
			PSsetlinecap(1);
			PSsetalpha(alpha/10);
			PSsetlinewidth(_columns * border * 4);
			PSrectclip(_x * gz.width + gz.width/4, _y *gz.height + gz.height/4, _columns * gz.width - gz.width/2, _rows * gz.height - gz.height/2);

			PSmoveto(_x * gz.width, (_y + i) * gz.height);
			PSlineto((_x + _columns) * gz.width, (_y + i + _columns) * gz.height);
			PSstroke();
			PSgrestore();
		}

		for (i = 0; i <_rows; i++)
		{
			PSgsave();
			PSsetlinecap(1);
			PSsetlinewidth(_columns * border * 2);
			PSrectclip(_x * gz.width + gz.width/4, _y *gz.height + gz.height/4, _columns * gz.width - gz.width/2, _rows * gz.height - gz.height/2);

			PSsetalpha(alpha/4);
			PSmoveto(_x * gz.width, (_y + i*4) * gz.height + (i + _rows) * 10);
			PSlineto((_x + _columns) * gz.width, (_y + i*4 + _columns) * gz.height + (i + _rows) * 10);
			PSstroke();
			PSgrestore();
		}
	}

	switch (_color)
	{
		case LP_COLOR_BLUE:
			PSsetrgbcolor(0,0,0.3);
			break;
		case LP_COLOR_RED:
			PSsetrgbcolor(0.3,0,0);
			break;
		case LP_COLOR_GREEN:
			PSsetrgbcolor(0,0.3,0);
			break;
		case LP_COLOR_YELLOW:
			PSsetrgbcolor(0.3,0.3,0);
			break;
		default:
			PSsetrgbcolor(0.3,0.3,0.3);
			break;
	}


	PSsetalpha(alpha/2);
	PSsetlinewidth(0);
	PSmoveto(_x * gz.width, _y * gz.height);
	PSlineto(_x * gz.width + gz.width/4, _y * gz.height + gz.width/4);
	PSlineto((_x+_columns) * gz.width - gz.width/4, _y * gz.height + gz.width/4);
	PSlineto((_x+_columns) * gz.width, _y * gz.height);
	PSfill();
	
	PSsetalpha(alpha/3);
	PSsetlinewidth(0);
	PSmoveto((_x+_columns) * gz.width, _y * gz.height);
	PSlineto((_x+_columns) * gz.width - gz.width/4, _y * gz.height + gz.width/4);
	PSlineto((_x+_columns) * gz.width - gz.width/4, (_y+_rows) * gz.height - gz.width/4);
	PSlineto((_x+_columns) * gz.width, (_y+_rows) * gz.height);
	PSfill();

}

- (BOOL) canRMoveX:(int)rx
				 Y:(int)ry
{
	id en;
	LPUnit* unit;

	int cx,cy,i,j;

	cx = _x + rx;
	cy = _y + ry;

	if (cx < 0 || cx > 5 || cy < 0)
	{
		return NO;
	}

	en = [[__owner allUnits] objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if (unit == self)
		{
			continue;
		}
		for (j = 0; j < _rows; j++)
		{
			for (i = 0; i < _columns; i++)
			{
				if ([unit hasPartAtX:cx+i
								   Y:cy+j])
				{
					return NO;
				}
			}
		}
	}

	return YES;
}

- (BOOL) canMoveInDir:(LPDirType)dir
{
  int cx,cy;

  switch(dir)
    {
    case LP_MOVE_LEFT:
      if (_x == 0)
	{
	  return NO;
	}
      cx = -1;
      cy = 0;
      break;
    case LP_MOVE_DOWN:
      if (_y == 0)
	{
	  return NO;
	}
      cx = 0;
      cy = -1;
      break;
    case LP_MOVE_RIGHT:
      if (_x == 5)
	{
	  return NO;
	}
      cx = 1;
      cy = 0;
      break;
    case LP_MOVE_UP:
      /* no check for upper border */
      cx = 0;
      cy = 1;
      break;
    default:
      NSAssert(0, @"Unreachable");
      return NO;
      break;
    }

  return [self canRMoveX:cx Y:cy];
}

- (BOOL) rMoveX:(int)rx
			  Y:(int)ry
{
	if (![self canRMoveX:rx
					   Y:ry])
	{
		return NO;
	}
	_x += rx;
	_y += ry;

	return YES;
}

- (BOOL) moveInDir:(LPDirType)dir
{
  if (![self canMoveInDir:dir])
    {
      return NO;
    }
  switch(dir)
    {
    case LP_MOVE_DOWN:
      _y--;
      break;
    case LP_MOVE_LEFT:
      _x--;
      break;
    case LP_MOVE_UP:
      _y++;
      break;
    case LP_MOVE_RIGHT:
      _x++;
      break;
    default:
      NSAssert(0, @"Unreachable");
      break;

    }
  return YES;
}

- (BOOL) hasPartAtX:(int)x
				  Y:(int)y
{
	if (x >= _x && y >= _y && x < (_x + _columns) && y < (_y + _rows))
	{
		return YES;
	}
	return NO;
}

- (void) addRows:(int)r
{
	_rows += r;
}

- (void) addColumns:(int)c
{
	_columns += c;
}
@end

@implementation LPGroupUnit

- (id) initWithOwner:(id <LPUnitOwner>)owner
			   atoms:(NSArray *)unitList
{
	__owner = owner;
	ASSIGN(_units, unitList);
	_laydir = LP_MOVE_DOWN;
	return self;
}

- (NSSize) gridSize
{
	return [__owner gridSize];
}

- (NSArray *) allUnits
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:[__owner allUnits]];
	[array removeObject:self];
	return array;
}

- (NSArray *) atoms
{
	return _units;
}

- (id) getUnitAtX:(int)x
				Y:(int)y
{
	exit(0);
	// NYI
}

- (void) rotateCCW
{
  id move = [_units objectAtIndex:0];
  id base = [_units objectAtIndex:1];

  switch(_laydir)
    {
    case LP_MOVE_DOWN:
      if ([move rMoveX:-1
		     Y:-1])
	{
	  _laydir = LP_MOVE_LEFT;
	}
      else if ([base canRMoveX:1 Y:0])
	{
	  [base rMoveX:1 Y:0];
	  [move rMoveX:0 Y:-1];
	  _laydir = LP_MOVE_LEFT;
	}
      break;
    case LP_MOVE_LEFT:
      if ([move rMoveX:1
		     Y:-1])
	{
	  _laydir = LP_MOVE_UP;
	}
      break;
    case LP_MOVE_UP:
      if ([move rMoveX:1
		     Y:1])
	{
	  _laydir = LP_MOVE_RIGHT;
	}
      else if ([base canRMoveX:-1 Y:0])
	{
	  [base rMoveX:-1 Y:0];
	  [move rMoveX:0 Y:1];
	  _laydir = LP_MOVE_RIGHT;
	}
      break;
    case LP_MOVE_RIGHT:
      if ([move rMoveX:-1
		     Y:1])
	{
	  _laydir = LP_MOVE_DOWN;
	}
      break;
    default:
      NSAssert(0, @"Unreachable");
      break;
    }

}

- (void) rotateCW
{
  id move = [_units objectAtIndex:0];
  id base = [_units objectAtIndex:1];

  switch(_laydir)
    {
    case LP_MOVE_DOWN:
      if ([move rMoveX:1 // should physically block rotation?
		     Y:-1])
	{
	  _laydir = LP_MOVE_RIGHT;
	}
      else if ([base canRMoveX:-1 Y:0])
	{
	  [base rMoveX:-1 Y:0];
	  [move rMoveX:0 Y:-1];
	  _laydir = LP_MOVE_RIGHT;
	}
      break;
    case LP_MOVE_RIGHT:
      if ([move rMoveX:-1
		     Y:-1])
	{
	  _laydir = LP_MOVE_UP;
	}
      break;
    case LP_MOVE_UP:
      if ([move rMoveX:-1
		     Y:1])
	{
	  _laydir = LP_MOVE_LEFT;
	}
      else if ([base canRMoveX:1 Y:0])
	{
	  [base rMoveX:1 Y:0];
	  [move rMoveX:0 Y:1];
	  _laydir = LP_MOVE_LEFT;
	}
      break;
    case LP_MOVE_LEFT:
      if ([move rMoveX:1
		     Y:1])
	{
	  _laydir = LP_MOVE_DOWN;
	}
      break;
    default:
      NSAssert(0, @"Unreachable");
      break;
    }

}

- (void) changePhase
{
	id en;
	LPUnit* unit;

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		[unit changePhase];
	}
}

- (void) draw
{
	id en;
	LPUnit* unit;

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		[unit draw];
	}
}

- (int) X
{
	id en;
	LPUnit* unit;
	float mX;
	mX = 5;

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if ([unit X] < mX)
		{
			mX = [unit X];
		}
	}
	return mX;
}

- (int) Y
{
  return 0;
}

- (void) dealloc
{
	RELEASE(_units);
	[super dealloc];
}

- (BOOL) hasPartAtX:(int)x
				  Y:(int)y
{
	id en;
	LPUnit* unit;

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if ([unit hasPartAtX:x
						   Y:y])
		{
			return YES;
		}
	}
	return NO;
}

- (BOOL) moveInDir:(LPDirType)dir
{
	id en;
	LPUnit* unit;

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if([unit canMoveInDir:dir] == NO)
		{
			return NO;
		}
	}

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		[unit moveInDir:dir];
	}
	return YES;
}

- (BOOL) canMoveInDir:(LPDirType)dir
{
	id en;
	LPUnit* unit;

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if([unit canMoveInDir:dir] == NO)
		{
			return NO;
		}
	}
	return YES;
}

- (BOOL) canRMoveX:(int)rx
				 Y:(int)ry
{
	id en;
	LPUnit* unit;

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if([unit canRMoveX:rx Y:ry] == NO)
		{
			return NO;
		}
	}
	return YES;
}

- (BOOL) rMoveX:(int)rx
			  Y:(int)ry
{
	id en;
	LPUnit* unit;
 
	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if([unit canRMoveX:rx Y:ry] == NO)
		{
			return NO;
		}
	}

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		[unit rMoveX:rx Y:ry];
	}
	return YES;
}

@end

@implementation LapisPuzzleView

static LPUnitColorType _random_unit_color()
{
	return random()%LP_COLOR_ALL;
}

static LPUnit * _random_unit(id owner, int x, int y, BOOL diamond)
{
	LPUnit* unit;
	if (random()%20 < 6)
	{
		if (random()%10 == 1 && diamond)
		{
			unit = [[LPSparkerUnit alloc] initWithOwner:owner
												  color:LP_COLOR_ALL
													  X:x
													  Y:y];
		}
		else
		{

			unit = [[LPSparkerUnit alloc] initWithOwner:owner
												  color:_random_unit_color()
													  X:x
													  Y:y];
		}
	}
	else
	{
		unit = [[LPJewelUnit alloc] initWithOwner:owner
											color:_random_unit_color()
												X:x
												Y:y];
	}
	return AUTORELEASE(unit);
}


- (NSSize) gridSize
{
	return NSMakeSize(
		NSWidth(_bounds)/(_numberOfColumns * _stepsInUnit),
		NSHeight(_bounds)/(((float)_numberOfRows + 0.3) * _stepsInUnit)
		);
}

- (void) awakeFromNib
{
	chain = 0;
	trip = 0;
	chaintrip = 0;
	_gameOver = NO;
	_numberOfRows = 13;
	_numberOfColumns = 6;

	_stepsInUnit = 1;
	_stepHeight = NSHeight(_frame)/((float)_numberOfRows + 0.3);
	_stepWidth = NSWidth(_frame)/_numberOfColumns;

	_units = [[NSMutableArray alloc] init];

	_blowing = [[NSMutableSet alloc] init];

}

- (void) setFrame:(NSRect)r
{
	[super setFrame:r];
}

- (void) setBackgroundImage:(NSImage *)image
{
	ASSIGN(_background, image);
}

- (void) gameOver
{
	_gameOver = YES;
}

- (void) round
{
	id en;
	LPUnit* unit;

	if (chain)
	{
		[self fallEmDown];
		[self packCell];
		[self blowIt];
		if (chain == 0)
		{
			[self runStone];
		}
		[self setNeedsDisplay:YES];
		return;
	}

	_lockControl = NO;

	if (__currentUnit == nil)
	{
		if (!_gameOver)
		{
			[__owner lapisPuzzleView:self
			 didFinishUnitWithResult:LP_RESULT_REQUEST];
		}
	}

	if(![__currentUnit moveInDir:LP_MOVE_DOWN])
	{
		if (__currentUnit)
		{
			/* replace timer stone with jewel */
			NSMutableArray *ar;

			_lockControl = YES;
			ar = [NSMutableArray array];
			en = [_units objectEnumerator];
			while ((unit = [en nextObject]))
			{
				if ([unit isMemberOfClass:[LPStoneUnit class]])
				{
					[(LPStoneUnit *)unit countDown];
					if ([(LPStoneUnit *)unit count] == 0)
					{
						[ar addObject:unit];
					}
				}
			}

			en = [ar objectEnumerator];
			while ((unit = [en nextObject]))
			{
				id new;
				new = [[LPJewelUnit alloc] initWithOwner:self
												   color:[unit unitColor]
													   X:[unit X]
													   Y:[unit Y]];
				[_units removeObject:unit];
				[_units addObject:new];
				[new release];
			}


			en = [[__currentUnit atoms] objectEnumerator];
			while ((unit = [en nextObject]))
			{
				[_units addObject:unit];
				[unit setOwner:self];
				[unit fallToBottom];
			}


			[_units removeObject:__currentUnit];
			__currentUnit = nil;
		}

		[self packCell];
		[self blowIt];
		if (chain == 0)
		{
			[self runStone];
		}


	}

	[self setNeedsDisplay:YES];
}

- (void) runStone
{
	LPUnit* unit;
	/* run stone */
	int yy,xx;

	if (stone > 0)
	{
		[(LPController *)__owner player:self processStone:stone];
	}

	yy = 13, xx = 0;
	while (stone > 0)
	{
		unit = nil;
		while (unit == nil)
		{
			while (unit == nil)
			{
				if ([self getUnitAtX:xx Y:yy] == nil)
				{
					unit = [[LPStoneUnit alloc] initWithOwner:self
								    color:_random_unit_color()
								    X:xx
								    Y:yy];
					[_units addObject:unit];
					[unit fallToBottom];
					RELEASE(unit);
				}
				xx++;
				if (xx > 5)
				{
					xx = 0;
					break;
				}
			}
			yy++;
		}
		stone--;
	}
}

- (id) getUnitAtX:(int)x
				Y:(int)y
{
	id en;
	LPUnit* unit;

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if ([unit hasPartAtX:x
						   Y:y])
		{
			return unit;
		}
	}

	return nil;
}

- (void) fallEmDown
{
	id en;
	LPUnit* unit;
	BOOL moving;

	/* fall em down */
	do
	{
		moving = NO;
		en = [_units objectEnumerator];
		while ((unit = [en nextObject]))
		{
			if ([unit moveInDir:LP_MOVE_DOWN])
			{
				moving = YES;
			}
		}
	} while (moving);

}

- (void) packCell
{
	id en;
	LPJewelUnit* unit;
	int i,j;
	BOOL merge;


	id m1,m2,m3;
	LPUnitColorType color;

	if (_gameOver)
	{
		return;
	}

	/* pack bigger cell */
	for (i = 0; i < 12; i++)
	{
		for (j = 0; j < 5; j++)
		{
			unit = [self getUnitAtX:j
								  Y:i];
			if (unit && [unit rows] == 1 && [unit isMemberOfClass:[LPJewelUnit class]])
			{
				color = [unit unitColor];
				if ((m1 = [self getUnitAtX:j+1 Y:i]) &&
					[m1 unitColor] == color &&
					[m1 rows] == 1 &&
					[m1 isMemberOfClass:[LPJewelUnit class]] &&
					(m2 = [self getUnitAtX:j Y:i+1]) &&
					[m2 unitColor] == color &&
					[m2 rows] == 1 &&
					[m2 isMemberOfClass:[LPJewelUnit class]] &&
					(m3 = [self getUnitAtX:j+1 Y:i+1]) &&
					[m3 unitColor] == color &&
					[m3 rows] == 1 &&
					[m3 isMemberOfClass:[LPJewelUnit class]]
					)
				{
					[unit addRows:1];
					[unit addColumns:1];
					[_units removeObject:m1];
					[_units removeObject:m2];
					[_units removeObject:m3];
				}
			}
		}
	}

	do
	{
		merge = NO;
		en = [_units objectEnumerator];
		while ((unit = [en nextObject]))
		{
			int unit_x, unit_y, unit_rows, unit_columns;
			LPUnitColorType color;

			unit_rows = [unit rows];

			if (unit_rows >= 2)
			{
				NSMutableArray *ar = [NSMutableArray array];

				color = [unit unitColor];
				unit_x = [unit X];
				unit_y = [unit Y];
				unit_columns = [unit columns];

				
				m1 = [self getUnitAtX:unit_x + unit_columns
									Y:unit_y];

				/* check horizontal axis */
				if (m1 && [m1 isMemberOfClass:[LPJewelUnit class]] && [m1 Y] == unit_y && [m1 rows] == unit_rows && [m1 unitColor] == color)
				{
					merge = YES;
					[unit addColumns:[m1 columns]];
					[_units removeObject:m1];
					break;
				}

				m1 = [self getUnitAtX:unit_x
									Y:unit_y + unit_rows];

				/* check vertical axis */
				if (m1 && [m1 isMemberOfClass:[LPJewelUnit class]] && [m1 X] == unit_x && [m1 columns] == unit_columns && [m1 unitColor] == color)
				{
					merge = YES;
					[unit addRows:[m1 rows]];
					[_units removeObject:m1];
					break;
				}


				/* check right side */
				for (i = 0; i < unit_rows; i++)
				{
					m1 = [self getUnitAtX:unit_x + unit_columns
										Y:unit_y + i];
					if (m1 == nil || ![m1 isMemberOfClass:[LPJewelUnit class]] || [m1 rows] > 1 || [m1 unitColor]!=color)
					{
						break;
					}
					[ar addObject:m1];
				}
				if ([ar count] == unit_rows)
				{
					id en2, unit2;

					merge = YES;
					en2 = [ar objectEnumerator];
					while ((unit2 = [en2 nextObject]))
					{
						[_units removeObject:unit2];
					}
					[unit addColumns:1];
					break;
				}

				/* check left side */
				ar = [NSMutableArray array];
				for (i = 0; i < unit_rows; i++)
				{
					m1 = [self getUnitAtX:unit_x - 1
										Y:unit_y + i];
					if (m1 == nil || ![m1 isMemberOfClass:[LPJewelUnit class]] || [m1 rows] > 1 || [m1 unitColor]!=color)
					{
						break;
					}
					[ar addObject:m1];
				}
				if ([ar count] == unit_rows)
				{
					id en2, unit2;

					merge = YES;
					en2 = [ar objectEnumerator];
					while ((unit2 = [en2 nextObject]))
					{
						[_units removeObject:unit2];
					}
					[unit addColumns:1];
					[unit moveInDir:LP_MOVE_LEFT];
					break;
				}

				/* check top side */
				ar = [NSMutableArray array];
				for (i = 0; i < unit_columns; i++)
				{
					m1 = [self getUnitAtX:unit_x + i
										Y:unit_y + unit_rows];
					if (m1 == nil || ![m1 isMemberOfClass:[LPJewelUnit class]] || [m1 rows] > 1 || [m1 unitColor]!=color)
					{
						break;
					}
					[ar addObject:m1];
				}
				if ([ar count] == unit_columns)
				{
					id en2, unit2;

					merge = YES;
					en2 = [ar objectEnumerator];
					while ((unit2 = [en2 nextObject]))
					{
						[_units removeObject:unit2];
					}
					[unit addRows:1];
					break;
				}

				/* check bottom side */
				ar = [NSMutableArray array];
				for (i = 0; i < unit_columns; i++)
				{
					m1 = [self getUnitAtX:unit_x + i
										Y:unit_y - 1];
					if (m1 == nil || ![m1 isMemberOfClass:[LPJewelUnit class]] || [m1 rows] > 1 || [m1 unitColor]!=color)
					{
						break;
					}
					[ar addObject:m1];
				}
				if ([ar count] == unit_columns)
				{
					id en2, unit2;

					merge = YES;
					en2 = [ar objectEnumerator];
					while ((unit2 = [en2 nextObject]))
					{
						[_units removeObject:unit2];
					}
					[unit addRows:1];
					[unit moveInDir:LP_MOVE_DOWN];
					break;
				}

			}
		}
	} while(merge);
}

- (void) blowIt
{
	id en;
	LPUnit *unit;
	int i;

	LPUnit *all = nil;

	if (_gameOver)
	{
		return;
	}

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if ([unit isMemberOfClass:[LPSparkerUnit class]])
		{
			if ([unit unitColor] == LP_COLOR_ALL)
			{
				[unit blow];
				all = [self getUnitAtX:[unit X]
									 Y:[unit Y] - 1];
			}
			else [(LPSparkerUnit *)unit spark];
		}
	}

	if (all)
	{
		en = [_units objectEnumerator];
		while ((unit = [en nextObject]))
		{
			if ([unit unitColor] == [all unitColor])
			{
				[unit softBlow];
			}
		}
	}

	i = 0;
	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if ([unit isBlowing])
		{
			[_blowing addObject:unit];
			i++;
		}
	}

	if (i)
	{
//		NSLog(@"blow blocks %d",i);
	}
	stone -= (i/4) * chain + chain>1?chain:0;

	en = [_blowing objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if ([_units containsObject:unit])
		{
			if ([unit rows] > 1)
			{
				stone -= [unit rows] * 2 * [unit columns] * (chain + 1);
			}
			[_units removeObject:unit];
		}
	}

	if (i)
	{
		chain ++;
		if (chain >= 2)
		{
			stone -= chain;
		}
		chaintrip = chain * 2;
		if (chaintrip > 8)
		{
			chaintrip = 8;
		}
		if (chain > maxchain)
		{
			maxchain = chain;
		}
	}
	else
	{
		chain = 0;

		if (stone < 0)
		{
			[__owner player:self addStoneToOp:-stone];
			stone = 0;
		}
	}

#if 0
	if (stone < 0)
	{
//		NSLog(@"%@ sends %d stones",self,-stone);
		[__owner player:self addStoneToOp:-stone];
		stone = 0;
	}
#endif
}

- (void) restart
{
	id en;
	LPUnit * unit;
	[self gameOver];
	if (__currentUnit)
	{
		[_units removeObject:__currentUnit];
		__currentUnit = nil;
	}
	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		[unit blow];
	}

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if ([unit isBlowing])
		{
			[_blowing addObject:unit];
		}
	}

	en = [_blowing objectEnumerator];
	while ((unit = [en nextObject]))
	{
		[_units removeObject:unit];
	}

	_gameOver = NO;
	stone = 0;
	trip = 0;
	chaintrip = 0;
}

- (void) refresh
{
	id en;
	LPUnit *unit;

	NSMutableArray *ar;

	ar = [NSMutableArray array];

	if (trip)
	{
		trip--;
	}
	if (chaintrip)
	{
		chaintrip--;
		if (chaintrip == 0)
		{
			maxchain = 0;
		}
	}

	en = [_units objectEnumerator];
	while ((unit = [en nextObject]))
	{
		if (!_gameOver)
		{
			[unit changePhase];
		}
	}

	if (_gameOver)
	{
		int cc,xx,yy;
		LPUnit* unit;
		cc=0;

		for (yy = 13; yy >= 0 && cc < 8; yy--)
		for (xx = 5; xx >= 0; xx--)
		{
			unit = [self getUnitAtX:xx
								  Y:yy];

			if (unit && [unit unitColor] != LP_COLOR_ALL)
			{
				[unit setUnitColor:LP_COLOR_ALL];
				cc++;
			}
		}
	}
	else
	{
		en = [_blowing objectEnumerator];
		while ((unit = [en nextObject]))
		{
			[unit setAlpha:[unit alpha]-0.2];
			if ([unit alpha] < 0.2)
			{
				[ar addObject:unit];
			}
		}
		en = [ar objectEnumerator];
		while ((unit = [en nextObject]))
		{
			[_blowing removeObject:unit];
		}
	}

	[self setNeedsDisplay:YES];
}

- (void) addStone:(int)num
{
	stone += num;
	if (stone > 0)
	{
		trip = 8;
	}
}

- (void) addUnit:(id)newUnit
{
	[_units addObject:newUnit];

	__currentUnit = newUnit;

	if (![__currentUnit canMoveInDir:LP_MOVE_DOWN])
	{
		[_units removeObject:__currentUnit];
		__currentUnit = nil;
		[self gameOver];
		[__owner lapisPuzzleView:self
		 didFinishUnitWithResult:LP_RESULT_GAMEOVER];

	}
	[self setNeedsDisplay:YES];
}

- (void) addJewelUnit
{
	/*
	id newUnit = [LPGroupUnit alloc];
	[newUnit initWithOwner:self
					 atoms:[NSArray arrayWithObjects:
						   		_random_unit(newUnit,3,14),
								_random_unit(newUnit,3,13),nil]];

	[self addUnit:AUTORELEASE(newUnit)];
	*/
}

- (void) drawRect:(NSRect)r
{
	int i;
	id en;
	LPUnit *unit;

	/*
	[_background compositeToPoint:NSZeroPoint
						operation:NSCompositeCopy];
						*/

	PSsetrgbcolor(0,0,0);
	PSsetalpha(1.0);  // 0.7
	PSrectfill(0,0,NSWidth(_bounds),NSHeight(_bounds));

	PSsetrgbcolor(1,1,1);
	PSsetalpha(0.1);
	PSmoveto(0,0);
	for (i = 0; i < _numberOfRows; i++)
	{
		PSrlineto(NSWidth(_bounds), 0);
		PSrmoveto(-NSWidth(_bounds), _stepHeight);
	}
	PSstroke();

	PSmoveto(0,0);
	for (i = 0; i < _numberOfColumns; i++)
	{
		PSrlineto(0,NSHeight(_bounds));
		PSrmoveto(_stepWidth,-NSHeight(_bounds));
	}
	PSstroke();

	en = [_blowing objectEnumerator];
	while ((unit = [en nextObject]))
	{
		float p = [(LPJewelUnit *)unit phase] * 50;
		p = p - 12;
		PSgsave();
			PStranslate((1 - [unit alpha]) * p, (1 - [unit alpha]) * -p);
			[unit draw];
		PSgrestore();
	}


	{
		int cc,xx,yy;
		LPUnit* unit;
		NSMutableSet *set = [NSMutableSet setWithCapacity:70];
		cc=0;

		for (yy = 13; yy >= 0 && cc < 8; yy--)
		for (xx = 5; xx >= 0; xx--)
		{
			unit = [self getUnitAtX:xx
								  Y:yy];
			if (unit != nil)
			{
				[set addObject:unit];
			}
		}
		[set makeObjectsPerform:@selector(draw)];
	}

	PSgsave();
		PSinitclip();

		PSsetrgbcolor(0,0,0);
		PSsetalpha(0.3);
		PSrectfill(0, _stepHeight * 12, _stepWidth * 3, _stepHeight);
		PSrectfill(_stepWidth * 4, _stepHeight * 12, _stepWidth * 2, _stepHeight);

		PSsetalpha(0.5);
		PSsetrgbcolor(0.7,0.7,0.7);
		PSsetlinewidth(4);
		PSrectstroke(0, _stepHeight * 12, _stepWidth * 3, _stepHeight);
		PSrectstroke(_stepWidth * 4, _stepHeight * 12, _stepWidth * 2, _stepHeight);
		PSmoveto(0,NSHeight(_bounds));
		PSlineto(0,0);
		PSlineto(NSWidth(_bounds),0);
		PSlineto(NSWidth(_bounds),NSHeight(_bounds));
		PSstroke();

		/****/

		PSsetalpha(1);
		PSsetrgbcolor(0,0,0);
		PSsetlinewidth(2);
		PSrectstroke(0, _stepHeight * 12, _stepWidth * 3, _stepHeight);
		PSrectstroke(_stepWidth * 4, _stepHeight * 12, _stepWidth * 2, _stepHeight);
		PSmoveto(0,NSHeight(_bounds));
		PSlineto(0,0);
		PSlineto(NSWidth(_bounds),0);
		PSlineto(NSWidth(_bounds),NSHeight(_bounds));
		PSstroke();


		PStranslate(-1,1);
		PSsetrgbcolor(0.8,0.8,0.8);
		PSsetlinewidth(2);
		PSrectstroke(0, _stepHeight * 12, _stepWidth * 3, _stepHeight);
		PSrectstroke(_stepWidth * 4, _stepHeight * 12, _stepWidth * 2, _stepHeight);
		PSmoveto(0,NSHeight(_bounds));
		PSlineto(0,0);
		PSlineto(NSWidth(_bounds),0);
		PSlineto(NSWidth(_bounds),NSHeight(_bounds));
		PSstroke();
	PSgrestore();

	if (trip || stone > 0)
	{
		int istone = stone > 0?stone:0;
		NSMutableAttributedString *str;
		NSString *s;
		NSSize strSize;
		NSSize gz = [self gridSize];
		s = [NSString stringWithFormat:@"%d",istone];
		str = [[NSMutableAttributedString alloc] initWithString:s];
		[str addAttribute:NSForegroundColorAttributeName
					value:[NSColor redColor]
					range:NSMakeRange(0,[s length])];
		[str addAttribute:NSFontAttributeName
					value:[NSFont boldSystemFontOfSize:gz.height*1.2]
					range:NSMakeRange(0,[s length])];
		strSize = [str size];

		[str drawAtPoint:NSMakePoint(5 * gz.width - strSize.width/2, 12 * gz.height + gz.height/2 - strSize.height/2)];
		RELEASE(str);
	}

	if (chaintrip%2 == 1 && maxchain > 1)
	{
		NSMutableAttributedString *str;
		NSString *s;
		NSSize strSize;
		NSSize gz = [self gridSize];
		s = [NSString stringWithFormat:@"%d CHAINS!",maxchain];
		str = [[NSMutableAttributedString alloc] initWithString:s];
		[str addAttribute:NSForegroundColorAttributeName
					value:[NSColor yellowColor]
					range:NSMakeRange(0,[s length])];
		[str addAttribute:NSFontAttributeName
					value:[NSFont boldSystemFontOfSize:gz.height * (maxchain>4?4:maxchain)/4]
					range:NSMakeRange(0,[s length])];
		strSize = [str size];

		[str drawAtPoint:NSMakePoint((6 * gz.width / 2) - strSize.width/2, (13 * gz.height / 2) - strSize.height/2)];
		RELEASE(str);
	}

}

- (NSArray *) allUnits
{
	return _units;
}

/*** key ***/
- (BOOL) acceptsFirstResponder
{
	  return YES;
}

-(BOOL) performKeyEquivalent: (NSEvent *)event
{
	return NO;
}

- (id) currentUnit
{
	return __currentUnit;
}

-(BOOL) processDir:(LPDirType)dir
{
  if (_lockControl)
    {
      return NO;
    }
  if (__currentUnit == nil)
    {
      return NO;
    }
  switch(dir)
    {
    case LP_MOVE_DOWN:
      return [__currentUnit moveInDir:LP_MOVE_DOWN];
      break;
    case LP_MOVE_LEFT:
      return [__currentUnit moveInDir:LP_MOVE_LEFT];
      break;
    case LP_MOVE_RIGHT:
      return [__currentUnit moveInDir:LP_MOVE_RIGHT];
      break;
    case LP_MOVE_FALL:
      _lockControl = YES;
      [__currentUnit fallToBottom];
      break;
    case LP_MOVE_CW:
      [__currentUnit rotateCW];
      break;
    case LP_MOVE_CCW:
      [__currentUnit rotateCCW];
      break;
    default:
      NSAssert(0, @"Unreachable");
      break;

    }

  [self setNeedsDisplay:YES];
  return YES;
}

-(void) keyDown: (NSEvent *)event
{
//NSLog(@"%d %@",[event keyCode], [event characters]);

	switch ([[event characters] characterAtIndex:0])
	{
		case 'a':
			_useAI = !_useAI;
			break;
		case ',':
			[self processDir:LP_MOVE_CW];
			break;
		case '.':
			[self processDir:LP_MOVE_CCW];
			break;
		case ' ':
			[self processDir:LP_MOVE_FALL];
			break;
		case NSUpArrowFunctionKey:
			[self processDir:LP_MOVE_CCW];
			break;
		case NSLeftArrowFunctionKey:
			[self processDir:LP_MOVE_LEFT];
			break;
		case NSRightArrowFunctionKey:
			[self processDir:LP_MOVE_RIGHT];
			break;
		case NSDownArrowFunctionKey:
			[self processDir:LP_MOVE_DOWN];
			break;
		case 'd':
			[__owner op:self processDir:LP_MOVE_CW];
			break;
		case 'f':
			[__owner op:self processDir:LP_MOVE_CCW];
			break;
		case 'x':
	   		[__owner op:self processDir:LP_MOVE_LEFT];
			break;
		case 'v':
	   		[__owner op:self processDir:LP_MOVE_RIGHT];
			break;
		case 'c':
			[__owner op:self processDir:LP_MOVE_DOWN];
			break;
		default:
			break;
	}
	[self setNeedsDisplay:YES];
}

- (void) toggleAI
{
	_useAI = !_useAI;
}

- (BOOL) useAI
{
	return _useAI;
}

@end

@implementation LapisNextView
- (void) awakeFromNib
{
	chain = 0;
	trip = 0;
	chaintrip = 0;
	_gameOver = NO;
	_numberOfRows = 2;
	_numberOfColumns = 1;

	_stepsInUnit = 1;
	_stepHeight = NSHeight(_frame)/((float)_numberOfRows);
	_stepWidth = NSWidth(_frame)/_numberOfColumns;

	_units = [[NSMutableArray alloc] init];

	_blowing = [[NSMutableSet alloc] init];

}

- (NSSize) gridSize
{
	return NSMakeSize(
		NSWidth(_bounds)/(_numberOfColumns * _stepsInUnit),
		NSHeight(_bounds)/(((float)_numberOfRows) * _stepsInUnit)
		);
}

- (void) addJewelUnit
{
	id newUnit = [LPGroupUnit alloc];
	newUnit = [newUnit initWithOwner:self
					 atoms:[NSArray arrayWithObjects:
						   		_random_unit(newUnit,0,10,YES),
								_random_unit(newUnit,0,9,NO),nil]];

	[self addUnit:AUTORELEASE(newUnit)];
}

- (void) removeUnit:(id)unit
{
	[_units removeObject:unit];
}

-(void) keyDown: (NSEvent *)event
{
}

@end
