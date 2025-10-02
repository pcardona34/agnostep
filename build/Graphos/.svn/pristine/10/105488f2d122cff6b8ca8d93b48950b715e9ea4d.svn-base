/*
 Project: Graphos
 GRImageEditor.m

 Copyright (C) 2015 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2015-03-24

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

#import "GRImage.h"
#import "GRImageEditor.h"

@implementation GRImageEditor

- (NSPoint)constrainControlPoint:(NSPoint)p
{
  NSPoint pos;
  CGFloat w, h;
  NSPoint retP;
  float ratio;
  float wSign;
  float hSign;
  
  ratio = [(GRImage *)object originalRatio];
  retP = p;
  pos = [(GRBox *)object position];
  w = pos.x-p.x;
  h = pos.y-p.y;
  /* we adjust the deltas, but need to retain the sign of w and h */
  wSign = 1.0;
  hSign = 1.0;
  if (w < 0)
    wSign = -1.0;
  if (h < 0)
    hSign = -1.0;
  if (fabs(w / h) > ratio)
    w = wSign * fabs(h * ratio);
  else
    h = hSign * fabs(w / ratio);

  retP.x = pos.x-w;
  retP.y = pos.y-h;
  
  return retP;
}


@end
