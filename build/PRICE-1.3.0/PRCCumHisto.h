//
//  PRCCumHisto.h
//  PRICE
//  Cumulative Histogram Controller
//
//  Created by Riccardo Mottola on Thu Dec 18 2003.
//  Copyright (c) 2003 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCHistogram.h"
#import "PRCumHisto.h"


@interface PRCCumHisto : PRCHistogram
{
    IBOutlet PRCumHisto *histoView;
}

- (IBAction)showHistogram:(id)sender;

@end
