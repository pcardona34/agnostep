/*
copyright 2002, 2003 Alexander Malmberg <alexander@malmberg.org>
          2009-2011 GNUstep Application Project (Riccardo Mottola)

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#ifndef TerminalViewPrefs_h
#define TerminalViewPrefs_h

#import "PrefBox.h"


@class NSString,NSFont,NSColor;
@class GSVbox,NSTextField,NSColorWell,NSMatrix;

extern NSString *TerminalViewDisplayPrefsDidChangeNotification;

@interface TerminalViewDisplayPrefs : NSObject <PrefBox>
{
	GSVbox *top;
	NSTextField *f_terminalFont,*f_boldTerminalFont;
	NSColorWell *w_cursorColor;
	NSMatrix *m_cursorStyle;
	NSTextField *f_scrollBackLines;
	NSButton *b_useMultiCellGlyphs;
	NSButton *b_blackOnWhite;

	NSTextField *f_cur;
}

+(NSFont *) terminalFont;
+(NSFont *) boldTerminalFont;

+(BOOL) useMultiCellGlyphs;
+(BOOL) blackOnWhite;

+(const float *) brightnessForIntensities;
+(const float *) saturationForIntensities;

#define CURSOR_LINE          0
#define CURSOR_BLOCK_STROKE  1
#define CURSOR_BLOCK_FILL    2
#define CURSOR_BLOCK_INVERT  3
+(int) cursorStyle;
+(NSColor *) cursorColor;

+(int) scrollBackLines;

@end


@interface TerminalViewShellPrefs : NSObject <PrefBox>
{
	GSVbox *top;

	NSTextField *tf_shell;
	NSButton *b_loginShell;
}

+(NSString *) shell;
+(BOOL) loginShell;

@end


@interface TerminalViewKeyboardPrefs : NSObject <PrefBox>
{
	GSVbox *top;

	NSButton *b_commandAsMeta;
	NSButton *b_doubleEscape;
	NSButton *b_altIsNotMeta;
}

+(BOOL) commandAsMeta;
+(BOOL) altIsNotMeta;
+(BOOL) doubleEscape;

@end

#endif

