/*
    HKSyntaxHighlighter.m

    Implementation of the HKSyntaxHighlighter class for the HighlighterKit
    framework.

    Copyright (C) 2005, 2006, 2007, 2008  Saso Kiselkov

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "HKSyntaxHighlighter.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSValue.h>

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSTextStorage.h>

#import "HKSyntaxDefinition.h"

static NSString * const KeywordsNotFixedAttributeName = @"KNF";
static NSString * const ContextAttributeName = @"C";

static inline BOOL
my_isspace(unichar c)
{
  if (c == ' ' || c == '\t' || c == '\f')
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

/**
 * This function looks ahead and after `startRange' in `string' and
 * tries to return the range of a whitespace delimited word at the
 * specified range. E.g. string = @"abc def ghi" and startRange = {5, 1},
 * then {4, 3} is returned, because the word "def" lies within the range.
 * Please note that even when the range points to a whitespace area
 * (e.g. string = @"abc def" and startRange = {3, 1}), the lookup
 * will occur and not return `not found' (e.g. in the above example it
 * would return {0, 7}). When the range is also surrounded by whitespace
 * (e.g. @"   " and startRange = {1, 1}) the startRange itself is returned.
 */
static NSRange
RangeOfWordInString(NSString * string, NSRange startRange)
{
  SEL sel = @selector(characterAtIndex:);
  unichar (*characterAtIndex)(id, SEL, unsigned int) = 
    (unichar (*)(id, SEL, unsigned int)) [string methodForSelector: sel];
  int ahead, after;
  unsigned int length = [string length];

  for (ahead = 1; ahead <= (int) startRange.location; ahead++)
    {
      if (my_isspace(characterAtIndex(string,
                                      sel,
                                      startRange.location - ahead)))
        {
          break;
        }
    }
  ahead--;

  for (after = 0; (after + NSMaxRange(startRange)) < length; after++)
    {
      if (my_isspace(characterAtIndex(string,
                                      sel,
                                      (after + NSMaxRange(startRange)))))
        {
          break;
        }
    }

  {
    unsigned int start = startRange.location - ahead,
                 length = startRange.length + ahead + after;

    if (start > 0)
      {
        start--;
        length++;
      }
    if (length + 1 < length)
      {
        length++;
      }

    return NSMakeRange(start, length);
  }
}

static inline BOOL
LocateString(NSString * str,
             unichar * buf,
             unsigned int length,
             unsigned int offset)
{
  unsigned int i, n;

  for (i = 0, n = [str length]; i < n; i++)
    {
      if (i >= length)
        {
          return NO;
        }

      if (buf[i + offset] != [str characterAtIndex: i])
        {
          return NO;
        }
    }

  return YES;
}

@interface HKSyntaxHighlighter (Private)

- (void) fixUpContextsInRange: (NSRange) r;

- (void) fixUpKeywordsInRange: (NSRange) r;
- (void) lazilyFixUpKeywordsInRange: (NSRange) r;

- (void) assignGraphicalAttributesOfContext: (unsigned int) context
                                    toRange: (NSRange) r;

- (void) assignGraphicalAttributesOfKeyword: (unsigned int) keyword
                                  inContext: (unsigned int) context
                                    toRange: (NSRange) r;

- (int) contextBeforeRange: (NSRange) r;
- (int) contextAfterRange: (NSRange) r;
- (int) contextAtEndOfRange: (NSRange) r;

- (void) beginEditingIfNeeded;
- (void) endEditingIfNeeded;

@end

@implementation HKSyntaxHighlighter (Private)

/**
 * Fixes up the contexts inside the text storage in range `r'. A context
 * is recognized by the "Context" attribute which holds the number of
 * the context. This method also applies graphical attributes of the
 * corresponding contexts to the context ranges.
 */
- (void) fixUpContextsInRange: (NSRange) r
{
  HKTextPattern ** beginnings = [syntax contextBeginnings];
  const char * beginningChars = [syntax contextBeginningCharacters];
  unsigned numBeginningChars = [syntax numberOfContextBeginningCharacters];

  unsigned int i;
  unichar * string;
  unsigned int context;

  string = (unichar *) malloc(r.length * sizeof(unichar));
  [[textStorage string] getCharacters: string range: r];

  i = 0;
  context = [self contextBeforeRange: r];
  while (i < r.length)
    {
       // marks the beginning of the currently processed range
      unsigned int mark = i;

      // default context - look for beginning symbols
      if (context == 0)
        {
          unsigned int j = 0;
          HKTextPattern * pattern = NULL;
          NSRange ctxtRange;
          int l = 0;
          HKTextPattern ** skips = [syntax contextSkipsForContext: 0];
          const char * skipChars = [syntax contextSkipCharactersForContext: 0];
          unsigned int numSkipChars = [syntax
            numberOfContextSkipCharactersForContext: 0];

          for (;i < r.length; i++)
            {
              unichar c = string[i];

              // Optimize - look into the skip characters array if the
              // character could be the beginning of a skip sequence.
              // If not, don't perform skip sequence recognition at all.
              if (c < numSkipChars && skipChars[c])
                {
                  for (j = 0; (pattern = skips[j]) != NULL; j++)
                    {
                      l = HKCheckTextPatternPresenceInString (pattern,
                                                              string,
                                                              r.length,
                                                              i);
                      if (l > 0)
                        {
                          break;
                        }
                    }

                  if (l > 0)
                    {
                      i += l - 1;
                      continue;
                    }
                }

              // optimize - skip unneeded characters
              if (c < numBeginningChars && !beginningChars[c])
                {
                  continue;
                }

              for (j = 0; (pattern = beginnings[j]) != NULL; j++)
                {
                  l = HKCheckTextPatternPresenceInString(pattern, string,
                                                       r.length, i);
                  if (l > 0)
                    {
                      break;
                    }
                }

              if (l > 0)
                {
                  break;
                }
            }

          // non-default contexts begin with number 1, not zero
          j++;

          ctxtRange = NSMakeRange(r.location + mark, i - mark);
          if (ctxtRange.length > 0)
            {
              // add an attribute telling the context into the text storage
              [textStorage addAttribute: ContextAttributeName
                                  value: [NSNumber numberWithInt: 0]
                                  range: ctxtRange];
              [self assignGraphicalAttributesOfContext: 0 toRange: ctxtRange];
            }

          ctxtRange = NSMakeRange(r.location + i, l);
          if (ctxtRange.length > 0)
            {
              [textStorage addAttribute: ContextAttributeName
                                  value: [NSNumber numberWithInt: j]
                                  range: ctxtRange];
              [self assignGraphicalAttributesOfContext: j
                                               toRange: ctxtRange];
            }
          i += l;

          // switch to the found context again
          context = j;
        }
      // specific context - look for it's terminator, but skip it's
      // exceptions
      else
        {
          int l = 0;
          HKTextPattern * ending = [syntax contextEndingForContext: context - 1];
          NSRange ctxtRange;
          HKTextPattern ** skips = [syntax contextSkipsForContext: context];
          const char * skipChars = [syntax contextSkipCharactersForContext:
            context];
          unsigned int numSkipChars = [syntax
            numberOfContextSkipCharactersForContext: context];

          for (;i < r.length; i++)
            {
              unichar c = string[i];
              unsigned int j;

              if (c < numSkipChars && skipChars[c])
                {
                  unsigned int j;
                  HKTextPattern * pattern;

                  for (j = 0; (pattern = skips[j]) != NULL; j++)
                    {
                      l = HKCheckTextPatternPresenceInString(pattern, string,
                                                           r.length, i);
                      if (l > 0)
                        {
                          break;
                        }
                    }

                  if (l > 0)
                    {
                      i += l - 1;
                      continue;
                    }
                }

              l = HKCheckTextPatternPresenceInString(ending, string,
                                                   r.length, i);
              if (l > 0)
                {
                  break;
                }
            }

          ctxtRange = NSMakeRange(r.location + mark, i - mark);
          if (ctxtRange.length > 0)
            {
              // add an attribute telling the context into the
              // text storage
              [textStorage addAttribute: ContextAttributeName
                                  value: [NSNumber numberWithInt: context]
                                  range: ctxtRange];
              [self assignGraphicalAttributesOfContext: context
                                               toRange: ctxtRange];
            }

          ctxtRange = NSMakeRange(r.location + i, l);
          if (ctxtRange.length > 0)
            {
              [textStorage addAttribute: ContextAttributeName
                                  value: [NSNumber numberWithInt: 0]
                                  range: ctxtRange];
              [self assignGraphicalAttributesOfContext: context
                                               toRange: ctxtRange];
            }
          i += l;

          // switch to the default context again
          context = 0;
        }
    }

  free(string);
}

/**
 * Passes through the specified text range and fixes up keyword
 * looks based on the contexts active in the given regions. It is
 * simmilar in purpose to fixUpContextsInRange:, except that it
 * uses the information stored in the text storage by the previous
 * method, and thus must be invoked after it.
 */
- (void) fixUpKeywordsInRange: (NSRange) r
{
  unichar * string;
  unsigned int i;

  string = malloc(r.length * sizeof(unichar));
  [[textStorage string] getCharacters: string range: r];

  for (i = 0; i < r.length;)
    {
      NSRange contextRange;
      HKTextPattern ** patterns;
      int context;

      context = [[textStorage attribute: ContextAttributeName
                                atIndex: i + r.location
                         effectiveRange: &contextRange] intValue];

      contextRange = NSIntersectionRange(r, contextRange);
      contextRange.location -= r.location;

      patterns = [syntax keywordsInContext: context];

      while (i < NSMaxRange(contextRange))
        {
          unichar c = string[i];
          unsigned int l = 0;
          unsigned int j;
          HKTextPattern * pattern;

          // skip whitespace - it can't start a keyword
          if (my_isspace(c) || c == '\r' || c == '\n')
            {
              i++;
              continue;
            }

          for (j = 0; (pattern = patterns[j]) != NULL; j++)
            {
              l = HKCheckTextPatternPresenceInString (pattern,
                                                      string,
                                                      r.length,
                                                      i);
              if (l > 0)
                {
                  break;
                }
            }

          // found a pattern?
          if (pattern != NULL)
            {
              NSRange keywordRange = NSMakeRange(i + r.location, l);

              [self assignGraphicalAttributesOfKeyword: j
                                             inContext: context
                                               toRange: keywordRange];
              i += l;
            }
          else
            {
              i++;
            }
        }
    }

  free(string);
}

- (void) lazilyFixUpKeywordsInRange: (NSRange) r
{
  unsigned int i;
  BOOL localDidBeginEditing = NO;

  for (i = r.location; i < NSMaxRange(r);)
    {
      NSRange effectiveRange;

      // locate non-fixed areas and fix them up
      if ([textStorage attribute: KeywordsNotFixedAttributeName
                         atIndex: i
           longestEffectiveRange: &effectiveRange
                         inRange: r] != nil)
        {
          if (localDidBeginEditing == NO)
            {
              localDidBeginEditing = YES;
              [textStorage beginEditing];
            }
          effectiveRange = NSIntersectionRange(effectiveRange, r);
          [self fixUpKeywordsInRange: effectiveRange];
          [textStorage removeAttribute: KeywordsNotFixedAttributeName
                                 range: effectiveRange];
          i += effectiveRange.length;
        }

      // skip over fixed areas
      else
        {
          i += effectiveRange.length;
        }
    }

  if (localDidBeginEditing == YES)
    {
      [textStorage endEditing];
    }
}

/*
 * Assigns the graphical attributes of the specified context to the
 * provided text range.
 */
- (void) assignGraphicalAttributesOfContext: (unsigned int) ctxt
                                    toRange: (NSRange) r
{
  if (r.length > 0)
    {
      BOOL bold, italic;
      NSColor * color;
      
      color = [syntax foregroundColorForContext: ctxt];
      if (color != nil)
        {
          [textStorage addAttribute: NSForegroundColorAttributeName
                       value: color
                       range: r];
        }
      else if (defaultTextColor != nil)
        {
          [textStorage addAttribute: NSForegroundColorAttributeName
                       value: defaultTextColor
                       range: r];
        }
      else
        {
          [textStorage removeAttribute: NSForegroundColorAttributeName range: r];
        }
      
      color = [syntax backgroundColorForContext: ctxt];
      if (color != nil)
        {
          [textStorage addAttribute: NSBackgroundColorAttributeName
                       value: color
                       range: r];
        }
      else
        {
          [textStorage removeAttribute: NSBackgroundColorAttributeName range: r];
        }
      
      bold = [syntax isBoldFontForContext: ctxt];
      italic = [syntax isItalicFontForContext: ctxt];
      if (bold && italic)
        {
          [textStorage addAttribute: NSFontAttributeName
                       value: boldItalicFont
                       range: r];
        }
      else if (bold)
        {
          [textStorage addAttribute: NSFontAttributeName
                       value: boldFont
                       range: r];
        }
      else if (italic)
        {
          [textStorage addAttribute: NSFontAttributeName
                       value: italicFont
                       range: r];
        }
      else
        {
          [textStorage addAttribute: NSFontAttributeName
                       value: normalFont
                       range: r];
        }
    }
}

/*
 * Assigns the graphical attributes (color, font, etc.) of the specified
 * keyword argument to the range argument, given that the keyword is part
 * of the specified context.
 */
- (void) assignGraphicalAttributesOfKeyword: (unsigned int) keyword
                                  inContext: (unsigned int) context
                                    toRange: (NSRange) r
{
  if (r.length > 0)
    {
      BOOL bold, italic;
      NSColor * color;
      
      color = [syntax foregroundColorForKeyword: keyword inContext: context];
      if (color != nil)
        {
          [textStorage addAttribute: NSForegroundColorAttributeName
                       value: color
                       range: r];
        }
      else
        {
          color = [syntax foregroundColorForContext: context];
          
          if (color != nil)
            {
              [textStorage addAttribute: NSForegroundColorAttributeName
                           value: color
                              range: r];
            }
          else if (defaultTextColor != nil)
            {
              [textStorage addAttribute: NSForegroundColorAttributeName
                           value: defaultTextColor
                           range: r];
            }
          else
            {
              [textStorage removeAttribute: NSForegroundColorAttributeName
                           range: r];
            }
        }
        
      color = [syntax backgroundColorForKeyword: keyword inContext: context];
      if (color != nil)
        {
          [textStorage addAttribute: NSBackgroundColorAttributeName
                       value: color
                       range: r];
        }
      else
        {
          color = [syntax backgroundColorForContext: context];
          
          if (color != nil)
            {
              [textStorage addAttribute: NSBackgroundColorAttributeName
                           value: color
                           range: r];
            }
          else
            {
              [textStorage removeAttribute: NSBackgroundColorAttributeName
                           range: r];
            }
        }
      
      bold = [syntax isBoldFontForKeyword: keyword inContext: context];
      italic = [syntax isItalicFontForKeyword: keyword inContext: context];
      if (bold && italic)
        {
          [textStorage addAttribute: NSFontAttributeName
                       value: boldItalicFont
                       range: r];
        }
      else if (bold)
        {
          [textStorage addAttribute: NSFontAttributeName
                       value: boldFont
                       range: r];
        }
      else if (italic)
        {
          [textStorage addAttribute: NSFontAttributeName
                       value: italicFont
                       range: r];
        }
      else
        {
          [textStorage addAttribute: NSFontAttributeName
                       value: normalFont
                       range: r];
        }
    }
}

/*
 * Returns the context number which is active before the beginning of
 * the provided range argument.
 */
- (int) contextBeforeRange: (NSRange) r
{
  NSRange tmp;

  if (r.location == 0)
    {
      return 0;
    }
  else
    {
      return [[textStorage attribute: ContextAttributeName
                             atIndex: r.location - 1
                      effectiveRange: &tmp] intValue];
    }
}

/*
 * Returns the context number which is active after the end of the provided
 * range argument.
 */
- (int) contextAfterRange: (NSRange) r
{
  NSRange tmp;
  unsigned int i, length;

  i = NSMaxRange(r);
  length = [textStorage length];

  if (length == 0)
    {
      return 0;
    }
  else if (i < length)
    {
      return [[textStorage attribute: ContextAttributeName
                             atIndex: i
                      effectiveRange: &tmp] intValue];
    }
  else
    {
      return 0;
    }
}

/**
 * Returns the context number which is active at the end of the provided
 * range argument.
 */
- (int) contextAtEndOfRange: (NSRange) r
{
  NSRange tmp;
  int i = (int) NSMaxRange(r) - 1;

  if (i < 0)
    {
      return 0;
    }
  else
    {
      return [[textStorage attribute: ContextAttributeName
                             atIndex: i
                      effectiveRange: &tmp] intValue];
    }
}

/*
 * Sends a message to the receiver's text storage to begin
 * editing if it has not been sent already.
 */
- (void) beginEditingIfNeeded
{
  if (didBeginEditing == NO)
    {
      didBeginEditing = YES;
      [textStorage beginEditing];
    }
}

/*
 *Sends a message to the receiver's text storage to end
 * editing if it has not been sent already.
 */
- (void) endEditingIfNeeded
{
  if (didBeginEditing == YES)
    {
      didBeginEditing = NO;
      [textStorage endEditing];
    }
}

@end

@implementation HKSyntaxHighlighter

+ (NSFont *) defaultFont
{
  NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
  NSString * fontName;
  float fontSize;
  NSFont * font = nil;

  fontName = [df objectForKey: @"HKFont"];
  fontSize = [df floatForKey: @"HKFontSize"];

  if (fontName != nil)
    {
      font = [NSFont fontWithName: fontName size: fontSize];
    }
  if (font == nil)
    {
      font = [NSFont userFixedPitchFontOfSize: fontSize];
    }

  return font;
}

+ (NSFont *) defaultBoldFont
{
  NSFont * font = [self defaultFont];
  
  return [[NSFontManager sharedFontManager] convertFont: font
                                            toHaveTrait: NSBoldFontMask];
}

+ (NSFont *) defaultItalicFont
{
  NSFont * font = [self defaultFont];

  return [[NSFontManager sharedFontManager] convertFont: font
                                            toHaveTrait: NSItalicFontMask];
}

+ (NSFont *) defaultBoldItalicFont
{
  NSFont * font = [self defaultFont];

  return [[NSFontManager sharedFontManager] convertFont: font
                                            toHaveTrait: NSBoldFontMask |
                                                         NSItalicFontMask];
}


- (id) initWithHighlighterType: (NSString *) type
                   textStorage: (NSTextStorage *) aStorage
              defaultTextColor: (NSColor *) aColor
{
  HKSyntaxDefinition * def = [HKSyntaxDefinition
    syntaxDefinitionForType: type];

  return [self initWithSyntaxDefinition: def
                            textStorage: aStorage
                       defaultTextColor: aColor];
}
                       
- (id) initWithSyntaxDefinition: (HKSyntaxDefinition *) aSyntaxDefinition
                    textStorage: (NSTextStorage *) aStorage
               defaultTextColor: (NSColor *) aColor
{
  if ((self = [self init]) != nil)
    {
      NSRange r;

      ASSIGN (textStorage, aStorage);
      ASSIGN (syntax, aSyntaxDefinition);

      // no syntax definition - no highlighting possible
      if (syntax == nil)
        {
          [self release];
          return nil;
        }

      // mark all of the text storage as requiring keyword fixing
      r = NSMakeRange(0, [textStorage length]);
      if (r.length > 0)
        {      
          [textStorage addAttribute: KeywordsNotFixedAttributeName
                       value: [NSNull null]
                       range: r];
        }

      [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(textStorageWillProcessEditing:)
               name: NSTextStorageWillProcessEditingNotification
             object: textStorage];

      ASSIGN (normalFont, [[self class] defaultFont]);
      ASSIGN (boldFont, [[self class] defaultBoldFont]);
      ASSIGN (italicFont, [[self class] defaultItalicFont]);
      ASSIGN (boldItalicFont, [[self class] defaultBoldItalicFont]);

      ASSIGN (defaultTextColor, aColor);

      return self;
    }
  else
    {
      return nil;
    }
}

- (void) dealloc
{
  NSDebugLLog(@"HKSyntaxHighlighter", @"HKSyntaxHighlighter: dealloc");

  [[NSNotificationCenter defaultCenter] removeObserver: self];

  TEST_RELEASE (textStorage);
  TEST_RELEASE (syntax);
  TEST_RELEASE (normalFont);
  TEST_RELEASE (boldFont);
  TEST_RELEASE (italicFont);
  TEST_RELEASE (boldItalicFont);

  TEST_RELEASE (defaultTextColor);

  [super dealloc];
}

- (void) highlightRange: (NSRange) r
{
  if (delayedProcessedRange.length > 0)
    {
      [self beginEditingIfNeeded];
      [self fixUpContextsInRange: delayedProcessedRange];
      [self fixUpKeywordsInRange: delayedProcessedRange];

      if ([self contextAtEndOfRange: delayedProcessedRange] !=
          [self contextAfterRange: delayedProcessedRange])
        {
          NSRange invalidatedRange;

          lastProcessedContextIndex = NSMaxRange(delayedProcessedRange);

          invalidatedRange = NSMakeRange(NSMaxRange(delayedProcessedRange),
            [textStorage length] - NSMaxRange(delayedProcessedRange));
          if (invalidatedRange.length > 0)
            {
              [textStorage addAttribute: KeywordsNotFixedAttributeName
                           value: [NSNull null]
                           range: invalidatedRange];
            }
        }
    }
  else
    {
      if (delayedProcessedRange.location > 0 &&
        [self contextBeforeRange: delayedProcessedRange] !=
        [self contextAfterRange: delayedProcessedRange])
        {
          NSRange invalidatedRange;

          lastProcessedContextIndex = NSMaxRange(delayedProcessedRange);

          [self beginEditingIfNeeded];

          invalidatedRange = NSMakeRange(NSMaxRange(delayedProcessedRange),
            [textStorage length] - NSMaxRange(delayedProcessedRange));
          if (invalidatedRange.length > 0)
            {
              [textStorage addAttribute: KeywordsNotFixedAttributeName
                           value: [NSNull null]
                           range: invalidatedRange];
            }
        }
    }

  delayedProcessedRange = NSMakeRange(0, 0);

  r = RangeOfWordInString([textStorage string], r);

  // need to fixup contexts?
  if (NSMaxRange(r) > lastProcessedContextIndex)
    {
      unsigned int prevContext;
      NSRange fixupRange;

      fixupRange = NSMakeRange(lastProcessedContextIndex,
                               NSMaxRange(r) - lastProcessedContextIndex);

      [self beginEditingIfNeeded];
      [self fixUpContextsInRange: fixupRange];

      lastProcessedContextIndex = NSMaxRange(r);
    }

  [self lazilyFixUpKeywordsInRange: r];

  [self endEditingIfNeeded];
}

- (void) textStorageWillProcessEditing: (NSNotification *) notif
{
  if ([textStorage editedMask] & NSTextStorageEditedCharacters)
    {
      NSRange editedRange = [textStorage editedRange];

      delayedProcessedRange = RangeOfWordInString([textStorage string],
                                                  editedRange);

      if (lastProcessedContextIndex > editedRange.location)
        {
          lastProcessedContextIndex += [textStorage changeInLength];
        }
    }
}

@end
