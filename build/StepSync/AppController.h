/* 
 Project: StepSync
 AppController.h
 
 Copyright (C) 2017-2021 Riccardo Mottola
 
 Author: Riccardo Mottola
 
 Created: 2017-02-02
 
 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.
 
 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
*/



#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class FileMap;
@class Engine;

@interface AppController : NSObject
{
  IBOutlet NSTextField *sourcePathField;
  IBOutlet NSTextField *sourceDirNumberField;
  IBOutlet NSTextField *sourceFileNumberField;
  IBOutlet NSTextField *sourceSizeField;

  IBOutlet NSTextField *targetPathField;
  IBOutlet NSTextField *targetDirNumberField;
  IBOutlet NSTextField *targetFileNumberField;
  IBOutlet NSTextField *targetSizeField;

  IBOutlet NSButton *handleDirectoriesCheck;
  IBOutlet NSButton *updateSourceCheck;
  IBOutlet NSButton *insertItemsCheck;
  IBOutlet NSButton *updateItemsCheck;
  IBOutlet NSButton *deleteItemsCheck;
  IBOutlet NSButton *analyzeButton;
  IBOutlet NSButton *syncButton;
  IBOutlet NSButton *stopButton;
  IBOutlet NSProgressIndicator *progressBar;
  IBOutlet NSTextView *logView;

  /* Preferences */
  IBOutlet NSPanel *prefPanel;
  IBOutlet NSButton *skipHiddenFoldersCheck;
  IBOutlet NSButton *skipHiddenFilesCheck;
  IBOutlet NSButton *skipThumbFilesCheck;
  IBOutlet NSButton *forceUpdateIfOnlyDateDiffersCheck;
  IBOutlet NSTextField *timeToleranceField;
  
  Engine *engine;
}

- (IBAction)showPreferences:(id)sender;
- (IBAction)applyPreferences:(id)sender;

- (IBAction)setSourcePath:(id)sender;
- (IBAction)setTargetPath:(id)sender;

- (IBAction)analyzeAction:(id)sender;
- (void)reportAnalysis;
- (IBAction)syncAction:(id)sender;
- (IBAction)stopTask:(id)sender;

- (void)initProgress:(id)sender;
- (void)updateProgress:(id)sender;
- (void)finishProgress:(id)sender;

@end
