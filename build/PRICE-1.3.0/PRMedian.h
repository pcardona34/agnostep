//
//  PRMedian.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 25 2004.
//  Copyright (c) 2004 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>
#import "PRProgressAction.h"
#import "PRImage.h"

enum medianForms { HORIZONTAL_F, VERTICAL_F, CROSS_F, BOX_F };


@interface PRMedian : PRProgressAction
{

}

- (PRImage *)medianImage :(PRImage *)srcImage :(enum medianForms)form :(int)size :(BOOL)separable :(PRCProgress *)prPanel;

@end
