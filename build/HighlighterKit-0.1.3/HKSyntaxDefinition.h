/*
    HKSyntaxDefinition.h

    Interface declaration of the HKSyntaxDefinition class for the
    HighlighterKit framework.

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

#import <Foundation/NSObject.h>

#import "HKTextPattern.h"

@class NSColor, NSArray;

@interface HKSyntaxDefinition : NSObject
{
  HKTextPattern ** contextBeginnings;
  char contextBeginningChars[128];

  HKTextPattern *** contextSkips;
  char ** contextSkipChars;

  HKTextPattern ** contextEndings;
  NSArray * contextGraphics;

  // First indirection is context number, second is keyword
  // number, third is the keyword itself. Both lists are NULL pointer
  // terminated.
  HKTextPattern *** keywords;

  NSArray * keywordGraphics;
}

+ (NSString *) findSyntaxFileForType: (NSString *) type;
+ (HKSyntaxDefinition *) syntaxDefinitionForType: (NSString *) type;
+ (void) themeDidChange;

- (id) initWithContextList: (NSArray *) contexts;

// Obtaining context starting, ending and skips
- (HKTextPattern **) contextBeginnings;
- (const char *) contextBeginningCharacters;
- (unsigned int) numberOfContextBeginningCharacters;

- (const char *) contextSkipCharactersForContext: (unsigned int) ctxt;
- (unsigned int) numberOfContextSkipCharactersForContext: (unsigned int) ctxt;

- (HKTextPattern **) contextSkipsForContext: (unsigned int) ctxt;
- (HKTextPattern *) contextEndingForContext: (unsigned int) ctxt;

// Inquiring about graphical attributes of contexts
- (NSColor *) foregroundColorForContext: (unsigned int) context;
- (NSColor *) backgroundColorForContext: (unsigned int) context;
- (BOOL) isItalicFontForContext: (unsigned int) context;
- (BOOL) isBoldFontForContext: (unsigned int) context;

// Obtaining keyword patterns
- (HKTextPattern **) keywordsInContext: (unsigned int) context;

// Inquiring about graphical attributes of keywords
- (NSColor *) foregroundColorForKeyword: (unsigned int) keyword
                              inContext: (unsigned int) context;
- (NSColor *) backgroundColorForKeyword: (unsigned int) keyword
                              inContext: (unsigned int) context;
- (BOOL) isItalicFontForKeyword: (unsigned int) keyword
                      inContext: (unsigned int) context;
- (BOOL) isBoldFontForKeyword: (unsigned int) keyword
                    inContext: (unsigned int) context;

@end
