/*
copyright 2002, 2003 Alexander Malmberg <alexander@malmberg.org>

2009-2010 GAP Project

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#import <Foundation/NSBundle.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>
#import <AppKit/NSBox.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSMatrix.h>
#import <AppKit/NSTextField.h>
#import <GNUstepGUI/GSTable.h>
#import <GNUstepGUI/GSVbox.h>
#import "Label.h"

#include "TerminalWindowPrefs.h"


static NSUserDefaults *ud;


static NSString
	*WindowCloseBehaviorKey=@"WindowCloseBehavior",
	*WindowHeightKey=@"WindowHeight",
	*WindowWidthKey=@"WindowWidth",
	*AddYBordersKey=@"AddYBorders";


static int windowCloseBehavior;
static int windowWidth,windowHeight;
static BOOL addYBorders;


@implementation TerminalWindowPrefs

+(void) initialize
{
	if (!ud)
	{
		ud=[NSUserDefaults standardUserDefaults];

		windowCloseBehavior=[ud integerForKey: WindowCloseBehaviorKey];
		windowWidth=[ud integerForKey: WindowWidthKey];
		windowHeight=[ud integerForKey: WindowHeightKey];
		addYBorders=[ud boolForKey: AddYBordersKey];

		if (windowWidth<=0)
			windowWidth=80;
		if (windowHeight<=0)
			windowHeight=25;
	}
}

+(int) windowCloseBehavior
{
	return windowCloseBehavior;
}

+(int) defaultWindowWidth
{
	return windowWidth;
}
+(int) defaultWindowHeight
{
	return windowHeight;
}

+(BOOL) addYBorders
{
	return addYBorders;
}


-(void) save
{
	if (!top) return;

	windowCloseBehavior=[[m_close selectedCell] tag];
	[ud setInteger: windowCloseBehavior  forKey: WindowCloseBehaviorKey];

	addYBorders=[b_addYBorders state];
	[ud setBool: addYBorders  forKey: AddYBordersKey];

	windowWidth=[tf_width intValue];
	windowHeight=[tf_height intValue];

	if (windowWidth<=0)
		windowWidth=80;
	if (windowHeight<=0)
		windowHeight=25;

	[ud setInteger: windowWidth  forKey: WindowWidthKey];
	[ud setInteger: windowHeight  forKey: WindowHeightKey];
}

-(void) revert
{
	[m_close selectCellWithTag: windowCloseBehavior];

	[tf_width setIntValue: windowWidth];
	[tf_height setIntValue: windowHeight];

	[b_addYBorders setState: addYBorders];
}


-(NSString *) name
{
	return _(@"Terminal Window");
}

-(void) setupButton: (NSButton *)b
{
	[b setTitle: _(@"Terminal\nWindow")];
	[b sizeToFit];
}

-(void) willHide
{
}

-(NSView *) willShow
{
	if (!top)
	{
		top=[[GSVbox alloc] init];
		[top setDefaultMinYMargin: 1];

		{
			NSTextField *f;

			{
				NSMatrix *m;
				NSButtonCell *b=[NSButtonCell new];
				NSSize s,s2;

				[b setButtonType: NSRadioButton];

				m=m_close=[[NSMatrix alloc] initWithFrame: NSMakeRect(0,0,1,1)
					mode: NSRadioModeMatrix
					prototype: b
					numberOfRows: 2
					numberOfColumns: 1];
				[m setAutoresizingMask: NSViewMinXMargin|NSViewMaxXMargin|
					NSViewMinYMargin|NSViewMaxYMargin];

				[[m cellAtRow: 0 column: 0] setTitle: _(@"Close new windows when idle")];
				[[m cellAtRow: 1 column: 0] setTitle: _(@"Don't close new windows")];
				[[m cellAtRow: 0 column: 0] setTag: 0];
				[[m cellAtRow: 1 column: 0] setTag: 1];

				s=[[m cellAtRow: 0 column: 0] cellSize];
				s2=[[m cellAtRow: 0 column: 0] cellSize];
				if (s2.width>s.width) s.width=s2.width;
				
				[m setCellSize: s];
				[m setIntercellSpacing: NSMakeSize(0,3)];
				[m sizeToCells];

				[top addView: m enablingYResizing: YES];
				DESTROY(m);
			}

			{
				NSBox *b;
				GSTable *t;

				b=[[NSBox alloc] init];
				[b setAutoresizingMask:
					NSViewWidthSizable|NSViewMinYMargin|NSViewMaxYMargin];
				[b setTitle: _(@"Default size")];

				t=[[GSTable alloc] initWithNumberOfRows: 2 numberOfColumns: 2];

				f=[NSTextField newLabel: _(@"Width:")];
				[f setAutoresizingMask: NSViewMinXMargin|NSViewMinYMargin|NSViewMaxYMargin];
				[t putView: f atRow: 1 column: 0
					withXMargins: 2 yMargins: 2];
				tf_width=f=[[NSTextField alloc] init];
				[f setAutoresizingMask: NSViewWidthSizable];
				[f sizeToFit];
				[t putView: f atRow: 1 column: 1];
				[f release];

				f=[NSTextField newLabel: _(@"Height:")];
				[f setAutoresizingMask: NSViewMinXMargin|NSViewMinYMargin|NSViewMaxYMargin];
				[t putView: f atRow: 0 column: 0
					withXMargins: 2 yMargins: 2];
				tf_height=f=[[NSTextField alloc] init];
				[f setAutoresizingMask: NSViewWidthSizable];
				[f sizeToFit];
				[t putView: f atRow: 0 column: 1];
				[f release];

				[b setContentView: t];
				[b sizeToFit];
				DESTROY(t);

				[top addView: b enablingYResizing: YES];
				DESTROY(b);
			}

			{
				NSButton *b;

				b=b_addYBorders=[[NSButton alloc] init];
				[b setAutoresizingMask: NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
				[b setButtonType: NSSwitchButton];
				[b setTitle: _(@"Add top and bottom border")];
				[b sizeToFit];
				[top addView: b enablingYResizing: YES];
			}
		}

		[self revert];
	}
	return top;
}

-(void) dealloc
{
	DESTROY(top);
	[super dealloc];
}

@end

