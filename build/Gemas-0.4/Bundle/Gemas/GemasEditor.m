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

#import <HighlighterKit/HighlighterKit.h>

#import "GemasEditor.h"
#import "GemasEditorView.h"

NSString *PCEditorDidChangeFileNameNotification = 
          @"PCEditorDidChangeFileNameNotification";

NSString *PCEditorWillOpenNotification = @"PCEditorWillOpenNotification";
NSString *PCEditorDidOpenNotification = @"PCEditorDidOpenNotification";
NSString *PCEditorWillCloseNotification = @"PCEditorWillCloseNotification";
NSString *PCEditorDidCloseNotification = @"PCEditorDidCloseNotification";

NSString *PCEditorWillChangeNotification = @"PCEditorWillChangeNotification";
NSString *PCEditorDidChangeNotification = @"PCEditorDidChangeNotification";
NSString *PCEditorWillSaveNotification = @"PCEditorWillSaveNotification";
NSString *PCEditorDidSaveNotification = @"PCEditorDidSaveNotification";
NSString *PCEditorWillRevertNotification = @"PCEditorWillRevertNotification";
NSString *PCEditorDidRevertNotification = @"PCEditorDidRevertNotification";

NSString *PCEditorDidBecomeActiveNotification = 
          @"PCEditorDidBecomeActiveNotification";
NSString *PCEditorDidResignActiveNotification = 
          @"PCEditorDidResignActiveNotification";

@implementation GemasEditor (UInterface)

- (void) setupNewDefaults
{
  NSDictionary *df = [[NSUserDefaults standardUserDefaults]
                                          persistentDomainForName: @"Gemas"];
  NSData *data;

  data = [df valueForKey: @"EditorTextColor"];
  if (data != nil)
    {
      ASSIGN (textColor, [NSKeyedUnarchiver unarchiveObjectWithData: data]);
    }
  else
    {
      ASSIGN (textColor, [NSColor blackColor]);
    }
  
  [_intEditorView setTextColor: textColor];

  data = [df valueForKey: @"EditorBackgroundColor"];
  if (data != nil)
    {
      [_intEditorView setBackgroundColor: [NSKeyedUnarchiver unarchiveObjectWithData: data]];
    }
  else
    {
      [_intEditorView setBackgroundColor: [NSColor whiteColor]];
    }

  data = [df valueForKey: @"EditorInsertionPointColor"];
  if (data != nil)
    {
      [_intEditorView setInsertionPointColor: [NSKeyedUnarchiver unarchiveObjectWithData: data]];
    }
  else
    {
      [_intEditorView setInsertionPointColor: [NSColor blackColor]];
    }
  
  data = [df valueForKey: @"EditorSelectionColor"];
  if (data != nil)
    {
      [_intEditorView setSelectedTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
        [NSKeyedUnarchiver unarchiveObjectWithData: data], NSBackgroundColorAttributeName,
        [NSColor whiteColor], NSForegroundColorAttributeName,
        nil]];
    }
  else
    {
      [_intEditorView setSelectedTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
        [NSColor grayColor], NSBackgroundColorAttributeName,
        [NSColor whiteColor], NSForegroundColorAttributeName,
        nil]];
    }


  /* Set the font here, so the textview knows beforehand the font size that
   * the highlighter will use. With this there isn't discrepancy about the
   * document size. */  
  NSString * fontName = nil;
  NSUInteger fontSize;
  NSFont * font = nil;

  fontName = [[df valueForKey: @"HKFont"] description];
  fontSize = [[[df valueForKey: @"HKFontSize"] description] floatValue];

  if (fontName != nil)
    {
      font = [NSFont fontWithName: fontName size: fontSize];
    }
  if (font == nil)
    {
      font = [NSFont userFixedPitchFontOfSize: fontSize];
    }
  
  if (font != nil)
    {
      [[NSUserDefaults standardUserDefaults]
        setObject: fontName
             forKey: @"HKFont"];
             
      [[NSUserDefaults standardUserDefaults]
        setInteger: fontSize
               forKey: @"HKFontSize"];
             
      [_intEditorView setFont: font];
    }

  //HKTheme
  if ([df valueForKey: @"HKTheme"] != nil)
    {
      [[NSUserDefaults standardUserDefaults]
        setObject: [[df valueForKey: @"HKTheme"] description]
             forKey: @"HKTheme"];
    }
  
  //Set the syntax highlighter again
  [_intEditorView createSyntaxHighlighterForFileType: [_path pathExtension]];

  [_intEditorView setNeedsDisplay: YES];
}

- (void) createInternalView
{
  NSRect rect = NSMakeRect(0, 0, 512, 320);
  NSString *text = [NSString stringWithContentsOfFile: _path];
  NSTextField *label1, *label2;
  
  // Internal view
  _intView = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 512, 345)];

  // Scroll view
  _intScrollView = [[NSScrollView alloc] initWithFrame: rect];
  [_intScrollView setHasHorizontalScroller: NO];
  [_intScrollView setHasVerticalScroller: YES];
  [_intScrollView setBorderType: NSBezelBorder];
  [_intScrollView setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];
  rect = [[_intScrollView contentView] frame];

  // Text view
  _intEditorView = [self createEditorViewWithFrame: rect];

  //Add text  
  [_intEditorView replaceCharactersInRange: NSMakeRange(0, 0)
				withString: text];
  [_intEditorView setSelectedRange: NSMakeRange(0, 0)];

  //Setup the user preferences
  [self setupNewDefaults];  

  /*
   * Setting up text view / scroll view / window
   */
  [_intScrollView setDocumentView: _intEditorView];
  [_intEditorView setNeedsDisplay: YES];
  [_intEditorView release];
  [_intView addSubview: _intScrollView];
  [_intScrollView release];
  
  // Add labels for line number and column number
  label1 = [[NSTextField alloc] initWithFrame: NSMakeRect(20, 325, 50, 20)];
  [label1 setEditable: NO];
  [label1 setBezeled: NO];
  [label1 setDrawsBackground: NO];
  [label1 setAlignment: NSLeftTextAlignment];
  [label1 setStringValue: @"Line:"];
  [label1 setAutoresizingMask: NSViewMinYMargin];
  
  _line = [[NSTextField alloc] initWithFrame: NSMakeRect(80, 325, 50, 20)];
  [_line setEditable: NO];
  [_line setBezeled: NO];
  [_line setDrawsBackground: NO];
  [_line setAlignment: NSLeftTextAlignment];
  [_line setStringValue: @"1"];
  [_line setAutoresizingMask: NSViewMinYMargin];
  
  label2 = [[NSTextField alloc] initWithFrame: NSMakeRect(140, 325, 50, 20)];
  [label2 setEditable: NO];
  [label2 setBezeled: NO];
  [label2 setDrawsBackground: NO];
  [label2 setAlignment: NSLeftTextAlignment];
  [label2 setStringValue: @"Column:"];
  [label2 setAutoresizingMask: NSViewMinYMargin];
  
  _column = [[NSTextField alloc] initWithFrame: NSMakeRect(200, 325, 50, 20)];
  [_column setEditable: NO];
  [_column setBezeled: NO];
  [_column setDrawsBackground: NO];
  [_column setAlignment: NSLeftTextAlignment];
  [_column setStringValue: @"1"];
  [_column setAutoresizingMask: NSViewMinYMargin];
  
  [_intView addSubview: label1];
  [_intView addSubview: _line];
  [_intView addSubview: label2];
  [_intView addSubview: _column];
  
  [label1 release];
  [label2 release];
  [_line release];
  [_column release];
}

- (GemasEditorView *) createEditorViewWithFrame: (NSRect)fr
{
  GemasEditorView *textView;
  NSMutableDictionary *typingAttrs;
  
  // Create the editor view
   textView = [[GemasEditorView alloc] initWithFrame: fr];
  
  /* turn off ligatures */
  typingAttrs = [[[textView typingAttributes] mutableCopy] autorelease];
  [typingAttrs setObject: [NSNumber numberWithInt: 0]
                              forKey: NSLigatureAttributeName];
  [textView setTypingAttributes: typingAttrs];
  [textView setAllowsUndo: YES];
  [textView setUsesFindPanel: YES];
  [textView setDrawsBackground: YES];

  // Autocomplete
  length = 0;
 
  [textView setEditor: self];
  [textView setMinSize: NSMakeSize(0, 0)];
  [textView setMaxSize: NSMakeSize(1e7, 1e7)];
  [textView setRichText:YES];
  [textView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [textView setTextContainerInset: NSMakeSize(5, 5)];
  [[textView textContainer] setWidthTracksTextView: YES];
  [[textView textContainer] setContainerSize: NSMakeSize(fr.size.width, 1e7)];
  [textView setEditable: _isEditable];
  [textView awakeFromNib];

  return textView;
}

@end

@implementation GemasEditor

- (id) init
{
  if ((self = [super init]))
    {
      NSBundle *bundle = [NSBundle bundleForClass:
                                               NSClassFromString(@"GemasEditor")];
      
      _intView = nil;
      _intScrollView = nil;
      _intEditorView = nil;
      _categoryPath = nil;
      parserClasses = nil;
      parserMethods = nil;
      textColor = nil;
      
      _isEdited = NO;
      NSLog([bundle bundlePath]);
      // Autocomplete list of words
      list = [NSArray arrayWithContentsOfFile:
                 [bundle pathForResource: @"words" ofType: @"plist"]];
      [list retain];

      undoManager = [[NSUndoManager alloc] init];
    }

  return self;
}

- (void)dealloc
{
#ifdef DEVELOPMENT
  NSLog(@"PCEditor: %@ dealloc", [_path lastPathComponent]);
#endif

  [[NSNotificationCenter defaultCenter] removeObserver: self];
  
  [list retain];

  [_path release];
  [_categoryPath release];
  [_intView release];

  [parserClasses release];
  [parserMethods release];
  [aParser release];
  
  [textColor release];

  [undoManager release];

  [super dealloc];
}

// --- Protocol
- (void) setParser: (id)parser
{
  ASSIGN(aParser, parser);
}

- (id) openFileAtPath: (NSString *)filePath
          editorManager: (id)editorManager
                      editable: (BOOL)editable
{
  // Inform about future file opening
  [[NSNotificationCenter defaultCenter]
              postNotificationName: PCEditorWillOpenNotification
                            object: self];

  _editorManager = editorManager;
  _path = [filePath copy];
  _isEditable = editable;

  [self createInternalView];
  [_intEditorView setDelegate: self];
  
  // File open was finished
  [[NSNotificationCenter defaultCenter]
           postNotificationName: PCEditorDidOpenNotification
                         object: self];

  return self;
}

- (id) openExternalEditor: (NSString *)editor
                             withPath: (NSString *)file
                  editorManager: (id)aDelegate
{
  NSTask         *editorTask = nil;
  NSArray        *ea = nil;
  NSMutableArray *args = nil;
  NSString       *app = nil;

  if (!(self = [super init]))
    {
      return nil;
    }

  _editorManager = aDelegate;
  _path = [file copy];

  // Task
  ea = [editor componentsSeparatedByString: @" "];
  args = [NSMutableArray arrayWithArray: ea];
  app = [ea objectAtIndex: 0];

  [[NSNotificationCenter defaultCenter]
         addObserver: self
                  selector: @selector(externalEditorDidClose:)
                      name: NSTaskDidTerminateNotification
                    object: nil];

  editorTask = [[NSTask alloc] init];
  [editorTask setLaunchPath: app];
  [args removeObjectAtIndex: 0];
  [args addObject: file];
  [editorTask setArguments: args];
  
  [editorTask launch];
//  AUTORELEASE(editorTask);

  // Inform about file opening
  [[NSNotificationCenter defaultCenter]
             postNotificationName: PCEditorDidOpenNotification
                                        object: self];

  return self;
}
// --- Protocol End

- (void) externalEditorDidClose: (NSNotification *)aNotif
{
  NSString *path = [[[aNotif object] arguments] lastObject];

  if (![path isEqualToString:_path])
    {
      NSLog(@"external editor task terminated");
      return;
    }
    
  NSLog(@"Our Editor task terminated");

  // Inform about closing
  [[NSNotificationCenter defaultCenter] 
         postNotificationName: PCEditorDidCloseNotification
                                    object: self];
}

// CodeEditor protocol

// --- Accessor methods
- (id) editorManager
{
  return _editorManager;
}

- (NSWindow *) editorWindow
{
  return nil;
}

- (NSView *) editorView 
{
  if (!_intScrollView)
    {
      [self createInternalView];
    }

  return _intEditorView;
}

- (NSView *) componentView
{
  if (_intView == nil)
    {
      [self createInternalView];
    }

  return _intView;
}

- (NSString *) path
{
  return _path;
}

- (void) setPath: (NSString *)path
{
  NSMutableDictionary *notifDict = [[NSMutableDictionary dictionary] retain];

  // Prepare notification object
  [notifDict setObject: self forKey: @"Editor"];
  [notifDict setObject: _path forKey: @"OldFile"];
  [notifDict setObject: path forKey: @"NewFile"];

  // Set path
  [_path autorelease];
  _path = [path copy];

  // Post notification
  [[NSNotificationCenter defaultCenter] 
          postNotificationName: PCEditorDidChangeFileNameNotification
                                     object: notifDict];
                                     
  [notifDict autorelease];
}

- (NSString *) categoryPath
{
  return _categoryPath;
}

- (void) setCategoryPath: (NSString *)path
{
  [_categoryPath autorelease];
  _categoryPath = [path copy];
}

- (BOOL) isEdited
{
  return _isEdited;
}

- (void) setIsEdited: (BOOL)yn
{
  _isEdited = yn;
}

- (NSImage *) fileIcon
{
  NSString *fileExtension = [[_path lastPathComponent] uppercaseString];
  NSString *imageName = nil;
  NSString *imagePath = nil;
  NSBundle *bundle = nil;
  NSImage  *image = nil;

  fileExtension = [[[_path lastPathComponent] pathExtension] uppercaseString];
  if (_isEdited)
    {
      imageName = [NSString stringWithFormat: @"FileIcon%@E", fileExtension];
    }
  else
    {
      imageName = [NSString stringWithFormat: @"FileIcon%@", fileExtension];
    }

  bundle = [NSBundle bundleForClass: NSClassFromString(@"GemasEditor")];
  imagePath = [bundle pathForResource: imageName ofType: @"tiff"];

  image = [[NSImage alloc] initWithContentsOfFile: imagePath];

  return [image autorelease];
}

- (NSArray *) _methodsForClass: (NSString *)className
{
  NSEnumerator   *enumerator;
  NSDictionary   *method;
  NSDictionary   *class;
  NSMutableArray *items = [NSMutableArray array];
  NSRange        classRange;
  NSRange        methodRange;

  ASSIGN(parserClasses, [aParser classNames]);
  ASSIGN(parserMethods, [aParser methodNames]);

  enumerator = [parserClasses objectEnumerator];
  while ((class = [enumerator nextObject]))
    {
      if ([[class objectForKey: @"ClassName"] isEqualToString: className])
        {
          classRange = NSRangeFromString([class objectForKey: @"ClassBodyRange"]);
          break;
        }
    }

  methodRange = NSMakeRange(0, 0);
  enumerator = [parserMethods objectEnumerator];
  while ((method = [enumerator nextObject]))
    {
      //      NSLog(@"Method> %@", method);
      methodRange = NSRangeFromString([method objectForKey: @"MethodBodyRange"]);
      if (NSIntersectionRange(classRange, methodRange).length != 0)
        {
          [items addObject: [method objectForKey: @"MethodName"]];
        }
    }

  return items;
}

- (NSArray *) browserItemsForItem: (NSString *)item
{
  NSEnumerator   *enumerator;
//  NSDictionary   *method;
  NSDictionary   *class;
  NSMutableArray *items = [NSMutableArray array];
  
  NSLog(@"PCEditor: asked for browser items for: %@", item);

  [aParser setString: [_intEditorView string]];

  // If item is .m or .h file show class list
  if ([[item pathExtension] isEqualToString: @"m"]
      || [[item pathExtension] isEqualToString: @"h"])
    {
      ASSIGN(parserClasses, [aParser classNames]);

      enumerator = [parserClasses objectEnumerator];
      while ((class = [enumerator nextObject]))
        {
          NSLog(@"Class> %@", class);
          [items addObject:[class objectForKey:@"ClassName"]];
        }
    }

  // If item starts with "@" show method list
  if ([[item substringToIndex:1] isEqualToString: @"@"])
    {
/*      ASSIGN(parserMethods, [aParser methodNames]);

      enumerator = [parserMethods objectEnumerator];
      while ((method = [enumerator nextObject]))
	{
	  //      NSLog(@"Method> %@", method);
	  [items addObject:[method objectForKey:@"MethodName"]];
	}*/
      return [self _methodsForClass:item];
    }

  return items;
}

- (void) show
{
  // Nothing to do.
}

- (void) setWindowed: (BOOL)yn
{
  // Nothing to do.
}

- (BOOL) isWindowed
{
  return NO;
}

// --- Object managment

- (BOOL) saveFileIfNeeded
{
  if ((_isEdited))
    {
      return [self saveFile];
    }

  return YES;
}

- (BOOL) saveFile
{
  BOOL saved = NO;

  if (_isEdited == NO)
    {
      return YES;
    }
    
  [[NSNotificationCenter defaultCenter]
         postNotificationName: PCEditorWillSaveNotification
                       object: self];

  // Send the notification to Gorm...
  if([[_path pathExtension] isEqual: @"h"])
    {
      [[NSDistributedNotificationCenter defaultCenter]
		postNotificationName: @"GormParseClassNotification"
                              object: _path];
    }

  saved = [[_intEditorView string] writeToFile: _path atomically:YES];
 
  if (saved == YES)
    {
      [self setIsEdited: NO];
      [[NSNotificationCenter defaultCenter]
		postNotificationName: PCEditorDidSaveNotification
		  	      object: self];
    }
  else
    {
      NSRunAlertPanel(@"Save File",
		      @"Couldn't save file '%@'!",
		      @"OK", nil, nil, [_path lastPathComponent]);
    }

  return saved;
}

- (BOOL) saveFileTo: (NSString *)path
{
  return [[_intEditorView string] writeToFile: path atomically: YES];
}

- (BOOL) revertFileToSaved
{
  NSString           *text = [NSString stringWithContentsOfFile: _path];
  NSMutableDictionary *typingAttrs = nil;

  if (_isEdited == NO)
    {
      return YES;
    }

  if (NSAlertDefaultReturn !=
      NSRunAlertPanel(@"Revert",
		      @"%@ has been modified.  "
		      @"Are you sure you want to undo changes?",
		      @"Revert", @"Cancel", nil,
		      [_path lastPathComponent]))
      {
	return NO;
      }

  [[NSNotificationCenter defaultCenter]
             postNotificationName: PCEditorWillRevertNotification
                           object: self];

  /* turn off ligatures */
  typingAttrs = [[[_intEditorView typingAttributes] mutableCopy] autorelease];
  [typingAttrs setObject: [NSNumber numberWithInt: 0]
                  forKey: NSLigatureAttributeName];
  [_intEditorView setTypingAttributes: typingAttrs];
  [_intEditorView setAllowsUndo: YES];
  [_intEditorView setUsesFindPanel: YES];
  
  [_intEditorView replaceCharactersInRange: NSMakeRange(0, [[_intEditorView string] length])
            withString: text];
  [_intEditorView setSelectedRange: NSMakeRange(0, 0)];
  
  //Setup the user preferences
  [self setupNewDefaults];
  
  [[NSNotificationCenter defaultCenter]
         postNotificationName: PCEditorDidRevertNotification
                       object: self];
		  
  return YES;
}

// FIXME: Do we really need this method?
- (BOOL) closeFile: (id)sender save: (BOOL)save
{
  if (save == YES)
    {
      [self saveFileIfNeeded];
    }

  // Inform about closing
  [[NSNotificationCenter defaultCenter] 
      postNotificationName: PCEditorDidCloseNotification
                    object: self];

  return YES;
}

- (BOOL) close: (id)sender
{
  if ([self editorShouldClose] == YES)
    {
      // Inform about closing
      [[NSNotificationCenter defaultCenter] 
                 postNotificationName: PCEditorDidCloseNotification
                               object: self];

      return YES;
    }

  return NO;
}

- (BOOL) editorShouldClose
{
  if (_isEdited)
    {
      int ret;

      ret = NSRunAlertPanel(@"Close File",
			    @"File %@ has been modified. Save?",
			    @"Save and Close", @"Don't save", @"Cancel", 
			    [_path lastPathComponent]);
      switch (ret)
        {
        case NSAlertDefaultReturn: // Save And Close
          if ([self saveFile] == NO)
            {
              return NO;
            }
          break;
        case NSAlertAlternateReturn: // Don't save
          break;
        case NSAlertOtherReturn: // Cancel
          return NO;
          break;
        }

      [self setIsEdited: NO];
    }

  return YES;
}

// Window delegate
- (NSUndoManager *) windowWillReturnUndoManager:(NSWindow *)window
{
  return undoManager;
}

// TextView (_intEditorView) delegate
- (BOOL) becomeFirstResponder: (GemasEditorView *)view
{
  [[NSNotificationCenter defaultCenter] 
         postNotificationName: PCEditorDidBecomeActiveNotification
			  object: self];

  return YES;
}

- (BOOL) resignFirstResponder: (GemasEditorView *)view
{
  [[NSNotificationCenter defaultCenter] 
           postNotificationName: PCEditorDidResignActiveNotification
                         object: self];

  return YES;
}

- (void) textDidChange:(NSNotification *)aNotification
{
  id object = [aNotification object];
  
  if ([object isKindOfClass: [GemasEditorView class]]
       && (object == _intEditorView))
    {
      if (_isEdited == NO)
        {
          [[NSNotificationCenter defaultCenter]
                postNotificationName: PCEditorWillChangeNotification
                                           object: self];

          [self setIsEdited: YES];
          
          [[NSNotificationCenter defaultCenter]
                postNotificationName: PCEditorDidChangeNotification
                                           object: self];
        }
    }
}

- (void) textViewDidChangeSelection: (NSNotification *) notification
{
  //Number of line and column
  NSRange tex = [_intEditorView selectedRange];
  NSArray *selectedLines = [[[_intEditorView string] substringWithRange:
                                       NSMakeRange(0, tex.location)]
                              componentsSeparatedByString: @"\n"];

  [_line setIntValue: [selectedLines count]];
  [_column setIntValue: [[selectedLines lastObject] length] + 1];
}

- (NSArray *) textView: (NSTextView *)aTextView completions: (NSArray *)words
  forPartialWordRange: (NSRange)range indexOfSelectedItem: (NSInteger *)index
{
  NSString *word = [[aTextView string] substringWithRange: range];
  NSString *item;
  NSEnumerator *enumerator;
  NSMutableArray *array;
  
  if ([word length] < 3)
    {
      return nil;
    }
  
  if ( (words != nil) && (range.length > length) )
    {
      length = range.length;
      enumerator = [words objectEnumerator];
      array = [NSMutableArray array];
      
      while ((item = [enumerator nextObject]))
        {
          if ([item hasPrefix: word])
            {
              [array addObject: item];
            }
        }
    }
  else
    {
      length = range.length;
      enumerator = [list objectEnumerator];
      array = [NSMutableArray array];
      
      while ((item = [enumerator nextObject]))
        {
          if ([item hasPrefix: word])
            {
              [array addObject: item];
            }
        }
    }
  
  if ([array count] > 0)
    {
      return [NSArray arrayWithArray: array];
    }
  else
    {
      return nil;
    }
}

// Scrolling
- (void) fileStructureItemSelected: (NSString *)item
{
  NSString *firstSymbol;

  NSLog(@"[PCEditor] selected file structure item: %@", item);

  firstSymbol = [item substringToIndex: 1];
  if ([firstSymbol isEqualToString: @"@"])      // class selected
    {
      [self scrollToClassName: item];
    }
  else if ([firstSymbol isEqualToString: @"-"]  // method selected
	|| [firstSymbol isEqualToString: @"+"])
    {
      [self scrollToMethodName: item];
    }
}

- (void) scrollToClassName: (NSString *)className
{
  NSEnumerator   *enumerator = nil;
  NSDictionary   *class = nil;
  NSRange        classNameRange;

  NSLog(@"SCROLL to class: \"%@\"", className);

  classNameRange = NSMakeRange(0, 0);
  enumerator = [parserClasses objectEnumerator];
  while ((class = [enumerator nextObject]))
    {
      if ([[class objectForKey: @"ClassName"] isEqualToString: className])
        {
          classNameRange = 
              NSRangeFromString([class objectForKey: @"ClassNameRange"]);
          break;
        }
    }

  NSLog(@"classNameRange: %@", NSStringFromRange(classNameRange));
  if (classNameRange.length != 0)
    {
      [_intEditorView setSelectedRange: classNameRange];
      [_intEditorView scrollRangeToVisible: classNameRange];
    }
}

- (void) scrollToMethodName: (NSString *)methodName
{
  NSEnumerator   *enumerator = nil;
  NSDictionary   *method = nil;
  NSRange        methodNameRange;

  NSLog(@"SCROLL to method: \"%@\"", methodName);

  methodNameRange = NSMakeRange(0, 0);
  enumerator = [parserMethods objectEnumerator];
  while ((method = [enumerator nextObject]))
    {
      if ([[method objectForKey: @"MethodName"] isEqualToString: methodName])
        {
          methodNameRange = 
             NSRangeFromString([method objectForKey: @"MethodNameRange"]);
          break;
        }
    }

  NSLog(@"methodNameRange: %@", NSStringFromRange(methodNameRange));
  if (methodNameRange.length != 0)
    {
      [_intEditorView setSelectedRange: methodNameRange];
      [_intEditorView scrollRangeToVisible: methodNameRange];
    }
}

- (void) scrollToLineNumber: (unsigned int)lineNumber
{
  unsigned int offset;
  unsigned int i;
  NSString     *line;
  NSEnumerator *e;
  NSArray      *lines;
  NSRange      range;

  lines = [[_intEditorView string] componentsSeparatedByString: @"\n"];
  e = [lines objectEnumerator];

  for (offset = 0, i = 1; (line = [e nextObject]) != nil && i < lineNumber; i++)
    {
      offset += [line length] + 1;
    }

  if (line != nil)
    {
      range = NSMakeRange(offset, [line length]);
    }
  else
    {
      range = NSMakeRange([[_intEditorView string] length], 0);
    }
  [_intEditorView setSelectedRange: range];
  [_intEditorView scrollRangeToVisible: range];
}

@end
