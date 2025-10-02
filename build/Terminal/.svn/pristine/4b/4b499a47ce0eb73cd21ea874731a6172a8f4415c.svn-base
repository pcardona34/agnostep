/*
Copyright 2002, 2003 Alexander Malmberg <alexander@malmberg.org>
Copyright 2009-2012 Free Software Foundation Inc.

Authors: Alexander Malmberg
         Riccardo Mottola

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#import <Foundation/NSObject.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSBundle.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSClipView.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSBox.h>
#import <GNUstepGUI/GSHbox.h>
#import <GNUstepGUI/GSVbox.h>

#import "autokeyviewchain.h"
#import "PreferencesWindowController.h"
#import "PrefBox.h"


/*
Changing the font in TerminalViewPrefs won't work unless the panel can be
the main window (the font panel gets confused about where to send the
-changeFont:), hence this class. When per-window preferences are done, this
won't be necessary.
*/
@interface PreferencesPanel : NSPanel
@end

@implementation PreferencesPanel
-(BOOL) canBecomeMainWindow
{
	return YES;
}
@end


@implementation PreferencesWindowController

-(void) save: (id)sender
{
	[pref_boxes makeObjectsPerformSelector: @selector(save)];
}

-(void) revert: (id)sender
{
	[pref_boxes makeObjectsPerformSelector: @selector(revert)];
}


- init
{
	NSWindow *win;

	win=[[PreferencesPanel alloc] initWithContentRect: NSMakeRect(100,100,290,400)
		styleMask: NSClosableWindowMask|NSTitledWindowMask|NSResizableWindowMask|NSMiniaturizableWindowMask
		backing: NSBackingStoreRetained
		defer: YES];
	if (!(self=[super initWithWindow: win])) return nil;

	{
		GSVbox *vbox;

		vbox=[[GSVbox alloc] init];
		[vbox setBorder: 4];
		[vbox setDefaultMinYMargin: 4];

		{
			NSButton *b;
			GSHbox *hbox;

			hbox=[[GSHbox alloc] init];
			[hbox setDefaultMinXMargin: 4];
			[hbox setAutoresizingMask: NSViewMinXMargin];

			b=[[NSButton alloc] init];
			[b setTitle: _(@"Revert")];
			[b setTarget: self];
			[b setAction: @selector(revert:)];
			[b sizeToFit];
			[hbox addView: b];
			[b release];

			b=[[NSButton alloc] init];
			[b setTitle: _(@"Apply and save")];
			[b setKeyEquivalent: @"\r"];
			[b setTarget: self];
			[b setAction: @selector(save:)];
			[b sizeToFit];
			[hbox addView: b];
			[b release];

			[vbox addView: hbox  enablingYResizing: NO];
			[hbox release];
		}

		{
			pref_box=[[NSBox alloc] initWithFrame: NSMakeRect(0,0,1,1)];
			[pref_box setTitle: @"<invalid>"];
			[pref_box setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
			[pref_box setAutoresizesSubviews: YES];
			[vbox addView: pref_box  enablingYResizing: YES];
		}

		{
			NSScrollView *sv;
			NSSize s;

			button_box=[[GSHbox alloc] init];

			s=[NSScrollView frameSizeForContentSize: NSMakeSize(1,68)
				hasHorizontalScroller: YES
				hasVerticalScroller: YES
				borderType: NSNoBorder]; /* TODO? */

			sv=[[NSScrollView alloc] initWithFrame: NSMakeRect(0,0,1,s.height)];
			[sv setDocumentView: button_box];
			[sv setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
			[sv setHasHorizontalScroller: YES];
			[sv setBorderType: NSBezelBorder];

			[vbox addView: sv  enablingYResizing: NO];
			DESTROY(sv);
		}

		[win setContentView: vbox];
		[vbox release];
	}
	[win setDelegate: self];
	[win setTitle: _(@"Preferences")];

	[win setMinSize: NSMakeSize(410,430)];
	[win setFrameUsingName: @"Preferences"];
	[win setFrameAutosaveName: @"Preferences"];

	[win autoSetupKeyViewChain];

	[win release];

	pref_boxes=[[NSMutableArray alloc] init];
	pref_buttons=[[NSMutableArray alloc] init];

	return self;
}

-(void) dealloc
{
	if (current)
	{
		[current willHide];
		current=nil;
	}

	DESTROY(pref_boxes);
	DESTROY(pref_buttons);
	DESTROY(button_box);
	[super dealloc];
}


-(void) _displayBox: (NSObject<PrefBox> *)pb
{
  NSUInteger idx;

  idx = [pref_boxes indexOfObjectIdenticalTo: pb];
  if (idx==NSNotFound)
    return;

  if (current==pb)
    return;

	if (current)
	{
		[[pref_buttons objectAtIndex: [pref_boxes indexOfObjectIdenticalTo: current]] setState: 0];
		[current willHide];
		current=nil;
	}

	[[pref_buttons objectAtIndex: idx] setState: 1];
	[pref_box setTitle: [pb name]];
	[pref_box setContentView: [pb willShow]];
	current=pb;

	[[self window] autoSetupKeyViewChain];
}


-(void) _displayBoxButton: (id)sender
{
  NSUInteger idx;

  idx = [pref_buttons indexOfObjectIdenticalTo: sender];
  if (idx==NSNotFound)
    return;

  if ([pref_boxes objectAtIndex: idx]==current)
    {
      [sender setState: 1];
      return;
    }

  [self _displayBox: [pref_boxes objectAtIndex: idx]];
}

-(void) addPrefBox: (NSObject<PrefBox> *)pb
{
	NSButton *b=[[NSButton alloc] init];

	[pref_boxes addObject: pb];
	[pref_buttons addObject: b];

	[pb setupButton: b];
	if ([b frame].size.height<=64)
		[b setFrame: NSMakeRect(0,0,[b frame].size.width,64)];
	[b setTarget: self];
	[b setAction: @selector(_displayBoxButton:)];
	[b setButtonType: NSPushOnPushOffButton];
	[button_box addView: b];
	[b release];
	[button_box sizeToFit];

	if (!current)
		[self _displayBox: pb];
	else
		[[self window] autoSetupKeyViewChain];
}


/* well, it works */
-(BOOL) respondsToSelector: (SEL)s
{
	if ([super respondsToSelector: s])
		return YES;

	if (current)
		return [current respondsToSelector: s];
	return NO;
}

-(void) forwardInvocation: (NSInvocation *)i
{
	if (current)
		if ([current respondsToSelector: [i selector]])
		{
			[i invokeWithTarget: current];
			return;
		}
	[super forwardInvocation: i];
}

-(NSMethodSignature *) methodSignatureForSelector: (SEL)sel
{
	return [super methodSignatureForSelector: sel];
}

@end

