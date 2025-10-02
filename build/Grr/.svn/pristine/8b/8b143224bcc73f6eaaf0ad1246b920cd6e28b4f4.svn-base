/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2022  GNUstep Application Team
                            Riccardo Mottola

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA. 
*/

#import "NSString+TolerantHTML.h"

#import <AppKit/AppKit.h>

#ifdef __APPLE__
#import "GNUstep.h"
#endif

// #define TAG_SEL_PAIR(tag, sel) [NSNumber numberWithInt: (int)(@selector(sel))], (tag)



// ------------------------------------------------------------
//    some needed static variables for the parser
// ------------------------------------------------------------


/*
 * Keys: Tag names (NSString*)
 * Values: The method selector that is called when this tag opens
 *         or closes. (Interpreted as int and wrapped in a NSNumber)
 */
static NSDictionary* openingTagsHandlers = nil;
static NSDictionary* closingTagsHandlers = nil;

/**
 * Character sets for the HTML parser
 */
static NSCharacterSet* outOfTagStopSet = nil;
static NSCharacterSet* entityEndSet = nil;
static NSCharacterSet* whitespaces = nil;
static NSCharacterSet* tagClosing = nil;
static NSCharacterSet* whitespacesAndTagClosing = nil;
static NSCharacterSet* whitespacesAndRightTagBrackets = nil;

/*
 * A dictionary that maps HTML entities to their Unicode numbers.
 */
static NSDictionary* entityDictionary = nil;

/**
 * Initialises the constants for the parser. (see above)
 */
void init_constants() {
    NSMutableCharacterSet* wsAndTagClosing;
    NSMutableCharacterSet* wsAndRightTagBrackets;


    // Assume that when this is nil, every variable is nil and vice versa
    if (openingTagsHandlers != nil) {
        return;
    }
    
    openingTagsHandlers = [[NSDictionary dictionaryWithObjectsAndKeys:
        @"openParagraph:", @"p",
        @"openBold:", @"b", 
        @"openItalic:",@"i",
        @"openItalic:",@"em", 
        @"openFont:",@"font",
        @"openParagraph:",@"br",
        @"openAnchor:", @"a",
        @"openPre:",@"pre",
	@"openCode:",@"code",
	@"openImage:",@"img",
        nil
    ] retain];
    NSLog(@"opening: %@", openingTagsHandlers);
    
    closingTagsHandlers = [[NSDictionary dictionaryWithObjectsAndKeys:
        @"stylePop", @"p",// FIXME: Was: closeParagraph
        @"stylePop", @"font",
        @"stylePop",@"b",
        @"stylePop", @"i",
        @"stylePop",@"em",
        @"stylePop",@"a",
        @"stylePop",@"pre",
	@"stylePop",@"code",
	@"stylePop",@"img",
        nil
    ] retain];
    
    outOfTagStopSet = [[NSCharacterSet characterSetWithCharactersInString: @"&<"] retain];
    entityEndSet = [[NSCharacterSet characterSetWithCharactersInString: @";&<"] retain];
    whitespaces = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
    
    tagClosing = [[NSCharacterSet characterSetWithCharactersInString: @"/>"] retain];
    wsAndTagClosing = [NSMutableCharacterSet characterSetWithCharactersInString: @"/>"];
    [wsAndTagClosing formUnionWithCharacterSet: whitespaces];
    whitespacesAndTagClosing = [wsAndTagClosing retain];
    
    wsAndRightTagBrackets = [NSMutableCharacterSet new];
    [wsAndRightTagBrackets addCharactersInString: @">"];
    [wsAndRightTagBrackets formUnionWithCharacterSet: whitespaces];
    whitespacesAndRightTagBrackets = [wsAndRightTagBrackets retain];
    
    entityDictionary = [NSDictionary dictionaryWithContentsOfFile:
        [[NSBundle mainBundle] pathForResource: @"HTML-Entities" ofType: @"plist"]];
    [entityDictionary retain];
    
    NSCAssert(entityDictionary != nil, @"Couldn't load HTML entity dictionary!");
}


// ------------------------------------------------------------
//    HTML Interpreter class
// ------------------------------------------------------------

/**
 * This class retrieves events from the parser (like 'found plaintext', 'found escape',
 * 'found an opening tag called this and that' etc.)
 */
@interface HTMLInterpreter : NSObject
{
    NSMutableArray* fontAttributeStack;
    NSMutableDictionary* defaultStyle;
    NSMutableAttributedString* resultDocument;
}

+(id) sharedInterpreter;

-(void) startParsing;
-(void) stopParsing;

-(NSAttributedString*) result;

-(void) foundPlaintext: (NSString*) string;
-(void) foundEscape: (NSString*) escape;
-(void) foundNewline;
-(BOOL) foundOpeningTagName: (NSString*) name
                 attributes: (NSDictionary*) attributes;
-(BOOL) foundClosingTagName: (NSString*) name
                 attributes: (NSDictionary*) attributes;

+(NSFont*) fixedPitchFont;
+(NSFont*) standardFont;

@end

@implementation HTMLInterpreter

// -----------------------------------------------------------
//    initialiser
// -----------------------------------------------------------

-(id)init
{
    return [super init];
}

+(id) sharedInterpreter
{
    static HTMLInterpreter* singleton = nil;
    
    if (singleton == nil) {
        singleton = [[self alloc] init];
    }
    
    return singleton;
}

// -----------------------------------------------------------
//    start and stop
// -----------------------------------------------------------

-(void) startParsing
{
    ASSIGN(fontAttributeStack, [NSMutableArray new]);
    ASSIGN(defaultStyle, [NSMutableDictionary new]);
    ASSIGN(resultDocument, [NSMutableAttributedString new]);
    
    [defaultStyle setObject: [HTMLInterpreter standardFont]
                     forKey: NSFontAttributeName];
}

-(void) stopParsing
{
    DESTROY(fontAttributeStack);
    DESTROY(defaultStyle);
    DESTROY(resultDocument);
}

// -----------------------------------------------------------
//    giving back the result
// -----------------------------------------------------------

-(NSAttributedString*) result
{
    return [[resultDocument retain] autorelease];
}

// -----------------------------------------------------------
//    handling of the font style stack
// -----------------------------------------------------------

-(void)stylePush: (NSMutableDictionary*) fontAttr
{
    [fontAttributeStack addObject: fontAttr];
}

-(NSMutableDictionary*)style
{
    NSMutableDictionary* result;
    int count = [fontAttributeStack count];
    if (count >= 1) {
        result = [fontAttributeStack objectAtIndex: count - 1];
    } else {
        result = defaultStyle;
    }
    
    return result;
}

-(void)stylePop
{
    int count = [fontAttributeStack count];
    if (count >= 1) {
        [fontAttributeStack removeObjectAtIndex: count-1];
    }
}

// Helper method to convert the current font's traits and push it onto the style stack.
-(void) pushStyleWithFontTrait: (int) trait
{
    NSMutableDictionary* attributes = [[self style] mutableCopyWithZone: (NSZone*)nil];
    
    // Convert original font in bold version
    NSFont* font = [attributes objectForKey: NSFontAttributeName];
    NSFont* boldFont =
        [[NSFontManager sharedFontManager] convertFont: font toHaveTrait: trait];
    
    if (boldFont == nil) {
        // Font couldn't be converted, staying with the old version.
        boldFont = font;
    }
    
    // Set the new bold version
    [attributes setObject: boldFont
                   forKey: NSFontAttributeName];
    
    [self stylePush: attributes];
}



// -----------------------------------------------------------
//    some methods to interprete text and escapes
// -----------------------------------------------------------

-(void) foundPlaintext: (NSString*) string
{
    NSAttributedString* plainText;
    plainText = [[NSAttributedString alloc] initWithString: string attributes: [self style]];
    
    [resultDocument appendAttributedString: plainText];
    [plainText release];
}

-(void) foundEscape: (NSString*) escape
{
    unichar value;
    unichar ch;

    NSAssert([escape length] > 0, @"Empty escape sequence &;!");
    
    ch = [escape characterAtIndex: 0];
    if (ch == '#') {
        int i;
        // FIXME: Is that a UNICODE number?
        
        // this parses the number (faster than using NSScanner and easily done)
        value = 0; // a character is a number, too. (value is a unichar)
        for (i=1; i<[escape length]; i++) {
            value = value * 10;
            value += [escape characterAtIndex: i] - '0';
        }
    } else {
        value = [[entityDictionary objectForKey: escape] intValue];
    }
    
    if (value == 0)
      NSLog(@"Entity &%@; not understood!", escape);
    
    [self foundPlaintext: [NSString stringWithCharacters: &value length: 1]];
}

-(void) foundNewline
{
    // FIXME: optimise by doing it directly?
    // FIXME: Make sure not more than two spaces are printed directly after each other!
    [self foundPlaintext: @" "];
}

// -----------------------------------------------------------
//    the methods that dispatch tags to their specific methods
// -----------------------------------------------------------

/* YES - found interpretable, NO - unknown tag */
-(BOOL) foundOpeningTagName: (NSString*) name
                 attributes: (NSDictionary*) attributes
{
  NSString* str = [openingTagsHandlers objectForKey: name];

  if (str != nil)
    {
      [self performSelector: NSSelectorFromString(str) withObject: attributes];
      return YES;
    }

  return NO;
}

/* YES - found interpretable, NO - unknown tag */
-(BOOL) foundClosingTagName: (NSString*) name
                 attributes: (NSDictionary*) attributes;
{
  NSString* str = [closingTagsHandlers objectForKey: name];

  if (str != nil)
    {
      [self performSelector: NSSelectorFromString(str)];
      return YES;
    }

  return NO;
}

// -----------------------------------------------------------
//    some methods to interprete common HTML tags
// -----------------------------------------------------------

-(void) openParagraph: (NSDictionary*) aDictionary
{
    [self foundPlaintext: @"\n"];
}

// FIXME: Currently not used to see if it makes sense like this.
-(void) closeParagraph
{
    [self foundPlaintext: @"\n"];
}

-(void) openFont: (NSDictionary*) aDictionary
{
    // FIXME
}

-(void) openBold: (NSDictionary*) aDictionary
{
    [self pushStyleWithFontTrait: NSBoldFontMask];
}

-(void) openItalic: (NSDictionary*) aDictionary
{
    [self pushStyleWithFontTrait: NSItalicFontMask];
}

-(void) openAnchor: (NSDictionary*) aDictionary
{
    NSMutableDictionary* attributes = [[self style] mutableCopyWithZone: (NSZone*)nil];
    NSString *urlString = nil;
    NSURL* hyperlinkTarget = nil;
    id val = nil;

    val = [aDictionary objectForKey: @"href"];
    if (val == [NSNull null])
      val = nil;
    urlString = (NSString *)val;
    hyperlinkTarget = [NSURL URLWithString: urlString];
    if (hyperlinkTarget != nil)
      {
        [attributes setObject: hyperlinkTarget
                       forKey: NSLinkAttributeName];
        [attributes setObject: [hyperlinkTarget absoluteString]
                       forKey: NSToolTipAttributeName];
        [attributes setObject: [NSCursor pointingHandCursor]
                       forKey: NSCursorAttributeName];
      }
    
    [self stylePush: attributes];
}

-(void) openImage: (NSDictionary*) aDictionary
{
  NSString *urlString = nil;
  NSString *altString = nil;
  NSURL *srcURL;
  id val = nil;

  val = [aDictionary objectForKey: @"src"];
  if (val == [NSNull null])
    val = nil;
  urlString = (NSString *)val;
  srcURL = [NSURL URLWithString:urlString];

  val = [aDictionary objectForKey: @"alt"];
  if (val == [NSNull null])
    val = nil;
  altString = (NSString *)val;

  NSLog(@"Image (%@) - src URL: %@", altString, srcURL);
}

-(void) openPre: (NSDictionary*) aDictionary
{
    NSMutableDictionary* attributes = [[self style] mutableCopyWithZone: (NSZone*)nil];
    
    [attributes setObject: [HTMLInterpreter fixedPitchFont]
                   forKey: NSFontAttributeName];
    [self stylePush: attributes];
}

-(void) openCode: (NSDictionary*) aDictionary
{
    NSMutableDictionary* attributes = [[self style] mutableCopyWithZone: (NSZone*)nil];
    
    [attributes setObject: [HTMLInterpreter fixedPitchFont]
                   forKey: NSFontAttributeName];
    [self stylePush: attributes];
}


// ---------------------------------------------------------------------------------
//    different fonts
// ---------------------------------------------------------------------------------

+(NSFont*) fixedPitchFont
{
    static NSFont* fixedPitchFont = nil;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* fontName = [defaults objectForKey: @"RSSReaderFixedArticleContentFontDefaults"];
    NSNumber* fontSize = [defaults objectForKey: @"RSSReaderFixedArticleContentSizeDefaults"];
    fixedPitchFont = [NSFont fontWithName: fontName size: [fontSize floatValue]];
    
    if (fixedPitchFont == nil) {
        NSLog(
            @"Couldn't use font (%@, %@ pt) set in the defaults, falling back to system font.",
            fontName, fontSize
        );
        fixedPitchFont = [NSFont userFixedPitchFontOfSize: [NSFont systemFontSize]];
    }
    
    return fixedPitchFont;
}

+(NSFont*) standardFont
{
    static NSFont* standardFont = nil;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* fontName = [defaults objectForKey: @"RSSReaderArticleContentFontDefaults"];
    NSNumber* fontSize = [defaults objectForKey: @"RSSReaderArticleContentSizeDefaults"];
    standardFont = [NSFont fontWithName: fontName size: [fontSize floatValue]];
    
    if (standardFont == nil) {
        NSLog(
            @"Couldn't use font (%@, %@ pt) set in the defaults, falling back to system font.",
            fontName, fontSize
        );
        standardFont = [NSFont userFontOfSize: [NSFont systemFontSize]];
    }
    
    return standardFont;
}

@end



/**
 * The category itself. It is able to parse tags that roughly conform to HTML and XML
 * and notifies the HTMLInterpreter.
 */
@implementation NSString (TolerantHTML)

-(NSAttributedString*) parseHTML
{
    NSScanner* scanner = [NSScanner scannerWithString: self];
    NSString* str = nil;
    HTMLInterpreter* interpreter = [HTMLInterpreter sharedInterpreter];
    NSAttributedString* result;
    BOOL pre = NO;     // the flag of being inside <pre>...</pre>
    NSUInteger start;  // the start position of any tag '<'
    NSUInteger end;    // the position following of the end of any tag '>'
    BOOL res;          // to store boolean returns of functions

    init_constants();    
    [interpreter startParsing];
    [scanner setCharactersToBeSkipped: [NSCharacterSet new]];
    
    while ([scanner isAtEnd] == NO) {
        // ASSERT: out of tag
        if ([scanner scanUpToCharactersFromSet: outOfTagStopSet intoString: &str] == YES) {
            [interpreter foundPlaintext: str];
        }

        if ([scanner isAtEnd] == NO) {
	    unichar ch = [self characterAtIndex: [scanner scanLocation]];
            if (ch == '&') {
	        NSUInteger ret = [scanner scanLocation]; // store & location in case of misparse
                [scanner scanString: @"&" intoString: (NSString**)nil];
		[scanner scanUpToCharactersFromSet: entityEndSet intoString: &str];
		if ([self characterAtIndex: [scanner scanLocation]] == ';')
		  {
		    [interpreter foundEscape: str];
		    [scanner scanString: @";" intoString: (NSString**)nil];
		  }
		else // we ended entity without proper ; termination
		  {
		    [interpreter foundPlaintext: @"&"];
		    [scanner setScanLocation: ret + 1];
		  }
            } else if (ch == '\n') {
	      if (!pre)
		{
		  NSLog(@"parse newline");
		  res = [scanner scanCharactersFromSet: whitespaces intoString: (NSString**)nil];
		  NSAssert(res == YES, @"Couldn't parse newline!");
		  [interpreter foundNewline];
	        }
	      else
		{
		  // if <pre> keep it as is
		  [scanner scanString: @"\n" intoString: (NSString**)nil];
		  [interpreter foundPlaintext: @"\n"];
		}
            } else {
                NSString* name = nil;
                BOOL opening = YES;
                BOOL closing = NO;
                NSMutableDictionary* attrDict;
                unichar nextChar;

                // ASSERT: At the beginning of a tag.
                NSAssert1(ch == '<', @"Beginning of a tag expected, got '%c' instead", ch);
                attrDict = [NSMutableDictionary new];
                
                // default values, change dependent on if it's <xxx>, <xxx/> or </xxx>
                start = [scanner scanLocation]; // store the start of tag
                [scanner scanString: @"<" intoString: (NSString**)nil];

		nextChar = [self characterAtIndex: [scanner scanLocation]];
                if (nextChar == '/') {
		    [scanner scanString: @"/" intoString: (NSString**)nil];
                    closing = YES;
                    opening = NO;
                } else if (nextChar == '?') {
		  // <?xml.....?>
		  [scanner setScanLocation: start]; // return to <
		  [scanner scanUpToString: @"?>" intoString: &str];
		  NSAssert(str != nil, @"Malformed '<?'");
		  [scanner scanString: @"?>" intoString: (NSString**)nil];
		  continue;
		} else if (nextChar == '!') {
		  // <!-- -->
		  [scanner setScanLocation: start]; // return to <
		  [scanner scanUpToString: @"-->" intoString: &str];
		  NSAssert(str != nil, @"Malformed '<!--'");
		  [scanner scanString: @"-->" intoString: (NSString**)nil];
		  continue;
		}

                [scanner scanUpToCharactersFromSet: whitespacesAndTagClosing intoString: &name];
                [scanner scanCharactersFromSet: whitespaces intoString: (NSString**)nil];

                nextChar = [self characterAtIndex: [scanner scanLocation]];

                while (nextChar != '>' && nextChar != '/') {
		  if (!pre)
		    {
		      // ASSERT: At the beginning of a new attribute
		      NSString* attrName = nil;
		      NSString* attrValue = nil;
                    
		      [scanner scanUpToString: @"=" intoString: &attrName];
		      [scanner scanString: @"=" intoString: (NSString**)nil];

		      if ([scanner scanString: @"\"" intoString: (NSString**)nil] == YES)
			{
			  // double quotation marks
			  [scanner scanUpToString: @"\"" intoString: &attrValue];
			  [scanner scanString: @"\"" intoString: (NSString**)nil];
			}
		      else if ([scanner scanString: @"\'" intoString: (NSString**)nil] == YES)
			{
			  // single quotation marks
			  [scanner scanUpToString: @"\'" intoString: &attrValue];
			  [scanner scanString: @"\'" intoString: (NSString**)nil];
			}
		      else
			{
			  [scanner scanUpToCharactersFromSet: whitespacesAndRightTagBrackets
						  intoString: &attrValue];
			}
		      [scanner scanCharactersFromSet: whitespaces intoString: (NSString**)nil];
		      if (attrName)
			{
			  if (attrValue == nil)
			    {
			      NSLog(@"Value was nil for attribute %@ in tag %@", attrName, name);
			      [attrDict setObject: [NSNull null] forKey: attrName];
			    }
			  else
			    {
			      [attrDict setObject: attrValue forKey: attrName];
			    }
			}
		      else
			{
			  NSLog(@"Attribute name was nil in tag %@", name);
			}
		    }
		  else
		    {
		      [scanner scanUpToCharactersFromSet: tagClosing intoString: (NSString**)nil];
		    }
                    
                    nextChar = [self characterAtIndex: [scanner scanLocation]];
                }
                
                if (nextChar == '/') {
		    [scanner scanString: @"/" intoString: (NSString**)nil];
                    closing = YES;
                    opening = YES;
                }
                
                [scanner scanString: @">" intoString: (NSString**)nil];
		end = [scanner scanLocation]; // store the after end of tag

                // normalise element name
                name = [name lowercaseString];

                if (opening) {
		  res = [interpreter foundOpeningTagName: name
					      attributes: attrDict];

		  if (pre && !res)
		    {
		      // do not eat unknown tags inside <pre>
		      [interpreter foundPlaintext:
				     [self substringWithRange: NSMakeRange(start, end - start)]];
		    }

		  // TODO: People use <br/> inside <pre>, parse that!
		  if ([name isEqualToString: @"pre"])
		    {
		      NSString* preformattedText;

		      NSAssert(!pre, @"nested <pre>");

		      NSUInteger ret = [scanner scanLocation]; // store the location of <pre>' body start
		      [scanner scanUpToString: @"</pre" intoString: &preformattedText];

		      NSAssert(preformattedText != nil, @"No matching closing </pre> tag");

		      [scanner setScanLocation: ret];
		      pre = YES;
		    }
                }
                
                if (closing) {
		  res = [interpreter foundClosingTagName: name
					      attributes: attrDict];
		  if (pre && !res)
		    {
		      // do not eat unknown tags inside <pre>
		      [interpreter foundPlaintext:
				     [self substringWithRange: NSMakeRange(start, end - start)]];
		    }

		    if ([name isEqualToString: @"pre"]) {
		      pre = NO;
		    }
                }
            }
        }
    }
    
    result = [interpreter result];
    [interpreter stopParsing];
    return result;
}

@end
