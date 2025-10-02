//
//  PRCurves.h
//  PRICE
//
//  Created by Riccardo Mottola on 07/08/11.
//  Copyright 2011 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <Foundation/Foundation.h>
#import "PRFilter.h"
#import "PRImage.h"


@interface PRCurves : PRFilter
{

}

- (PRImage *)adjustImage :(PRImage *)srcImage :(unsigned *)arrayL :(unsigned *)arrayR :(unsigned *)arrayG :(unsigned *)arrayB;

@end
