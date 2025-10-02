//
//  FSChartView.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 20-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSChartView.m,v 1.1 2008/10/28 13:10:09 hns Exp $

#import "FSChartView.h"


@implementation FSChartView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    NSRect     bounds = [self bounds];    
    
    [[NSColor controlColor] set];
    NSRectFill(bounds);
}

@end
