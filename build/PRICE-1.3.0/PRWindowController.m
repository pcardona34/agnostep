//
//  PRWindowController.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 12 2002.
//  Copyright (c) 2002-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRWindowController.h"
#import "MyDocument.h"


@implementation PRWindowController

- (void)dealloc
{
    /* remove observer for the window resize */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:[self window]];
    
    [super dealloc];
}


- (void)scaleFromMenu:(id)sender
{
    int    tag;
    NSSize currViewSize;
    NSSize imgSize;
    float  hscale, vscale;
    
    tag = [[scalePopUp selectedItem] tag];
    currViewSize = [[[view enclosingScrollView] contentView] visibleRect].size;
    imgSize = [[[self document] activeImage] size];
    switch (tag)
    {
        case -4:
            [scalePanel makeKeyAndOrderFront:nil];
            break;
        case -3:
            vscale = currViewSize.height / imgSize.height;
            hscale = currViewSize.width / imgSize.width;
            if (hscale > vscale)
                [self scaleImageTo:vscale];
            else
                [self scaleImageTo:hscale];
            break;
        case -2:
            hscale = currViewSize.width / imgSize.width;
            NSLog(@"%f %f", currViewSize.width, imgSize.width);
            [self scaleImageTo:hscale];
            break;
        case -1:
            vscale = currViewSize.height / imgSize.height;
            NSLog(@"%f %f", currViewSize.height, imgSize.height);
            [self scaleImageTo:vscale];
            break;
        case 12:
            [self scaleImageTo:0.125];
            break;
        case 25:
            [self scaleImageTo:0.25];
            break;
        case 50:
            [self scaleImageTo:0.5];
            break;
        case 75:
            [self scaleImageTo:0.75];
            break;
        case 100:
            [self scaleImageTo:1.0];
            break;
        case 150:
            [self scaleImageTo:1.55];
            break;
        case 200:
            [self scaleImageTo:2.0];
            break;
        case 400:
            [self scaleImageTo:4.0];
            break;
        default:
            NSLog(@"unexpected case in scale menu selection");
            break;
    }
}

- (void)scalePanelOk:(id)sender
{
    float percent;

    percent = [scalePanelScaleField floatValue];
    [scalePanel performClose:nil];
    [self scaleImageTo:percent/100.0];
}

- (void)scalePanelCancel:(id)sender
{
    [scalePanel performClose:nil];
}


/* stores the given value as a scale factor */
- (void)scaleImageTo:(float)internal_scale
{
    if (internal_scale > 0)
        scale = internal_scale;
    [self scaleImage];
}

/* scales the image by the current scale factor */
- (void)scaleImage
{
    [view scaleFrameBy:scale];
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
  imgSize = [[[self document] activeImage] pixelSize];
  switch (tag)
  {
    case -3:
      vscale = currViewSize.height / imgSize.height;
      hscale = currViewSize.width / imgSize.width;
      if (hscale > vscale)
        [self scaleImageTo:vscale];
      else
        [self scaleImageTo:hscale];
      break;
    case -2:
      hscale = currViewSize.width / imgSize.width;
      NSLog(@"%f %f", currViewSize.width, imgSize.width);
      [self scaleImageTo:hscale];
      break;
    case -1:
      vscale = currViewSize.height / imgSize.height;
      NSLog(@"%f %f", currViewSize.height, imgSize.height);
      [self scaleImageTo:vscale];
      break;
    default:
      break;
  }  
}

- (void)windowDidLoad
/* some initialization stuff */
{
    NSWindow *currWin;
    NSRect   currentWinContentRect;
    NSSize   currentWindowSize;
    NSSize   currViewSize;
    NSSize   currImageSize;
    NSSize   windowToViewBorder;
    NSSize   newWinSize;
    NSSize   minWinSize;
    NSSize   screenFrameSize;
    PRImage  *currImage;
    BOOL     shouldResize;

    shouldResize = NO;
    
    /* views coming froma NIB window need a retain, we need this for the save panel */
    [saveOptionsView retain];
    [fileTypePopUp setTarget: [self document]];
    [fileTypePopUp setAction: @selector(changeSaveType:)];
    
    /* display the data by MyDocument's activeImage method */
    currImage = [[self document] activeImage];
    
    [self setImageToDraw:currImage];
    [self scaleImageTo:1.0];

    /* resize the window accordingly to the image's size */
    screenFrameSize = [[NSScreen mainScreen] visibleFrame].size;
    NSLog(@"current screen size: %f x  %f", screenFrameSize.width, screenFrameSize.height);

    /* get the current window size and limits */
    currWin = [self window];
    currentWinContentRect = [NSWindow contentRectForFrameRect:[currWin frame] styleMask:[currWin styleMask]];
    currentWindowSize = currentWinContentRect.size;
    minWinSize = [currWin minSize];
    NSLog(@"current window size: %f x  %f", currentWindowSize.width, currentWindowSize.height);
    newWinSize = currentWindowSize;

    /* get size of the visible part of the view */
    currViewSize = [[view enclosingScrollView] contentSize];

    /* calculate the difference that makes up the border */
    windowToViewBorder.width = currentWindowSize.width - currViewSize.width;
    windowToViewBorder.height = currentWindowSize.height - currViewSize.height;

    /* get the image size */
    currImageSize = [currImage size];

    /* resize if image is smaller */
    if (currImageSize.width < currViewSize.width)
    {
        float newViewWidth;

        shouldResize = YES;
        if (currImageSize.width > minWinSize.width)
            newViewWidth = currImageSize.width;
        else
            newViewWidth = minWinSize.width;
        newWinSize.width = newViewWidth + windowToViewBorder.width;
    }
    if (currImageSize.height < currViewSize.height)
    {
        float newViewHeight;

        shouldResize = YES;
        if (currImageSize.height > minWinSize.height)
            newViewHeight = currImageSize.height;
        else
            newViewHeight = minWinSize.height;
        newWinSize.height = newViewHeight + windowToViewBorder.height;
    }

    /* resize if image is larger */
    if ([[NSApp delegate] prefEnlargeWindows])
    {
        if (currImageSize.width > currViewSize.width)
        {
            float newViewWidth;

            shouldResize = YES;
            if (currImageSize.width < screenFrameSize.width)
                newViewWidth = currImageSize.width;
            else
                newViewWidth = screenFrameSize.width - currentWinContentRect.origin.x - windowToViewBorder.width;
            newWinSize.width = newViewWidth + windowToViewBorder.width;
        }
        if (currImageSize.height > currViewSize.height)
        {
            float newViewHeight;

            shouldResize = YES;
            if (currImageSize.height < screenFrameSize.height)
                newViewHeight = currImageSize.height;
            else
                newViewHeight = screenFrameSize.height - windowToViewBorder.height;
            newWinSize.height = newViewHeight + windowToViewBorder.height;
        }
    }

    if (shouldResize)
    {
        [currWin setContentSize:newWinSize];
    }
    
    /* add an observer for the window resize */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResize:) name:NSWindowDidResizeNotification object:currWin];
}

/* view accessor */
- (PRImageView *)view
{
    return view;
}


- (void)setImageToDraw:(PRImage *)image
{    
    [view setImage:image];
    [self setImageInfo:image];
}

- (void)setImageInfo:(PRImage *)image
{   
    [imageInfoLine setStringValue: [NSString stringWithFormat:
                                               @"%ld x %ld, %ldx%ld bpp",
                                             (long int)[image width],
                                             (long int)[image height],
                                             (long int)[image bitsPerSample],
                                             (long int)[image samplesPerPixel]
        ]];
}

/** Sets the FileType popup content*/
- (void)setWritableFileTypes:(NSArray *)types
{
  NSString *type, *title;
  unsigned i;
  unsigned count = [types count];

  [fileTypePopUp removeAllItems];
  for (i = 0; i < count; i++)
    {
      type = [types objectAtIndex: i];
      title = [[NSDocumentController sharedDocumentController] displayNameForType: type];
      [fileTypePopUp addItemWithTitle: title];
      [[fileTypePopUp itemAtIndex: i] setRepresentedObject: type];
    }
}


/* ===== delegates =====*/

- (BOOL) prepareSavePanel:(NSSavePanel *) panel
{
  [panel setAccessoryView:saveOptionsView];

  return YES;
}

- (void)changeSaveType:(id)sender
{
  NSLog(@"changeSaveType type:%@", [[sender selectedItem] representedObject]); 
  [self setCompressionType:[[sender selectedItem] representedObject]];
}

/* save panel delegates */
/** change the file type */
- (void)setCompressionType:(NSString *)type
{
  NSString *title;

  title = [[NSDocumentController sharedDocumentController] displayNameForType: type];

  if ([fileTypePopUp itemWithTitle:title] == nil)
    {
      NSLog(@"%@ type not found, defaulting to TIFF", type);
      type = @"TIFF";
      title = [[NSDocumentController sharedDocumentController] displayNameForType: type];
    }
  [fileTypePopUp selectItemWithTitle: title];

  if ([type isEqualToString:@"TIFF"])
    {
      NSLog(@"set type to Tiff");
      [jpegCompressionSlider setEnabled:NO];
      [jpegCompressionField setEnabled:NO];
    }
  else if ([type isEqualToString:@"JPEG"])
    {
      NSLog(@"set type to Jpeg");
      [jpegCompressionSlider setEnabled:YES];
      [jpegCompressionField setEnabled:YES];
      /* simulate click to make interface consistent */
      [jpegCompressionSlider performClick:nil];
    }
}

/** keep the slider and the text view of the compression level in sync */
- (IBAction)setCompressionLevel:(id)sender
{
  if (sender == jpegCompressionField)
    [jpegCompressionSlider takeFloatValueFrom:sender];
  else
    [jpegCompressionField takeFloatValueFrom:sender];
  compressionLevel = [sender floatValue] / 100;
}

- (float)compressionLevel
{
  return compressionLevel;
}


@end
