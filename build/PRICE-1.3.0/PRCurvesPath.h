//
//  PRCurvesPath.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu 11 August 2011.
//  Copyright 2011-2014 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <Foundation/Foundation.h>
#import <AppKit/NSBezierPath.h>

@interface PRCurvesPath : NSBezierPath
{
  BOOL isEditing;
}

-(BOOL)isEditing;
-(void)setIsEditing: (BOOL)flag;
-(NSArray *)values;

/** returns black point */
-(NSPoint)blackPoint;

/** returns white point */
-(NSPoint)whitePoint;

/** moves a control point p1 to p2 */
-(void)move: (NSPoint)p1 toPoint:(NSPoint)p2;

/** determines if any control point of the path got hit */
-(BOOL)pointOnControlHandle:(NSPoint)p;

@end
