/*
Copyright 2002 Alexander Malmberg <alexander@malmberg.org>
          2012 Free Software Foundation, Inc

Authros: Alexander Malmberg
         Riccardo Mottola

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#import <AppKit/NSWindowController.h>

#import "PrefBox.h"

@class GSHbox,NSBox;

@interface PreferencesWindowController : NSWindowController
{
	GSHbox *button_box;
	NSBox *pref_box;

	NSObject<PrefBox> *current;

	NSMutableArray *pref_boxes;
	NSMutableArray *pref_buttons;
}

-(void) addPrefBox: (NSObject<PrefBox> *)pb;

@end


