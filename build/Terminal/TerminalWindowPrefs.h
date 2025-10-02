/*
copyright 2002 Alexander Malmberg <alexander@malmberg.org>

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#ifndef TerminalWindowPrefs_h
#define TerminalWindowPrefs_h

#include "PrefBox.h"


@class GSVbox,NSTextField,NSButton,NSMatrix;

@interface TerminalWindowPrefs : NSObject <PrefBox>
{
	GSVbox *top;

	NSMatrix *m_close;
	NSTextField *tf_width,*tf_height;
	NSButton *b_addYBorders;
}

+(int) windowCloseBehavior;

+(int) defaultWindowWidth;
+(int) defaultWindowHeight;

+(BOOL) addYBorders;

@end


#endif
