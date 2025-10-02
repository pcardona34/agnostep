/*
 *  Clock.h: Interface and declarations for the TimeDateView Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2001 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: August 2001
 *
 *  Modified by Ludovic Marcotte <ludovic@Sophos.ca>
 * 
 *  - renamed from TimeDateView to Clock
 *  - refactored the code
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _GNUMail_H_Clock
#define _GNUMail_H_Clock

#import <AppKit/AppKit.h>

@interface Clock : NSView
{
  NSString *pathToResources;

  NSImage *maskImage;

  NSImage *hour1Image;
  NSImage *hour2Image;
  NSImage *hour3Image;

  NSImage *minute1Image;
  NSImage *minute2Image;

  NSImage *dayweekImage;

  NSImage *daymont1Image;
  NSImage *daymont2Image;

  NSImage *monthImage;
}


//
//
//
- (id) initWithPathToResources: (NSString *) thePath;


//
// access / mutation methods
// 
- (void) setDate: (NSCalendarDate *) theDate;

@end


#endif // _GNUMail_H_Clock
