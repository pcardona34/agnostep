/* 
   Copyright (C) 2013, 2014 German A. Arias <germanandre@gmx.es>

   This file is part of Gemas application

   Gemas is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "GemasEditor.h"
#import "GemasEditorView.h"
#import <Foundation/Foundation.h>
#import <HighlighterKit/HighlighterKit.h>

static NSPanel *panel = nil;

@interface GemasEditorView (Private)

- (NSString *) indentForCloseBracket;
- (BOOL) isGSmarkupIndent: (NSString *)string;
- (BOOL) isGSmarkupBackIndent: (NSString *)string;
- (void) insertSpace;

@end

@implementation GemasEditorView (Private)

- (NSString *) indentForCloseBracket
{
  NSUInteger start;
  NSString *selection = @"}", *search = @"{" ;
  NSRange firstClose, firstOpen;
  NSRange textRange = [self selectedRange];
  
  NSString *contextA, *contextB, *sub;
  NSString *context = [[self string] substringFromRange: NSMakeRange(0, textRange.location)];
  
  firstOpen = [context rangeOfString: search options: NSBackwardsSearch];
  firstClose = [context rangeOfString: selection options: NSBackwardsSearch];
  
  // If no open bracket return nil.
  if (firstOpen.location == NSNotFound)
    {
      return nil;
    }

  while ((firstOpen.location < firstClose.location) &&
               (firstClose.length != 0) && (firstClose.length != 0))
    {
      contextA = [[self string] substringFromRange: NSMakeRange(0, firstOpen.location)];
      contextB = [[self string] substringFromRange: NSMakeRange(0, firstClose.location)];
      
      firstOpen = [contextA rangeOfString: search options: NSBackwardsSearch];
      firstClose = [contextB rangeOfString: selection options: NSBackwardsSearch];
    }
  
  // If there isn't a corresponding open bracket return nil.
  if (firstOpen.location == NSNotFound)
    {
      return nil;
    }
  
  start = [[[self string] substringToIndex: firstOpen.location]
                                          rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]
                                                                            options: NSBackwardsSearch].location;
  
  if (start == NSNotFound)
    {
      start = -1;
    }
  
  sub = [[self string] substringFromRange: NSMakeRange(start + 1, firstOpen.location - start - 1)];
  
  if ([[sub stringByTrimmingLeadSpaces] length] > 0)
    {
      return nil;
    }
  else
    {
      return sub;
    }
}

- (BOOL) isGSmarkupIndent: (NSString *)string
{
  if ([type isEqualToString: @"GSmarkup"])
    {
      if ([string hasPrefix: @"<"] &&
          [string hasSuffix: @">"] &&
          ![string hasPrefix: @"<!"] &&
          ![string hasPrefix: @"<?"] &&
          ![string hasPrefix: @"</"] &&
          ![string hasSuffix: @"/>"] &&
          ![string hasSuffix: @"</label>"] &&
          ![string hasSuffix: @"</textField>"] &&
          ![string hasSuffix: @"</secureTextField>"])
        {
          return YES;
        }
      else
        {
          return NO;
        }
    }
  else
    {
      return NO;
    }
}

- (BOOL) isGSmarkupBackIndent: (NSString *)string
{
  return NO;
}

- (void) insertSpace
{
  switch ([[NSUserDefaults standardUserDefaults] integerForKey: @"Indentation"])
    {
    case 0: // 2 spaces
      [super insertText: @"  "];
      break;
    case 1: // 4 spaces
      [super insertText: @"    "];
      break;
    }
}

@end

@implementation GemasEditorView

// ---
- (BOOL) becomeFirstResponder
{
  return [editorDocument becomeFirstResponder: self];
}

- (BOOL) resignFirstResponder
{
  return [editorDocument resignFirstResponder: self];
}

- (BOOL) acceptsFirstMouse: (NSEvent *)theEvent
{
  return YES;
}
// ---

- (void)setEditor: (GemasEditor *)anEditor
{
  editorDocument = anEditor;
}

- (GemasEditor *) editor
{
  return editorDocument;
}

- (NSRect) selectionRect
{
  return _insertionPointRect;
}
//---

// The code below is the same as in Gemas editor.
- (void) dealloc
{
  TEST_RELEASE(highlighter);
  TEST_RELEASE(openCharacters);
  TEST_RELEASE(closeCharacters);
  TEST_RELEASE(indentCharacters);
  TEST_RELEASE(backIndentCharacters);
  TEST_RELEASE(otherIndentCharacters);
  TEST_RELEASE(nonEnglishCharacters);
  TEST_RELEASE(type);
  [super dealloc];
}

- (void) awakeFromNib
{
  openCharacters = [NSCharacterSet characterSetWithCharactersInString: @"[{("];
  [openCharacters retain];
  closeCharacters = [NSCharacterSet characterSetWithCharactersInString: @"]})"];
  [closeCharacters retain];
  indentCharacters = [NSCharacterSet characterSetWithCharactersInString: @"{"];
  [indentCharacters retain];
  backIndentCharacters = [NSCharacterSet characterSetWithCharactersInString: @"}"];
  [backIndentCharacters retain];
  otherIndentCharacters = [NSCharacterSet characterSetWithCharactersInString: @"|&"];
  [otherIndentCharacters retain];
  
  //Dictionary for foreing characters
  NSBundle *bundle = [NSBundle bundleForClass: NSClassFromString(@"GemasEditor")];
  nonEnglishCharacters = [NSDictionary dictionaryWithContentsOfFile:
                           [bundle pathForResource: @"nonEnglishCharacters" ofType: @"plist"]];
  [nonEnglishCharacters retain];
}

- (void) drawRect: (NSRect) frame
{
  NSLayoutManager *layoutManager;
  NSTextContainer *textContainer;
  NSRange drawnRange;
  
  layoutManager = [self layoutManager];
  textContainer = [self textContainer];
  drawnRange = [layoutManager glyphRangeForBoundingRect: frame
                              inTextContainer: textContainer];
  
  [highlighter highlightRange: drawnRange];
  [super drawRect: frame];
}

// Find ":" for next parameter
- (void) nextParameter: (id)sender
{
  NSRange range;
  NSUInteger loc = [self selectedRange].location;
  
  range = [[[self string] substringToIndex: loc] rangeOfString: @" "
                                             options: NSBackwardsSearch];
  
  if (range.location != NSNotFound)
    {
      NSString *line = nil;
      
      line = [[[self string] substringToIndex: loc]
                           substringFromIndex: range.location];
      
      range = [line rangeOfString: @":"];
      
      if (range.location != NSNotFound &&
           range.location < ([line length] - 1))
        {
          [self setSelectedRange: NSMakeRange(loc -
                                      ([line length] - range.location) + 1, 0)];
        }
      else
        {
          range = [[[self string] substringFromIndex: loc] rangeOfString: @":"];
          
          if (range.location != NSNotFound)
            {
              [self setSelectedRange: NSMakeRange(range.location + loc + 1, 0)];
            }
        }
    }
  else
    {
      range = [[[self string] substringFromIndex: loc] rangeOfString: @":"];
          
      if (range.location != NSNotFound)
        {
          [self setSelectedRange: NSMakeRange(range.location + loc + 1, 0)];
        }
    }
}

//Convert the key pressed in the corresponding action.
- (void) keyDown: (NSEvent*)theEvent
{
  if ([[theEvent charactersIgnoringModifiers] isEqualToString: @"p"] && 
       [theEvent modifierFlags] == NSCommandKeyMask)
    {
      [self complete: self];
    }
  else if ([[theEvent charactersIgnoringModifiers] isEqualToString: @"n"] &&
       [theEvent modifierFlags] == NSAlternateKeyMask)
    {
      [self nextParameter: self];
    }
  else if ([[theEvent charactersIgnoringModifiers] isEqualToString: @"r"] &&
       [theEvent modifierFlags] == NSAlternateKeyMask)
    {
      [self deleteToBeginningOfLine: self];
    }
  else if ([[theEvent charactersIgnoringModifiers] isEqualToString: @"q"] &&
       [theEvent modifierFlags] == NSAlternateKeyMask)
    {
      [self deleteToEndOfLine: self];
    }
  else
    {
      [super keyDown: theEvent];
    }
}

//Insert the correponding indentation when the user press Tab key
- (void) insertTab: (id)sender
{
  if (![type isEqualToString: @"GNUmakefile"] && [sender tag] != 500)
    {
      NSString *lastLine, *previousLine = nil;
      NSRange textRange;
      NSArray *lines;
      
      textRange = [self selectedRange];
      lines = [[[self string] substringFromRange: NSMakeRange(0, textRange.location)]
                     componentsSeparatedByString: @"\n"];
      
      lastLine = [lines objectAtIndex: [lines count] - 1];
      
      if ([lines count] >= 2)
        {
          previousLine = [lines objectAtIndex: [lines count] - 2];
        }
      
      if (previousLine != nil)
        {
          NSRange loc = [previousLine rangeOfString: @":"
                                            options: NSBackwardsSearch];
          
          if (loc.location != NSNotFound)
            {
              previousLine = [previousLine substringToIndex: loc.location];

              loc = [previousLine rangeOfString: @" "
                                        options: NSBackwardsSearch];
              
              if (loc.location != NSNotFound)
                {
                  NSUInteger lg;
                  NSString *insert;
                  
                  if ( (loc.location + 1) > [lastLine length])
                    {
                      lg = (loc.location + 1) - [lastLine length];

                      insert = [@"" stringByPaddingToLength: lg
                                                 withString: @" "
                                            startingAtIndex: 0];
                      
                      [super insertText: insert];
                    }
                  else
                    {
                      [self insertSpace];
                    }
                }
              else
                {
                  [self insertSpace];
                }
            }
          else
            {
              [self insertSpace];
            }          
        }
      else
        {
          [self insertSpace];
        }
    }
  else
    {
      [super insertTab: sender];
    }
}

//If the new line need indentation, add it
- (void) insertNewline: (id)sender
{
  NSString *spaceToInsert, *previousLine = nil;
  NSString *lastLine;
  NSRange textRange;
  NSArray *lines;
  
  [super insertNewline: sender];
  
  textRange = [self selectedRange];
  lines = [[[self string] substringFromRange: NSMakeRange(0, textRange.location)]
                          componentsSeparatedByString: @"\n"];

  // Get the previous line
  if ([lines count] >= 3)
    {
      previousLine = [lines objectAtIndex: [lines count] - 3];
      previousLine = [previousLine stringByReplacingOccurrencesOfString: @" "
                                   withString: @""];
    }

  // Get last line
  lastLine = [lines objectAtIndex: [lines count] - 2];

  // If last line is empy, insert a space with the same length.  
  if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] isSupersetOfSet:
               [NSCharacterSet characterSetWithCharactersInString: lastLine]])
    {
      spaceToInsert = [NSString stringWithString: lastLine];
    }
  // Else, insert a space according with the case.
  else
    {
      unichar lastChar;
      NSInteger tab = [[NSUserDefaults standardUserDefaults]
                        integerForKey: @"Indentation"];
      /* checkline is the last line with all spaces removed. So we can check the
         precense of reserved words, without worries about spaces. */
      NSString *checkLine = [lastLine stringByReplacingOccurrencesOfString: @" "
                                      withString: @""];
      
      // Get the indent of last line.
      spaceToInsert = [lastLine stringByDeletingSuffix:
                                [lastLine stringByTrimmingLeadSpaces]];
      
      // Get last char in last line.
      lastChar = [[lastLine stringByTrimmingTailSpaces] characterAtIndex:
                            [[lastLine stringByTrimmingTailSpaces] length] - 1];
      
      // Indent according with reserved word or if is a gsmarkup indent.
      if ((([indentCharacters characterIsMember: lastChar]) &&
               (![previousLine hasPrefix: @"switch("])) ||
               ([checkLine hasPrefix: @"if("]) ||
               ([checkLine hasPrefix: @"else"]) ||
               ([checkLine hasPrefix: @"while("] && ![previousLine hasPrefix: @"}"]) ||
               ([checkLine hasPrefix: @"for("]) ||
               ([checkLine isEqualToString: @"do"]) ||
               ([checkLine isEqualToString: @"default:"]) ||
               ([checkLine hasPrefix: @"switch("]) ||
               ([checkLine hasPrefix: @"case"]) ||
               ([self isGSmarkupIndent: checkLine]))
        {
          /* Check if last character is "&" or "|". If so, indent. For example, in the
             case when the condition at one "if" as multiple lines. */
          if ([otherIndentCharacters characterIsMember: lastChar] &&
               ![type isEqualToString: @"GSmarkup"])
            {
              spaceToInsert = [spaceToInsert stringByAppendingString: @"   "];
            }
          
          if (tab == 0)
            {
              spaceToInsert = [spaceToInsert stringByAppendingString: @"  "];
            }
          
          if (tab == 1)
            {
              spaceToInsert = [spaceToInsert stringByAppendingString: @"    "];
            }
        }
      else
        {
          // Check if is a case of a backindent.
          if (([backIndentCharacters characterIsMember: lastChar]) ||
              ([checkLine hasSuffix: @"break;"]) ||
              ([self isGSmarkupBackIndent: checkLine]))
            {
              if ((tab == 0) && ([spaceToInsert length] >= 2))
                {
                  spaceToInsert = [spaceToInsert stringByDeletingPrefix: @"  "];
                }
              
              if ((tab == 1) && ([spaceToInsert length] >= 4))
                {
                  spaceToInsert = [spaceToInsert stringByDeletingPrefix: @"    "];
                }
            }
          // Take care with "switch" sentence.
          else if ( !([indentCharacters characterIsMember: lastChar] &&
               [previousLine hasPrefix: @"switch("]) )
            {
              /* Don't indent if the user is closing a multiline condition.
                 For example, in an "if" sentence. */
              if (![otherIndentCharacters characterIsMember: lastChar] &&
                   lastChar != ')')
                {
                  NSString *space = [self indentForCloseBracket];
                    
                  if (space != nil)
                    {
                      if (tab == 0)
                        {
                          spaceToInsert = [space stringByAppendingString: @"  "];
                        }
                      
                      if (tab == 1)
                        {
                          spaceToInsert = [space stringByAppendingString: @"    "];
                        }
                    }
                }
            }
        }
    }

  [super insertText: spaceToInsert];
}

- (void) insertText: (id)string
{
  if ([string isKindOfClass: [NSString class]] && ([string length] > 0) )
    {
      /* Insert the corresponding code instead the character for non english
         character. */
      if ([type isEqualToString: @"Strings"] || [type isEqualToString: @"Plist"])
        {
          if ([[nonEnglishCharacters allKeys] containsObject: string])
            {
              [super insertText: [nonEnglishCharacters objectForKey: string]];
            }
          else if ([string length] > 1)
            {
              int x;
              NSString *character;
              for (x = 0; x < [string length]; x++)
                {
                  character = [string substringFromRange: NSMakeRange(x, 1)];
                  
                  if ([[nonEnglishCharacters allKeys] containsObject: character])
                    {
                      [super insertText: [nonEnglishCharacters objectForKey: character]];
                    }
                  else
                    {
                      [super insertText: character];
                    }
                }
            }
          else
            {
              [super insertText: string];
            }
        }
      // Indent the line if user insert "*" in ChangeLog files.
      else if ([type isEqualToString: @"ChangeLog"] && [string isEqualToString: @"*"])
        {
          NSRange textRange = [self selectedRange];
          NSArray *lines = [[[self string]
                              substringFromRange: NSMakeRange(0, textRange.location)]
                              componentsSeparatedByString: @"\n"];
          
          if ([[lines objectAtIndex: [lines count] - 1] length] > 0)
            {
              [super insertText: string];
            }
          else
            {
              [super insertText: @"        *"];
            }
        }
      // Indentation cases in Objective-C and GSmarkup.
      else if (([backIndentCharacters characterIsMember: [string characterAtIndex: 0]]) ||
               ([indentCharacters characterIsMember: [string characterAtIndex: 0]]) ||
               ([otherIndentCharacters characterIsMember: [string characterAtIndex: 0]]) ||
               ([string isEqualToString: @";"]) ||
               ([string isEqualToString: @"c"]) ||
               ([type isEqualToString: @"GSmarkup"] && [string isEqualToString: @"/"]))
        {
          BOOL gsmarkup = NO;
          BOOL backIndent = NO;
          BOOL backIndentCase = NO;
          NSString *prevLine, *lastLine;
          NSRange textRange = [self selectedRange];
          NSArray *lines = [[[self string]
                              substringFromRange: NSMakeRange(0, textRange.location)]
                              componentsSeparatedByString: @"\n"];
          
          // Get previous line.                   
          if ([lines count] >= 2)
            {
              prevLine = [lines objectAtIndex: [lines count] - 2];
            }
          else
            {
              prevLine = @"";
            }
          
          // Get last line.
          if ([lines count] >= 1)
            {
              lastLine = [lines objectAtIndex: [lines count] - 1];
            }
          else
            {
              lastLine = @"";
            }
          
          int length;
          NSString *stringToReplace;
          NSCharacterSet *spaces = [NSCharacterSet whitespaceCharacterSet];
          NSCharacterSet *charsLine = [NSCharacterSet characterSetWithCharactersInString:
                                                      lastLine];
          NSInteger tab = [[NSUserDefaults standardUserDefaults]
                            integerForKey: @"Indentation"];

          // Check if is a gsmarkup case.
          if ([[lastLine stringByTrimmingLeadSpaces] isEqualToString: @"<"] && 
              [type isEqualToString: @"GSmarkup"])
            {
              gsmarkup = YES;
            }

          // Check if is a backindent case with "break".
          if ([[prevLine stringByTrimmingTailSpaces] hasSuffix: @"}"] &&
              [[lastLine stringByTrimmingLeadSpaces] isEqualToString: @"break"] &&
              [string isEqualToString: @";"])
            {
              backIndent = YES;
            }
          
          // Check if is a backindent case with "case".
          if ([[prevLine stringByTrimmingLeadSpaces] hasPrefix: @"case "] &&
              [string isEqualToString: @"c"])
            {
              backIndentCase = YES;
            }
          
          // Get the string to replace, if apply.  
          if ((([lastLine length] == 0) || ([spaces isSupersetOfSet: charsLine])) ||
                 gsmarkup ||
                 backIndent)
            {
              stringToReplace = [NSString stringWithString: lastLine];
            }
          else
            {
              [super insertText: string];
              return;
            }
          
          length = [stringToReplace length];

          //Check if is a gsmarkup character
          if (gsmarkup)
            {
              // GSmarkup backIndent
              if ((tab == 0) && ([stringToReplace length] >= 3))
                {
                  stringToReplace = [stringToReplace stringByDeletingPrefix: @"  "];
                }
              
              if ((tab == 1) && ([stringToReplace length] >= 5))
                {
                  stringToReplace = [stringToReplace stringByDeletingPrefix: @"    "];
                }
            }
          // Back indent with "break".
          else if (backIndent)
            {
              if (tab == 0)
                {
                  stringToReplace = [stringToReplace stringByReplacingString: @"break"
                                                     withString: @"  break"];
                }
              
              if (tab == 1)
                {
                  stringToReplace = [stringToReplace stringByReplacingString: @"break"
                                                     withString: @"    break"];
                }
            }
          // Back indent with "case", when the user add other "case" in current line.
          else if (backIndentCase)
            {
              if ((tab == 0) && ([stringToReplace length] >= 2))
                {
                  stringToReplace = [stringToReplace stringByDeletingPrefix: @"  "];
                }
              
              if ((tab == 1) && ([stringToReplace length] >= 4))
                {
                  stringToReplace = [stringToReplace stringByDeletingPrefix: @"    "];
                }
            }
          // Check backindent for characters "{" after close a multiline condition.
          else if ([indentCharacters characterIsMember: [string characterAtIndex: 0]])
            {
              NSString *str = [[prevLine stringByTrimmingTailSpaces]
                                                 stringByTrimmingLeadSpaces];
              
              if (![str hasPrefix: @"else if"] && ![str hasPrefix: @"if"] &&
                   ![str hasPrefix: @"while"] && ![str hasPrefix: @"switch"] &&
                   ![str hasPrefix: @"for"] && [str hasSuffix: @")"] &&
                   ([stringToReplace length] >= 5))
                {
                  stringToReplace = [stringToReplace stringByDeletingPrefix: @"   "];
                }
            }
          // Check indentation of a line in a multiline condition.
          else if ([otherIndentCharacters characterIsMember: [string characterAtIndex: 0]])
            {
              NSString *str = [prevLine stringByTrimmingLeadSpaces];
              
              if ([str hasPrefix: @"else if"] || [str hasPrefix: @"if"] ||
                   [str hasPrefix: @"while"])
                {
                  stringToReplace = [stringToReplace stringByAppendingString: @"   "];
                }
            }
          else if (![string isEqualToString: @";"] && ![string isEqualToString: @"c"])
            {
              /* Back indent for "}", except after "break" which
                 backindent automatically. */
              if (![[prevLine stringByTrimmingTailSpaces] hasSuffix: @"break;"])
                {
                  if ((tab == 0) && ([stringToReplace length] >= 2))
                    {
                      stringToReplace = [stringToReplace stringByDeletingPrefix: @"  "];
                    }
                  
                  if ((tab == 1) && ([stringToReplace length] >= 4))
                    {
                      stringToReplace = [stringToReplace stringByDeletingPrefix: @"    "];
                    }
                  
                  // Backindent if the user insert "}".
                  if ([backIndentCharacters characterIsMember:
                                            [string characterAtIndex: 0]])
                    {
                      NSString *space = [self indentForCloseBracket];
                      
                      if (space != nil)
                        {
                          stringToReplace = space;
                        }
                    }
                }
            }
          
          [self replaceCharactersInRange: NSMakeRange(textRange.location - length, length)
                withString: stringToReplace];
          [super insertText: string];
        }
      else
        {
          [super insertText: string];
        }
    }
  else
    {
      [super insertText: string];
    }
}

// Delete from the beginning of line to current position
- (void) deleteToBeginningOfLine: (id)sender
{
  NSUInteger start;
  NSUInteger loc = [self selectedRange].location;
  
  start = [[[self string] substringToIndex: loc]
                          rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]
                                          options: NSBackwardsSearch].location;
  
  if (start == NSNotFound)
    {
      start = -1;
    }
  
  if (loc > start + 1)
    {
      [self setSelectedRange: NSMakeRange(start + 1, loc - start - 1)];
      [self delete: self];
    }
}

// Delete from current position to end of line
- (void) deleteToEndOfLine: (id)sender
{
  NSUInteger end;
  NSUInteger loc = [self selectedRange].location;
  
  end = [[[self string] substringFromIndex: loc]
                 rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]].location;
  
  if (end == NSNotFound)
    {
      end = [[self string] length] - 1;
    }
  
  if (end > 1)
    {
      [self setSelectedRange: NSMakeRange(loc, end)];
      [self delete: self];
    }
}

/*Select the range of parentheses when the user do a double 
  click obove one*/
- (void) mouseDown: (NSEvent *)event 
{
  NSRange textRange;
  NSString *selection;
  [super mouseDown: event];
  textRange = [self selectedRange];
  selection = [[self string] substringFromRange: textRange];

  if ([selection length] == 1)
    {
      //Open character {[(
      if ([openCharacters characterIsMember: [selection characterAtIndex: 0]])
        {
          NSString *search = nil;
          NSRange firstClose, firstOpen;
          NSString *contextA, *contextB;
          NSString *context = [[self string] substringFromRange: NSMakeRange(textRange.location + 1, [[self string] length] - textRange.location - 1)];

          if ([selection isEqualToString: @"{"])
            {
              search = @"}";
            }

          if ([selection isEqualToString: @"["])
            {
              search = @"]";
            }

          if ([selection isEqualToString: @"("])
            {
              search = @")";
            }

          firstOpen = [context rangeOfString: selection];
          firstClose = [context rangeOfString: search];

          firstOpen = NSMakeRange(firstOpen.location + 1, firstOpen.length);
          firstClose = NSMakeRange(firstClose.location + 1, firstClose.length);

          while ((firstOpen.location < firstClose.location) && (firstOpen.length != 0) && (firstClose.length != 0))
            {
              contextA = [[self string] substringFromRange: NSMakeRange(textRange.location + firstOpen.location + 1, [[self string] length] - firstOpen.location - textRange.location - 1)];
              contextB = [[self string] substringFromRange: NSMakeRange(textRange.location + firstClose.location + 1, [[self string] length] - firstClose.location - textRange.location - 1)];
              
              firstOpen = NSMakeRange([[self string] length] - [contextA length] + [contextA rangeOfString: selection].location - textRange.location, [contextA rangeOfString: selection].length);
              firstClose = NSMakeRange([[self string] length] - [contextB length] + [contextB rangeOfString: search].location - textRange.location, [contextB rangeOfString: search].length);
            }

          [self setSelectedRange: NSMakeRange(textRange.location, firstClose.location + 1)];
        }
      
      //Close character }])
      if ([closeCharacters characterIsMember: [selection characterAtIndex: 0]])
        {
          NSString *search = nil;
          NSRange firstClose, firstOpen;
          NSString *contextA, *contextB;
          NSString *context = [[self string] substringFromRange: NSMakeRange(0, textRange.location)];

          if ([selection isEqualToString: @"}"])
            {
              search = @"{";
            }

          if ([selection isEqualToString: @"]"])
            {
              search = @"[";
            }

          if ([selection isEqualToString: @")"])
            {
              search = @"(";
            }

          firstOpen = [context rangeOfString: search options: NSBackwardsSearch];
          firstClose = [context rangeOfString: selection options: NSBackwardsSearch];

          while ((firstOpen.location < firstClose.location) && (firstClose.length != 0))
            {
              contextA = [[self string] substringFromRange: NSMakeRange(0, firstOpen.location)];
              contextB = [[self string] substringFromRange: NSMakeRange(0, firstClose.location)];
              
              firstOpen = [contextA rangeOfString: search options: NSBackwardsSearch];
              firstClose = [contextB rangeOfString: selection options: NSBackwardsSearch];
              
            }
          
          [self setSelectedRange: NSMakeRange(firstOpen.location,
                          textRange.location - firstOpen.location + 1)];
        }
    }
}

- (NSRange) rangeForUserCompletion
{
  NSUInteger count = 0;
  NSRange range = [super rangeForUserCompletion];
  NSString *word = [[self string] substringWithRange: range];
  
  while ([word hasPrefix: @"["] || [word hasPrefix: @"("])
    {
      word = [word substringFromIndex: 1];
      count += 1;
    }
  
  return NSMakeRange(range.location + count, range.length - count);
}

//Creates a new syntax highlighter for the specified file type
- (void) createSyntaxHighlighterForFileType: (NSString *) fileType
{
  NSString *name = [editorDocument->_path lastPathComponent];
  NSString *ext = [editorDocument->_path pathExtension];
  

  if ([ext isEqualToString: @""])
    {
      if ([name isEqualToString: @"ChangeLog"] ||
           [name isEqualToString: @"Changelog"])
        {
          type = [NSString stringWithString: @"ChangeLog"];
        }
      else if ([name isEqualToString: @"GNUmakefile"])
        {
          type = [NSString stringWithString: @"GNUmakefile"];
        }
      else
        {
          type = [NSString stringWithString: @"Generic"];
        }
    }
  else if ([ext isEqualToString: @"c"])
    {
      type = [NSString stringWithString: @"C"];
    }
  else if ([ext isEqualToString: @"h"])
    {
      type = [NSString stringWithString: @"C-Header"];
    }
  else if ([ext isEqualToString: @"cc"] || [ext isEqualToString: @"cpp"])
    {
      type = [NSString stringWithString: @"C++"];
    }
  else if ([ext isEqualToString: @"m"])
    {
      type = [NSString stringWithString: @"ObjC"];
    }
  else if ([ext isEqualToString: @"mm"])
    {
      type = [NSString stringWithString: @"ObjC++"];
    }
  else if ([ext isEqualToString: @"plist"])
    {
      type = [NSString stringWithString: @"Plist"];
    }
  else if ([ext isEqualToString: @"strings"])
    {
      type = [NSString stringWithString: @"Strings"];
    }
  else if ([ext isEqualToString: @"gsmarkup"])
    {
      type = [NSString stringWithString: @"GSmarkup"];
    }
  else if ([ext isEqualToString: @"preamble"] || [ext isEqualToString: @"postamble"])
    {
      type = [NSString stringWithString: @"GNUmakefile"];
    }
  else
    {
      type = [NSString stringWithString: @"Generic"];
    }
  
  ASSIGN (highlighter, [[[HKSyntaxHighlighter alloc]
                          initWithHighlighterType: type
                          textStorage: [self textStorage]
                          defaultTextColor: editorDocument->textColor]
                          autorelease]);
                          
  [type retain];
}

// Go to line panel
- (void) openGoToLinePanel: (id)sender
{
  if (panel == nil)
    {
      NSTextField *field;
      NSRect rect = NSMakeRect (100, 100, 150, 30);
      NSUInteger styleMask = NSTitledWindowMask 
                             | NSClosableWindowMask;

      panel = [[NSPanel alloc] initWithContentRect: rect
                               styleMask: styleMask
                               backing: NSBackingStoreBuffered
                               defer: NO];
  
      field = [[NSTextField alloc] initWithFrame: 
                                  NSMakeRect(5, 5, 140, 20)];
      [field setAction: @selector(goToLine:)];
      [field setTarget: self];
      [[panel contentView] addSubview: field];
      [field release];
      [panel setTitle: @""];
      [panel center];
    }
  
  [panel makeKeyAndOrderFront: self];
    
}

- (void) goToLine: (id) sender
{
  NSInteger line = [sender intValue];
  [[sender window] performClose: self];
  
  if (line > 0)
    {
      [editorDocument scrollToLineNumber: line];
    }
}

@end
