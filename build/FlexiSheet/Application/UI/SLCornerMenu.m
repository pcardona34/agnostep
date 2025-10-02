//
//  SLCornerMenu.m
//
//  Created by Stefan Leuker on 27-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: SLCornerMenu.m,v 1.1 2008/10/28 13:10:32 hns Exp $

#import "SLCornerMenu.h"


@implementation SLCornerMenu

- (id)initWithFrame:(NSRect)buttonFrame pullsDown:(BOOL)flag
{
    return [self initWithFrame:buttonFrame];
}


- (id)initWithFrame:(NSRect)buttonFrame
{
    self = [super initWithFrame:buttonFrame pullsDown:YES];
    if (self) {
        [self setPullsDown:YES];
        [self setAutoenablesItems:YES];
    }
    return self;
}


- (void)drawRect:(NSRect)rect
{
    NSImage *img = [NSImage imageNamed:@"CornerMenu"];

    NSDrawButton([self bounds], rect);
    
    [img setFlipped:YES];
    [img drawAtPoint:NSMakePoint(2,3) fromRect:NSMakeRect(0,0,13,13)
                operation:NSCompositeSourceOver fraction:1];
}

@end
