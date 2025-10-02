//
//  PRDFTFilter.h
//  PRICE
//
//  Created by Riccardo Mottola on Tue Nov 18 2003.
//  Copyright (c) 2003-2005 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import <AppKit/AppKit.h>
#import "PRImage.h"


@interface PRDFTFilter : NSObject
{

}

- (PRImage *)filterImage :(PRImage *)srcImage :(double **)filterMatRe :(double **)filterMatIm :(unsigned int) filterSize :(BOOL)autoRange :(id)controller;

@end
