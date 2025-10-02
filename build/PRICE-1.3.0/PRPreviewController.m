//
//  PRPreviewController.m
//  PRICE
//
//  Created by Riccardo Mottola on 2/19/10.
//  Copyright 2010-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import "PRPreviewController.h"


@implementation PRPreviewController

- (id)init
{
  if ((self = [super init]))
  {
    [NSBundle loadNibNamed:@"Preview" owner:self];

    /* add an observer for the window resize */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResize:) name:NSWindowDidResizeNotification object:previewWindow];
  }
  return self;
}

- (void)dealloc
{
  /* remove observer for the window resize */
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:previewWindow];
  
  [super dealloc];
}


- (void)setFilterController: (PRFilterController *)controller
{
  filterController = controller;
}

- (void)showPreview
{
  [previewWindow orderFront: self];
}

- (void)hidePreview
{
  [previewWindow orderOut: self];
}

/** returns wether continuous update of the preview is desired or not */
- (BOOL)continuous
{
    if ([buttContinuous state] == NSOnState)
        return YES;
    return NO;
}

- (void)setContinuous :(BOOL)flag
{
    if (flag == YES)
        [buttContinuous setState: NSOnState];
    else
        [buttContinuous setState: NSOffState];
}


- (IBAction)cleanPreview:(id)sender
{
  [view setImage:nil];
}

- (IBAction)updatePreview:(id)sender
{
  PRImage *img;
  
  img = [filterController filteredImage];
  [view setImage:img];

  [self scaleFromMenu:scalePopUp];
}

- (void)scaleFromMenu:(id)sender
{
  int    tag;
  NSSize currViewSize;
  NSSize imgSize;
  float  hscale, vscale;
  
  tag = [[sender selectedItem] tag];
  currViewSize = [[[view enclosingScrollView] contentView] visibleRect].size;
  imgSize = [(PRImage *)[view image] size];
  switch (tag)
    {
    case -3:
      vscale = currViewSize.height / imgSize.height;
      hscale = currViewSize.width / imgSize.width;
      if (hscale > vscale)
        [view scaleFrameBy:vscale];
      else
        [view scaleFrameBy:hscale];
      break;
    case -2:
      hscale = currViewSize.width / imgSize.width;
      NSLog(@"%f %f", currViewSize.width, imgSize.width);
      [view scaleFrameBy:hscale];
      break;
    case -1:
      vscale = currViewSize.height / imgSize.height;
      NSLog(@"%f %f", currViewSize.height, imgSize.height);
      [view scaleFrameBy:vscale];
      break;
    case 12:
      [view scaleFrameBy:0.125];
      break;
    case 25:
      [view scaleFrameBy:0.25];
      break;
    case 50:
      [view scaleFrameBy:0.5];
      break;
    case 75:
      [view scaleFrameBy:0.75];
      break;
    case 100:
      [view scaleFrameBy:1.0];
      break;
    case 150:
      [view scaleFrameBy:1.55];
      break;
    case 200:
      [view scaleFrameBy:2.0];
      break;
    default:
    NSLog(@"unexpected case in scale menu selection");
      break;
    }  
}

/** method called as a notification from the window resize
or if scale preferences changed */
- (void)_windowDidResize :(NSNotification *)notif
{
  int    tag;
  NSSize currViewSize;
  NSSize imgSize;
  float  hscale, vscale;
  
  tag = [[scalePopUp selectedItem] tag];
  currViewSize = [[[view enclosingScrollView] contentView] visibleRect].size;
  imgSize = [(PRImage *)[view image] pixelSize];
  switch (tag)
    {
    case -3:
      vscale = currViewSize.height / imgSize.height;
      hscale = currViewSize.width / imgSize.width;
      if (hscale > vscale)
        [view scaleFrameBy:vscale];
      else
        [view scaleFrameBy:hscale];
      break;
    case -2:
      hscale = currViewSize.width / imgSize.width;
      NSLog(@"%f %f", currViewSize.width, imgSize.width);
      [view scaleFrameBy:hscale];
      break;
    case -1:
      vscale = currViewSize.height / imgSize.height;
      NSLog(@"%f %f", currViewSize.height, imgSize.height);
      [view scaleFrameBy:vscale];
      break;
    default:
      break;
    }  
}


/* ---- FilterProgress protocol methods */

- (void)setTitle:(NSString *)title
{
}

- (void)setProgress:(double)progress
{
    [progressBar setDoubleValue:progress];    
    [previewWindow displayIfNeeded];
    [previewWindow flushWindowIfNeeded];
}

- (void)setActivity:(NSString *)title
{
    [activityDescription setStringValue:title];
    [previewWindow displayIfNeeded];
}


@end
