/*
    HKSyntaxHighlighter.h

    Interface declaration of the HKSyntaxHighlighter class for the
    HighlighterKit framework.

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
#import <Foundation/NSRange.h>
#import <Foundation/NSCharacterSet.h>

@class NSNotification,
       NSDictionary,
       NSMutableDictionary,
       NSString,
       NSTextStorage;

@class NSFont,
       NSColor;

@class HKSyntaxDefinition;

@interface HKSyntaxHighlighter : NSObject
{
  NSTextStorage * textStorage;
  HKSyntaxDefinition * syntax;

  NSFont * normalFont,
         * boldFont,
         * italicFont,
         * boldItalicFont;
  NSColor * defaultTextColor;

  unsigned int lastProcessedContextIndex;

  NSRange delayedProcessedRange;
  BOOL didBeginEditing;
}

+ (NSFont *) defaultFont;
+ (NSFont *) defaultBoldFont;
+ (NSFont *) defaultItalicFont;
+ (NSFont *) defaultBoldItalicFont;

- (id) initWithHighlighterType: (NSString *) type
                   textStorage: (NSTextStorage *) aStorage
              defaultTextColor: (NSColor *) aColor;

- (id) initWithSyntaxDefinition: (HKSyntaxDefinition *) aSyntaxDefinition
                    textStorage: (NSTextStorage *) aStorage
               defaultTextColor: (NSColor *) aColor;

- (void) highlightRange: (NSRange) r;

- (void) textStorageWillProcessEditing: (NSNotification *) notif;

@end
