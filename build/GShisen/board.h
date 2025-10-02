/* 
 Project: GShisen
 
 Copyright (C) 2003-2015 The GNUstep Application Project
 
 Author: Enrico Sersale, Riccardo Mottola
 
 Board View
 
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
#import <AppKit/AppKit.h>
#import "tile.h"
#import "tilepair.h"

#define GAME_STATE_RUNNING     1
#define GAME_STATE_PAUSED      0

@interface GSBoard : NSView
{
  NSUserDefaults *defaults;
  NSMutableArray *scores;
  NSArray *iconsNamesRefs;
  NSMutableArray *tiles;
  GSTile *firstTile, *secondTile;
  NSTextField *timeField;
  NSTimer *tmr;
  int seconds, minutes;
  BOOL hadEndOfGame;
  NSMutableArray *undoArray;
  int gameState;
  int numScoresToKeep;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)newGame;
- (void)undo;
- (void)timestep:(NSTimer *)t;
- (int)prepareTilesToRemove:(GSTile *)clickedTile;
- (void)removeCurrentTiles;
- (BOOL)findPathBetweenTiles: (GSTile *)tile1 :(GSTile *)tile2;
- (BOOL)findSimplePathFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (BOOL)canMakeLineFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2;
- (void)unSetCurrentTiles;
- (void)pause;
- (BOOL)getHintMove :(GSTile **)tileStart :(GSTile **)tileEnd;
- (void)getHint;
- (void)verifyEndOfGame;
- (void)endOfGame;
- (NSArray *)tilesAtXPosition:(int)xpos;
- (NSArray *)tilesAtYPosition:(int)ypos;
- (GSTile *)tileAtxPosition:(int)xpos yPosition:(int)ypos;
- (int)gameState;
- (NSMutableArray *)scores;

@end

