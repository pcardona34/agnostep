//
//  PRTransforms.h
//  PRICE
//
//  Created by Riccardo Mottola on Mon Dec 23 2002.
//  Copyright (c) 2002-2008 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#define TRANSPOSE  1
#define ROTATE90   2
#define ROTATE180  3
#define ROTATE270  4
#define FLIP_VERT  5
#define FLIP_HORIZ 6

#import <AppKit/AppKit.h>
#import "PRImage.h"
#import "PRFilter.h"


@interface PRTransforms : PRFilter
{
    NSString *actionName;
}

- (void)setActionName:(NSString *)name;

- (PRImage *)transposeImage:(PRImage *)srcImage;
- (PRImage *)rotateImage90:(PRImage *)srcImage;
- (PRImage *)rotateImage180:(PRImage *)srcImage;
- (PRImage *)rotateImage270:(PRImage *)srcImage;
- (PRImage *)flipImageVert:(PRImage *)srcImage;
- (PRImage *)flipImageHoriz:(PRImage *)srcImage;

@end
