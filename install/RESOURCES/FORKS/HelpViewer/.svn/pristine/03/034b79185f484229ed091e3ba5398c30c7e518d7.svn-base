/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>
                  2020 Riccardo Mottola <rm@gnu.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the
    Free Software Foundation, Inc.  
    31 Milk Street #960789 Boston, MA 02196 USA
*/

#include "Section.h"
#include "HandlerStructureXLP.h"

static id <TextFormatter> TextFormatter = nil;
static NSBundle* Bundle = nil;

@implementation Section

+ (void) setTextFormatter: (id) obj {
	ASSIGN (TextFormatter, obj);
}

+ (void) setBundle: (NSBundle*) obj {
	ASSIGN (Bundle, obj);
	[TextFormatter setBundle: Bundle];
}

- (id) initWithHeader: (NSString*) pheader
{
  if ((self = [super init]))
    {
      ASSIGN (header, pheader);
      text = [[NSMutableAttributedString alloc] init];
      subs = [[NSMutableArray alloc] init];
      parent = nil;
      rendered = NO;
      loaded = NO;
      path = nil;
    }
  return self;
}

- (void) dealloc
{
  RELEASE (subs);
  RELEASE (text);
  RELEASE (header);
  RELEASE (path);
  [super dealloc];
}

- (NSMutableAttributedString*) text {
	return text;
}

- (void) setPath: (NSString*) src {
	ASSIGN (path, [Bundle pathForResource: [src stringByDeletingPathExtension] ofType: [src pathExtension]]);
}

- (void) setLoaded: (BOOL) load {
	loaded = load;
}

- (BOOL) loaded {
	return loaded;
}

- (void) load
{
  if ([[NSFileManager defaultManager] fileExistsAtPath: path])
    {
      id <HandlerStructure, NSObject> handler = [[HandlerStructureXLP alloc] initWithSection: self];
      [handler setPath: path];
      [handler parse];
      [handler release];
      loaded = YES;
    }
  else
    {
      NSLog(@"[Section load] file %@ not found for header %@", path, header);
    }
}

- (NSMutableAttributedString*) contentWithLevel: (int) level
{
  NSUInteger i;
  NSAttributedString *ret = nil;

  NSLog (@"Section contentWithLevel: %d (%@)", level, [self header]);
  if (rendered)
    {
      ret = [[NSMutableAttributedString alloc] initWithAttributedString: text];
      [ret autorelease];
    }
  else
    {
      if (loaded == NO)
	{
	  [self load];
	  if (loaded == NO)
	    {
	      NSLog(@"Load failed");
	    }
	}

      if ((loaded == YES))
	{
	  ret = [[NSMutableAttributedString alloc] init];

	  if (type != SECTION_TYPE_PLAIN)
	    {
	      id head  = [TextFormatter renderHeader: header withLevel: level];
	      [ret appendAttributedString: head];
	    }
	  id ttext = [TextFormatter renderText: text];
	  [ret appendAttributedString: ttext];
	  for (i=0; i < [subs count]; i++)
	    {
	      Section *sub;
	      NSMutableAttributedString *as = nil;

	      sub = [subs objectAtIndex: i];
	      as = [sub contentWithLevel: level+1];
	      if (as != nil)
		{
		  [ret appendAttributedString: as];
		}
	    }
	  [text release];
	  text = [[NSMutableAttributedString alloc] initWithAttributedString: ret];
	  rendered = YES;
	  [ret autorelease];
	}
    }

  return ret;
}

- (void) setType: (int) t { type = t; }
- (int) type { return type; }

/*
- (void) setText: (NSMutableAttributedString*) t {
	NSLog (@"setText : %@", t);
	RELEASE (text);
	text = [[NSMutableAttributedString alloc] initWithAttributedString: t];
}*/

- (NSString*) header {
    return header;
}

- (NSRange) range {
    return range;
}

- (BOOL) hasSubsections
{
  if (subs != nil && [subs count] > 0)
    return YES;
  return NO;
}

- (NSMutableArray*) subsections {
	return subs;
};

- (void) setRange: (NSRange) prange {
    range = prange;
}

- (void) addSubsection: (Section*) sub {
	//NSLog (@"addSub: Section (%@)", [sub header]);
	[sub setParent: self];
	[subs addObject: sub];
	//NSLog (@"fin addSub: Section (%@)", [sub header]);
}

- (void) setParent: (Section*) par {
	parent = par;
}

- (Section*) parent { return parent; }

- (void) print {
	NSUInteger i;
	NSLog (@"(nom : %@) {", header);
	for (i=0; i < [subs count]; i++)
	{
		[[subs objectAtIndex: i] print];
	}
	NSLog (@"} (nom : %@)", header);
}

@end
