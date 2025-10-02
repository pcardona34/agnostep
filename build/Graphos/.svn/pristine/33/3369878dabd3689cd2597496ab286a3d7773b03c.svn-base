/*
 Project: Graphos
 GRPropsEditor.h

 Copyright (C) 2000-2018 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#ifndef MAC_OS_X_VERSION_10_4
#define MAC_OS_X_VERSION_10_4 1040
#endif

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4) && !defined(CGFloat)
#define NSInteger int
#define NSUInteger unsigned
#define CGFloat float
#endif

@class GRDocView;

/**
 * Object properties editor
 */


@interface GRPropsEditor : NSObject
{
  IBOutlet NSPanel *propsPanel;

  IBOutlet NSButton *stkButt;
  IBOutlet NSButton *fllButt;

  IBOutlet NSMatrix *lineCapMatrix;
  IBOutlet NSMatrix *lineJoinMatrix;

  IBOutlet NSTextField *linewidthField;
  IBOutlet NSTextField *flatnessField;
  IBOutlet NSTextField *miterlimitField;
  IBOutlet NSStepper *linewidthStepper;
  IBOutlet NSStepper *flatnessStepper;
  IBOutlet NSStepper *miterlimitStepper;

  IBOutlet NSColorWell *strokeColorWell;
  IBOutlet NSColorWell *fillColorWell;

  BOOL ispath;
  CGFloat flatness, miterlimit, linewidth;
  int linejoin, linecap;
  BOOL stroked;
  NSColor *strokeColor;
  BOOL filled;
  NSColor *fillColor;
  
  GRDocView *docView;
}

- (void)setControlsEnabled:(BOOL)state;

/** reads the selection properties from the current view */
- (void)readProperties;

/** sets the view which contains the objects.
  The view needs to needs to be set so that the selection properties
  can be read or applied. */
- (void)setDocView: (GRDocView *)view;

- (void)makeKeyAndOrderFront:(id)sender;

- (void)selectionChanged: (NSNotification *)notif;

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;

- (IBAction)stepperAction:(id)sender;

- (IBAction)setLnCap:(id)sender;

- (IBAction)setLnJoin:(id)sender;

- (IBAction)fllButtPressed:(id)sender;

- (IBAction)stkButtPressed:(id)sender;

- (IBAction)valuesChanged:(id)sender;

- (NSDictionary *)properties;

@end
