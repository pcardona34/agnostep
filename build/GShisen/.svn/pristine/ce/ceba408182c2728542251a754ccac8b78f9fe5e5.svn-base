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


#import "gshisen.h"
#import "board.h"

int imin(int a, int b) {
    if(a < b)
    	return a;
    else
    	return b;
}

int imax(int a, int b) {
    if(a > b)
    	return a;
    else
    	return b;
}

static NSComparisonResult randomizeTiles(GSTile *t1, GSTile *t2, id self)
{
    return [[t1 rndpos] compare: [t2 rndpos]];
}

static NSComparisonResult sortScores(NSDictionary *d1, NSDictionary *d2, id self)
{
    int min1, min2, sec1, sec2;
	
    min1 = [[d1 objectForKey: @"minutes"] intValue];
    sec1 = [[d1 objectForKey: @"seconds"] intValue];
    sec1 += min1 * 60;
    min2 = [[d2 objectForKey: @"minutes"] intValue];
    sec2 = [[d2 objectForKey: @"seconds"] intValue];
    sec2 += min2 * 60;

    return [[NSNumber numberWithInt: sec1] compare: [NSNumber numberWithInt: sec2]];
}

@implementation GSBoard

- (id)initWithFrame:(NSRect)frameRect
{
    NSArray *tempArray;
    self = [super initWithFrame:frameRect];
    if(self)
      {
        seconds = 0;
        minutes = 0;
        tiles = nil;
        timeField = nil;
        tmr = nil;
        gameState = GAME_STATE_PAUSED;
        iconsNamesRefs = [[NSArray alloc] initWithObjects:
                                          @"1-1", @"1-2", @"1-3", @"1-4", @"2-1", @"2-2", @"2-3", @"2-4",
                                          @"3-1", @"3-2", @"3-3", @"3-4", @"4-1", @"4-2", @"4-3", @"4-4",
                                          @"5-1", @"5-2", @"5-3", @"5-4", @"6-1", @"6-2", @"6-3", @"6-4",
                                          @"7-1", @"7-2", @"7-3", @"7-4", @"8-1", @"8-2", @"8-3", @"8-4",
                                          @"9-1", @"9-2", @"9-3", @"9-4", nil]; 

        defaults = [NSUserDefaults standardUserDefaults];
				numScoresToKeep = [defaults integerForKey:@"scoresToKeep"];
				if (numScoresToKeep == 0) {
					numScoresToKeep = 20;
				}
        tempArray = [[defaults arrayForKey:@"scores"] retain];
        scores = [[NSMutableArray arrayWithCapacity:1] retain];
        if(tempArray)
          [scores setArray:tempArray];

        [defaults setObject:scores forKey:@"scores"];
        [defaults synchronize];
        [tempArray release];
                
        hadEndOfGame = NO;
        undoArray = nil;
                
        [self newGame];
    }
    return self;
}

- (void)dealloc
{
    [tiles release];
    [iconsNamesRefs release];
    [timeField release];
    [scores release];
    [undoArray release];
    [super dealloc];
}

- (void)undo
{
    GSTilePair *pairToUndo;
    if( [undoArray count] > 0 )
    {
        pairToUndo = [undoArray lastObject];
        [pairToUndo activateTiles];
        [undoArray removeObject:pairToUndo];
    }
    else
    {
        NSBeep();
    }
}

- (void)newGame
{
    NSMutableArray *tmptiles;
    GSTile *tile;
    NSString *ref;
    NSTimeInterval timeInterval;
    int i, j, p;
    BOOL bordt;
    int borderPositions[56] = 
    {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
     20,                                                                39,
     40,                                                                59,
     60,                                                                79,
     80,                                                                99,
     100,                                                              119,
     120,                                                              139,
     140,                                                              159,
     160,                                                              179,
     180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 
     194, 195, 196, 197, 198, 199};

    timeInterval = [NSDate timeIntervalSinceReferenceDate];
    srand((int)timeInterval);

    if(undoArray != nil)
    {
        [undoArray removeAllObjects];
        [undoArray release];
        undoArray = nil;
    }
    undoArray = [[NSMutableArray alloc] initWithCapacity: 72];
    
    tmptiles = [NSMutableArray arrayWithCapacity: 144];
    for(i = 0; i < [iconsNamesRefs count]; i++) {
        for(j = 0; j < 4; j++) {
            ref = [iconsNamesRefs objectAtIndex: i];
            tile = [[GSTile alloc] initOnBoard: self 
                                   iconRef: ref group: i rndpos: rand() isBorderTile:NO];
            [tmptiles addObject: tile];
            [tile release];
        }
    }
    tmptiles = (NSMutableArray *)[tmptiles sortedArrayUsingFunction:(NSComparisonResult (*)(id, id, void*))randomizeTiles context:self];

    if(tmr && !hadEndOfGame) {
        if([tmr isValid])
            [tmr invalidate];
    }
    if(timeField) {
        [timeField removeFromSuperview];
        [timeField release];
    }	

    if(tiles) {
        for(i = 0; i < [tiles count]; i++)
            [[tiles objectAtIndex: i] removeFromSuperview];
        [tiles release];
        tiles = nil;
    }
    tiles = [[NSMutableArray alloc] initWithCapacity: 200];
	
    p = 0;
    for(i = 0; i < 200; i++) {
        bordt = NO;
        for(j = 0; j < 56; j++) {
            if(i == borderPositions[j]) {
                tile = [[GSTile alloc] initOnBoard: self 
                                       iconRef: nil group: -1 rndpos: -1 isBorderTile: YES];
                [tiles addObject: tile];
                [tile release];
                bordt = YES;
            }
        }
        if(!bordt) {
            [tiles addObject: [tmptiles objectAtIndex: p]];
            p++;
        }
    }

    for(i = 0; i < [tiles count]; i++) 
        [self addSubview: [tiles objectAtIndex:i]];
		
    firstTile = nil;
    secondTile = nil;	
	
    timeField = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 5, 60, 15)];
    [timeField setFont: [NSFont systemFontOfSize: 10]];
    [timeField setAlignment:NSCenterTextAlignment];	
    [timeField setBezeled:NO];
    [timeField setEditable:NO];
    [timeField setSelectable:NO];
    [timeField setStringValue:@"00:00"];
    [self addSubview: timeField];
		
    [self resizeWithOldSuperviewSize: [self frame].size];
    
    seconds = 0;
    minutes = 0;
    
    tmr = [NSTimer scheduledTimerWithTimeInterval:1 target:self 
                   selector:@selector(timestep:) userInfo:nil repeats:YES];
    hadEndOfGame = NO;
    gameState = GAME_STATE_RUNNING;
}

- (void)timestep:(NSTimer *)t
{
    NSString *timeStr;

    if(gameState == GAME_STATE_RUNNING)
    {
        seconds++;
        if(seconds == 60) {
            seconds = 0;
            minutes++;
        }
    }
    timeStr = [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];
    [timeField setStringValue: timeStr];
    [timeField setNeedsDisplay: YES];
}

- (int)prepareTilesToRemove:(GSTile *)clickedTile
{
    if(!firstTile) {
        firstTile = clickedTile;
        return 1;
    }
    secondTile = clickedTile;
	
    if([firstTile group] == [secondTile group])
    {
      if([self findPathBetweenTiles :firstTile :secondTile])	
            return 2;
        else
        {
            [firstTile unselect];
            firstTile = clickedTile;
            secondTile = nil;
            return 1;
        }
    }
    else
    {
        [firstTile unselect];
        firstTile = clickedTile;
        secondTile = nil;
        return 1;
    }

    return 0;
}

- (BOOL)findPathBetweenTiles: (GSTile *)tile1 :(GSTile *)tile2
{
  int x1 = [tile1 px];
  int y1 = [tile1 py];
  int x2 = [tile2 px];
  int y2 = [tile2 py];
  int dx[4] = {1, 0, -1, 0};
  int dy[4] = {0, 1, 0, -1};
  int newx, newy;
  unsigned i;

    if([self findSimplePathFromX1:x1 y1:y1 toX2:x2 y2:y2])
        return YES;
		
    for(i = 0; i < 4; i++) {
        newx = x1 + dx[i];
        newy = y1 + dy[i];

        while(![[self tileAtxPosition:newx yPosition:newy] isActive] 		
              && newx >= 0 && newx < 20 && newy >= 0 && newy < 10) {

            if([self findSimplePathFromX1:newx y1:newy toX2:x2 y2:y2])
                return YES;

            newx += dx[i];
            newy += dy[i];
        }
    }
		
    return NO;		
}

- (BOOL)findSimplePathFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2
{
    GSTile *tile;
    BOOL r = NO;

    if([self canMakeLineFromX1:x1 y1:y1 toX2:x2 y2:y2]) {
        r = YES;
    } else {
        if(!(x1 == x2 || y1 == y2)) {
            tile = [self tileAtxPosition:x2 yPosition:y1];
            if(![tile isActive] 
               && [self canMakeLineFromX1:x1 y1:y1 toX2:x2 y2:y1]
               && [self canMakeLineFromX1:x2 y1:y1 toX2:x2 y2:y2]) {
                r = YES;
            } else {
                tile = [self tileAtxPosition:x1 yPosition:y2];
                if(![tile isActive] 
                   && [self canMakeLineFromX1:x1 y1:y1 toX2:x1 y2:y2]
                   && [self canMakeLineFromX1:x1 y1:y2 toX2:x2 y2:y2]) {
                    r = YES;
                }
            }
        }
    }
	
    return r;
}

- (BOOL)canMakeLineFromX1:(int)x1 y1:(int)y1 toX2:(int)x2 y2:(int)y2
{
  NSArray *lineOfTiles;
  GSTile *tile;
  unsigned i;
	
    if(x1 == x2) {
        lineOfTiles = [self tilesAtXPosition: x1];
    	for(i = imin(y1, y2)+1; i < imax(y1, y2); i++) {
            tile = [lineOfTiles objectAtIndex: i];
            if([tile isActive])
                return NO;
        }
        return YES;
    }
	
    if(y1 == y2) {
        lineOfTiles = [self tilesAtYPosition: y1];
    	for(i = imin(x1, x2)+1; i < imax(x1, x2); i++) {
            tile = [lineOfTiles objectAtIndex: i];
            if([tile isActive])
                return NO;
        }
        return YES;
    }	
	
    return NO;
}

- (void)removeCurrentTiles
{
  GSTilePair *removedPair;
  
  [firstTile deactivate];
  [secondTile deactivate];
  
  removedPair = [[GSTilePair alloc] initWithTile:firstTile andTile:secondTile];
  
  [undoArray addObject:removedPair];
  [removedPair release];
    
  [self verifyEndOfGame];
  [self unSetCurrentTiles];
}

- (void)unSetCurrentTiles
{
    firstTile = nil;
    secondTile = nil;		
}

- (void)verifyEndOfGame
{
  GSTile *tile;
  unsigned i;
  BOOL hasMoreTiles = NO;
  BOOL hasMoreMoves = NO;
  
  i = 0;
  while (i < [tiles count] && !hasMoreTiles)
    {
      tile = [tiles objectAtIndex: i];
      if([tile isActive])
        {
          hasMoreTiles = YES;
        }
      i++;
    }
  
  if (hasMoreTiles)
    {
      GSTile *tile1;
      GSTile *tile2;

      tile1 = nil;
      tile2 = nil;
      hasMoreMoves = [self getHintMove :&tile1 :&tile2];
    }

  if(!hasMoreTiles)
    {
      [self endOfGame];
      return;
    }

  // FIXME, this should go perhaps into ghsien class
  if (!hasMoreMoves)
    {
      int result;
      
      result = NSRunAlertPanel(nil, @"No more moves possible!", @"New Game", @"Quit", @"Continue");
      if(result == NSAlertDefaultReturn)
        [self newGame];
      else if (result == NSAlertAlternateReturn)
        [NSApp terminate:self];
    }
}

- (BOOL)getHintMove :(GSTile **)tileStart :(GSTile **)tileEnd
{
  GSTile *tile1;
  GSTile *tile2;
  BOOL found;
  unsigned i;
  unsigned j;

  tile1 = nil;
  tile2 = nil;
  found = NO;
  for(i = 0; i < [tiles count]; i++)
    {
      GSTile *tile;

      tile = [tiles objectAtIndex: i];
      if([tile isActive] && [tile isSelect])
        [tile unselect];
    }
	
    for(i = 0; i < [tiles count]; i++)
      {
        if(found)
          break;
        for(j = 0; j < [tiles count]; j++)
          {
            if(i != j)
              {
                tile1 = [tiles objectAtIndex: i];
                tile2 = [tiles objectAtIndex: j];
                if([tile1 isActive] && [tile2 isActive])
                  {
                    if([tile1 group] == [tile2 group])
                      {
                        if([self findPathBetweenTiles :tile1 :tile2])
                          {
                            found = YES;
                            *tileStart = tile1;
                            *tileEnd = tile2;
                            break;
                          }
                      }
                  }
              }
          }
      }
    return found;
}

- (void)getHint
{
  GSTile *tile1;
  GSTile *tile2;
  BOOL found = NO;

  tile1 = nil;
  tile2 = nil;
  found = [self getHintMove :&tile1 :&tile2];
  
  if(found)
    {
      [tile1 hightlight];
      [tile2 hightlight];
      [[NSRunLoop currentRunLoop] runUntilDate: 
                                    [NSDate dateWithTimeIntervalSinceNow: 2]];
      [tile1 unselect];
      [tile2 unselect];									
    }

}

- (void)pause
{
    if(gameState == GAME_STATE_PAUSED) {
        gameState = GAME_STATE_RUNNING;
    } else if(gameState == GAME_STATE_RUNNING) {
        gameState = GAME_STATE_PAUSED;
    }
    [self setNeedsDisplay:YES];
}

- (void)endOfGame
{
    NSString *username;
    NSMutableDictionary *gameData;
    NSString *entry;

    hadEndOfGame = YES;
        
    if([tmr isValid])
        [tmr invalidate];
    
    gameState = GAME_STATE_PAUSED;

    username = [[GShisen sharedshisen] getUserName];
	
    gameData = [NSMutableDictionary dictionaryWithCapacity: 3];
    [gameData setObject: username forKey: @"username"];
    entry = [NSString stringWithFormat: @"%i", minutes];
    [gameData setObject: entry forKey: @"minutes"];
    entry = [NSString stringWithFormat: @"%02i", seconds];
    [gameData setObject: entry forKey: @"seconds"];
    [gameData setObject: [NSDate date] forKey: @"date"];

    [scores addObject: gameData];
    [scores sortUsingFunction:(NSComparisonResult (*)(id, id, void*))sortScores context:self];
		if ([scores count] > numScoresToKeep) {
			NSRange scoresToZap = NSMakeRange(numScoresToKeep, 
				[scores count] - numScoresToKeep);
			[scores removeObjectsInRange:scoresToZap];
		}
    [defaults setObject: scores forKey: @"scores"];
    [defaults synchronize];
	
    [[GShisen sharedshisen] showHallOfFame:self];

    seconds = 0;
    minutes = 0;

    [self setNeedsDisplay:YES];
}

- (NSMutableArray *)scores
{
  return scores;
}

- (NSArray *)tilesAtXPosition:(int)xpos
{
    NSMutableArray *tls;
    GSTile *tile;
    int i;

    tls = [NSMutableArray arrayWithCapacity: 1];
    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        if([tile px] == xpos)
            [tls addObject: tile];
    }
    return tls;
}

- (NSArray *)tilesAtYPosition:(int)ypos
{
    NSMutableArray *tls;
    GSTile *tile;
    int i;

    tls = [NSMutableArray arrayWithCapacity: 1];
    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        if([tile py] == ypos)
            [tls addObject: tile];
    }
    return tls;
}

- (GSTile *)tileAtxPosition:(int)xpos yPosition:(int)ypos
{
    GSTile *tile;
    int i;

    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        if(([tile px] == xpos) && ([tile py] == ypos))
            return tile;
    }
    return nil;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldFrameSize
{
    GSTile *tile;
    int i, hcount, vcount, hpos, vpos;

    vpos = [self frame].size.height -10;
    hpos = -30;
    hcount = 0;
    vcount = 0;
    for(i = 0; i < [tiles count]; i++) {
        tile = [tiles objectAtIndex: i];
        [tile setPositionOnBoard: hcount posy: vcount];			  
        [tile setFrame: NSMakeRect(hpos, vpos, 40, 56)];
        [self setNeedsDisplayInRect: [tile frame]];
        hpos += 40;
        hcount++;
        if(hcount == 20) {
            hcount = 0;
            vcount++;
            hpos = -30;
            vpos -= 56;
        }
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    NSString *commchar = [theEvent charactersIgnoringModifiers];

    if([commchar isEqualToString: @"n"]) {
        [self newGame];
        return YES;
    }
    if([commchar isEqualToString: @"g"]) {
        [self getHint];
        return YES;
    }
    if([commchar isEqualToString: @"z"]) {
        [self undo];
        return YES;
    }

    return NO;
}

- (void)drawRect:(NSRect)rect
{
    id font = [NSFont boldSystemFontOfSize:48];
    //id font = [NSFont boldSystemFontOfSize:24];
    NSString *pauseString = @"Paused";
    NSString *gameOverString = @"Game Over";
    
    // arrays for dictionaries
    NSArray *keyArray = [NSArray arrayWithObjects:NSFontAttributeName, 
                            NSForegroundColorAttributeName, nil];
    NSArray *valueArray1 = [NSArray arrayWithObjects:font,
                            [NSColor colorWithCalibratedRed: 0.09 green: 0.3 blue: 0 alpha: 1], nil];
    NSArray *valueArray2 = [NSArray arrayWithObjects:font,
                            [NSColor colorWithCalibratedRed: 0.9 green: 0.9 blue: 1 alpha: 1], nil];
    
    // attribute dictionaries
    NSDictionary *fontDict1 = [NSDictionary dictionaryWithObjects:valueArray1 forKeys:keyArray];
    NSDictionary *fontDict2 = [NSDictionary dictionaryWithObjects:valueArray2 forKeys:keyArray];
    
    // drawing locations
    NSPoint drawLocation = { 260, 256 };
    NSPoint drawLocation2 = { 256, 260 };

    [[NSColor colorWithCalibratedRed: 0.1 green: 0.47 blue: 0 alpha: 1] set];
    NSRectFill(rect);
    if(gameState == GAME_STATE_PAUSED && !hadEndOfGame) {
        [pauseString drawAtPoint:drawLocation withAttributes:fontDict1];
        [pauseString drawAtPoint:drawLocation2 withAttributes:fontDict2];
    }
    else if(hadEndOfGame) {
        [gameOverString drawAtPoint:drawLocation withAttributes:fontDict1];
        [gameOverString drawAtPoint:drawLocation2 withAttributes:fontDict2];
    }
}

- (int)gameState
{
    return gameState;
}

@end




