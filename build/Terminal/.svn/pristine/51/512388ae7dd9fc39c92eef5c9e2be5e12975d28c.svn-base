/*
copyright 2002, 2003 Alexander Malmberg <alexander@malmberg.org>

This file is a part of Terminal.app. Terminal.app is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; version 2
of the License. See COPYING or main.m for more information.
*/

#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSBundle.h>
#import <AppKit/NSPopUpButton.h>
#import <AppKit/NSBox.h>
#import <GNUstepGUI/GSTable.h>
#import <GNUstepGUI/GSVbox.h>
#import "Label.h"

#import "TerminalParser_LinuxPrefs.h"


static NSUserDefaults *ud;


NSString
	*TerminalParser_LinuxPrefsDidChangeNotification=
		@"TerminalParser_LinuxPrefsDidChangeNotification";

static NSString *CharacterSetKey=@"Linux_CharacterSet";


static NSString *characterSet;


typedef struct
{
	NSString *name;
	NSString *display_name;
} character_set_choice_t;

static character_set_choice_t cs_choices[]={
{@"utf-8"             ,__(@"UTF-8")},
{@"iso-8859-1"        ,__(@"West Europe, latin1")},
{@"iso-8859-2"        ,__(@"East Europe, latin2")},
{@"big-5"             ,__(@"Chinese")},
{nil                  ,__(@"Custom, leave unchanged")},
{nil,nil}
};


@implementation TerminalParser_LinuxPrefs

+(void) initialize
{
	if (!ud)
	{
		ud=[NSUserDefaults standardUserDefaults];

		characterSet=[[ud stringForKey: CharacterSetKey] retain];
		if (!characterSet)
			characterSet=@"iso-8859-1";
	}
}

+(const char *) characterSet
{
	return [characterSet cString];
}


-(void) save
{
	int i;

	if (!top) return;

	i=[pb_characterSet indexOfSelectedItem];
	if (cs_choices[i].name!=nil)
	{
		ASSIGN(characterSet,cs_choices[i].name);
		[ud setObject: characterSet  forKey: CharacterSetKey];

		[[NSNotificationCenter defaultCenter]
			postNotificationName: TerminalParser_LinuxPrefsDidChangeNotification
			object: self];
	}
}

-(void) revert
{
	int i;
	character_set_choice_t *c;
	for (i=0,c=cs_choices;c->name;i++,c++)
	{
		if (c->name &&
		    [c->name caseInsensitiveCompare: characterSet]==NSOrderedSame)
			break;
	}
	[pb_characterSet selectItemAtIndex: i];
}


-(NSString *) name
{
	return _(@"'linux' terminal parser");
}

-(void) setupButton: (NSButton *)b
{
	[b setTitle: _(@"'linux'\nparser")];
	[b sizeToFit];
}

-(void) willHide
{
}

-(NSView *) willShow
{
	if (!top)
	{
		GSVbox *top2;

		top2=[[GSVbox alloc] init];

		top=[[GSVbox alloc] init];
		[top setAutoresizingMask: NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
		[top setDefaultMinYMargin: 2];

		{
			NSTextField *f;
			NSPopUpButton *pb;
			int i;
			character_set_choice_t *c;

			pb_characterSet=pb=[[NSPopUpButton alloc] init];
			[pb setAutoresizingMask: NSViewMinXMargin|NSViewMaxXMargin];
			[pb setAutoenablesItems: NO];
			for (i=0,c=cs_choices;c->display_name;i++,c++)
			{
				NSString *name;
				if (c->name)
					name=[NSString stringWithFormat: @"%@ (%@)",
						_(c->display_name),c->name];
				else
					name=_(c->display_name);
				[pb addItemWithTitle: name];
			}
			[pb sizeToFit];
			[top addView: pb enablingYResizing: NO];
			DESTROY(pb);

			f=[NSTextField newLabel: _(@"Character set:")];
			[top addView: f enablingYResizing: NO];
			DESTROY(f);
		}

		[top2 addView: top enablingYResizing: YES];
		DESTROY(top);
		top=top2;

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

