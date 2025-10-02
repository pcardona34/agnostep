/*  
 *  Clock.m: Implementation of the TimeDateView Class 
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

#include "Clock.h"

#include "Constants.h"

#define LED_COLON  10
#define LED_AM     11
#define LED_PM     12

static const int tf_posx[11] = {5, 14, 24, 28, 37, 40, 17, 17, 22, 27, 15};
static const int posy[4]  = {14, 26, 42, 51};

@implementation Clock

//
//
//
- (id) initWithPathToResources: (NSString *) thePath;
{
  self = [super init];
  
  pathToResources = thePath;
  RETAIN(pathToResources);

  maskImage = nil;
  hour1Image = nil;
  hour2Image = nil;
  hour3Image = nil;
  minute1Image = nil;
  minute2Image = nil;
  dayweekImage = nil;
  daymont1Image = nil;
  daymont2Image = nil;
  monthImage = nil;

  [self setDate: [NSCalendarDate calendarDate]];
  
  return self;
}

//
//
//
- (void) dealloc
{
  RELEASE(pathToResources);

  TEST_RELEASE(maskImage);
  TEST_RELEASE(hour1Image);
  TEST_RELEASE(hour2Image);
  TEST_RELEASE(hour3Image);
  TEST_RELEASE(minute1Image);
  TEST_RELEASE(minute2Image);
  TEST_RELEASE(dayweekImage);
  TEST_RELEASE(daymont1Image);
  TEST_RELEASE(daymont2Image);
  TEST_RELEASE(monthImage);
  
  [super dealloc];
}


//
// access / mutation methods
// 
- (void) setDate: (NSCalendarDate *) theDate
{
  NSString *imgName;

  int n, hour, minute, dayOfWeek, dayOfMonth, month;

  if (theDate == nil)
    {
      return;
    }

  hour = [theDate hourOfDay];
  minute = [theDate minuteOfHour];
  dayOfWeek = [theDate dayOfWeek];
  dayOfMonth = [theDate dayOfMonth];
  month = [theDate monthOfYear];
  
  // We dealloc the previously used images
  TEST_RELEASE(maskImage);
  TEST_RELEASE(hour1Image);
  TEST_RELEASE(hour2Image);
  TEST_RELEASE(hour3Image);
  TEST_RELEASE(minute1Image);
  TEST_RELEASE(minute2Image);
  TEST_RELEASE(dayweekImage);
  TEST_RELEASE(daymont1Image);
  TEST_RELEASE(daymont2Image);
  TEST_RELEASE(monthImage);

  // We create our new set of images
  maskImage = [[NSImage alloc] initWithContentsOfFile: [NSString stringWithFormat: @"%@/Mask.tiff",
								 pathToResources]];
  
  //
  // hour
  //
  n = hour/10;
  imgName = [NSString stringWithFormat: @"LED-%d", n];		
  hour1Image = [[NSImage alloc] initWithContentsOfFile:
				  [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
  
  n = hour%10;		
  imgName = [NSString stringWithFormat: @"LED-%d", n];
  hour2Image = [[NSImage alloc] initWithContentsOfFile:
				  [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
  
  n = LED_COLON;
  imgName = [NSString stringWithFormat: @"LED-%d", n];
  hour3Image = [[NSImage alloc] initWithContentsOfFile:
				  [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
  
  //
  // minute
  //
  n = minute/10;
  imgName = [NSString stringWithFormat: @"LED-%d", n];
  minute1Image = [[NSImage alloc] initWithContentsOfFile:
				    [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
  
  n = minute%10;
  imgName = [NSString stringWithFormat: @"LED-%d", n];
  minute2Image = [[NSImage alloc] initWithContentsOfFile:
				    [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
  
  //
  // dayOfWeek
  //
  imgName = [NSString stringWithFormat: @"Weekday-%d", dayOfWeek];
  dayweekImage = [[NSImage alloc] initWithContentsOfFile:
				    [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
  
  //
  // dayOfMonth
  //
  n = dayOfMonth/10;
  imgName = [NSString stringWithFormat: @"Date-%d", n];
  daymont1Image = [[NSImage alloc] initWithContentsOfFile:
				     [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
  
  n = dayOfMonth%10;
  imgName = [NSString stringWithFormat: @"Date-%d", n];
  daymont2Image = [[NSImage alloc] initWithContentsOfFile:
				     [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
  
  //
  // month
  //
  n = month;
  imgName = [NSString stringWithFormat: @"Month-%d", n];
  monthImage = [[NSImage alloc] initWithContentsOfFile:
				  [NSString stringWithFormat: @"%@/%@.tiff", pathToResources, imgName]];
	
  [self setNeedsDisplay: YES];
}


//
// Implementation of the inherited methods from NSView
//
- (BOOL) isOpaque
{
  return YES;
}

- (NSRect) frame
{
  NSLog(@"FRAME INVOKED");
  return NSMakeRect(0,0,55,57);
}

- (void) drawRect: (NSRect) rect
{
  NSRect r;
  NSSize s; 
  NSPoint p;
  float h;
  
  if (maskImage == nil)
    {
      return;
    }
  
  s = [maskImage size];
  h = s.height;
  r = NSInsetRect(rect, (rect.size.width - s.width)/2, 
		  (rect.size.height - s.height)/2);
  p = NSMakePoint(r.origin.x, r.origin.y);
  [maskImage compositeToPoint: NSZeroPoint operation: NSCompositeSourceOver];
  
  //
  // hour
  //
  p.x = tf_posx[0];
  p.y = h - posy[0];
  [hour1Image compositeToPoint: p operation: NSCompositeSourceOver];
  p.x = tf_posx[1];
  [hour2Image compositeToPoint: p operation: NSCompositeSourceOver];
  p.x = tf_posx[2];
  [hour3Image compositeToPoint: p operation: NSCompositeSourceOver];
  
  //
  // minute
  //
  p.x = tf_posx[3];
  [minute1Image compositeToPoint: p operation: NSCompositeSourceOver];
  p.x = tf_posx[4];
  [minute2Image compositeToPoint: p operation: NSCompositeSourceOver];
  
  //
  // dayOfWeek
  //
  p.x = tf_posx[6];
  p.y = h - posy[1];
  [dayweekImage compositeToPoint: p operation: NSCompositeSourceOver];
  
  //
  // dayOfMonth
  //
  p.x = tf_posx[7];  
  p.y = h - posy[2];
  [daymont1Image compositeToPoint: p operation: NSCompositeSourceOver];
  p.x = tf_posx[9];
  [daymont2Image compositeToPoint: p operation: NSCompositeSourceOver];
  
  //
  // month
  //
  p.x = tf_posx[10];
  p.y = h - posy[3];
  [monthImage compositeToPoint: p operation: NSCompositeSourceOver];
}

@end
