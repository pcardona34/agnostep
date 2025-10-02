//
//  PRFilter.h
//  PRICE
//
//  Created by Riccardo Mottola on 11/8/08.
//  Copyright (c) 2008-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>

#import "PRImage.h"
#import "PRCProgress.h"
#import "PRFilterController.h"

@interface PRFilter : NSObject
{
  @protected PRFilterController *filterController;
}

- (BOOL)displayProgress;
- (NSString *)actionName;
- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(id <FilterProgress>)progressPanel;


@end
