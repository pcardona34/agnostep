/*
  Copyright 2002, 2003 Alexander Malmberg <alexander@malmberg.org>
            2016 Riccardo Mottola
            2016 Tim Sheridan

  This file is a part of Terminal.app. Terminal.app is free software; you
  can redistribute it and/or modify it under the terms of the GNU General
  Public License as published by the Free Software Foundation; version 2
  of the License. See COPYING or main.m for more information.
*/

#include <math.h>
#include <sys/wait.h>

#import <Foundation/NSBundle.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSScroller.h>
#import <AppKit/NSTabViewItem.h>
#import <AppKit/NSWindow.h>
#import <GNUstepGUI/GSHbox.h>

#import "TerminalWindow.h"

#import "TerminalWindowPrefs.h"
#import "TerminalView.h"


/* TODO: this needs cleaning up. chances are this will interfere
with NSTask */
static void get_zombies(void)
{
	int status,pid;
	while ((pid=waitpid(-1,&status,WNOHANG))>0)
	{
//		printf("got %i\n",pid);
	}
}


static int num_instances;


NSString *TerminalWindowNoMoreActiveWindowsNotification=
	@"TerminalWindowNoMoreActiveWindowsNotification";


@implementation TerminalWindowController

- init
{
  if ((self = [super init]))
    {
	NSWindow *win;
	NSScroller *scroller;
	GSHbox *hb;
	CGFloat fx,fy;
	CGFloat scroller_width;
	NSRect contentRect,windowRect;
	NSSize contentSize,minSize;
        NSTabViewItem *tab_item;
        TerminalView *tv;
	int sx,sy;

        isShowingTabs = NO;
        if ([self showTabBar])
          isShowingTabs = YES;

	{
		NSSize size=[TerminalView characterCellSize];
		fx=size.width;
		fy=size.height;
	}

	sx=[TerminalWindowPrefs defaultWindowWidth];
	sy=[TerminalWindowPrefs defaultWindowHeight];

	scroller_width=[NSScroller scrollerWidth];

	// calc the rects for our window
	contentSize = NSMakeSize (fx * sx + scroller_width + 1, fy * sy + 1);
	minSize = NSMakeSize (fx * 20 + scroller_width + 1, fy * 4 + 1);

	// add the borders to the size
	contentSize.width += 8;
	minSize.width += 8;
	if ([TerminalWindowPrefs addYBorders])
	{
		contentSize.height += 8;
		minSize.height += 8;
	}

	contentRect = NSMakeRect (100, 100, contentSize.width, contentSize.height);

	win=[[NSWindow alloc] initWithContentRect: contentRect
		styleMask: NSClosableWindowMask|NSTitledWindowMask|NSResizableWindowMask|NSMiniaturizableWindowMask
		backing: NSBackingStoreRetained
		defer: YES];
	if (!(self=[super initWithWindow: win])) return nil;

	num_instances++;

	windowRect = [win frame];
	minSize.width += windowRect.size.width - contentSize.width;
	minSize.height += windowRect.size.height - contentSize.height;

	[win setTitle: @"Terminal"];
	[win setDelegate: self];

	[win setContentSize: contentSize];
	[win setResizeIncrements: NSMakeSize (fx , fy)];
	[win setMinSize: minSize];

	hb=[[GSHbox alloc] init];

	scroller=[[NSScroller alloc] initWithFrame: NSMakeRect(0,0,[NSScroller scrollerWidth],fy)];
	[scroller setArrowsPosition: NSScrollerArrowsMaxEnd];
	[scroller setEnabled: YES];
	[scroller setAutoresizingMask: NSViewHeightSizable];
	[hb addView: scroller  enablingXResizing: NO];
	[scroller release];

	tab_view = [[NSTabView alloc] init];
	[tab_view setDelegate:self];
	tab_item = [[NSTabViewItem alloc] init];
	[tab_item setLabel:@"Terminal"];
        if (isShowingTabs)
          [tab_item setView:hb];
	[tab_view addTabViewItem:tab_item];
        [tab_item release];
        
	tv = [[TerminalView alloc] init];
	[tv setIgnoreResize: YES];
	[tv setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];
	[tv setScroller: scroller];
	[hb addView: tv];
	[tv release];
	[win makeFirstResponder: tv];
	[tv setIgnoreResize: NO];

	terminal_views = [[NSMutableArray alloc] init];
	[terminal_views addObject:tv];

	if ([TerminalWindowPrefs addYBorders])
		[tv setBorder: 4 : 4];
	else
		[tv setBorder: 4 : 0];

        if (isShowingTabs)
          {
            [win setContentView: tab_view];
          }
        else
          {
            [win setContentView: hb];
          }
	DESTROY(hb);


	[win release];

	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(_becameIdle:)
		name: TerminalViewBecameIdleNotification
		object: tv];
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(_becameNonIdle:)
		name: TerminalViewBecameNonIdleNotification
		object: tv];
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(_updateTitle:)
		name: TerminalViewTitleDidChangeNotification
		object: tv];

    }
  return self;
}


-(void) _updateTitleFromTerminalView: (TerminalView *)tv
{
  NSUInteger index;
  
  index = [terminal_views indexOfObjectIdenticalTo:tv];
  if (index == NSNotFound)
    {
      NSLog(@"updateTitle view not found: %@ %@", [tv windowTitle], [tv representedFilename]);
      NSLog(@"view is: %@, views are: %@", tv, terminal_views);
      return;
    }
	[[tab_view tabViewItemAtIndex:index] setLabel:[tv windowTitle]];
	[tab_view display];

	if (tv == [self frontTerminalView]) {
		[[self window] setTitle: [tv windowTitle]];
		[[self window] setMiniwindowTitle: [tv miniwindowTitle]];
		[[self window] setRepresentedFilename: [tv representedFilename]];
	}
}

-(void) _updateTitle: (NSNotification *)n
{
	TerminalView *tv = [n object];
	[self _updateTitleFromTerminalView:tv];
}


-(void) dealloc
{
	num_instances--;
	[TerminalWindowController checkActiveWindows];
	[[NSNotificationCenter defaultCenter]
		removeObserver: self];
        [terminal_views release];
        [tab_view release];
	[super dealloc];
}


static NSMutableArray *idle_list;

-(void) windowWillClose: (NSNotification *)n
{
	get_zombies();
	[idle_list removeObject: self];
	[self autorelease];
}

-(void) _becameIdle: (NSNotification *)n
{
	NSDebugLLog(@"idle",@"%@ _becameIdle",self);

	if (close_on_idle)
	{
		TerminalView *tv = [n object];
		[self closeTerminalTab:tv inWindow:[self window]];
		return;
	}

	[idle_list addObject: self];
	NSDebugLLog(@"idle",@"idle list: %@",idle_list);

	{
		NSString *t;

		t=[[self window] title];
		t=[t stringByAppendingString: _(@" (idle)")];
		[[self window] setTitle: t];

		t=[[self window] miniwindowTitle];
		t=[t stringByAppendingString: _(@" (idle)")];
		[[self window] setMiniwindowTitle: t];
	}

	[TerminalWindowController checkActiveWindows];
}

-(void) _becameNonIdle: (NSNotification *)n
{
	NSDebugLLog(@"idle",@"%@ _becameNonIdle",self);
	[idle_list removeObject: self];
	NSDebugLLog(@"idle",@"idle list: %@",idle_list);
}


-(TerminalView *) frontTerminalView
{
	NSTabViewItem *item = [tab_view selectedTabViewItem];
	NSInteger index = [tab_view indexOfTabViewItem:item];
	return [terminal_views objectAtIndex:index];
}

-(void) setShouldCloseWhenIdle: (BOOL)should
{
	close_on_idle=should;
}


+(void) initialize
{
	if (!idle_list)
		idle_list=[[NSMutableArray alloc] init];
}


+(TerminalWindowController *) newTerminalWindow
{
	TerminalWindowController *twc;

	twc=[[self alloc] init];
	if ([TerminalWindowPrefs windowCloseBehavior]==0)
		[twc setShouldCloseWhenIdle: YES];
	[twc showWindow: self];
	return twc;
}

+(TerminalWindowController *) idleTerminalWindow
{
	TerminalWindowController *new;

	NSDebugLLog(@"idle",@"get idle window from idle list: %@",idle_list);
	if ([idle_list count])
		return [idle_list objectAtIndex: 0];
	new=[[self alloc] init];
	[new showWindow: self];
	return new;
}

+(int) numberOfActiveWindows
{
	return num_instances-[idle_list count];
}

+(void) checkActiveWindows
{
	if (![self numberOfActiveWindows])
	{
		[[NSNotificationCenter defaultCenter]
			postNotificationName: TerminalWindowNoMoreActiveWindowsNotification
			object: self];
	}
}

-(BOOL) showTabBar
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"ShowTabBar"];
}

-(void) setShowTabBar:(BOOL)visible inWindow:(NSWindow *)window
{
	// TODO more explicit default value
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:visible forKey:@"ShowTabBar"];
	[defaults synchronize];

	if ([tab_view numberOfTabViewItems] == 1) {
		if (visible) {
                  NSView *view;

                  view = [window contentView];
                  [view retain];
                  [window setContentView:tab_view];
                  [[tab_view tabViewItemAtIndex:0] setView:view];
                  [tab_view selectFirstTabViewItem:nil];
                  [tab_view display];
                  [view release];
                  isShowingTabs = YES;
		} else {
                  NSView *view = [[tab_view selectedTabViewItem] view];
                  [window setContentView:view];
                  isShowingTabs = NO;
		}
	}
}

-(void) newTerminalTabInWindow:(NSWindow *)window
{
        NSTabViewItem *tab_item;
        TerminalView *tv;
        NSScroller *scroller;
        GSHbox *hb;
	CGFloat fy;

	if (!isShowingTabs)
          {
            NSView *view;

            view = [window contentView];
            [view retain];
            [window setContentView:tab_view];
            [[tab_view tabViewItemAtIndex:0] setView:view];
            [view release];
            isShowingTabs = YES;
          }

	{
		NSSize size=[TerminalView characterCellSize];
		fy=size.height;
	}

	tab_item = [[NSTabViewItem alloc] init];
	[tab_item setLabel:@"Terminal"];
	[tab_view addTabViewItem:tab_item];
        [tab_item release];
        
	hb=[[GSHbox alloc] init];

	scroller=[[NSScroller alloc] initWithFrame: NSMakeRect(0,0,[NSScroller scrollerWidth],fy)];
	[scroller setArrowsPosition: NSScrollerArrowsMaxEnd];
	[scroller setEnabled: YES];
	[scroller setAutoresizingMask: NSViewHeightSizable];
	[hb addView: scroller  enablingXResizing: NO];
	[scroller release];

	tv = [[TerminalView alloc] init];
	[tv setIgnoreResize: YES];
	[tv setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];
	[tv setScroller: scroller];
	[hb addView: tv];
	[tv release];
	[tv setIgnoreResize: NO];

	[terminal_views addObject:tv];

	if ([TerminalWindowPrefs addYBorders])
		[tv setBorder: 4 : 4];
	else
		[tv setBorder: 4 : 0];

	[tab_item setView:hb];
        DESTROY(hb);

	[tab_view selectLastTabViewItem:nil];

	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(_becameIdle:)
		name: TerminalViewBecameIdleNotification
		object: tv];
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(_becameNonIdle:)
		name: TerminalViewBecameNonIdleNotification
		object: tv];
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(_updateTitle:)
		name: TerminalViewTitleDidChangeNotification
		object: tv];
}

-(void) closeTerminalTab:(TerminalView *)tv inWindow:(NSWindow *)window
{
	NSTabViewItem *item;
        NSInteger index;
        NSInteger first_tab_index;
        NSInteger last_tab_index;
        
        if ([tab_view numberOfTabViewItems] == 1) {
		[window performClose:nil];
		return;
	}

	item = [tab_view selectedTabViewItem];
	index = [tab_view indexOfTabViewItem:item];

	// Select new tab before removing old one
	first_tab_index = 0;
	last_tab_index = [tab_view numberOfTabViewItems] - 1;
	// TODO A better tab selection heuristic (e.g. most recently used)
	if (index == first_tab_index) {
		[tab_view selectNextTabViewItem:nil];
	} else if (index == last_tab_index) {
		[tab_view selectPreviousTabViewItem:nil];
	} else {
		[tab_view selectNextTabViewItem:nil];
	}

	[tab_view removeTabViewItem:item];
	[terminal_views removeObjectAtIndex:index];

	if ([tab_view numberOfTabViewItems] == 1)
          {
            NSView *view;

            view = [[tab_view tabViewItemAtIndex:0] view];
            [view retain];
            [window setContentView: view];
            [view release];
            [window makeFirstResponder:[terminal_views objectAtIndex:0]];

		// Follow tab bar visible setting
		[self setShowTabBar:[self showTabBar] inWindow:window];
	}

	[tab_view display];
}

-(void) showPreviousTab
{
	// Clamp
	NSInteger first_tab_index = 0;
	NSTabViewItem *item = [tab_view selectedTabViewItem];
	NSInteger index = [tab_view indexOfTabViewItem:item];
	if (index == first_tab_index) {
		return;
	}

	[tab_view selectPreviousTabViewItem:nil];
}

-(void) showNextTab
{
	// Clamp
	NSInteger last_tab_index = [tab_view numberOfTabViewItems] - 1;
	NSTabViewItem *item = [tab_view selectedTabViewItem];
	NSInteger index = [tab_view indexOfTabViewItem:item];
	if (index == last_tab_index) {
		return;
	}

	[tab_view selectNextTabViewItem:nil];
}

-(void) moveTabLeft
{
	NSTabViewItem *old_item;

        // Clamp
	NSInteger first_tab_index = 0;
	NSTabViewItem *item = [tab_view selectedTabViewItem];
	NSInteger index = [tab_view indexOfTabViewItem:item];
	if (index == first_tab_index) {
		return;
	}

	NSInteger destination_index = index - 1;

	TerminalView *old_tv = [terminal_views objectAtIndex:destination_index];
	TerminalView *new_tv = [terminal_views objectAtIndex:index];
	[terminal_views replaceObjectAtIndex:destination_index withObject:new_tv];
	[terminal_views replaceObjectAtIndex:index             withObject:old_tv];

	old_item = [tab_view tabViewItemAtIndex:destination_index];
        [old_item retain];
	[tab_view removeTabViewItem:old_item];
	[tab_view insertTabViewItem:old_item atIndex:index];
        [old_item release];

	[self _updateTitleFromTerminalView:old_tv];
	[self _updateTitleFromTerminalView:new_tv];

	[tab_view selectTabViewItemAtIndex:destination_index];

	[tab_view display];
}

-(void) moveTabRight
{
	NSTabViewItem *old_item;
        NSInteger destination_index;
        TerminalView *old_tv;
        TerminalView *new_tv;
        
        // Clamp
	NSInteger last_tab_index = [tab_view numberOfTabViewItems] - 1;
	NSTabViewItem *item = [tab_view selectedTabViewItem];
	NSInteger index = [tab_view indexOfTabViewItem:item];
	if (index == last_tab_index) {
		return;
	}

	destination_index = index + 1;

	old_tv = [terminal_views objectAtIndex:destination_index];
	new_tv = [terminal_views objectAtIndex:index];
	[terminal_views replaceObjectAtIndex:destination_index withObject:new_tv];
	[terminal_views replaceObjectAtIndex:index             withObject:old_tv];

	old_item = [tab_view tabViewItemAtIndex:destination_index];
        [old_item retain];
	[tab_view removeTabViewItem:old_item];
	[tab_view insertTabViewItem:old_item atIndex:index];
        [old_item release];

	[self _updateTitleFromTerminalView:old_tv];
	[self _updateTitleFromTerminalView:new_tv];

	[tab_view selectTabViewItemAtIndex:destination_index];

	[tab_view display];
}

- (void) tabView: (NSTabView*)tabView didSelectTabViewItem: (NSTabViewItem*)tabViewItem
{
	NSInteger tab_number = [tabView indexOfTabViewItem:tabViewItem];

	TerminalView *tv = [terminal_views objectAtIndex:tab_number];
	[self _updateTitleFromTerminalView:tv];

	[[self window] makeFirstResponder:[terminal_views objectAtIndex:tab_number]];
	[tv setNeedsDisplay:YES];
}

@end

