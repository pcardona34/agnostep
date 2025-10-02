//
//  PRTransforms.h
//  PRICE
//
//  Created by Riccardo Mottola on Fri Nov 14 2008.
//  Copyright (c) 2002-2008 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import <AppKit/AppKit.h>


@interface PRCTransforms : NSObject
{
    NSString *actionName;
}

- (void)setActionName:(NSString *)name;

- (IBAction)transposeImage:(id)sender;
- (IBAction)rotateImage90:(id)sender;
- (IBAction)rotateImage180:(id)sender;
- (IBAction)rotateImage270:(id)sender;
- (IBAction)flipImageVert:(id)sender;
- (IBAction)flipImageHoriz:(id)sender;

@end
