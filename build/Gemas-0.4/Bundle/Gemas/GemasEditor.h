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

#import <AppKit/AppKit.h>

#import <Protocols/CodeEditor.h>
#import <Protocols/CodeParser.h>

#import <Foundation/NSRange.h>

@class NSNotification, NSString, NSFont, NSColor, GemasEditorView;

@interface GemasEditor : NSObject <CodeEditor>
{
  int             length;
  id              _editorManager;

  BOOL            _isEdited;
  BOOL            _isEditable;

  NSArray            *list;
  NSView             *_intView;   
  NSScrollView       *_intScrollView;
  GemasEditorView    *_intEditorView;
  NSString           *_categoryPath;
  NSTextField        *_line, *_column;

  // Parser
  id<CodeParser>  aParser;
  NSArray         *parserClasses;
  NSArray         *parserMethods;

  // Keep one undo manager for the editor
  NSUndoManager   *undoManager;
  
@public  
  NSMutableString *_path;
  NSColor         *textColor;
}

- (BOOL) editorShouldClose;

// Window
- (NSUndoManager *) windowWillReturnUndoManager: (NSWindow *)window;

// TextView delegate
- (BOOL) becomeFirstResponder: (GemasEditorView *)view;
- (BOOL) resignFirstResponder: (GemasEditorView *)view;
- (void) textDidChange:(NSNotification *)aNotification;
- (NSArray *) textView: (NSTextView *)aTextView completions: (NSArray *)words
  forPartialWordRange: (NSRange)range indexOfSelectedItem: (NSInteger *)index;

// Parser and scrolling
- (void) fileStructureItemSelected: (NSString *)item;  // CodeEditor protocol
- (void) scrollToClassName: (NSString *)className;
- (void) scrollToMethodName: (NSString *)methodName;
- (void) scrollToLineNumber: (unsigned int)lineNumber; // CodeEditor protocol

@end

@interface GemasEditor (UInterface)

- (void) createInternalView;
- (GemasEditorView *) createEditorViewWithFrame:(NSRect)fr;

@end

@interface GemasEditor (Menu)

- (void)pipeOutputOfCommand:(NSString *)command;
// Find
- (void) findNext:sender;
- (void) findPrevious:sender;
- (void) jumpToSelection:sender;

@end
