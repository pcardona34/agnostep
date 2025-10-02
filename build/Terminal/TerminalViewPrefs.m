/*
copyright 2002, 2003 Alexander Malmberg <alexander@malmberg.org>

2009-2011 GAP Project

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>
#import <AppKit/NSBox.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSColorPanel.h>
#import <AppKit/NSColorWell.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSFontManager.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSButtonCell.h>
#import <AppKit/NSMatrix.h>
#import <GNUstepGUI/GSVbox.h>
#import <GNUstepGUI/GSHbox.h>
#import "Label.h"

#import "TerminalViewPrefs.h"


NSString *TerminalViewDisplayPrefsDidChangeNotification=
	@"TerminalViewDisplayPrefsDidChangeNotification";

static NSUserDefaults *ud;


static NSString
	*TerminalFontKey=@"TerminalFont",
	*TerminalFontSizeKey=@"TerminalFontSize",
	*BoldTerminalFontKey=@"BoldTerminalFont",
	*BoldTerminalFontSizeKey=@"BoldTerminalFontSize",
	*UseMultiCellGlyphsKey=@"UseMultiCellGlyphs",
	*BlackOnWhiteKey=@"BlackOnWhite",
	*CursorStyleKey=@"CursorStyle",
	*ScrollBackLinesKey=@"ScrollBackLines",

	*CursorColorRKey=@"CursorColorR",
	*CursorColorGKey=@"CursorColorG",
	*CursorColorBKey=@"CursorColorB",
	*CursorColorAKey=@"CursorColorA";


static NSFont *terminalFont,*boldTerminalFont;

static BOOL useMultiCellGlyphs;
static BOOL blackOnWhite;

static float brightness[3]={0.6,0.8,1.0};
static float saturation[3]={1.0,1.0,0.75};

static int cursorStyle;
static NSColor *cursorColor;

static int scrollBackLines;


@implementation TerminalViewDisplayPrefs

+(void) initialize
{
	if (!ud)
		ud=[NSUserDefaults standardUserDefaults];

	if (!cursorColor)
	{
		NSString *s;
		float size;


		size=[ud floatForKey: TerminalFontSizeKey];
		s=[ud stringForKey: TerminalFontKey];
		if (!s)
			terminalFont=[[NSFont userFixedPitchFontOfSize: size] retain];
		else
		{
			terminalFont=[[NSFont fontWithName: s  size: size] retain];
			if (!terminalFont)
				terminalFont=[[NSFont userFixedPitchFontOfSize: size] retain];
		}

		size=[ud floatForKey: BoldTerminalFontSizeKey];
		s=[ud stringForKey: BoldTerminalFontKey];
		if (!s)
			boldTerminalFont=[[NSFont userFixedPitchFontOfSize: size] retain];
		else
		{
			boldTerminalFont=[[NSFont fontWithName: s  size: size] retain];
			if (!boldTerminalFont)
				boldTerminalFont=[[NSFont userFixedPitchFontOfSize: size] retain];
		}

		useMultiCellGlyphs=[ud boolForKey: UseMultiCellGlyphsKey];
		blackOnWhite=[ud boolForKey: BlackOnWhiteKey];

		cursorStyle=[ud integerForKey: CursorStyleKey];
		if ([ud objectForKey: CursorColorRKey])
		{
			float r,g,b,a;
			r=[ud floatForKey: CursorColorRKey];
			g=[ud floatForKey: CursorColorGKey];
			b=[ud floatForKey: CursorColorBKey];
			a=[ud floatForKey: CursorColorAKey];
			cursorColor=[[NSColor colorWithCalibratedRed: r
				green: g
				blue: b
				alpha: a] retain];
		}
		else
		{
			cursorColor=[[NSColor whiteColor] retain];
		}

		scrollBackLines=[ud integerForKey: ScrollBackLinesKey];
		if (scrollBackLines<=0)
			scrollBackLines=256;
	}
}

+(NSFont *) terminalFont
{
	NSFont *f=[terminalFont screenFont];
	if (f)
		return f;
	return terminalFont;
}

+(NSFont *) boldTerminalFont
{
	NSFont *f=[boldTerminalFont screenFont];
	if (f)
		return f;
	return boldTerminalFont;
}

+(BOOL) useMultiCellGlyphs
{
	return useMultiCellGlyphs;
}

+(BOOL) blackOnWhite
{
	return blackOnWhite;
}

+(const float *) brightnessForIntensities
{
	return brightness;
}
+(const float *) saturationForIntensities
{
	return saturation;
}

+(int) cursorStyle
{
	return cursorStyle;
}

+(NSColor *) cursorColor
{
	return cursorColor;
}

+(int) scrollBackLines
{
	return scrollBackLines;
}


-(void) save
{
	BOOL	newState;

	if (!top) return;

	newState = !![b_blackOnWhite state];
	if (blackOnWhite != newState)
	  {
	    blackOnWhite = newState;
	    [ud setBool: blackOnWhite
		 forKey: BlackOnWhiteKey];
	    if (blackOnWhite == YES)
	      {
		[w_cursorColor setColor: [NSColor blackColor]];
	      }
	    else
	      {
		[w_cursorColor setColor: [NSColor whiteColor]];
	      }
	    [w_cursorColor setNeedsDisplay];
	  }

	cursorStyle=[[m_cursorStyle selectedCell] tag];
	[ud setInteger: cursorStyle
		forKey: CursorStyleKey];

	{
		DESTROY(cursorColor);
		cursorColor=[w_cursorColor color];
		cursorColor=[[cursorColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
		[ud setFloat: [cursorColor redComponent]
			forKey: CursorColorRKey];
		[ud setFloat: [cursorColor greenComponent]
			forKey: CursorColorGKey];
		[ud setFloat: [cursorColor blueComponent]
			forKey: CursorColorBKey];
		[ud setFloat: [cursorColor alphaComponent]
			forKey: CursorColorAKey];
	}

	ASSIGN(terminalFont,[f_terminalFont font]);
	[ud setFloat: [terminalFont pointSize]
		forKey: TerminalFontSizeKey];
	[ud setObject: [terminalFont fontName]
		forKey: TerminalFontKey];

	ASSIGN(boldTerminalFont,[f_boldTerminalFont font]);
	[ud setFloat: [boldTerminalFont pointSize]
		forKey: BoldTerminalFontSizeKey];
	[ud setObject: [boldTerminalFont fontName]
		forKey: BoldTerminalFontKey];

	scrollBackLines=[f_scrollBackLines intValue];
	[ud setInteger: scrollBackLines
		forKey: ScrollBackLinesKey];

	useMultiCellGlyphs=!![b_useMultiCellGlyphs state];
	[ud setBool: useMultiCellGlyphs
		forKey: UseMultiCellGlyphsKey];

	[[NSNotificationCenter defaultCenter]
		postNotificationName: TerminalViewDisplayPrefsDidChangeNotification
		object: self];
}

-(void) revert
{
	NSFont *f;

	[b_useMultiCellGlyphs setState: useMultiCellGlyphs];
	[b_blackOnWhite setState: blackOnWhite];

	[m_cursorStyle selectCellWithTag: [[self class] cursorStyle]];
	[w_cursorColor setColor: [[self class] cursorColor]];

	f=[[self class] terminalFont];
	[f_terminalFont setStringValue: [NSString stringWithFormat: @"%@ %0.1f",[f fontName],[f pointSize]]];
	[f_terminalFont setFont: f];

	f=[[self class] boldTerminalFont];
	[f_boldTerminalFont setStringValue: [NSString stringWithFormat: @"%@ %0.1f",[f fontName],[f pointSize]]];
	[f_boldTerminalFont setFont: f];

	[f_scrollBackLines setIntValue: scrollBackLines];
}


-(NSString *) name
{
	return _(@"Display");
}

-(void) setupButton: (NSButton *)b
{
	[b setTitle: _(@"Display")];
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
		[top setDefaultMinYMargin: 2];

		[top addView: [[[NSView alloc] init] autorelease] enablingYResizing: YES];

		{
			NSTextField *f;
			NSButton *butt;
			GSHbox *hb;

			hb=[[GSHbox alloc] init];
			[hb setDefaultMinXMargin: 4];
			[hb setAutoresizingMask: NSViewWidthSizable];

			f=[NSTextField newLabel: _(@"Scroll-back length in lines:")];
			[f setAutoresizingMask: 0];
			[hb addView: f  enablingXResizing: NO];
			DESTROY(f);

			f_scrollBackLines=f=[[NSTextField alloc] init];
			[f setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
			[f sizeToFit];
			[hb addView: f  enablingXResizing: YES];
			DESTROY(f);

			[top addView: hb enablingYResizing: NO];
			DESTROY(hb);

			[top addView: [[[NSView alloc] init] autorelease] enablingYResizing: YES];

			{
				NSBox    *box;
				GSTable *t;
				NSColorWell *w;

				box=[[NSBox alloc] init];
				[box setAutoresizingMask: NSViewMinXMargin|NSViewMaxXMargin];
				[box setTitle: _(@"Cursor")];

				t = [[[GSTable alloc] initWithNumberOfRows: 2 numberOfColumns: 2] autorelease];
				[t setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

				f=[NSTextField newLabel: _(@"Style:")];
				[f setAutoresizingMask: NSViewMinXMargin|NSViewMinYMargin|NSViewMaxYMargin];
				[t putView: f  atRow: 0 column: 0  withXMargins: 2 yMargins: 2];
				DESTROY(f);

				{
					NSMatrix *m;
					NSButtonCell *bc=[NSButtonCell new];
					NSSize s;

					[bc setImagePosition: NSImageOnly];
					[bc setHighlightsBy: NSChangeBackgroundCellMask];
					[bc setShowsStateBy: NSChangeBackgroundCellMask];

					m=m_cursorStyle=[[NSMatrix alloc] initWithFrame: NSMakeRect(0,0,1,1)
						mode: NSRadioModeMatrix
						prototype: bc
						numberOfRows: 1
						numberOfColumns: 4];

					[bc release];
					[[m cellAtRow: 0 column: 0] setImage: [NSImage imageNamed: @"cursor_line"]];
					[[m cellAtRow: 0 column: 1] setImage: [NSImage imageNamed: @"cursor_stroked"]];
					[[m cellAtRow: 0 column: 2] setImage: [NSImage imageNamed: @"cursor_filled"]];
					[[m cellAtRow: 0 column: 3] setImage: [NSImage imageNamed: @"cursor_inverted"]];
					[[m cellAtRow: 0 column: 0] setTag: 0];
					[[m cellAtRow: 0 column: 1] setTag: 1];
					[[m cellAtRow: 0 column: 2] setTag: 2];
					[[m cellAtRow: 0 column: 3] setTag: 3];

					s=[[m cellAtRow: 0 column: 0] cellSize];
					s.width+=6;
					s.height+=6;
					[m setCellSize: s];
					[m sizeToCells];

					[t putView: m  atRow: 0 column: 1  withXMargins: 2 yMargins: 2];
					DESTROY(m);
				}


				f=[NSTextField newLabel: _(@"Color:")];
				[f setAutoresizingMask: NSViewMinXMargin|NSViewMinYMargin|NSViewMaxYMargin];
				[t putView: f  atRow: 1 column: 0  withXMargins: 2 yMargins: 2];
				DESTROY(f);

				w_cursorColor=w=[[NSColorWell alloc] initWithFrame: NSMakeRect(0,0,40,30)];
				[t putView: w  atRow: 1 column: 1  withXMargins: 2 yMargins: 2];
				DESTROY(w);

				[[NSColorPanel sharedColorPanel] setShowsAlpha: YES];


				[t sizeToFit];
				[box setContentView: t];
				[box sizeToFit];
				[top addView: box enablingYResizing: NO];
				DESTROY(box);
			}

			[top addView: [[[NSView alloc] init] autorelease] enablingYResizing: YES];


			butt=b_useMultiCellGlyphs=[[NSButton alloc] init];
			[butt setTitle: _(@"Handle wide (multi-cell) glyphs")];
			[butt setButtonType: NSSwitchButton];
			[butt sizeToFit];
			[top addView: butt enablingYResizing: NO];
			DESTROY(butt);

			butt=b_blackOnWhite=[[NSButton alloc] init];
			[butt setTitle: _(@"Display black on white text")];
			[butt setButtonType: NSSwitchButton];
			[butt sizeToFit];
			[top addView: butt enablingYResizing: NO];
			DESTROY(butt);


			hb=[[GSHbox alloc] init];
			[hb setDefaultMinXMargin: 4];
			[hb setAutoresizingMask: NSViewWidthSizable];

			f=[NSTextField newLabel: _(@"Bold font:")];
			[f setAutoresizingMask: 0];
			[hb addView: f  enablingXResizing: NO];
			DESTROY(f);

			f_boldTerminalFont=f=[[NSTextField alloc] init];
			[f setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
			[f setEditable: NO];
			[hb addView: f  enablingXResizing: YES];
			DESTROY(f);

			butt=[[NSButton alloc] init];
			[butt setTitle: _(@"Pick font...")];
			[butt setTarget: self];
			[butt setAction: @selector(_pickBoldTerminalFont:)];
			[butt sizeToFit];
			[hb addView: butt  enablingXResizing: NO];
			DESTROY(butt);

			[top addView: hb enablingYResizing: NO];
			DESTROY(hb);


			hb=[[GSHbox alloc] init];
			[hb setDefaultMinXMargin: 4];
			[hb setAutoresizingMask: NSViewWidthSizable];

			f=[NSTextField newLabel: _(@"Normal font:")];
			[f setAutoresizingMask: 0];
			[hb addView: f  enablingXResizing: NO];
			DESTROY(f);

			f_terminalFont=f=[[NSTextField alloc] init];
			[f setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
			[f setEditable: NO];
			[hb addView: f  enablingXResizing: YES];
			DESTROY(f);

			butt=[[NSButton alloc] init];
			[butt setTitle: _(@"Pick font...")];
			[butt setTarget: self];
			[butt setAction: @selector(_pickTerminalFont:)];
			[butt sizeToFit];
			[hb addView: butt  enablingXResizing: NO];
			DESTROY(butt);

			[top addView: hb enablingYResizing: NO];
			DESTROY(hb);


			[top addView: [[[NSView alloc] init] autorelease] enablingYResizing: YES];
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


-(void) _pickFont
{
	NSFontManager *fm=[NSFontManager sharedFontManager];
	[fm setSelectedFont: [f_cur font] isMultiple: NO];
	[fm orderFrontFontPanel: self];
}

-(void) _pickTerminalFont: (id)sender
{
	f_cur=f_terminalFont;
	[self _pickFont];
}

-(void) _pickBoldTerminalFont: (id)sender
{
	f_cur=f_boldTerminalFont;
	[self _pickFont];
}

-(void) changeFont: (id)sender
{
	NSFont *f;

	if (!f_cur)
	  return;
	f=[sender convertFont: [f_cur font]];
	if (!f)
	  return;

	[f_cur setStringValue: [NSString stringWithFormat: @"%@ %0.1f",[f fontName],[f pointSize]]];
	[f_cur setFont: f];

	return;
}

@end


static NSString
	*LoginShellKey=@"LoginShell",
	*ShellKey=@"Shell";

static NSString *shell;
static BOOL loginShell;

@implementation TerminalViewShellPrefs

+(void) initialize
{
	if (!ud)
		ud=[NSUserDefaults standardUserDefaults];

	if (!shell)
	{
		loginShell=[ud boolForKey: LoginShellKey];
		shell=[ud stringForKey: ShellKey];
		if (!shell && getenv("SHELL"))
			shell=[NSString stringWithCString: getenv("SHELL")];
		if (!shell)
			shell=@"/bin/sh";
		shell=[shell retain];
	}
}

+(NSString *) shell
{
	return shell;
}

+(BOOL) loginShell
{
	return loginShell;
}


-(void) save
{
	if (!top) return;

	if ([b_loginShell state])
		loginShell=YES;
	else
		loginShell=NO;
	[ud setBool: loginShell forKey: LoginShellKey];

	DESTROY(shell);
	shell=[[tf_shell stringValue] copy];
	[ud setObject: shell forKey: ShellKey];
}

-(void) revert
{
	[b_loginShell setState: loginShell];
	[tf_shell setStringValue: shell];
}


-(NSString *) name
{
	return _(@"Shell");
}

-(void) setupButton: (NSButton *)b
{
	[b setTitle: _(@"Shell")];
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
		[top setDefaultMinYMargin: 4];

		{
			NSTextField *f;
			NSButton *b;

			b=b_loginShell=[[NSButton alloc] init];
			[b setAutoresizingMask: NSViewMinYMargin];
			[b setTitle: _(@"Start as login-shell")];
			[b setButtonType: NSSwitchButton];
			[b sizeToFit];
			[top addView: b enablingYResizing: YES];
			DESTROY(b);

			tf_shell=f=[[NSTextField alloc] init];
			[f sizeToFit];
			[f setAutoresizingMask: NSViewWidthSizable];
			[top addView: f enablingYResizing: NO];
			DESTROY(f);

			f=[NSTextField newLabel: _(@"Shell:")];
			[f setAutoresizingMask: NSViewMaxYMargin];
			[f sizeToFit];
			[top addView: f enablingYResizing: YES];
			DESTROY(f);
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


static NSString
         *CommandAsMetaKey=@"CommandAsMeta",
         *DoubleEscapeKey=@"DoubleEscape",
         *AltIsNotMetaKey=@"AltIsNotMeta";

static BOOL commandAsMeta,doubleEscape, altIsNotMeta;

@implementation TerminalViewKeyboardPrefs

+(void) initialize
{
	if (!ud)
		ud=[NSUserDefaults standardUserDefaults];

	commandAsMeta=[ud boolForKey: CommandAsMetaKey];
	doubleEscape=[ud boolForKey: DoubleEscapeKey];
	altIsNotMeta=[ud boolForKey: AltIsNotMetaKey];
}

+(BOOL) commandAsMeta
{
	return commandAsMeta;
}

+(BOOL) doubleEscape
{
	return doubleEscape;
}

+(BOOL) altIsNotMeta
{
  return altIsNotMeta;
}


-(void) save
{
	if (!top) return;

	if ([b_commandAsMeta state])
		commandAsMeta=YES;
	else
		commandAsMeta=NO;
	[ud setBool: commandAsMeta forKey: CommandAsMetaKey];

	if ([b_doubleEscape state])
		doubleEscape=YES;
	else
		doubleEscape=NO;
	[ud setBool: doubleEscape forKey: DoubleEscapeKey];

	if ([b_altIsNotMeta state])
		altIsNotMeta=YES;
	else
		altIsNotMeta=NO;
	[ud setBool: altIsNotMeta forKey: AltIsNotMetaKey];

}

-(void) revert
{
	[b_commandAsMeta setState: commandAsMeta];
	[b_doubleEscape setState: doubleEscape];
	[b_altIsNotMeta setState: altIsNotMeta];
}


-(NSString *) name
{
	return _(@"Keyboard");
}

-(void) setupButton: (NSButton *)b
{
	[b setTitle: _(@"Keyboard")];
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
		[top setDefaultMinYMargin: 8];

		{
			NSButton *b;

			b=b_commandAsMeta=[[NSButton alloc] init];
			[b setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin|NSViewWidthSizable];
			[b setTitle:
				_(@"Treat the command key as meta.\n"
				  @"\n"
				  @"Note that with this enabled, you won't be\n"
				  @"able to access menu entries with the\n"
				  @"keyboard.")];
			[b setButtonType: NSSwitchButton];
			[b sizeToFit];
			[top addView: b enablingYResizing: YES];
			DESTROY(b);

			b=b_altIsNotMeta=[[NSButton alloc] init];
			[b setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin|NSViewWidthSizable];
			[b setTitle:
				_(@"Treat the Alt key as Alt and not Meta.\n"
				  @"Useful if command is used as Meta\n"
				  @"And the keyboard has AltGr and not right Alt\n")];
			[b setButtonType: NSSwitchButton];
			[b sizeToFit];
			[top addView: b enablingYResizing: YES];
			DESTROY(b);


			[top addSeparator];

			b=b_doubleEscape=[[NSButton alloc] init];
			[b setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin|NSViewWidthSizable];
			[b setTitle:
				_(@"Send a double escape for the escape key.\n"
				  @"\n"
				  @"This means that the escape key will be\n"
				  @"recognized faster by many programs, but\n"
				  @"you can't use it as a substitute for meta.")];
			[b setButtonType: NSSwitchButton];
			[b sizeToFit];
			[top addView: b enablingYResizing: YES];
			DESTROY(b);
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

