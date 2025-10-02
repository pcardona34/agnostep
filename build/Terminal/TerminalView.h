/* -*- mode: objc -*-

Copyright (c) 2002 Alexander Malmberg <alexander@malmberg.org>
Copyright (c) 2017 Riccardo Mottola <rm@gnu.org>


This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#ifndef TerminalView_h
#define TerminalView_h

#import <AppKit/NSView.h>


extern NSString
	*TerminalViewBecameIdleNotification,
	*TerminalViewBecameNonIdleNotification,

	*TerminalViewTitleDidChangeNotification;


#include "Terminal.h"

/* TODO: this is slightly ugly */
@class TerminalParser_Linux;


@class NSScroller;

struct selection_range
{
	int location,length;
};

@interface TerminalView : NSView
{
	NSScroller *scroller;

	NSFont *font,*boldFont;
	CGFloat fx,fy;
	CGFloat fontBoundDiffY;

	BOOL use_multi_cell_glyphs;
	BOOL blackOnWhite;

	struct
	{
		int x0,y0,x1,y1;
	} dirty;

	int master_fd;

	unsigned char *write_buf;
	int write_buf_len,write_buf_size;

	int max_scrollback;
	int sb_length,current_scroll;
	screen_char_t *sbuf;

	int sx,sy;
	screen_char_t *screen;

	int cursor_x,cursor_y;
	int current_x,current_y;

	NSString *title_window,*title_miniwindow,*title_filename;

	NSObject<TerminalParser> *tp;

	int draw_all; /* 0=only lazy, 1=don't know, do all, 2=do all */
	BOOL draw_cursor;

	struct selection_range selection;

	/* scrolling by compositing takes a long while, so we break out of such
	loops fairly often to process other events */
	int num_scrolls;

	/* To avoid doing lots of scrolling compositing, we combine multiple
	full-screen scrolls. pending_scroll is the combined pending line delta */
	int pending_scroll;

	BOOL ignore_resize;

	CGFloat border_x,border_y;
}

-(void) setIgnoreResize: (BOOL)ignore;

-(void) setBorder: (CGFloat)x : (CGFloat)y;

-(NSString *) windowTitle;
-(NSString *) miniwindowTitle;
-(NSString *) representedFilename;

+(NSSize) characterCellSize;

+(void) registerPasteboardTypes;

@end

@interface TerminalView (display) <TerminalScreen>
-(void) setNeedsLazyDisplayInRect: (NSRect)r;
@end

/* TODO: this is ugly */
@interface TerminalView (scrolling_2)
-(void) setScroller: (NSScroller *)sc;
@end

@interface TerminalView (input_2)
-(void) closeProgram;
-(void) runShell;
-(void) runProgram: (NSString *)path
	withArguments: (NSArray *)args
	initialInput: (NSString *)d;
-(void) runProgram: (NSString *)path
	withArguments: (NSArray *)args
	inDirectory: (NSString *)directory
	initialInput: (NSString *)d
	arg0: (NSString *)arg0;
@end



#endif

