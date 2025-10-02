/*
    HKSyntaxDefinition.h

    Implementation of the HKSyntaxDefinition class for the HighlighterKit
    framework.

    Copyright (C) 2005, 2006, 2007, 2008, 2012  Saso Kiselkov, German Arias

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

#import "HKSyntaxDefinition.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSValue.h>

#import <AppKit/NSColor.h>

static NSDictionary *
ParseSyntaxGraphics (NSDictionary * specification)
{
  NSMutableDictionary * dict = [NSMutableDictionary dictionary];
  NSString * value;

  value = [specification objectForKey: @"ForegroundColor"];
  if (value != nil)
    {
      float r, g, b, a;
      NSScanner * scanner = [NSScanner scannerWithString: value];

      if ([scanner scanFloat: &r] && [scanner scanFloat: &g] &&
          [scanner scanFloat: &b])
        {
          if ([scanner scanFloat: &a] == NO)
            {
              a = 1.0;
            }

          [dict setObject: [NSColor colorWithCalibratedRed: r
                                                     green: g
                                                      blue: b
                                                     alpha: a]
                   forKey: @"ForegroundColor"];
        }
      else
        {
          NSLog(_(@"Invalid ForegroundColor specification \"%@\" found: "
                  @"the correct format is \"r g b [a]\" where each component"
                  @"is a real number in the range of 0.0 thru 1.0 inclusive, "
                  @"specifying the red, green, blue and alpha (optional) "
                  @"components of the desired color."), value);
        }
    }

  value = [specification objectForKey: @"BackgroundColor"];
  if (value != nil)
    {
      float r, g, b, a;
      NSScanner * scanner = [NSScanner scannerWithString: value];

      if ([scanner scanFloat: &r] && [scanner scanFloat: &g] &&
          [scanner scanFloat: &b])
        {
          if ([scanner scanFloat: &a] == NO)
            {
              a = 1.0;
            }

          [dict setObject: [NSColor colorWithCalibratedRed: r
                                                     green: g
                                                      blue: b
                                                     alpha: a]
                   forKey: @"BackgroundColor"];
        }
      else
        {
          NSLog(_(@"Invalid BackgroundColor specification \"%@\" found: "
                  @"the correct format is \"r g b [a]\" where each component"
                  @"is a real number in the range of 0.0 thru 1.0 inclusive, "
                  @"specifying the red, green, blue and alpha (optional) "
                  @"components of the desired color."), value);
        }
    }

  value = [specification objectForKey: @"Bold"];
  if (value != nil)
    {
      [dict setObject: [NSNumber numberWithBool: [value boolValue]]
               forKey: @"Bold"];
    }

  value = [specification objectForKey: @"Italic"];
  if (value != nil)
    {
      [dict setObject: [NSNumber numberWithBool: [value boolValue]]
               forKey: @"Italic"];
    }

  return [[dict copy] autorelease];
}

static void
MarkTextPatternBeginningCharacters (HKTextPattern * pattern,
                                    char * buffer, unsigned int bufSize)
{
  unichar * chars = HKPermissibleCharactersAtPatternBeginning (pattern);

  if (chars == (unichar *) -1)
    {
      memset(buffer, 1, 128);
    }
  else if (chars != NULL)
    {
      unsigned int i;
      unichar c;

      for (i = 0; (c = chars[i]) != 0; i++)
        {
          if (c < bufSize)
            {
              buffer[c] = 1;
            }
        }

      free(chars);
    }
}

static NSMutableDictionary * syntaxDefinitions = nil;

/**
 * Tries to find a syntax file in any of the passed bundles.
 *
 * @param bundles An array of bundles to search for the syntax file.
 * @param type The syntax type name to look for. The lookup is done by
 *      taking all the resources with a .syntax extension from each
 *      bundle and comparing their file-extension stripped basename
 *      case-insensitively with the passed syntax type name.
 *
 * @return An absolute path to the syntax file if it is found, otherwise `nil'.
 */
static NSString *
SearchBundlesForSyntaxFile (NSArray *bundles, NSString *type)
{
  NSEnumerator *e = [bundles objectEnumerator];
  NSBundle *bundle;

  while ((bundle = [e nextObject]) != nil)
    {
      NSString * file;

      NSEnumerator *e2 = [[bundle pathsForResourcesOfType: @"syntax" inDirectory: nil]
        objectEnumerator];
      while ((file = [e2 nextObject]) != nil)
        {
          if ([[[[file lowercaseString] lastPathComponent]
            stringByDeletingPathExtension] isEqualToString: type])
            {
              return file;
            }
        }
    }

  return nil;
}

/**
 * This class representas a compiled syntax definition file and is needed
 * by the HighlighterKit internals in order to do any syntax highlighting.
 */
@implementation HKSyntaxDefinition

+ (void) initialize
{
  if (self == [HKSyntaxDefinition class])
    {
      syntaxDefinitions = [NSMutableDictionary new];
    }
}

/**
 * Locates a syntax file of the apropriate type and returns it's path.
 *
 * This method is used when creating syntax definitions of a certain
 * type. Syntax files can be placed in a variety of places in the file
 * system so that this method will find them:
 *
 * - in one of the system's domains in the 'Library/SyntaxDefinitions'
 *   subdirectory (or any of it's subdirectories)
 * - in the application's main bundle as a resource
 * - in this framework's bundle as a resource
 *
 * The syntax file is matched by looking at the file's extension - it must
 * say "syntax". Then the `type' argument is matched against the file's
 * name (in a case insensitive manner) - they must match. After that a
 * path to the file is returned.
 *
 * @param type The syntax file type which to look for.
 *
 * @return If found, a path to the syntax file, or `nil' if not.
 */
+ (NSString *) findSyntaxFileForType: (NSString *) type
{
  NSEnumerator * e;
  NSString *directory;
  NSString *file;
  NSFileManager * fm = [NSFileManager defaultManager];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  // make the search case insensitive
  type = [type lowercaseString];

  if ([defaults stringForKey: @"HKTheme"] == nil)
    {
      // first we look into all the app's bundles, as they might contain
      // the latest version of the syntax file
      file = SearchBundlesForSyntaxFile ([NSBundle allBundles], type);
      if (file)
	return file;
      
      // search all domains for the matching .syntax file
      e = [NSSearchPathForDirectoriesInDomains (NSLibraryDirectory,
						NSAllDomainsMask, YES) objectEnumerator];
      while ((directory = [e nextObject]) != nil)
	{
	  NSString * subpath = [directory stringByAppendingPathComponent:
					    @"SyntaxDefinitions"];
	  BOOL dir;
	  
	  if ([fm fileExistsAtPath: subpath isDirectory: &dir] && dir)
	    {
	      NSDirectoryEnumerator * de = [fm enumeratorAtPath: subpath];
	      NSString * origPath;
	      
	      while ((origPath = [de nextObject]) != nil)
		{
		  NSString *path;
		  origPath = [subpath stringByAppendingPathComponent: origPath];
		  
		  path = [origPath lowercaseString];
		  
		  if ([[path pathExtension] isEqualToString: @"syntax"] &&
		      [[[path lastPathComponent] stringByDeletingPathExtension]
			isEqualToString: type] &&
		      [[[de fileAttributes] fileType] isEqualToString:
							NSFileTypeRegular])
		    {
		      return origPath;
		    }
		}
	    }
	}
      
      // frameworks are search last
      file = SearchBundlesForSyntaxFile ([NSBundle allFrameworks], type);
      if (file)
	return file;
    }
  else
    {
      NSString *subpath = [defaults stringForKey: @"HKTheme"];
      BOOL dir;

      if ([fm fileExistsAtPath: subpath isDirectory: &dir] && dir)
	{
	  NSDirectoryEnumerator *de = [fm enumeratorAtPath: subpath];
	  NSString *origPath;
	  
	  while ((origPath = [de nextObject]) != nil)
	    {
	      NSString *path;
	      origPath = [subpath stringByAppendingPathComponent: origPath];
	      
	      path = [origPath lowercaseString];
	      
	      if ([[path pathExtension] isEqualToString: @"syntax"] &&
		  [[[path lastPathComponent] stringByDeletingPathExtension]
			isEqualToString: type] &&
		  [[[de fileAttributes] fileType] isEqualToString:
						    NSFileTypeRegular])
		{
		  return origPath;
		}
	    }
	}
    }

  // not found
  return nil;
}

/**
 * Retrieves a syntax definition of the specified type.
 *
 * It is better if you use this method instead of constructing syntax
 * definition objects by hand, since this method uses the standardized
 * search algorithms for syntax files (see +[HKSyntaxDefinition
 * findSyntaxFileForType:]) and also caches the resulting
 * syntax definition (syntax definitions are, by nature, immutable),
 * making later queries faster.
 *
 * @param type The syntax type name from which to construct the definition.
 *
 * @return The syntax definition, if it was found. If it wasn't, then `nil'.
 */
+ (HKSyntaxDefinition *) syntaxDefinitionForType: (NSString *) type
{
  HKSyntaxDefinition * def;

  def = [syntaxDefinitions objectForKey: type];
  if (def == nil)
    {
      NSString * file = [self findSyntaxFileForType: type];
      NSDictionary * contents = [NSDictionary
        dictionaryWithContentsOfFile: file];

      if (contents != nil && [contents objectForKey: @"Contexts"] != nil)
        {
          def = [[[HKSyntaxDefinition alloc]
            initWithContextList: [contents objectForKey: @"Contexts"]]
            autorelease];

          if (def != nil)
            {
              [syntaxDefinitions setObject: def forKey: type];
            }

          return def;
        }
      else
        {
          return nil;
        }
    }
  else
    {
      return def;
    }
}

/**
 * Clean syntaxDefinitions, so this can be created with the new path 
 * of syntax files.
 */
+ (void) themeDidChange
{
  [syntaxDefinitions removeAllObjects];
}

/**
 * Initializes a syntax definition manually.
 *
 * @param contexts An array of context definitions as found in the
 *      `Contexts' key of a syntax definition file.
 *
 * @return Self if initialization succeeded, `nil' otherwise.
 */
- (id) initWithContextList: (NSArray *) contexts
{
  if ((self = [self init]) != nil)
    {
      unsigned int i, n;
      NSMutableArray * contextGraphicsTmp = [NSMutableArray array],
                     * keywordGraphicsTmp = [NSMutableArray array];

      // compile the syntax definition
      for (i = 0, n = [contexts count]; i < n; i++)
        {
          unsigned int j, keywordCount, skipCount;
          NSDictionary * context = [contexts objectAtIndex: i];
          NSArray * ctxtKeywords, * skips;
          NSMutableArray * contextKeywordsGraphicsTmp;

          // context beginning/ending missing?
          if (([context objectForKey: @"Beginning"] == nil ||
               [context objectForKey: @"Ending"] == nil) &&
              i > 0)
            {
              NSLog(@"Syntax compilation error: context beginning or ending symbol missing.");

              [self release];
              return nil;
            }

          // process context beginnings/endings
          if (i > 0)
            {
              contextBeginnings = realloc(contextBeginnings, i *
                sizeof(HKTextPattern *));
              contextBeginnings[i - 1] = HKCompileTextPattern([context
                objectForKey: @"Beginning"]);

              MarkTextPatternBeginningCharacters(contextBeginnings[i - 1],
                contextBeginningChars, sizeof(contextBeginningChars));

              contextEndings = realloc(contextEndings, i *
                sizeof(HKTextPattern *));
              contextEndings[i - 1] = HKCompileTextPattern([context
                objectForKey: @"Ending"]);
            }

          // process context skips
          contextSkipChars = realloc(contextSkipChars, (i + 1) *
            sizeof(char *));
          contextSkipChars[i] = calloc(128, sizeof(char));
          contextSkips = realloc(contextSkips, sizeof(HKTextPattern **) *
            (i + 1));
          contextSkips[i] = NULL;
          skips = [context objectForKey: @"ContextSkips"];
          for (j = 0, skipCount = [skips count]; j < skipCount; j++)
            {
              NSString * skip = [skips objectAtIndex: j];

              contextSkips[i] = realloc(contextSkips[i], (j + 1) *
                sizeof(HKTextPattern *));
              contextSkips[i][j] = HKCompileTextPattern(skip);
              MarkTextPatternBeginningCharacters(contextSkips[i][j],
                contextSkipChars[i], 128);
            }
          contextSkips[i] = realloc(contextSkips[i], (j + 1) *
            sizeof(HKTextPattern *));
          contextSkips[i][j] = NULL;

          // process context graphics
          [contextGraphicsTmp addObject: ParseSyntaxGraphics(context)];

          keywords = realloc(keywords, (i + 1) * sizeof(HKTextPattern **));
          keywords[i] = NULL;

          ctxtKeywords = [context objectForKey: @"Keywords"];
          contextKeywordsGraphicsTmp = [NSMutableArray arrayWithCapacity:
            [ctxtKeywords count]];

          // run through all keywords in the context
          for (j = 0, keywordCount = [ctxtKeywords count];
               j < keywordCount;
               j++)
            {
              NSDictionary * keyword = [ctxtKeywords objectAtIndex: j];
              NSString * keywordString = [keyword objectForKey: @"Pattern"];
              HKTextPattern * pattern;

              if (keywordString == nil)
                {
                  NSLog(_(@"Missing keyword pattern declaration "
                          @"in context %i keyword %i. Ignoring all the "
                          @"remaining of the keywords in this context."),
                          i, j);
                  break;
                }
              pattern = HKCompileTextPattern(keywordString);
              if (pattern == NULL)
                {
                  break;
                }

              keywords[i] = realloc(keywords[i],
                                    (j + 1) * sizeof(HKTextPattern *));
              keywords[i][j] = pattern;

              [contextKeywordsGraphicsTmp addObject:
                ParseSyntaxGraphics(keyword)];
            }

          // append a trailing NULL to terminate the list
          keywords[i] = realloc(keywords[i], (j + 1) * sizeof(HKTextPattern *));
          keywords[i][j] = NULL;

          [keywordGraphicsTmp addObject: [[contextKeywordsGraphicsTmp
            copy] autorelease]];
        }

      // terminate the keywords array by appending a trailing NULL pointer
      keywords = realloc(keywords, (i + 1) * sizeof(HKTextPattern **));
      keywords[i] = NULL;

      // begining and ending arrays don't include the default context!
      // Thus it is indexed by 'i' not 'i + 1'
      contextBeginnings = realloc(contextBeginnings, i *
        sizeof(HKTextPattern **));
      contextBeginnings[i - 1] = NULL;
      contextEndings = realloc(contextEndings, i * sizeof(HKTextPattern **));
      contextEndings[i - 1] = NULL;

      contextSkipChars = realloc(contextSkipChars, (i + 1) * sizeof(char *));
      contextSkipChars[i] = NULL;

      ASSIGNCOPY (contextGraphics, contextGraphicsTmp);
      ASSIGNCOPY (keywordGraphics, keywordGraphicsTmp);

      return self;
    }
  else
    {
      return nil;
    }
}

- (void) dealloc
{
  HKTextPattern * pattern;
  unsigned int i;
  HKTextPattern ** patternList;
  char * buf;

  // free context beginnings
  for (i = 0; (pattern = contextBeginnings[i]) != NULL; i++)
    {
      HKFreeTextPattern (pattern);
    }
  free (contextBeginnings);

  // free context endings
  for (i = 0; (pattern = contextEndings[i]) != NULL; i++)
    {
      HKFreeTextPattern (pattern);
    }
  free (contextEndings);

  // free context skip characters
  for (i = 0; (buf = contextSkipChars[i]) != NULL; i++)
    {
      free (buf);
    }
  free (contextSkipChars);

  // free context skips
  for (i = 0; (patternList = contextSkips[i][0]) != NULL; i++)
    {
      unsigned int j;
      
      for (j = 0; (pattern = patternList[j]) != NULL; j++)
	{
	  HKFreeTextPattern (pattern);
	}
      free (patternList);
    }
  free (contextSkips);
  
  // free keywords
  for (i = 0; (patternList = keywords[i]) != NULL; i++)
    {
      unsigned int j;

      for (j = 0; (pattern = patternList[j]) != NULL; j++)
        {
          HKFreeTextPattern (pattern);
        }

      free (patternList);
    }
  free (keywords);

  TEST_RELEASE (contextGraphics);
  TEST_RELEASE (keywordGraphics);

  [super dealloc];
}

/**
 * Returns a NULL pointer terminated list of context beginning symbols.
 */
- (HKTextPattern **) contextBeginnings
{
  return contextBeginnings;
}

/**
 * Returns an array of characters which might start a context.
 */
- (const char *) contextBeginningCharacters
{
  return contextBeginningChars;
}

/**
 * Returns the number of elements in the array returned by
 * -[HKSyntaxDefinition contextBeginningCharacters].
 */
- (unsigned int) numberOfContextBeginningCharacters
{
  return sizeof(contextBeginningChars);
}

/**
 * For a given context, returns the characters which should be
 * skipped when searching for a context ending.
 */
- (const char *) contextSkipCharactersForContext: (unsigned int) ctxt
{
  return contextSkipChars[ctxt];
}

/**
 * Returns the number of elements in the array returned by
 * -[HKSyntaxDefinition contextSkipCharactersForContext:].
 */
- (unsigned int) numberOfContextSkipCharactersForContext: (unsigned int) ctxt
{
  return 128;
}

/**
 * Returns the context ending symbol for the context identified by `ctxt'.
 */
- (HKTextPattern *) contextEndingForContext: (unsigned int) ctxt
{
  return contextEndings[ctxt];
}

/**
 * Returns a NULL pointer terminated list of text patterns which
 * represent the patters the parser should skip when looking for
 * context ends.
 */
- (HKTextPattern **) contextSkipsForContext: (unsigned int) ctxt
{
  return contextSkips[ctxt];
}

/**
 * Returns the foreground color for a given context.
 */
- (NSColor *) foregroundColorForContext: (unsigned int) context
{
  return [[contextGraphics
    objectAtIndex: context]
    objectForKey: @"ForegroundColor"];
}

/**
 * Returns the background color for a given context.
 */
- (NSColor *) backgroundColorForContext: (unsigned int) context
{
  return [[contextGraphics
    objectAtIndex: context]
    objectForKey: @"BackgroundColor"];
}

/**
 * Returns YES if an italic (or slanted) font should be used to draw
 * the contents of a context.
 */
- (BOOL) isItalicFontForContext: (unsigned int) context
{
  return [[[contextGraphics
    objectAtIndex: context]
    objectForKey: @"Italic"]
    boolValue];
}

/**
 * Returns YES if a bold font should be used to draw the contents
 * of a context.
 */
- (BOOL) isBoldFontForContext: (unsigned int) context
{
  return [[[contextGraphics
    objectAtIndex: context]
    objectForKey: @"Bold"]
    boolValue];
}

/**
 * Returns a NULL pointer terminated list of text patterns representing
 * keywords to be matched inside context `context'.
 */
- (HKTextPattern **) keywordsInContext: (unsigned int) context
{
  return keywords[context];
}

/**
 * Returns the color with which the keyword identified by `keyword'
 * in `contextName' should be colored. The argument `keyword' is the
 * index of the keyword in the array returned by -keywordsInContext:.
 */
- (NSColor *) foregroundColorForKeyword: (unsigned int) keyword
                              inContext: (unsigned int) context
{
  return [[[keywordGraphics
    objectAtIndex: context]
    objectAtIndex: keyword]
    objectForKey: @"ForegroundColor"];
}

/**
 * Returns the background color with which the keyword identified by
 * `keyword' in `contextName' should be colored. The argument `keyword'
 * is the index of the keyword in the array returned by -keywordsInContext:.
 */
- (NSColor *) backgroundColorForKeyword: (unsigned int) keyword
                              inContext: (unsigned int) context
{
  return [[[keywordGraphics
    objectAtIndex: context]
    objectAtIndex: keyword]
    objectForKey: @"BackgroundColor"];
}

/**
 * Returns YES if the font with which the keyword identified by `keyword'
 * should be italic (or slanted) and NO if it should be normal.
 */
- (BOOL) isItalicFontForKeyword: (unsigned int) keyword
                      inContext: (unsigned int) context
{
  return [[[[keywordGraphics
    objectAtIndex: context]
    objectAtIndex: keyword]
    objectForKey: @"Italic"]
    boolValue];
}

/**
 * Returns YES if the font with which the keyword identified by `keyword'
 * should be bold and NO if it should be normal weigth.
 */
- (BOOL) isBoldFontForKeyword: (unsigned int) keyword
                    inContext: (unsigned int) context
{
  return [[[[keywordGraphics
    objectAtIndex: context]
    objectAtIndex: keyword]
    objectForKey: @"Bold"]
    boolValue];
}

@end
