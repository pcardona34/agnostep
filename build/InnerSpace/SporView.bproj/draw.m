/*
	NeXT Drawing Stuff
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "draw.h"

void cSetColor( int color, int ins )
{
  if( color == 0 )
    PSsetrgbcolor( 0, 0, 0 );
  
  if( color == 1 )
    {
      PSsetrgbcolor( 0.01*ins, 0, 0 );
    }
  if( color == 2 )
    {
      PSsetrgbcolor( 0, 0.01*ins, 0 );
    }
  if( color == 3 )
    {
      PSsetrgbcolor( 0.0, 0.0, 0.01*ins );
    }
  
  return;
}

void cSetSpor( int x, int y )
{
  NSRect	aRect;
  
  aRect.origin.x = x * 4;				/* 4 -> size of Spore */
  aRect.origin.y = y * 4;
  aRect.size.height = 4;
  aRect.size.width = 4;
  
  NSRectFill( aRect );
  
  return;
}

void cSetLine( int x1, int y1, int x2, int y2 )
{
  NSRect	theRect;
  
  theRect.size.height = y2 - y1;
  theRect.size.width = 1;
  theRect.origin.x = x1;
  theRect.origin.y = y1;
  
  NSRectFill( theRect );
  
  return;
}

void NextCls( int maxX, int maxY )
{
  NSRect	theRect;
  
  cSetColor( 0, 100 );
  theRect.origin.x = theRect.origin.y = 0;
  theRect.size.width = maxX + 2;
  theRect.size.height = maxY + 8;
  
  NSRectFill( theRect );
  
  return;
}

