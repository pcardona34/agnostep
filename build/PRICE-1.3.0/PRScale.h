//
//  PRScale.h
//  PRICE
//
//  Created by Riccardo Mottola on Wed Jan 19 2005.
//  Copyright (c) 2005-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>
#import "PRProgressAction.h"
#import "PRImage.h"

#define NEAREST_NEIGHBOUR 1
#define BILINEAR 2


@interface PRScale : PRProgressAction
{

}

- (PRImage *)scaleImage :(PRImage *)srcImage :(int)sizeX :(int)sizeY :(int)method :(PRCProgress *)prPanel;

@end
