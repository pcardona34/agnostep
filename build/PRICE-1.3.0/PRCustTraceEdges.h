//
//  PRCustTraceEdges.h
//  PRICE
//
//  Created by Riccardo Mottola on Fri Mar 19 2004.
//  Copyright (c) 2004-2011 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>
#import "PRProgressAction.h"
#import "PRImage.h"
#import "PRMedian.h"

@interface PRCustTraceEdges : PRProgressAction
{

}

- (PRImage *)edgeImage :(PRImage *)srcImage :(int)filterType :(float)thresholdLevel :(BOOL)useZeroCross :(BOOL)enable1 :(enum medianForms)form1 :(int)size1 :(BOOL)separable1 :(BOOL)enable2 :(enum medianForms)form2 :(int)size2 :(BOOL)separable2 :(BOOL) enable3 :(enum medianForms)form3 :(int)size3 :(BOOL)separable3 :(PRCProgress *)prPanel;

@end
