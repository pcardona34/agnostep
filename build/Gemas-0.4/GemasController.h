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

#include <AppKit/AppKit.h>

@class NSTask;

@interface GemasController : NSObject
{
  //Outlet for GoToLine panel
  id linePanel;

  //Outlet for Preferences panel
  id preferencesPanel;

  //Outlets to Coding preferences
  id indentation;
  id tabConversion;

  //Outlets for Looks
  id backgroundColor;
  id cursorColor;
  id textColor;
  id selectionColor;
  id highlighterTheme;
  id fontName;
  id fontSize;
  id fontSizeStepper;
  
  //Size of editor
  id editorWidth;
  id editorHeight;
  
  //Autosaving
  id autosavingDelay;
  id autosavingDelaySlider;
  
  // Autocomplete
  NSArray *list;
  
  //NSTask *GSmarkupBrowser;
}
//General methods
- (void) newSourceFile: (id)sender;
- (void) newProject: (id)sender;
- (void) openPreferences: (id)sender;
- (void) openGoToLinePanel: (id)sender;

//Preferences for coding
- (void) changeIndentation: (id)sender;
- (void) changeTabConversion: (id)sender;

//Preferenes for look
- (void) changeBackgroundColor: (id)sender;
- (void) changeCursorColor: (id)sender;
- (void) changeTextColor: (id)sender;
- (void) changeSelectionColor: (id)sender;
- (void) changeHighlighterTheme: (id)sender;

//Font Preferences
- (void) changeFontName: (id)sender;
- (void) changeFontSize: (id)sender;

//Editor Windows Size
- (void) changeEditorWidth: (id)sender;
- (void) changeEditorHeight: (id)sender;

//Autosaving Delay
- (void) changeAutosavingDelay: (id)sender;

//Restore to defaults
- (void) restoreDefaults: (id)sender;

//Go to line
- (void) goToLine: (id) sender;

//Tools
//- (void) testGSmarkup: (id)sender;
//- (void) terminateGSmarkupTest: (id)sender;

//Delegate
- (BOOL) validateMenuItem:(id <NSMenuItem>)menuItem;
- (BOOL) applicationShouldOpenUntitledFile:(NSApplication *)sender;
- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (id)sender;
- (void) windowWillClose: (NSNotification*)aNotification;

// Autocomplete
- (NSArray *) list;
@end
