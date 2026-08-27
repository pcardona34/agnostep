/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003      Nicolas Roard <nicolas@roard.com>
                  2020-2026 Riccardo Mottola <rm@gnu.org>

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

#ifdef GNUSTEP
#import <GNUstepBase/GNUstep.h>
#else
#import "GNUstep.h"
#endif

#import <AppKit/NSCell.h> 
#import "HelpDocument.h"
#import "Section.h"
#import "HandlerStructureXLP.h"
#import "TextFormatterXLP.h"

@implementation HelpDocument

- (NSString *) windowNibName
{
  return @"HelpDocument";
}

- (id)init
{
  self = [super init];
  if (self)
    {
      _textFormatter = [[TextFormatterXLP alloc] init];
      handler = nil;
    }
  return self;
}

- (void) initButtons 
{
  [findButton setTitle: _(@"Find")];
  [findButton setFont: [NSFont systemFontOfSize: 0]];
  [findButton setImagePosition: NSImageAbove];
  [findButton setImage: [NSImage imageNamed: @"Search.tiff"]];

  [index setTitle: _(@"Index")];
  [index setFont: [NSFont systemFontOfSize: 0]];
  [index setImagePosition: NSImageAbove];
  [index setImage: [NSImage imageNamed: @"Index.tiff"]];
  
  [back setTitle: _(@"Back")];
  [back setFont: [NSFont systemFontOfSize: 0]];
  [back setImagePosition: NSImageAbove];
  [back setImage: [NSImage imageNamed: @"Back.tiff"]];
  
  [bookshelf setTitle: _(@"Bookshelf")];
  [bookshelf setFont: [NSFont systemFontOfSize: 0]];
  [bookshelf setImagePosition: NSImageAbove];
  [bookshelf setImage: [NSImage imageNamed: @"Bookshelf.tiff"]];
}


- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
  NSLog(@"HelpDocument windowControllerDidLoadNib!");

  [self initButtons];

  [textView setDelegate: self];
  [textView setTextContainerInset: NSMakeSize (8,8)];
 
  [tocBrowser setDelegate: self];
  [tocBrowser setAllowsMultipleSelection: NO];
  [tocBrowser setCellClass: [BrowserCell class]];
  [tocBrowser setAction: @selector(browserClick:)];
  [tocBrowser setTarget: self];

  [_textFormatter setTextView: textView];
  [_textFormatter setHelpDocument: self];

  // after parse
  [tocBrowser reloadColumn: 0];
  [tocBrowser selectRow:0 inColumn:0];
  [self browserClick: tocBrowser];
}

- (void) print: (id) sender
{
  [[NSPrintOperation printOperationWithView: textView] runOperation];
}

- (IBAction) find: (id) sender
{
  NSString *stringToFind;

  stringToFind = [queryField stringValue];
  if (stringToFind != nil && [stringToFind length] > 0)
    {
      if (![self findString: stringToFind])
	{
	  NSBeep();
	}
      return;
    }
  NSBeep();
}

- (void) index: (id) sender 
{
  NSLog (@"Index ...");
}

- (void) back: (id) sender
{
  NSLog (@"Back ...");
}

- (void) bookshelf: (id) sender
{
  NSLog (@"Bookshelf ...");
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
  NSString *fileName = nil;
  BOOL ret = NO;
  
  if ([absoluteURL isFileURL])
    {
      fileName = [absoluteURL path];
    }
  else
    {
      NSLog(@"Non-file paths not supported on load");
    }

  if (fileName != nil)
    {
      ASSIGN (handler, [HandlerStructureXLP new]);

      _bundle = [NSBundle bundleWithPath: fileName];
      [handler setPath: [_bundle pathForResource: @"main" ofType: @"xlp"]];
      [handler setHelpDocument: self];

      ret = [handler parse];
      if (ret)
        {
          NSLog (@"loadFile YES : %@", fileName);
        }
    }

  return ret;
}

- (NSBundle *) bundle;
{
  return _bundle;
}

- (TextFormatterXLP *) textFormatter
{
  return _textFormatter;
}

- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
  NSInteger ret = 0;

  if (column == 0) // First column
    {
      Section* section = [handler sections];
      if ([section hasSubsections])
        {
          ret = (NSInteger)[[section subsections] count];
        }
    }	
  else
    {
      BrowserCell *cell = (BrowserCell *)[sender selectedCellInColumn: column -1];
      Section* section = [cell section];

      if ([section hasSubsections])
        {
          ret = (NSInteger)[[section subsections] count];
        }
    }

  return ret;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
  Section* sub = nil;

  [cell setLeaf: YES];

  //NSLog (@"browser:willDisplayCell:atRow:%dcolumn:%d",row,column);

  if (column == 0) // First column
    {
      Section* section = [handler sections];
      if ([section hasSubsections])
        {
          sub = [[section subsections] objectAtIndex: row];
        }
    }
  else
    {
      BrowserCell *cell = [sender selectedCellInColumn: column -1];
      Section *section = [(BrowserCell*)cell section];
    
      if ([section hasSubsections])
        {
          sub = [[section subsections] objectAtIndex: row];
        }
    }

  if (sub != nil)
    {
      NSString *secHeader;

      secHeader = [sub header];
      if (secHeader == nil)
        {
          // Default value if section has no header title
          secHeader = _(@"Untitled");
        }
      if ([sub hasSubsections])
	{
	  [cell setLeaf: NO];
	}
      [cell setSection: sub];
      [cell setStringValue: secHeader];

      if ([sub loaded] == NO)
	{
	  //NSLog (@"not loaded : %@", [sub header]);
	  [cell setImage: [NSImage imageNamed: @"notloaded.tiff"]];
	  //[cell setLeaf: NO];
	  //[sub load];
	}
      else
	{
	  if (([sub type] == SECTION_TYPE_PLAIN)
	      || ([sub type] == SECTION_TYPE_CHAPTER))
	    {
	      //NSLog (@"chapter : %@", [sub header]);
	      [cell setImage: [NSImage imageNamed: @"chapter.tiff"]];
	    }
	  else if ([sub type] == SECTION_TYPE_PART)
	    {
	      //NSLog (@"chapter : %@", [sub header]);
	      [cell setImage: [NSImage imageNamed: @"part.tiff"]];
	    }
	}
		
      //NSLog (@"sub : %@", [sub header]);
    }
  else
    {
      //NSLog (@"sub == nil");
      [cell setStringValue: @"ERROR"];
    }
  //NSLog (@"fin de browser:willDisplayCell:atRow:%dcolumn:%d",row,column);
}

- (void) browserClick: (id) sender
{
  Section* sub = [(BrowserCell *)[sender selectedCell] section];

  if (sub != nil)
    {
      if ([sub loaded] == NO)
	{
	  [sub load];
	  [tocBrowser reloadColumn: [tocBrowser lastColumn]];
	  [tocBrowser selectRow: [tocBrowser selectedRowInColumn: [tocBrowser lastColumn]]
			      inColumn: [tocBrowser lastColumn]];
	}
	
      if (([sub type] == SECTION_TYPE_PLAIN)
	  || ([sub type] == SECTION_TYPE_CHAPTER))
	{
	  // We have a "new" page, so we replace the entire text 
	  // NSLog (@"on a une nouvelle page ...");
	  id str = [sub contentWithLevel: 0];
	  // NSLog (@"on a recu : %@ et on va le mettre dans le textview", str);
	  [str retain];
	  [[textView textStorage] setAttributedString: str];
	  [str release];
	}
      else if ([sub type] == SECTION_TYPE_NORMAL)
	{
	  // We should select the right position in the textview
	  // (ie, point the user to the right section)
	}
      [tocBrowser reloadColumn: [tocBrowser lastColumn]];
    }
  //NSLog (@"FIN browserClick");
}

- (BOOL) findString: (NSString *)findString
{
  NSRange range;
  NSRange selectedRange;
  NSString *string;
  NSUInteger options = NSLiteralSearch | NSCaseInsensitiveSearch;

  string = [textView string];
  selectedRange = [textView selectedRange];

  range = NSMakeRange(NSMaxRange(selectedRange),
		      [string length] - NSMaxRange(selectedRange));
  range = [string rangeOfString: findString
			options: options
			  range: range];
  if (range.location == NSNotFound)
    {
      range = NSMakeRange (0, selectedRange.location);
      range = [string rangeOfString: findString
			    options:options
			      range: range];
    }

  if (range.location != NSNotFound) 
    {
      [textView setSelectedRange: range];
      [textView scrollRangeToVisible: range];
      return YES;
    }

  return NO;
}
		   
- (void) dealloc
{
  NSLog (@"=== dealloc HelpDocument ===");
  RELEASE ((NSObject*)handler);
  RELEASE(_bundle);
  RELEASE(_textFormatter);
  [super dealloc];
}

@end
