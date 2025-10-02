/* 
 Project: GShisen
 
 Copyright (C) 2003-2009 The GNUstep Application Project
 
 Author: Enrico Sersale, Riccardo Mottola
 
 Tile Pair
 
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

#import "tilepair.h"

@implementation GSTilePair

- (GSTilePair *)initWithTile:(GSTile *)tileOne andTile:(GSTile *)tileTwo
{
    fTile1 = tileOne;
    fTile2 = tileTwo;
    return self;
}

- (void)activateTiles
{
    [fTile1 unselect];
    [fTile1 activate];
    [fTile2 unselect];
    [fTile2 activate];
}

- (void)release
{
    fTile1 = nil;
    fTile2 = nil;
    [super release];
}


@end
