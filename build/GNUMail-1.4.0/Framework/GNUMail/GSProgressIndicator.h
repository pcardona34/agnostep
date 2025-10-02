/*
**
**  GSProgressIndicator.m
**
**  Copyright (c) 2018 Riccardo Mottola
**
**  Author: Riccardo Mottola <rm@gnu.org>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
  A simple indefinite spinning progress indicator with the GNUstep look
 */

#import <Foundation/NSArray.h>
#import <Foundation/NSTimer.h>

#import <AppKit/NSProgressIndicator.h>

@interface GSProgressIndicator : NSProgressIndicator
{
  NSMutableArray *images;
  NSUInteger index;
  NSTimer *progTimer;
  BOOL animating;
}

@end
