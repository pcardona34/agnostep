/*
  Copyright 2002, 2003 Alexander Malmberg <alexander@malmberg.org>
            2016-2020  Riccardo Mottola
            2016 Tim Sheridan

  This file is a part of Terminal.app. Terminal.app is free software; you
  can redistribute it and/or modify it under the terms of the GNU General
  Public License as published by the Free Software Foundation; version 2
  of the License. See COPYING or main.m for more information.
*/

#ifndef TerminalWindow_h
#define TerminalWindow_h

@class TerminalView;

#import <AppKit/NSWindowController.h>
#import <AppKit/NSTabView.h>

extern NSString *TerminalWindowNoMoreActiveWindowsNotification;

@interface TerminalWindowController : NSWindowController
{
	NSMutableArray *terminal_views;
	NSTabView *tab_view;
        BOOL isShowingTabs;
	BOOL close_on_idle;
}

+(TerminalWindowController *) newTerminalWindow;
+(TerminalWindowController *) idleTerminalWindow;

+(int) numberOfActiveWindows;
+(void) checkActiveWindows;

- init;

-(TerminalView *) frontTerminalView;

-(void) setShouldCloseWhenIdle: (BOOL)should_close;

-(BOOL) showTabBar;
-(void) setShowTabBar:(BOOL)visible inWindow:(NSWindow *)window;

-(void) newTerminalTabInWindow:(NSWindow *)window;
-(void) closeTerminalTab:(TerminalView *)tv inWindow:(NSWindow *)window;

-(void) showPreviousTab;
-(void) showNextTab;

-(void) moveTabLeft;
-(void) moveTabRight;

@end

#endif

