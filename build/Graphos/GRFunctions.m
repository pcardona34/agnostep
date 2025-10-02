/*
 Project: Graphos
 GRFunctions.m

 Utility functions.

 Copyright (C) 2000-2013 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

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

#import "GRFunctions.h"

#include <math.h>
#include <unistd.h>

#define GD_PI 3.14159265358979323846

NSPoint pointApplyingCostrainerToPoint(NSPoint p, NSPoint sp)
{
    float cos22 = cos(GD_PI * 22 / 180);
    float cos45 = cos(GD_PI * 45 / 180);
    float cos67 = cos(GD_PI * 67 / 180);
    double cy22, cy45, cy67, diffx, diffy;
    NSPoint cp;

    diffx = grmax(p.x, sp.x) - grmin(p.x, sp.x);
    diffy = grmax(p.y, sp.y) - grmin(p.y, sp.y);

    cy22 = diffx * pow(1 - pow(cos22, 2), 0.5) / cos22;
    cy45 = diffx * pow(1 - pow(cos45, 2), 0.5) / cos45;
    cy67 = diffx * pow(1 - pow(cos67, 2), 0.5) / cos67;

    if(diffy < cy45) {
        cp.x = p.x;
        if(diffy > cy22 && diffy < cy67)
        {
            if(p.y > sp.y)
                cp.y = sp.y + cy45;
            else
                cp.y = sp.y - cy45;
        } else
        {
            cp.y = sp.y;
        }
    } else {
        cp.x = sp.x;
        cp.y = p.y;
    }

    return cp;
}

NSRect GRMakeBounds(float x, float y, float width, float height)
{
    if (width < 0)
    {
        width = -width;
        x = x - width;
    }
    if (height < 0)
    {
        height = -height;
        y = y - height;
    }
    return NSMakeRect(x, y, width, height);
}

NSPoint GRpointDeZoom(NSPoint p, float zf)
{
  return NSMakePoint(p.x / zf, p.y / zf);
}

NSPoint GRpointZoom(NSPoint p, float zf)
{
  return NSMakePoint(p.x * zf, p.y * zf);
}

BOOL pointInRect(NSRect rect, NSPoint p)
{
    if(p.x >= rect.origin.x
       && p.x <= (rect.origin.x + rect.size.width)
       && p.y >= rect.origin.y
       && p.y <= (rect.origin.y + rect.size.height))
        return YES;

    return NO;
}

double grmin(double a, double b) {
    if(a < b)
        return a;
    else
        return b;
}

double grmax(double a, double b) {
    if(a > b)
        return a;
    else
        return b;
}


