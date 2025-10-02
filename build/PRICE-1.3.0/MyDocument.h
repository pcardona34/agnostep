//
//  MyDocument.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 12 2002.
//  Copyright (c) 2002-2008 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>
#import "PRWindowController.h"
#import "PRCProgress.h"
#import "AppController.h" /* so all other controllers have this included */
#import "PRImage.h"
#import "PRFilter.h"


@interface MyDocument : NSDocument
{
    PRWindowController *windowController;
    NSPrintInfo        *printInfo;
    @private PRImage   *activeImage;
    @private PRImage   *oldImage;
}

- (NSWindow *)window;
- (NSView *)view;
- (PRImage *)activeImage;
- (void)setActiveImage: (PRImage *)theImage;

- (void)runFilter:(PRFilter *)filter with:(NSArray *)parameters;

- (void)restoreLastImage;
- (void)saveCurrentImage;
- (void)setPrintInfo:(NSPrintInfo *)anObject;
- (NSPrintInfo *)printInfo;
@end
