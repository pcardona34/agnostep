/* 
   Copyright (C) 2013 German A. Arias <germanandre@gmx.es>

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

#import <AppKit/AppKit.h>

#import <Protocols/CodeEditorView.h>

@class GemasEditor, HKSyntaxHighlighter, NSCharcterSet, NSDictionary;

@interface GemasEditorView : NSTextView <CodeEditorView>
{
  NSString *type;
  GemasEditor *editorDocument;
  HKSyntaxHighlighter *highlighter;
  NSCharacterSet *openCharacters, *closeCharacters, *indentCharacters,
   *backIndentCharacters, *otherIndentCharacters;
  NSDictionary *nonEnglishCharacters;
}

- (void) setEditor: (GemasEditor *)anEditor;
- (GemasEditor *) editor;
- (void) createSyntaxHighlighterForFileType: (NSString *)fileType;
- (NSRect) selectionRect;

- (void) openGoToLinePanel: (id)sender;
- (void) goToLine: (id) sender;

- (void) keyDown: (NSEvent*)theEvent;

@end
