/* 
   Copyright (C) 2010, 2011, 2012, 2013 German A. Arias <german@xelalug.org>

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

#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSTask.h>
#import <HighlighterKit/HighlighterKit.h>
#import "GemasController.h"
#import "GemasDocument.h"

#define POST_CHANGE \
  [[NSNotificationCenter defaultCenter] \
    postNotificationName: CodeEditorDefaultsDidChangeNotification \
                  object: self \
                userInfo: nil]


@implementation GemasController

- (void) awakeFromNib
{
  //GSmarkupBrowser = nil;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSTimeInterval delay = [defaults integerForKey: @"AutosavingDelay"];  
  
  [[NSDocumentController sharedDocumentController] setAutosavingDelay: delay];
  
  // Autocomplete list of words
  list = [NSArray arrayWithContentsOfFile:
    [[NSBundle mainBundle] pathForResource: @"words" ofType: @"plist"]];
  [list retain];
}

- (void) dealloc
{
  [list release];
  [super dealloc];
}

- (void) newSourceFile: (id)sender
{
  switch([sender tag])
    {
    case 1:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"C" display: YES];
      break;
    case 2:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"C-Header" display: YES];
      break;
    case 3:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"ObjC" display: YES];
      break;
    case 4:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"C++" display: YES];
      break;
    case 5:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"ObjC++" display: YES];
      break;
    case 6:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"Plist" display: YES];
      break;
    case 7:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"Strings" display: YES];
      break;
    case 8:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"GSmarkup" display: YES];
      break;
    case 9:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"GNUmakefile" display: YES];
      break;
    case 10:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"ChangeLog" display: YES];
      break;
    case 11:
      [[NSDocumentController sharedDocumentController]
        openUntitledDocumentOfType: @"Generic" display: YES];
      break;
    }
}

- (void) newProject: (id)sender
{
  NSInteger option;
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setCanCreateDirectories: YES];
  [panel setTitle: _(@"Select a directory")];
  [panel setNameFieldLabel: _(@"Project Name:")];
  option = [panel runModal];

  if (option == NSOKButton)
    {
      NSString *directory = [panel directory];

      if ([[NSFileManager defaultManager] isWritableFileAtPath: directory])
        {
          BOOL succes = NO, badPath = NO;
          NSString *resource, *targetDirectory, *name;
          NSBundle *bundle;
          NSFileManager *manager = [NSFileManager defaultManager];

          name = [panel nameFieldStringValue];
          bundle = [NSBundle mainBundle];
          
          targetDirectory = [directory stringByAppendingPathComponent: name];

          //Verify if project path is valid
          if ([targetDirectory rangeOfString: @" "].location != NSNotFound ||
              [targetDirectory rangeOfString: @"\t"].location != NSNotFound ||
              [targetDirectory rangeOfString: @"\r"].location != NSNotFound ||
              [targetDirectory rangeOfString: @"\n"].location != NSNotFound)
            {
              if (NSRunAlertPanel(_(@"Alert"),
                                  _(@"Project path contains whitespaces. The tool Make won't work with this project. Do you want create the project anyway?"),
                                  _(@"OK"), _(@"Cancel"), nil) != NSAlertDefaultReturn)
                {
                  badPath = YES;
                }

            }
          
          if (!badPath)
            {
              switch ([sender tag])
                {
                case 0:
                  {
                    NSDirectoryEnumerator *files;
                    NSString *file, *originalFile, *copyFile;
                    
                    resource = [bundle pathForResource: @"AppResources" ofType: nil];
                    files = [manager enumeratorAtPath: resource];
                    succes = [manager createDirectoryAtPath: targetDirectory attributes: nil];
                    
                    if (succes)
                      {
                        BOOL error = NO;
                        NSString *makefilePath, *newInfoplistPath, *appControllerhPath, *appControllermPath;
                        while ((file = [files nextObject]))
                          {
                            originalFile = [resource stringByAppendingPathComponent: file];
                            copyFile = [targetDirectory stringByAppendingPathComponent: file];
                            
                            error = [manager copyItemAtPath: originalFile toPath: copyFile error: NULL];
                          }
                        error = YES;
                        
                        if (error)
                          {
                            makefilePath = [targetDirectory stringByAppendingPathComponent: 
                                                              @"GNUmakefile"];
                            NSString *makefileContent = [NSString stringWithContentsOfFile: makefilePath];
                            makefileContent = [makefileContent stringByReplacingString: @"[APP_NAME]"
                                                                            withString: name];
                            succes = [makefileContent writeToFile: makefilePath atomically: YES];
                          }
                        
                        if (error)
                          {
                            newInfoplistPath = [targetDirectory stringByAppendingPathComponent: 
                                                                 [name stringByAppendingString: @"Info.plist"]];
                            NSString *infoplistPath = [targetDirectory stringByAppendingPathComponent: 
                                                                         @"Info.plist"];
                            NSString *infoplistContent = [NSString stringWithContentsOfFile: infoplistPath];
                            infoplistContent = [infoplistContent stringByReplacingString: @"[APP_NAME]"
                                                                              withString: name];
                            infoplistContent = [infoplistContent stringByReplacingString: @"[AUTHORS]"
                                                                              withString: _(@"authors")];
                            succes = [infoplistContent writeToFile: newInfoplistPath atomically: YES];
                            [manager removeFileAtPath: infoplistPath handler: nil]; 
                          }

                        if (error)
                          {
                            //Open the new files
                            NSDocumentController *controller = [NSDocumentController sharedDocumentController];

                            appControllerhPath = [targetDirectory stringByAppendingPathComponent: 
                                                                    @"AppController.h"];
                            appControllermPath = [targetDirectory stringByAppendingPathComponent: 
                                                                    @"AppController.m"];
                            
                            [controller openDocumentWithContentsOfFile: makefilePath display: YES];
                            [controller openDocumentWithContentsOfFile: newInfoplistPath display: YES];
                            [controller openDocumentWithContentsOfFile: appControllerhPath display: YES];
                            [controller openDocumentWithContentsOfFile: appControllermPath display: YES];
                          }
                        
                        if (!error)
                          {
                            NSRunAlertPanel(_(@"Error"),
                                            _(@"An error occurred when copy the project files,"),
                                            _(@"OK"), nil, nil);
                          }
                      }
                    else
                      {
                        NSRunAlertPanel(_(@"Error"),
                                        _(@"Can't create the project directory."),
                                        _(@"OK"), nil, nil);
                      }
                  }
                  break;
                case 1:
                  {
                    NSString *makefilePath, *mainPath;
                    resource = [bundle pathForResource: @"ToolResources" ofType: nil];
                    succes = [manager copyItemAtPath: resource toPath: targetDirectory error: NULL];

                    if (succes)
                      {
                        makefilePath = [targetDirectory stringByAppendingPathComponent: 
                                                          @"GNUmakefile"];
                        NSString *makefileContent = [NSString stringWithContentsOfFile: makefilePath];
                        makefileContent = [makefileContent stringByReplacingString: @"[TOOL_NAME]"
                                                                        withString: name];
                        succes = [makefileContent writeToFile: makefilePath atomically: YES];
                      }
                    
                    if (succes)
                      {
                        //Open the new files
                        NSDocumentController *controller = [NSDocumentController sharedDocumentController];
                        
                        mainPath = [targetDirectory stringByAppendingPathComponent: @"main.m"];
                        
                        [controller openDocumentWithContentsOfFile: makefilePath display: YES];
                        [controller openDocumentWithContentsOfFile: mainPath display: YES];
                      }
                    
                    if (!succes)
                      {
                        NSRunAlertPanel(_(@"Error"),
                                        _(@"An error occurred when copy the project files,"),
                                        _(@"OK"), nil, nil);
                      }
                  }
                  break;
                }
            }
        }
      else
        {
          NSRunAlertPanel(_(@"Error"),
                          _(@"You don't have permission to write in that directory."),
                          _(@"OK"), nil, nil);
        }
    }
}

- (void) openPreferences: (id)sender
{
  if (preferencesPanel == nil)
    {
      int x;
      NSInteger size;
      NSUserDefaults *df;
      NSData *data;
      NSArray *themes;
      NSString *path, *themeItem;
      [NSBundle loadNibNamed: @"Preferences" owner: self];
      [preferencesPanel center];
      [preferencesPanel makeKeyAndOrderFront: self];
      
      df = [NSUserDefaults standardUserDefaults];

      //Editing
      [indentation selectItemAtIndex: [df integerForKey: @"Indentation"]];

      [tabConversion selectItemAtIndex: [df integerForKey: @"TabConversion"]]; 

      //Looks
      data = [df dataForKey: @"EditorTextColor"];
      if (data != nil)
        {
          [textColor setColor: [NSKeyedUnarchiver unarchiveObjectWithData: data]];
        }
      
      data = [df dataForKey: @"EditorBackgroundColor"];
      if (data != nil)
        {
          [backgroundColor setColor: [NSKeyedUnarchiver unarchiveObjectWithData:
                                                          data]];
        }

      data = [df dataForKey: @"EditorInsertionPointColor"];
      if (data != nil)
        {
          [cursorColor setColor: [NSKeyedUnarchiver
                                   unarchiveObjectWithData: data]];
        }
      
      data = [df dataForKey: @"EditorSelectionColor"];
      if (data != nil)
        {
          [selectionColor setColor: 
            [NSKeyedUnarchiver unarchiveObjectWithData: data]];
        }
      
      //Highlighter theme
      path = @"~";
      path = [path stringByAppendingPathComponent:
               [[NSUserDefaults standardUserDefaults] stringForKey: @"GNUSTEP_USER_DIR_LIBRARY"]];
      path = [path stringByAppendingPathComponent: @"HKThemes"];
      path = [path stringByExpandingTildeInPath];
      themes = [[NSFileManager defaultManager] directoryContentsAtPath: path];
      
      [highlighterTheme removeAllItems];
      [highlighterTheme addItemWithTitle: _(@"Default")];
      
      for (x = 0; x < [themes count]; x++)
        {
          if ([[themes objectAtIndex: x] hasSuffix: @".definition"])
            {
              themeItem = [[themes objectAtIndex: x] lastPathComponent];
              themeItem = [themeItem stringByDeletingPathExtension];
              [highlighterTheme addItemWithTitle: themeItem];
            }
        }
      
      if ([df stringForKey: @"HKTheme"] != nil)
        {
          themeItem = [[df stringForKey: @"HKTheme"] lastPathComponent];
          themeItem = [themeItem  stringByDeletingPathExtension];
          [highlighterTheme selectItemWithTitle: themeItem];
        }
      
      //Font
      [fontName addItemsWithObjectValues: [[NSFontManager sharedFontManager] availableFonts]];
      
      if ( ([df stringForKey: @"HKFont"] != nil) &&
           (![[df stringForKey: @"HKFont"] isEqualToString: @""]) )
        {
          [fontName setStringValue: [df stringForKey: @"HKFont"]];
        }
      else
        {
          [fontName setStringValue: _(@"Default")];
        }
      
      size = [df integerForKey: @"HKFontSize"];
      if ( (size >= 12) && (size <= 26) )
        {
          [fontSize setIntegerValue: size];
          [fontSizeStepper setIntegerValue: size];
        }
      else
        {
          [fontSize setStringValue: _(@"Default")];
        }
      
      //Editor window
      if ([df integerForKey: @"EditorWidth"] > 0)
        {
          [editorWidth setIntegerValue: [df integerForKey: @"EditorWidth"]];
        }
      else
        {
          [editorWidth setIntegerValue: 680];
        }
      
      if ([df integerForKey: @"EditorHeight"] > 0)
        {
          [editorHeight setIntegerValue: [df integerForKey: @"EditorHeight"]];
        }
      else
        {
          [editorHeight setIntegerValue: 510];
        }
      
      //Autosaving delay
      [autosavingDelay setIntegerValue: [df integerForKey: @"AutosavingDelay"]];
      [autosavingDelaySlider setIntegerValue: [df integerForKey: @"AutosavingDelay"]];
      
      [NSApp runModalForWindow: preferencesPanel];
    }
  else
    {
      [preferencesPanel makeKeyAndOrderFront: self];
      [NSApp runModalForWindow: preferencesPanel];
    }
}

- (void) openGoToLinePanel: (id)sender
{
  [NSBundle loadNibNamed: @"GoToLine" owner: self];
  [NSApp runModalForWindow:linePanel];
}

- (void) goToLine: (id) sender
{
  [[[NSDocumentController sharedDocumentController] currentDocument]
    goToLineNumber: [sender intValue]];
  [[sender window] performClose: self];    
}


//Editing

- (void) changeIndentation: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setInteger: [indentation indexOfSelectedItem]
        forKey: @"Indentation"];

  POST_CHANGE;
}

- (void) changeTabConversion: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setInteger: [tabConversion indexOfSelectedItem]
        forKey: @"TabConversion"];
}


//Looks

- (void) changeCursorColor: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setObject: [NSKeyedArchiver archivedDataWithRootObject: [cursorColor color]]
       forKey: @"EditorInsertionPointColor"];

  POST_CHANGE;
}

- (void) changeTextColor: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setObject: [NSKeyedArchiver archivedDataWithRootObject: [textColor color]]
       forKey: @"EditorTextColor"];

  POST_CHANGE;
}

- (void) changeBackgroundColor: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setObject: [NSKeyedArchiver archivedDataWithRootObject: [backgroundColor color]]
       forKey: @"EditorBackgroundColor"];

  POST_CHANGE;
}

- (void) changeSelectionColor: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setObject: [NSKeyedArchiver archivedDataWithRootObject: [selectionColor color]]
       forKey: @"EditorSelectionColor"];

  POST_CHANGE;
}

- (void) changeHighlighterTheme: (id)sender
{
  if ([[sender titleOfSelectedItem] isEqualToString: _(@"Default")])
    {
      [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"HKTheme"];
    }
  else
    {
      NSString *path;
      
      path = @"~";
      path = [path stringByAppendingPathComponent:
               [[NSUserDefaults standardUserDefaults] stringForKey: @"GNUSTEP_USER_DIR_LIBRARY"]];
      path = [path stringByAppendingPathComponent: @"HKThemes"];
      path = [path stringByAppendingPathComponent: [sender titleOfSelectedItem]];
      path = [path stringByAppendingPathExtension: @"definition"];
      path = [path stringByExpandingTildeInPath];
      
      [[NSUserDefaults standardUserDefaults]
        setObject: path
           forKey: @"HKTheme"];
    }

  [HKSyntaxDefinition themeDidChange];
  
  POST_CHANGE;
}

//Font
- (void) changeFontName: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setObject: [fontName stringValue]
       forKey: @"HKFont"];

  POST_CHANGE;
}

- (void) changeFontSize: (id)sender
{
  [fontSize setIntegerValue: [sender integerValue]];
  
  [[NSUserDefaults standardUserDefaults]
    setInteger: [fontSize integerValue]
       forKey: @"HKFontSize"];

  POST_CHANGE;
}

//Editor Window
- (void) changeEditorWidth: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setInteger: [editorWidth integerValue]
       forKey: @"EditorWidth"];
}

- (void) changeEditorHeight: (id)sender
{
  [[NSUserDefaults standardUserDefaults]
    setInteger: [editorHeight integerValue]
       forKey: @"EditorHeight"];
}

//Autosaving Delay
- (void) changeAutosavingDelay: (id)sender
{
  NSTimeInterval delay = [sender integerValue];
  [autosavingDelay setIntegerValue: [sender integerValue]];
  
  [[NSUserDefaults standardUserDefaults]
    setInteger: [sender integerValue]
       forKey: @"AutosavingDelay"];
       
  [[NSDocumentController sharedDocumentController] setAutosavingDelay: delay];
}

//Restore to defaults
- (void) restoreDefaults: (id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults removeObjectForKey: @"Indentation"];
  [defaults removeObjectForKey: @"TabConversion"];
  [defaults removeObjectForKey: @"EditorInsertionPointColor"];
  [defaults removeObjectForKey: @"EditorTextColor"];
  [defaults removeObjectForKey: @"EditorBackgroundColor"];
  [defaults removeObjectForKey: @"EditorSelectionColor"];
  [defaults removeObjectForKey: @"HKFont"];
  [defaults removeObjectForKey: @"HKFontSize"];
  [defaults removeObjectForKey: @"HKTheme"];
  [defaults removeObjectForKey: @"EditorWidth"];
  [defaults removeObjectForKey: @"EditorHeight"];
  [defaults removeObjectForKey: @"AutosavingDelay"];

  [HKSyntaxDefinition themeDidChange];

  POST_CHANGE;
  
  [preferencesPanel close];
  DESTROY(preferencesPanel);
}

//Tools
/*- (void) testGSmarkup: (id)sender
{
  NSString *autoLayout, *pathMB;
  NSString *filePath = [[[NSDocumentController sharedDocumentController] currentDocument] fileName];

  if (GSmarkupBrowser != nil)
    {
      NSLog(@"Se termina");
      [GSmarkupBrowser terminate];
    }
  
  if ([sender tag] == 1)
    {
      autoLayout = [NSString stringWithString: @"NO"];
    }
  else
    {
      autoLayout = [NSString stringWithString: @"YES"];
    }
  
  pathMB = [[NSWorkspace sharedWorkspace] fullPathForApplication: @"GSMarkupBrowser"];
  pathMB = [pathMB stringByAppendingString: @"/GSMarkupBrowser"];
  
  GSmarkupBrowser = [NSTask launchedTaskWithLaunchPath: pathMB arguments: [NSArray arrayWithObjects: filePath, @"-DisplayAutoLayout", autoLayout, nil]];

}

- (void) terminateGSmarkupTest: (id)sender
{
  if (GSmarkupBrowser != nil)
    {
      [GSmarkupBrowser terminate];
    }
    }*/

// Autocomplete
- (NSArray *) list
{
  return list;
}

//Delegate
- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
  if ([menuItem action] == @selector(openGoToLinePanel:))
    {
      if ([[[NSDocumentController sharedDocumentController] documents] count] > 0)
        {
          return YES;
        }
      else
        {
          return NO;
        }
    }
 
  return [[NSDocumentController sharedDocumentController] validateMenuItem: menuItem];
}

- (BOOL) applicationShouldOpenUntitledFile: (NSApplication *) sender
{
  if (NSInterfaceStyleForKey(@"NSMenuInterfaceStyle", nil) ==
      NSWindows95InterfaceStyle)
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (id)sender
{
  if (NSInterfaceStyleForKey(@"NSMenuInterfaceStyle", nil) ==
      NSWindows95InterfaceStyle)
    {
      NSDocumentController *docController;
      docController = [NSDocumentController sharedDocumentController];
      
      if ([[docController documents] count] > 0)
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
      return NO;
    }
}

- (void) windowWillClose: (NSNotification*)aNotification
{
  [NSApp stopModal];
}

@end
