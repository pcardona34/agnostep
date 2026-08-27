/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003      Nicolas Roard <nicolas@roard.com>
                  2020-2025 Riccardo Mottola <rm@gnu.org>

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

#include "HandlerStructureXLP.h"
#include "Parser.h"
#import <Foundation/NSXMLParser.h>

@interface NSXMLParser (sloppy)
- (void) _setAcceptHTML: (BOOL)flag;
@end
#define HAVING(str) ([[elementName lowercaseString] isEqualToString: str])

@implementation HandlerStructureXLP

- (id) init
{
  if ((self = [super init]))
    {
      _firstSection = [[Section alloc] initWithHeader: @"document"];
      _currentSection = _firstSection;
      _document = NO;
      _utf8DataContent = nil;
    }
  return self;
}

- (id) initWithSection: (Section*) section
{
  if ((self = [super init]))
    {
      ASSIGN (_firstSection, section);
      _currentSection = _firstSection;
      _currentContent = [section text];
      _document = YES;
      _utf8DataContent = nil;
    }
  return self;
}

- (void) dealloc
{
  RELEASE (_firstSection);
  RELEASE (_utf8DataContent);
  [super dealloc];
}

- (void)parser: (NSXMLParser *)parser didStartElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qName attributes: (NSMutableDictionary *)attributeDict
{
  [self startElement: elementName attributes: attributeDict];
}

- (void) startElement: (NSString*) elementName attributes: (NSMutableDictionary*) elementAttributes {
    //NSLog (@"startElement : <%@>", elementName);
    NSString* name = nil;
    NSString* src = nil;

    if ([elementAttributes objectForKey: @"name"] != nil)
    {
	name = [NSString stringWithString: [elementAttributes objectForKey: @"name"]];
        NSLog(@"%@ attribute name; %@", elementName, name);
    }

    if ([elementAttributes objectForKey: @"src"] != nil)
    {
	src = [NSString stringWithString: [elementAttributes objectForKey: @"src"]];
    }

    if HAVING (@"document") 
    { 
    	_document = YES; 
    }

    if (_document)
    {
	if (
		HAVING (@"section")
		|| HAVING (@"chapter")
		|| HAVING (@"part")
		|| HAVING (@"plain")
	   )
	{
		//NSLog (@"<section>name=%@", name);
		Section* newSection = [[Section alloc] initWithHeader: name];
		if (src != nil)
		{
                  NSLog(@"set section to %@ to path |%@|", name, src);
			[newSection setPath: src];
		}

		if HAVING (@"chapter") [newSection setType: SECTION_TYPE_CHAPTER];
		if HAVING (@"part") [newSection setType: SECTION_TYPE_PART];
		if HAVING (@"plain") [newSection setType: SECTION_TYPE_PLAIN];

		[_currentSection setLoaded: YES];
		[_currentSection addSubsection: newSection];
		_currentSection = newSection;
		_currentContent = [newSection text];
		[_currentSection retain];
		[_currentContent retain];
                _insideStringContent = NO;
	}
	else
	{
		id tag = [[NSString alloc] initWithFormat: @"<%@", elementName];
		id str = [[NSMutableAttributedString alloc] initWithString: tag];

		[tag release];
		
		NSEnumerator *enumerator = [elementAttributes keyEnumerator];
		id key;
	
		while ((key = [enumerator nextObject])) 
		{
			id strelem = [[NSString alloc] initWithFormat: @" %@=\"\%@\"",
				key, [elementAttributes objectForKey: key]];
			id astrelem = [[NSMutableAttributedString alloc] initWithString: strelem];
			[str appendAttributedString: astrelem];
			[astrelem release];
			[strelem release];
	    	}
		id strend = [[NSMutableAttributedString alloc] initWithString: @">"];

		[_currentContent appendAttributedString: str];
		[_currentContent appendAttributedString: strend];
		//[self addCurrentProgression: ([str length] + 1)];

		[str release];
		[strend release];
                if (HAVING (@"b")
                    || HAVING (@"i")
                    || HAVING (@"sc")
                    || HAVING (@"code")
                    || HAVING (@"pre")
                    )
                  {
                    // remain in-string context
                    // this could be more finegrained with flags specific for tags or a stack of tags
                    // text outside certain tags still maybe have too much coalescing
                  }
                else
                  {
                    _insideStringContent = NO;
                  }
	}
    }
}

- (void)parser: (NSXMLParser *)parser didEndElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qName
{
  [self endElement: elementName];
}

- (void) endElement: (NSString*) elementName {
    //NSLog (@"endElement : <%@>", elementName);

    if HAVING (@"document") 
    { 
    	_document = NO; 
    }

    if (_document)
    {
	if (
		HAVING (@"section")
		|| HAVING (@"chapter")
		|| HAVING (@"part")
		|| HAVING (@"plain")
	   )
	{
		//NSLog (@"characters (attr) : %@", _currentContent);
		//NSLog (@"</section>");

		if ([[_currentSection text] length] > 0)
		{
			[_currentSection setLoaded: YES];
		}
		
		Section* parent = [_currentSection parent];
		if (parent != nil)
		{	
			ASSIGN (_currentSection, parent);
			ASSIGN (_currentContent, [parent text]);
		}
                _insideStringContent = NO;
	}
	else
	{
		id tag = [[NSString alloc] initWithFormat: @"</%@>", elementName];
		id str = [[NSMutableAttributedString alloc] initWithString: tag];
		[_currentContent appendAttributedString: str];
		//[self addCurrentProgression: [str length]];
		[str release];
		[tag release];
		//NSLog (@"</%@>",elementName);
                if (HAVING (@"b")
                    || HAVING (@"i")
                    || HAVING (@"sc")
                    || HAVING (@"code")
                    || HAVING (@"pre")
                    )
                  {
                    // remain in-string context
                  }
                else
                  {
                    _insideStringContent = NO;
                  }
	}
        
    }

}

- (void) parser: (NSXMLParser *)parser foundCharacters: (NSString *)string
{
  [self characters: string];
}

- (void) characters: (NSString*) name {
    if (_document)
    {
    	NSLog (@"HandlerStructureXLP characters: |%@|", name);
        NSUInteger i;
        NSMutableString *mutStr = [[NSMutableString alloc] init];

        for (i = 0; i < [name length]; i++)
          {
            unichar ch;

            ch = [name characterAtIndex: i];
            if (ch == '<')
              [mutStr appendString: @"&lt;"];
            else if (ch == '>')
              [mutStr appendString: @"&gt;"];
            else if (ch == '&')
              [mutStr appendString: @"&amp;"];
            else if (ch == '\'')
              [mutStr appendString: @"&apos;"];
            else if (ch == '\"')
              [mutStr appendString: @"&quot;"];
            else
              [mutStr appendString: [NSString stringWithCharacters:&ch length:1]];
          }
        NSString *str = [mutStr stringByTrimmingSpacesSkippingStart:!_insideStringContent];
        if (str && [str length])
          {
            NSMutableAttributedString* astr;
     
            astr = [[NSMutableAttributedString alloc] initWithString: str];
            [_currentContent appendAttributedString: astr];
            //[self addCurrentProgression: [astr length]];
            [astr release];
          }

        [mutStr release];
        _insideStringContent = YES;
    }
}

- (void) addCurrentProgression: (int) add
{
	current += add;
	NSLog (@"Lu (%d) : %.2f / %.2f (%.2f)", add, current, max, current*100/max);
}

- (Section*) sections {
	return _firstSection;
}

- (void) setPath: (NSString*) p
{
  if (p != nil)
    {
      NSData *dataUnknownEncoding;
      NSStringEncoding enc;
      const unsigned char *ptr;

      ASSIGN (path, p);
      NSLog (@"[HandlerStructureXLP setPath]: %@", p);
      dataUnknownEncoding = [[NSData alloc] initWithContentsOfFile: path];

      NSUInteger	length = [dataUnknownEncoding length];
      
      if (length < 4)
        {
          [dataUnknownEncoding release];
          NSLog(@"File not long enough");
          return; // Not long enough to determine an encoding
        }

      // Check if we need to convert data to UTF-8
      ptr = (const unsigned char*)[dataUnknownEncoding bytes];

      // Default is UTF-9
      enc = NSUTF8StringEncoding;

      // BOM stuff
      if ((ptr[0] == 0xFE && ptr[1] == 0xFF)
        || (ptr[0] == 0xFF && ptr[1] == 0xFE))
        {
          // we should check for Little or Big Endian
          NSLog(@"found UTF-16 BOM");
          enc = NSUTF16StringEncoding;
        }
      if (ptr[0] == 0xEF && ptr[1] == 0xBB && ptr[2] == 0xBF)
        {
          NSLog(@"found UTF-8 BOM");
          enc = NSUTF8StringEncoding;
        }

      // look if he have an encoding
      // as in <?xml version="1.0" encoding="utf-8"?>
      {
        NSRange startRange;
        NSRange endRange;
        NSRange encRange;
        NSString *contentAsString;
        
        // we open the string as Latin1 becasue it does not fail and is good enough for tags
        contentAsString = [[NSString alloc] initWithData: dataUnknownEncoding
                                              encoding: NSISOLatin1StringEncoding];

        startRange = [contentAsString rangeOfString: @"<?xml"
                                                  options: NSCaseInsensitiveSearch];
        if (startRange.location != NSNotFound)
          {
            endRange = [contentAsString rangeOfString: @"?>"
                                                options: 0];
            if (endRange.location != NSNotFound)
              {
                NSRange xmlTagRange;

                xmlTagRange = NSMakeRange(startRange.location, endRange.location + endRange.length);
                NSLog(@"Extracted XML Tag: %@", [contentAsString substringWithRange:xmlTagRange]);
                encRange = [contentAsString rangeOfString: @"encoding"
                                                  options: NSCaseInsensitiveSearch
                                                  range: xmlTagRange];
                if (encRange.location != NSNotFound)
                  {
                    NSRange maxSearchRange;
                    NSString *encodingString;
                    NSRange firstQuote;

                    maxSearchRange = NSMakeRange(encRange.location, endRange.location - encRange.location);
                    NSLog(@"looking for encoding inside |%@|", [contentAsString substringWithRange:maxSearchRange]);
                    firstQuote = [contentAsString rangeOfString: @"\""
                                                        options: 0
                                                          range: maxSearchRange];
                    if (firstQuote.location != NSNotFound)
                      {
                        NSRange secondQuoteSearchRange;
                        NSRange secondQuote;
                        NSRange encValueRange;
                        
                        secondQuoteSearchRange = NSMakeRange(firstQuote.location + firstQuote.length, maxSearchRange.location + maxSearchRange.length - (firstQuote.location + firstQuote.length));
                        NSLog(@"second quote search string |%@|", [contentAsString substringWithRange:secondQuoteSearchRange]);
                        secondQuote = [contentAsString rangeOfString: @"\""
                                                             options: 0
                                                               range: secondQuoteSearchRange];
                        if (secondQuote.location != NSNotFound)
                          {
                            encValueRange = NSMakeRange(secondQuoteSearchRange.location, secondQuote.location - secondQuoteSearchRange.location);
                            if (encValueRange.location != NSNotFound)
                              {
                                encodingString = [contentAsString substringWithRange:encValueRange];
                                NSLog(@"Encoding Detected |%@|", encodingString);

                                if ([encodingString isEqualToString:@"ISO-8859-1"])
                                  {
                                    NSLog(@"Found Latin1");
                                    enc = NSISOLatin1StringEncoding;
                                  }
                                else if ([encodingString isEqualToString:@"ISO-8859-15"])
                                  {
                                    NSLog(@"Found Latin9");
// Cocoa lacks proper Latin 9, let's fall back even if we loose Euro sign
#ifdef MACOSX
                                    enc = NSWindowsCP1252StringEncoding;
#else
                                    enc = NSISOLatin9StringEncoding;
#endif
                                  }
                                else if ([encodingString isEqualToString:@"UTF-8"])
                                  {
                                    NSLog(@"Found UTF8");
                                    enc = NSUTF8StringEncoding;
                                  }
                              } // Encoding found
                          }
                      }
                  }
              } // XML Tag
          }
        [contentAsString release];
      }

 
      // otherwise assume UTF-8
      if (enc == NSUTF8StringEncoding)
        {
          NSLog(@"UTF-8 native, no conversion");
          _utf8DataContent = dataUnknownEncoding;
          [_utf8DataContent retain];
        }
      else
        {
          NSLog(@"Converting to UTF-8");
          NSString *tempStr;

          tempStr = [[NSString alloc] initWithData: dataUnknownEncoding
                                          encoding: enc];
          _utf8DataContent = [tempStr dataUsingEncoding: NSUTF8StringEncoding];
          [_utf8DataContent retain];
          [tempStr release];
        }
      [dataUnknownEncoding release];
    }
}

- (BOOL) parse
{
  Class		c = Nil;
  id		p = nil;
  NSString	*k;
  BOOL          parseSuccesful;

  NSLog(@"HandlerStructureXLP parse");

  k = [[NSUserDefaults standardUserDefaults] stringForKey: @"Parser"];
  if (nil == k) k = @"Internal";
  if ([k caseInsensitiveCompare: @"Internal"] == NSOrderedSame)
    {
      c = [Parser class];
      p = [c parserWithSAXHandler: (id<SAXHandler, NSObject>)self
			 withData: _utf8DataContent];
    }
  else if ([k caseInsensitiveCompare: @"Sloppy"] == NSOrderedSame)
    {
      c = NSClassFromString(@"GSSloppyXMLParser");
      p = AUTORELEASE([(NSXMLParser*)[c alloc] initWithData: _utf8DataContent]);
      [p _setAcceptHTML: YES];
      [p setDelegate: self];
    }
  else
    {
      c = NSClassFromString(@"GSHTMLParser");
      p = [c parserWithSAXHandler: self withData: _utf8DataContent];
    }
  NSLog(@"Parsing with '%@'%@", k, ((Nil == c) ? @" not found!" : @""));
  parseSuccesful = [p parse];

  return parseSuccesful;
}

- (void) setTextView: (NSTextView*) textview {
//    textView = textview;
}

@end
