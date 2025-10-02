/*
    HKTextPattern.m

    Implementation of operations on text patterns for the HighlighterKit
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

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

typedef struct {
  enum {
    SingleCharacterTextPatternItem,
    MultipleCharactersTextPatternItem,
    AnyCharacterTextPatternItem,
    BeginningOfWordTextPatternItem,
    EndingOfWordTextPatternItem,
    BeginningOfLineTextPatternItem,
    EndingOfLineTextPatternItem
  } type;

  union {
    unichar singleChar;
    struct {
      unichar * characters;
      unsigned int nCharacters;
    } multiChar;
  } data;

  unsigned int minCount, maxCount;
} TextPatternItem;

typedef struct {
  NSString * string;

  TextPatternItem ** items;
  unsigned int nItems;
} HKTextPattern;


#define IN_TEXT_PATTERN_M       /* hide the external declaration */
#import "HKTextPattern.h"

#import <Foundation/NSBundle.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSException.h>

/**
 * Frees a text pattern item, as returned by ParseTextPatternItem.
 * This internal function is used by the text pattern matching engine.
 *
 * @param item The text pattern which will be freed. The object
 * will afterwards be invalid and must not be further used.
 */
static void
FreeTextPatternItem (TextPatternItem * item)
{
  if (item->type == MultipleCharactersTextPatternItem)
    {
      free (item->data.multiChar.characters);
    }

  free (item);
}

/**
 * Parses a text pattern item from a string.
 *
 * This function is used internally by the text pattern matching
 * engine when it compiles text patterns.
 *
 * @param string The string which to parse.
 * @param index The offset in the string where to parse the text pattern
 *      item. When parsing is succesful, this value is set to the next
 *      character following the pattern item's position in the string,
 *      allowing for scanning in pattern items sequentially.
 *
 * @return In case the pattern item is parsed successfuly, a malloc'ed
 * and initialized TextPatternItem type. In case the pattern item isn't
 * valid, a warning message is logged and NULL is returned instead.
 */
static TextPatternItem *
ParseTextPatternItem (NSString * string, unsigned int * index)
{
  unsigned int i = *index, n = [string length];
  TextPatternItem * newItem;
  unichar c;

  newItem = (TextPatternItem *) calloc (1, sizeof (TextPatternItem));

  c = [string characterAtIndex: i];
  i++;
  switch (c)
    {
      case '[':
        {
          unichar * buf = NULL;
          unsigned int nChars = 0;

          for (; i < n; i++)
            {
              unichar c = [string characterAtIndex: i];

              // handle escapes
              if (c == '\\')
                {
                  if (i + 1 >= n)
                    {
                      NSLog(_(@"Text pattern item parse error in text "
                        @"pattern \"%@\" at index %i: unexpected end of "
                        @"pattern. Escape sequence expected."), string);

                      free (buf);
                      free (newItem);

                      return NULL;
                    }

                  i++;
                  c = [string characterAtIndex: i];
                }
              else if (c == ']')
                {
                  i++;
                  break;
                }

              nChars++;
              buf = (unichar *) realloc (buf, sizeof (unichar) * nChars);
              buf[nChars - 1] = c;
            }

          newItem->type = MultipleCharactersTextPatternItem;
          newItem->data.multiChar.nCharacters = nChars;
          newItem->data.multiChar.characters = buf;
        }
        break;
      case '.':
        newItem->type = AnyCharacterTextPatternItem;
        break;
      case '<':
        newItem->type = BeginningOfWordTextPatternItem;
        break;
      case '>':
        newItem->type = EndingOfWordTextPatternItem;
        break;
      case '^':
        newItem->type = BeginningOfLineTextPatternItem;
        break;
      case '$':
        newItem->type = EndingOfLineTextPatternItem;
        break;
      case '\\':
        if (i >= n)
          {
            NSLog(_(@"Text pattern item parse error in text pattern "
              @"\"%@\" at index %i: unexpected end of pattern. Escape "
              @"sequence expected."), string);

            free (newItem);
            return NULL;
          }
        c = [string characterAtIndex: i];
        i++;

      default:
        newItem->type = SingleCharacterTextPatternItem;
        newItem->data.singleChar = c;
        break;
    }

  // is there trailing cardinality indication?
  if (i < n)
    {
      c = [string characterAtIndex: i];
      i++;

      switch (c)
        {
          case '{':
            {
              NSScanner * scanner;
              int value;

              if (newItem->type != SingleCharacterTextPatternItem &&
                  newItem->type != MultipleCharactersTextPatternItem &&
                  newItem->type != AnyCharacterTextPatternItem)
                {
                  NSLog(_(@"Text pattern item parse error in text pattern "
                    @"\"%@\" at index %i: no cardinality indication in "
                    @"'<', '>', '^' or '$' allowed."), string, i);

                  FreeTextPatternItem(newItem);

                  return NULL;
                }

              scanner = [NSScanner scannerWithString: string];

              [scanner setScanLocation: i];
              if (![scanner scanInt: &value])
                {
                  NSLog(_(@"Text pattern item parse error in text pattern "
                    @"\"%@\" at index %i: integer expected."), string,
                    [scanner scanLocation]);

                  FreeTextPatternItem(newItem);

                  return NULL;
                }
              newItem->minCount = newItem->maxCount = value;
              i = [scanner scanLocation];
              if (i >= n)
                {
                  NSLog(_(@"Text pattern item parse error in text pattern "
                    @"\"%@\": unexpected end of pattern, '}' or ',' "
                    @"expected."), string);

                  FreeTextPatternItem(newItem);

                  return NULL;
                }
              c = [string characterAtIndex: i];
              if (c == ',')
                {
                  [scanner setScanLocation: i + 1];
                  if (![scanner scanInt: &value])
                    {
                      NSLog(_(@"Text pattern item parser error in text "
                        @"pattern \"%@\" at index %i: integer expected."),
                        string, [scanner scanLocation]);
    
                      FreeTextPatternItem(newItem);

                      return NULL;
                    }
                  newItem->maxCount = value;
                  i = [scanner scanLocation];
                }
              if (i >= n)
                {
                  NSLog(_(@"Text pattern item parse error in text pattern "
                    @"\"%@\": unexpected end of pattern, '}' expected."),
                    string);

                  FreeTextPatternItem(newItem);

                  return NULL;
                }
              c = [string characterAtIndex: i];
              i++;
              if (c != '}')
                {
                  NSLog(_(@"Text pattern item parse error in text pattern "
                    @"\"%@\" at index %i: '}' expected."), string, i);

                  FreeTextPatternItem(newItem);

                  return NULL;
                }
            }
            break;
          // no cardinality indication - the next character is part of
          // the next text pattern
          case '*':
            newItem->minCount = 0;
            newItem->maxCount = 0x7fffffff;
            break;
          case '?':
            newItem->minCount = 0;
            newItem->maxCount = 1;
            break;
          default:
            i--;
            newItem->minCount = newItem->maxCount = 1;
            break;
        }
    }
  else
    {
      newItem->minCount = newItem->maxCount = 1;
    }

  *index = i;

  return newItem;
}

/**
 * Prints out a description of a particular text pattern component.
 *
 * The printing is done using NSLog. This function is used when
 * debugging the text pattern system.
 *
 * @param item The item of a text pattern which to describe.
 */
static void
DescribeTextPatternItem(TextPatternItem * item)
{
  switch (item->type)
    {
    case SingleCharacterTextPatternItem:
      NSLog(@"  type: single char, value: '%c', min: %i, max: %i",
        item->data.singleChar,
        item->minCount,
        item->maxCount);
      break;
    case MultipleCharactersTextPatternItem:
      NSLog(@"  type: multi char, value: '%@', min: %i, max: %i",
        [NSString stringWithCharacters: item->data.multiChar.characters
                                length: item->data.multiChar.nCharacters],
        item->minCount, item->maxCount);
      break;
    case BeginningOfWordTextPatternItem:
      NSLog(@"  type: beginning of word");
      break;
    case EndingOfWordTextPatternItem:
      NSLog(@"  type: ending of word");
      break;
    case AnyCharacterTextPatternItem:
      NSLog(@"  type: any character, min: %i, max: %i",
        item->minCount, item->maxCount);
      break;
    case BeginningOfLineTextPatternItem:
      NSLog(@"  type: beginning of line");
      break;
    case EndingOfLineTextPatternItem:
      NSLog(@"  type: ending of line");
      break;
    }
}

/**
 * Compiles a textual representation of a text pattern.
 *
 * Prior to being used, a text pattern has to be compiled into an
 * efficient internal representation, represented by the HKTextPattern
 * type.
 *
 * @param string The pattern string which to compile.
 *
 * @return A malloc'ed HKTextPattern type describing the text pattern.
 *      When it's of no further use, release this returned value
 *      using the HKFreeTextPattern function.
 */
HKTextPattern *
HKCompileTextPattern (NSString * string)
{
  HKTextPattern * pattern;
  unsigned int i, n;

  pattern = (HKTextPattern *) calloc (1, sizeof (HKTextPattern));

  ASSIGN(pattern->string, string);

  for (i = 0, n = [string length]; i < n;)
    {
      TextPatternItem * item;

      item = ParseTextPatternItem(string, &i);
      if (item == NULL)
        {
          HKFreeTextPattern (pattern);

          return NULL;
        }

       // enlarge the pattern buffer
      pattern->nItems++;
      pattern->items = (TextPatternItem **) realloc (pattern->items,
        pattern->nItems * sizeof (TextPatternItem *));
      pattern->items[pattern->nItems - 1] = item;
    }

  return pattern;
}

/**
 * Frees all resources associated with a particular compiled representation
 * of a text pattern. The text pattern will aftewards be invalid and must
 * not be used.
 *
 * @param pattern The pattern which to free.
 */
void
HKFreeTextPattern (HKTextPattern * pattern)
{
  unsigned int i;

  for (i = 0; i < pattern->nItems; i++)
    {
      FreeTextPatternItem(pattern->items[i]);
    }

  free (pattern->items);

  TEST_RELEASE (pattern->string);

  free (pattern);
}

/**
 * Determines whether a character is the member of a character class.
 * This internal function is used by the text pattern matching engine.
 *
 * @param c The character which to test.
 * @param charClass The character class which to test against.
 * @param n The length of the charClass buffer.
 *
 * @return YES if the character is a member of the character class, NO
 *      if it isn't.
 */
static inline BOOL
IsMemberOfCharacterClass(unichar c, unichar * charClass, unsigned int n)
{
  unsigned int i;

  for (i = 0; i < n; i++)
    {
      if (charClass[i] == c)
        {
          return YES;
        }
    }

  return NO;
}

/**
 * Tests whether a particular character is an alphanumeric character.
 * This internal function is used by the text pattern matching engine.
 *
 * @param c The character which to test.
 *
 * @return YES if the passed character argument is an alphanumeric
 * character, NO if it isn't.
 */
static inline BOOL
my_isalnum (unichar c)
{
  if ((c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      (c >= '0' && c <= '9'))
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

/**
 * Tests whether a particular text pattern item is present in a string
 * at a specified offset. This internal function is used by the text
 * pattern matching engine.
 *
 * @param item The text pattern item which to test.
 * @param string The string buffer on which to test the pattern item.
 * @param stringLength The length of the string buffer.
 * @param offset The offset at which to perform the test. In case the
 *      test is positive, this offset will be set to the character
 *      right after the last character which matched the text pattern
 *      item.
 *
 * @return YES if the text pattern item is present in the string at the
 *      specified offset, NO if it isn't.
 */
static inline BOOL
CheckTextPatternItemPresence(TextPatternItem * item,
                             unichar * string,
                             unsigned int stringLength,
                             unsigned int * offset)
{
  switch (item->type)
    {
    case SingleCharacterTextPatternItem:
      {
        unsigned int i;
        unsigned int n;

         // read characters while they are equal to our letter
        for (n = 0, i = *offset;
             i < stringLength && n < item->maxCount;
             i++, n++)
          {
            if (string[i] != item->data.singleChar)
              {
                break;
              }
          }

        if (n >= item->minCount)
          {
            *offset = i;
            return YES;
          }
        else
          {
            return NO;
          }
      }
      break;
    case MultipleCharactersTextPatternItem:
      {
        unsigned int i;
        unsigned int n;

        for (n = 0, i = *offset;
             i < stringLength && n < item->maxCount;
             i++, n++)
          {
            if (!IsMemberOfCharacterClass(string[i],
                                          item->data.multiChar.characters,
                                          item->data.multiChar.nCharacters))
              {
                break;
              }
          }

        if (n >= item->minCount)
          {
            *offset = i;
            return YES;
          }
        else
          {
            return NO;
          }
      }
      break;
    case AnyCharacterTextPatternItem:
      {
        unsigned int i, n;

        for (i = *offset, n = 0; n < item->minCount; i++, n++)
          {
            if (i >= stringLength)
              {
                return NO;
              }
          }

        *offset = i;
        return YES;
      }
      break;
    case BeginningOfWordTextPatternItem:
      {
        unsigned int i = *offset;

        if (i >= stringLength)
          {
            return NO;
          }

        if (i > 0)
          {
            if (my_isalnum(string[i - 1]))
              {
                return NO;
              }
            else
              {
                return YES;
              }
          }
        else
          {
            return YES;
          }
      }
      break;
    case EndingOfWordTextPatternItem:
      {
        unsigned int i = *offset;

        if (i >= stringLength)
          {
            return YES;
          }

        if (!my_isalnum(string[i]))
          {
            return YES;
          }
        else
          {
            return NO;
          }
      }
      break;
    case BeginningOfLineTextPatternItem:
      {
        unsigned int i = *offset;

        if (i > 0)
          {
            return (string[i - 1] == '\n' || string[i - 1] == '\r');
          }
        else
          {
            return YES;
          }
      }
      break;
    case EndingOfLineTextPatternItem:
      {
        unsigned int i = *offset;

        if (i + 1 < stringLength)
          {
            return (string[i + 1] == '\n' || string[i + 1] == '\r');
          }
        else
          {
            return YES;
          }
      }
      break;
    }

/*  [NSException raise: NSInternalInconsistencyException
              format: _(@"Unknown text pattern item type %i encountered."),
    item->type];*/

  return NO;
}

/**
 * Test whether a specified text pattern is present in a string.
 * 
 *
 * @param pattern The text pattern which to test.
 * @param string The string buffer in which to look for the pattern.
 * @param stringLength The length of the string buffer.
 * @param index The index in the string buffer at which to look for
 *      the text pattern.
 *
 * @return The number of characters in the string buffer which
 *      the text pattern occupies, or 0 in case the text pattern
 *      wasn't found.
 */
unsigned int
HKCheckTextPatternPresenceInString (HKTextPattern * pattern,
                                    unichar * string,
                                    unsigned int stringLength,
                                    unsigned int index)
{
  unsigned int i, off;

  off = index;

  for (i = 0; i < pattern->nItems; i++)
    {
      if (!CheckTextPatternItemPresence(pattern->items[i],
                                        string,
                                        stringLength,
                                        &off))
        {
          break;
        }
    }

  if (i == pattern->nItems)
    {
      return off - index;
    }
  else
    {
      return 0;
    }
}

/**
 * Queries which characters can appear the beginning of a particular
 * text pattern.
 *
 * @param pattern The text pattern which to query.
 *
 * @return The following can occur:
 * - In case the text pattern has a finite set of beginning characters,
 *      a zero-terminated buffer of characters is returned, containing the
 *      possible opening characters
 * - In case the text pattern has an infinite set of beginning characters
 *      (such as a text pattern beginning with "."), -1 is returned instead.
 * - In case the text pattern cannot start with any character (e.g. a
 *      meaningless pattern like "<"), NULL is returned instead.
 */
unichar *
HKPermissibleCharactersAtPatternBeginning (HKTextPattern * pattern)
{
  unsigned int i;

  for (i = 0; i < pattern->nItems; i++)
    {
      switch (pattern->items[i]->type)
        {
        case SingleCharacterTextPatternItem:
          {
            unichar * buf;

            buf = malloc (2 * sizeof (unichar));
            buf[0] = pattern->items[i]->data.singleChar;
            buf[1] = 0;

            return buf;
          }
        case MultipleCharactersTextPatternItem:
          {
            unichar * buf;
            unsigned int n = pattern->items[i]->data.multiChar.nCharacters + 1;

            buf = malloc (n * sizeof (unichar));
            memcpy (buf, pattern->items[i]->data.multiChar.characters, n *
              sizeof (unichar));
            buf[n - 1] = 0;

            return buf;
          }
        case AnyCharacterTextPatternItem:
          return (unichar *) -1;

        default: break;
        }
    }

  return NULL;
}

/**
 * Tests whether two text patterns are equal.
 *
 * @param pattern1 The first text pattern which to compare.
 * @param pattern2 The second text pattern which to compare.
 *
 * @return YES if the text patterns are equal, NO if they aren't.
 */
BOOL
HKTextPatternsEqual (HKTextPattern * pattern1, HKTextPattern * pattern2)
{
  return [pattern1->string isEqualToString: pattern2->string];
}
