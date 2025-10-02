/*
copyright 2002 Alexander Malmberg <alexander@malmberg.org>

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#ifndef TerminalParser_LinuxPrefs_h
#define TerminalParser_LinuxPrefs_h

#import "PrefBox.h"


@class GSVbox,NSPopUpButton;

extern NSString *TerminalParser_LinuxPrefsDidChangeNotification;

@interface TerminalParser_LinuxPrefs : NSObject <PrefBox>
{
	GSVbox *top;
	NSPopUpButton *pb_characterSet;
}

+(const char *) characterSet;

@end

#endif
