/*
**  NSAttributedString+TextEnriched.m
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "NSAttributedString+TextEnriched.h"

#include "Constants.h"

// Parameter Command
#define PARAM          @"<param>"
#define PARAM_END      @"</param>"

// Font-Alteration Commands
#define BIGGER         @"<bigger>"
#define BIGGER_END     @"</bigger>"
#define BOLD           @"<bold>"
#define BOLD_END       @"</bold>"
#define COLOR          @"<color>"
#define COLOR_END      @"</color>"
#define FIXED          @"<fixed>"
#define FIXED_END      @"</fixed>"
#define FONTFAMILY     @"<fontfamily>"
#define FONTFAMILY_END @"</fontfamily>"
#define ITALIC         @"<italic>"
#define ITALIC_END     @"</italic>"
#define SMALLER        @"<smaller>"
#define SMALLER_END    @"</smaller>"
#define UNDERLINE      @"<underline>"
#define UNDERLINE_END  @"</underline>"

// Fill / Justification / Indentation Commands
#define CENTER         @"<center>"
#define CENTER_END     @"</center>"
#define FLUSHLEFT      @"<flushleft>"
#define FLUSHLEFT_END  @"</flushleft>"
#define FLUSHRIGHT     @"<flushright>"
#define FLUSHRIGHT_END @"</flushright>"
#define IN             @"<in>"
#define IN_END         @"</in>"
#define LEFT           @"<left>"
#define LEFT_END       @"</left>"
#define NOFILL         @"<nofill>"
#define NOFILL_END     @"</nofill>"
#define OUT            @"<out>"
#define OUT_END        @"</out>"
#define PARAINDENT     @"<paraindent>"
#define PARAINDENT_END @"</paraindent>"
#define RIGHT          @"<right>"
#define RIGHT_END      @"</right>"

// Markup Commands
#define EXCERPT        @"<excerpt>"
#define EXCERPT_END    @"</excerpt>"
#define LANG           @"<lang>"
#define LANG_END       @"</lang>"


//
//
//
@implementation NSAttributedString (TextEnriched)

+ (NSAttributedString *) attributedStringFromTextEnrichedString: (NSString *) theString
{
  NSMutableAttributedString *aMutableAttributedString;
  NSMutableDictionary *standardAttributes; 

  NSAutoreleasePool *pool;

  NSFontManager *aFontManager;

  NSScanner *aScanner;

  // We alloc our local autorelease pool
  pool = [[NSAutoreleasePool alloc] init];

  // We get our shared font manager
  aFontManager = [NSFontManager sharedFontManager];
  
  // We initialize our set of standard font attributes
  standardAttributes = [[NSMutableDictionary alloc] init];
  [standardAttributes setObject: [NSFont systemFontOfSize: 0]
		      forKey: NSFontAttributeName];

  // We initialize our mutable attributed string - the result of the conversion
  // from our text/enriched string.
  aMutableAttributedString = [[NSMutableAttributedString alloc] initWithString: theString
								attributes: standardAttributes];
  
  // We initialize our scanner
  aScanner = [[NSScanner alloc] initWithString: theString];
  [aScanner setCaseSensitive: NO];

  // We match BOLD / BOLD_END
  [aScanner setScanLocation: 0];
  [self _alterAttributedString: aMutableAttributedString
	withScanner: aScanner
	fontManager: aFontManager
	startCmd: BOLD
	endCmd: BOLD_END
	trait: NSBoldFontMask];
  
  
  // We match ITALIC / ITALIC_END
  [aScanner setScanLocation: 0];
  [self _alterAttributedString: aMutableAttributedString
	withScanner: aScanner
	fontManager: aFontManager
	startCmd: ITALIC
	endCmd: ITALIC_END
	trait: NSItalicFontMask];
  
  
  
  // We now remove all 'commands' from our attributedString
  [self _removeCommandsFromAttributedString: aMutableAttributedString];
  
  // We finally unfold our attributed string
  [self _unfoldAttributedString: aMutableAttributedString];
  
  // We release our local objects
  RELEASE(standardAttributes);
  RELEASE(aScanner);

  // We release our local pool
  RELEASE(pool);
  
  return AUTORELEASE(aMutableAttributedString);
}


//
// FIXME: Should be optimized.
//
+ (void) _alterAttributedString: (NSMutableAttributedString *) theMutableAttributedString
		    withScanner: (NSScanner *) theScanner
		    fontManager: (NSFontManager *) theFontManager
		       startCmd: (NSString *) theStartCmd
			 endCmd: (NSString *) theEndCmd
			  trait: (int) theTrait
{
  while ( ![theScanner isAtEnd] )
    {
      if ( [theScanner scanString: theStartCmd intoString: NULL] )
	{
	  int start, end;
	  
	  start = [theScanner scanLocation];
	  
	  if ( [theScanner scanUpToString: theEndCmd intoString: NULL] )
	    {
	      NSMutableDictionary *attributes;
	      
	      end = [theScanner scanLocation] + [theEndCmd length];
	      
	      attributes = [NSMutableDictionary dictionaryWithDictionary: 
						  [theMutableAttributedString attributesAtIndex: start
									      effectiveRange: NULL] ];
	      
	      [attributes setObject: [theFontManager convertFont: [attributes objectForKey: NSFontAttributeName]
						     toHaveTrait: theTrait]
			  forKey: NSFontAttributeName];

	      [theMutableAttributedString addAttributes: attributes
					  range: NSMakeRange(start, end - start)];
	    }
	}
      else
	{
	  [theScanner setScanLocation: [theScanner scanLocation] + 1];
	}
    }
}


//
// This method is used to remove all commands from out mutable attributed string.
//
+ (void) _removeCommandsFromAttributedString: (NSMutableAttributedString *) theMutableAttributedString
{
  NSArray *allCommands;
  int i;

  allCommands = [NSArray arrayWithObjects: PARAM, BIGGER, BIGGER_END, BOLD, BOLD_END, COLOR, COLOR_END, FIXED, FIXED_END, FONTFAMILY, FONTFAMILY_END, ITALIC, ITALIC_END, SMALLER, SMALLER_END, UNDERLINE, UNDERLINE_END, CENTER, CENTER_END, FLUSHLEFT, FLUSHLEFT_END, FLUSHRIGHT, FLUSHRIGHT_END, IN, IN_END, LEFT, LEFT_END, NOFILL, NOFILL_END, OUT, OUT_END, PARAINDENT, PARAINDENT_END, RIGHT, RIGHT_END, EXCERPT, EXCERPT_END, LANG, LANG_END, nil];

  for (i = 0; i < [allCommands count]; i++)
    {
      NSString *aCommand, *aString;
      NSRange aRange;
      
      aCommand = [allCommands objectAtIndex: i];
      
      aString = [theMutableAttributedString string];
      aRange = [aString rangeOfString: aCommand];
      
      while (aRange.location != NSNotFound)
	{
	  // If we are decoding a <param></param>, let's strip everything inside it.
	  if ( [aCommand isEqualToString: PARAM] )
	    {
	      aRange.length = NSMaxRange([aString rangeOfString: PARAM_END]) - aRange.location;
	    }

	  [theMutableAttributedString deleteCharactersInRange: aRange];
	  
	  aString = [theMutableAttributedString string];
	  aRange = [aString rangeOfString: aCommand];
	}
    }
}


//
// This method is used to unfold the attributed string.
//
// From the RFC1896:
//   "...
//   isolated CRLF pairs are translated
//   into a single SPACE character. Sequences of N consecutive CRLF pairs,
//   however, are translated into N-1 actual line breaks.
//   ..."
//
+ (void) _unfoldAttributedString: (NSMutableAttributedString *) theMutableAttributedString
{
  NSString *aString;
  int i, length;
  
  aString = [theMutableAttributedString string];
  length = [aString length];
  
  for (i = 0; i < length; i++)
    {
      unichar c1, c2;
      
      c1 = [aString characterAtIndex: i];
      
      if ( (i+1) < [aString length] )
	{ 
	  c2 = [aString characterAtIndex: (i+1)];
	}
      else
	{
	  c2 = ' ';
	}
      
      if (c1 == '\n' && c2 == '\n')
	{
	  [theMutableAttributedString replaceCharactersInRange: NSMakeRange(i, 2)
				      withString: @"\n"];
	}
      else if (c1 == '\n')
	{
	  [theMutableAttributedString replaceCharactersInRange: NSMakeRange(i, 1)
				      withString: @" "];
	}
      
      aString = [theMutableAttributedString string];
      length = [aString length];
    }
}

@end
