/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009  GNUstep Application Team
                       Riccardo Mottola

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA. 
*/

#import "NumberedImageTextCell.h"
#import <Foundation/Foundation.h>

static NSDictionary* numberDrawingAttributes = nil;
static NSImageCell* imageCell;

@implementation NumberedImageTextCell

-(void) setNumber: (int) number
{
    _number = number;
}

/*
 * FIXME: Contains some hard coded offsets to set positions.
 */
- (void) drawWithFrame: (NSRect) theFrame
                inView: (NSView *) theView
{
    NSString* numStr;
    NSSize size;
    NSRect leftRect, leftBadgeRect, midBadgeRect, rightBadgeRect;

    // Draw no badge if number is 0
    if (_number == 0) {
        [super drawWithFrame: theFrame inView: theView];
        return;
    }
    
    if (numberDrawingAttributes == nil) {
        numberDrawingAttributes =
            [[NSDictionary dictionaryWithObjectsAndKeys:
                [NSColor whiteColor], NSForegroundColorAttributeName,
                [NSFont boldSystemFontOfSize: [NSFont systemFontSize]], NSFontAttributeName,
                nil] retain];
    }
    
    if (imageCell == nil) {
        imageCell = [[NSImageCell alloc] init];
    }
    
    // FIXME: There must be an easier way to convert integers to strings.
    numStr = [[NSNumber numberWithInt: _number] description];
    size = [numStr sizeWithAttributes: numberDrawingAttributes];
    
    // FIXME: Hard-coded: 10.0 is the width of both round corners together
    NSDivideRect(theFrame, &rightBadgeRect, &leftRect, size.width + 10.0, NSMaxXEdge);
    
    // FIXME: Hard-coded: 15.0 is the image height of the badge
    rightBadgeRect.size.height = 14.0;
    
    // FIXME: Hard-coded: 1.0 is how much the badge needs to be moved in Y dir in Grr.
    if ([theView isFlipped]) {
        rightBadgeRect.origin.y += 1.0;
    } else {
        rightBadgeRect.origin.y -= 1.0;
    }
    
    // FIXME: Hard-coded: 5.0 is the width of the round corner images
    NSDivideRect(rightBadgeRect, &rightBadgeRect, &midBadgeRect, 5.0, NSMaxXEdge);
    NSDivideRect(midBadgeRect, &leftBadgeRect, &midBadgeRect, 5.0, NSMinXEdge);
    
    [imageCell setImageScaling: NSScaleNone];
    [imageCell setImage: [NSImage imageNamed: @"blue-badge-left"]];
    [imageCell drawWithFrame: leftBadgeRect inView: theView];
    [imageCell setImage: [NSImage imageNamed: @"blue-badge-right"]];
    [imageCell drawWithFrame: rightBadgeRect inView: theView];
    [imageCell setImage: [NSImage imageNamed: @"blue-badge-mid"]];
    [imageCell setImageScaling: NSScaleToFit];
    [imageCell drawWithFrame: midBadgeRect inView: theView];
    
    if ([theView isFlipped]) {
        midBadgeRect.origin.y += (midBadgeRect.size.height - size.height) / 2.0;
    } else {
        midBadgeRect.origin.y -= (midBadgeRect.size.height - size.height) / 2.0;
    }
    
    midBadgeRect.size.height = size.height;
    
    [numStr drawInRect: midBadgeRect withAttributes: numberDrawingAttributes];
    
    if (leftRect.size.width > 2.0) {
        leftRect.size.width -= 2.0;
    }
    
    [super drawWithFrame: leftRect inView: theView];
}

@end

