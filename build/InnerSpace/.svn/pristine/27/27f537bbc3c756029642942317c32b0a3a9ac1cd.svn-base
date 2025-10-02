/*
    PolyhedraViewWraps.m

    This program is part of the GNUstep Application Project

    Copyright (C) 2002 Gregory John Casamento

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
    Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA

    Gregory John Casamento <greg_casamento@yahoo.com>
    14218 Oxford Drive, Laurel, MD 20707, USA
*/

// translated from the pswraps for GNUstep/MOSX by Gregory John Casamento

#include <AppKit/PSOperators.h>

void colourTriangle(float x1, 
		    float y1, 
		    float x2, 
		    float y2, 
		    float x3, 
		    float y3, 
		    float r, 
		    float g, 
		    float b)
{
  //  NSLog(@"triangle %f %f %f %f %f %f",x1,y1,x2,y2,x3,y3);
  PSsetrgbcolor(r,g,b);
  PSmoveto(x1,y1);
  PSlineto(x2,y2);
  PSlineto(x3,y3); 
  PSlineto(x1,y1);
  PSfill();
  PSsetgray(1);
  PSmoveto(x1,y1); // moveto
  PSlineto(x2,y2); // lineto
  PSlineto(x3,y3); // lineto
  PSlineto(x1,y1); // lineto
  PSstroke();
}

void outlineTriangle(float x1, 
		     float y1, 
		     float x2, 
		     float y2, 
		     float x3, 
		     float y3)
{
  //  NSLog(@"triangle %f %f %f %f %f %f",x1,y1,x2,y2,x3,y3);
  PSsetgray(1);
  PSmoveto(x1,y1); // moveto
  PSlineto(x2,y2); // lineto
  PSlineto(x3,y3); // lineto
  PSlineto(x1,y1); // lineto
  PSstroke();
}

void colourSquare(float x1, 
		  float y1, 
		  float x2, 
		  float y2, 
		  float x3, 
		  float y3, 
		  float x4, 
		  float y4, 
		  float r, 
		  float g, 
		  float b)
{
  //  NSLog(@"square");
  PSsetrgbcolor(r,g,b);
  PSmoveto(x1,y1);
  PSlineto(x2,y2);
  PSlineto(x3,y3); 
  PSlineto(x4,y4); 
  PSlineto(x1,y1);
  PSfill();
  PSsetgray(1);
  PSmoveto(x1,y1); // moveto
  PSlineto(x2,y2); // lineto
  PSlineto(x3,y3); // lineto
  PSlineto(x4,y4); 
  PSlineto(x1,y1); // lineto
  PSstroke();
}

void outlineSquare(float x1, 
		   float y1, 
		   float x2, 
		   float y2, 
		   float x3, 
		   float y3, 
		   float x4, 
		   float y4)
{  
  //  NSLog(@"square");
  PSsetgray(1);
  PSmoveto(x1,y1); // moveto
  PSlineto(x2,y2); // lineto
  PSlineto(x3,y3); // lineto
  PSlineto(x4,y4); // lineto
  PSlineto(x1,y1); // lineto
  PSstroke();
}

void colourPentagon(float x1, 
		    float y1, 
		    float x2, 
		    float y2, 
		    float x3, 
		    float y3, 
		    float x4, 
		    float y4, 
		    float x5, 
		    float y5, 
		    float r, 
		    float g, 
		    float b)
{
  //  NSLog(@"pentagon");
  PSsetrgbcolor(r,g,b);
  PSmoveto(x1,y1);
  PSlineto(x2,y2);
  PSlineto(x3,y3); 
  PSlineto(x4,y4); 
  PSlineto(x5,y5); 
  PSlineto(x1,y1);
  PSfill();
  PSsetgray(1);
  PSmoveto(x1,y1); // moveto
  PSlineto(x2,y2); // lineto
  PSlineto(x3,y3); // lineto
  PSlineto(x4,y4); 
  PSlineto(x5,y5); 
  PSlineto(x1,y1); // lineto
  PSstroke();
}

void outlinePentagon(float x1, 
		     float y1, 
		     float x2, 
		     float y2, 
		     float x3, 
		     float y3, 
		     float x4, 
		     float y4, 
		     float x5, 
		     float y5)
{
  //  NSLog(@"pentagon");
  PSsetgray(1);
  PSmoveto(x1,y1); // moveto
  PSlineto(x2,y2); // lineto
  PSlineto(x3,y3); // lineto
  PSlineto(x4,y4); 
  PSlineto(x5,y5); 
  PSlineto(x1,y1); // lineto
  PSstroke();
}
