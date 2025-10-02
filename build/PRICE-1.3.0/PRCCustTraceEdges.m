//
//  PRCCustTraceEdges.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 18 2004.
//  Copyright (c) 2004-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCCustTraceEdges.h"
#import "PRCustTraceEdges.h"
#import "MyDocument.h"
#import "PRMedian.h"


@implementation PRCCustTraceEdges

- (id)init
{
    if ((self = [super init]))
    {
        filter = [[PRCustTraceEdges alloc] init];
    }
    return self;
}

- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];
    
    if (!edgeWindow)
        [NSBundle loadNibNamed:@"CustTraceEdges" owner:self];
    [edgeWindow makeKeyAndOrderFront:nil];
    
    /* edge tracer NIB defaults setting */
    [thresholdSlider setEnabled:YES];
    [thresholdField setEnabled:YES];
    if ([[filterType selectedItem] tag] >= 7)
        [zeroCrossCheck setEnabled:YES];
    thresholdLevel = [thresholdField floatValue];
    
    /* median image panes enables from NIB */
    if ([enableCheck1 state] == NSOffState)
        [self toggleStatePane1:NO];
    if ([enableCheck2 state] == NSOffState)
        [self toggleStatePane2:NO];
    if ([enableCheck3 state] == NSOffState)
        [self toggleStatePane3:NO];

    [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
    BOOL enable1, enable2, enable3;
    enum medianForms theForm1, theForm2, theForm3;
    BOOL isSeparable1, isSeparable2, isSeparable3;
    int theSize1, theSize2, theSize3;
    BOOL zeroCrossOn;
    NSArray        *parameters;
    
    theForm1 = theForm2 = theForm3 = 0;
    isSeparable1 = isSeparable2 = isSeparable3 = 0;
    theSize1 = theSize2 = theSize3 = 0;
    
    if ([enableCheck1 state] == NSOnState)
    {
        enable1 = YES;
        if ([separableCheck1 state] == NSOnState)
            isSeparable1 = YES;
        else
            isSeparable1 = NO;
        switch ([[formSelect1 selectedItem] tag])
        {
            case 1: theForm1 = HORIZONTAL_F;
                break;
            case 2: theForm1 = VERTICAL_F;
                break;
            case 3: theForm1 = CROSS_F;
                break;
            case 4: theForm1 = BOX_F;
                break;
            default: NSLog(@"Unrecognized form selected");
                theForm1 = BOX_F;
        }
        theSize1 = [sizeSlider1 intValue];
    } else
        enable1 = NO;
    
    if ([enableCheck2 state] == NSOnState)
    {
        enable2 = YES;
        if ([separableCheck2 state] == NSOnState)
            isSeparable2 = YES;
        else
            isSeparable2 = NO;
        switch ([[formSelect2 selectedItem] tag])
        {
            case 1: theForm2 = HORIZONTAL_F;
                break;
            case 2: theForm2 = VERTICAL_F;
                break;
            case 3: theForm2 = CROSS_F;
                break;
            case 4: theForm2 = BOX_F;
                break;
            default: NSLog(@"Unrecognized form selected");
                theForm2 = BOX_F;
        }
        theSize2 = [sizeSlider2 intValue];
    } else
        enable2 = NO;
        
    if ([enableCheck3 state] == NSOnState)
    {
        enable3 = YES;
            if ([separableCheck3 state] == NSOnState)
            isSeparable3 = YES;
        else
            isSeparable3 = NO;
        switch ([[formSelect3 selectedItem] tag])
        {
            case 1: theForm3 = HORIZONTAL_F;
                break;
            case 2: theForm3 = VERTICAL_F;
                break;
            case 3: theForm3 = CROSS_F;
                break;
            case 4: theForm3 = BOX_F;
                break;
            default: NSLog(@"Unrecognized form selected");
                theForm3 = BOX_F;
        }
        theSize3 = [sizeSlider3 intValue];
    } else
        enable3 = NO;

    if ([zeroCrossCheck state] == NSOnState)
        zeroCrossOn = YES;
    else
        zeroCrossOn = NO;
        
    /* set automatically  zero cross */    
    if ([[filterType selectedItem] tag] < 7)
    {
        [zeroCrossCheck setState:NO];
        zeroCrossOn = NO;
    }
    
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt: [[filterType selectedItem] tag]],
        [NSNumber numberWithFloat: thresholdLevel],
        [NSNumber numberWithBool: zeroCrossOn],
        [NSNumber numberWithBool: enable1],
        [NSNumber numberWithInt: theForm1],
        [NSNumber numberWithInt: theSize1],
        [NSNumber numberWithBool: isSeparable1],
        [NSNumber numberWithBool: enable2],
        [NSNumber numberWithInt: theForm2],
        [NSNumber numberWithInt: theSize2],
        [NSNumber numberWithBool: isSeparable2],
        [NSNumber numberWithBool: enable3],
        [NSNumber numberWithInt: theForm3],
        [NSNumber numberWithInt: theSize3],
        [NSNumber numberWithBool: isSeparable3],
        nil];


    return parameters;
}

- (void)closeFilterPanel
{
    [edgeWindow performClose:nil];
}

- (IBAction)changeSize1:(id)sender
{
    [sizeField1 setIntValue :[sizeSlider1 intValue] * 2 + 1];
    [self parametersChanged:sender];
}

- (IBAction)changeSize2:(id)sender
{
    [sizeField2 setIntValue :[sizeSlider2 intValue] * 2 + 1];
    [self parametersChanged:sender];
}

- (IBAction)changeSize3:(id)sender
{
    [sizeField3 setIntValue :[sizeSlider3 intValue] * 2 + 1];
    [self parametersChanged:sender];
}

- (IBAction)enablePane1:(id)sender
{
    if ([enableCheck1 state] == NSOnState)
        [self toggleStatePane1:YES];
    else
        [self toggleStatePane1:NO];
    [self parametersChanged:sender];
    
}

- (IBAction)enablePane2:(id)sender
{
    if ([enableCheck2 state] == NSOnState)
        [self toggleStatePane2:YES];
    else
        [self toggleStatePane2:NO];
    [self parametersChanged:sender];
}

- (IBAction)enablePane3:(id)sender
{
    if ([enableCheck3 state] == NSOnState)
        [self toggleStatePane3:YES];
    else
        [self toggleStatePane3:NO];
    [self parametersChanged:sender];
}


- (IBAction)toggleStatePane1:(BOOL) state
{
    if (state == NSOnState)
    {
        [separableCheck1 setEnabled:YES];
        [formSelect1 setEnabled:YES];
        [sizeSlider1 setEnabled:YES];
    } else
    {
        [separableCheck1 setEnabled:NO];
        [formSelect1 setEnabled:NO];
        [sizeSlider1 setEnabled:NO];
    }
}

- (IBAction)toggleStatePane2:(BOOL) state
{
    if (state == NSOnState)
    {
        [separableCheck2 setEnabled:YES];
        [formSelect2 setEnabled:YES];
        [sizeSlider2 setEnabled:YES];
    } else
    {
        [separableCheck2 setEnabled:NO];
        [formSelect2 setEnabled:NO];
        [sizeSlider2 setEnabled:NO];
    }
}

- (IBAction)toggleStatePane3:(BOOL) state
{
    if (state == NSOnState)
    {
        [separableCheck3 setEnabled:YES];
        [formSelect3 setEnabled:YES];
        [sizeSlider3 setEnabled:YES];
    } else
    {
        [separableCheck3 setEnabled:NO];
        [formSelect3 setEnabled:NO];
        [sizeSlider3 setEnabled:NO];
    }
}


- (IBAction)changeThreshold:(id)sender
{
    thresholdLevel = [sender floatValue];
    [thresholdField setFloatValue:thresholdLevel];
    [self parametersChanged:sender];
}

@end
