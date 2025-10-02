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

#import <Foundation/NSGeometry.h>


NSPoint pointApplyingCostrainerToPoint(NSPoint p, NSPoint sp);

/** returns if the point is inside the boundaries of the given rect */
BOOL pointInRect(NSRect rect, NSPoint p);

/** generates bounds from the coordinates and dimensions */
NSRect GRMakeBounds(float x, float y, float width, float height);

/** Removes Zoom from a Point by reverse applying it */
NSPoint GRpointDeZoom(NSPoint p, float zf);

/** Applies Zoom to a Point */
NSPoint GRpointZoom(NSPoint p, float zf);

/** retuns the minimum of a and b */
double grmin(double a, double b);

/** returns the maximum of a and b */
double grmax(double a, double b);
