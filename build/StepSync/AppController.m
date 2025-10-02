/* 
 Project: StepSync
 AppController.m
 
 Copyright (C) 2017-2025 Free Software Foundation
 
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

#import "AppController.h"
#import "FileMap.h"
#import "FileObject.h"
#import "FileArray.h"
#import "Engine.h"


@implementation AppController

- (void)dealloc
{
  [engine dealloc];
  
  [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  NSUserDefaults *defaults;
  NSString *str;

  defaults = [NSUserDefaults standardUserDefaults];

  [engine setSkipHiddenFolders:[defaults boolForKey:@"SKIP_HIDDEN_FOLDERS"]];
  [engine setSkipHiddenFiles: [defaults boolForKey:@"SKIP_HIDDEN_FILES"]];
  [engine setSkipThumbFiles: [defaults boolForKey:@"SKIP_THUBMNAIL_FILES"]];
  [engine setForceUpdateIfOnlyDateDiffers: [defaults boolForKey:@"FORCE_UPDATE_SAMESIZE_DIFFDATES"]];
  [engine setDateTimeTolerance: [defaults integerForKey:@"DATETIME_TOLERANCE"]];


  str = [defaults stringForKey:@"LAST_ANALYZED_SOURCE_PATH"];
  if (str)
    [sourcePathField setStringValue: str];
  str = [defaults stringForKey:@"LAST_ANALYZED_TARGET_PATH"];
  if (str)
    [targetPathField setStringValue: str];
}

- (void)awakeFromNib
{
  [logView setContinuousSpellCheckingEnabled:NO];
#if defined(__APPLE__) && defined(MAC_OS_X_VERSION_10_6) && (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6)
  [logView setAutomaticSpellingCorrectionEnabled:NO];
#endif

  [analyzeButton setEnabled:YES];
  [syncButton setEnabled:YES];
  [stopButton setEnabled:NO];

  engine = [[Engine alloc] init];
  [engine setController:self];
}

- (IBAction)showPreferences:(id)sender
{
  if ([engine skipHiddenFolders])
    [skipHiddenFoldersCheck setState:NSOnState];
  else
    [skipHiddenFoldersCheck setState:NSOffState];

  if ([engine skipHiddenFiles])
    [skipHiddenFilesCheck setState:NSOnState];
  else
    [skipHiddenFilesCheck setState:NSOffState];

  if ([engine skipThumbFiles])
    [skipThumbFilesCheck setState:NSOnState];
  else
    [skipThumbFilesCheck setState:NSOffState];

  if ([engine forceUpdateIfOnlyDateDiffers])
    [forceUpdateIfOnlyDateDiffersCheck setState:NSOnState];
  else
    [forceUpdateIfOnlyDateDiffersCheck setState:NSOffState];
  
  [timeToleranceField setIntValue:[engine dateTimeTolerance]];

  [prefPanel makeKeyAndOrderFront:sender];
}

- (IBAction)applyPreferences:(id)sender
{
  NSUserDefaults *defaults;
  NSInteger intVal;

  defaults = [NSUserDefaults standardUserDefaults];

  [engine setSkipHiddenFolders: [skipHiddenFoldersCheck state]];
  [defaults setBool:[engine skipHiddenFolders] forKey:@"SKIP_HIDDEN_FOLDERS"];

  [engine setSkipHiddenFiles: [skipHiddenFilesCheck state]];
  [defaults setBool:[engine skipHiddenFiles] forKey:@"SKIP_HIDDEN_FILES"];

  [engine setSkipThumbFiles: [skipThumbFilesCheck state]];
  [defaults setBool:[engine skipThumbFiles] forKey:@"SKIP_THUBMNAIL_FILES"];

  [engine setForceUpdateIfOnlyDateDiffers: [forceUpdateIfOnlyDateDiffersCheck state]];
  [defaults setBool:[engine forceUpdateIfOnlyDateDiffers] forKey:@"FORCE_UPDATE_SAMESIZE_DIFFDATES"];
  
  intVal = [timeToleranceField intValue];
  [engine setDateTimeTolerance: intVal];
  [defaults setInteger:intVal forKey:@"DATETIME_TOLERANCE"];

  [prefPanel close];
}

- (IBAction)setSourcePath:(id)sender
{
  NSOpenPanel *openPanel;
  NSString *currPath;
  
  currPath = [sourcePathField stringValue];
  openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  if (currPath != nil && [currPath length])
    [openPanel setDirectory:currPath];
  if ([openPanel runModal] == NSOKButton)
    {
      NSString *fileName;
    
      fileName = [openPanel filename];
      [sourcePathField setStringValue:fileName];
    }
}

- (IBAction)setTargetPath:(id)sender
{
  NSOpenPanel *openPanel;
  NSString *currPath;
    
  currPath = [targetPathField stringValue];
  openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  if (currPath != nil && [currPath length])
    [openPanel setDirectory:currPath];
  if ([openPanel runModal] == NSOKButton)
    {
      NSString *fileName;
    
      fileName = [openPanel filename];
      [targetPathField setStringValue:fileName];
    }  
}

- (void)performAnalyze:(id)sender
{
  NSAutoreleasePool *arp;
  NSUserDefaults *defaults;
  
  defaults = [NSUserDefaults standardUserDefaults];
  
  arp = [NSAutoreleasePool new]; // we are in a thread, have our own ARP

  [defaults setObject: [engine sourceRoot] forKey: @"LAST_ANALYZED_SOURCE_PATH"];
  [defaults setObject: [engine targetRoot] forKey: @"LAST_ANALYZED_TARGET_PATH"];
  [engine analyze];
  
  [sourceDirNumberField setStringValue:[[NSNumber numberWithUnsignedInteger:[[[engine sourceMap] directories] count]] description]];
  [sourceFileNumberField setStringValue:[[NSNumber numberWithUnsignedInteger:[[[engine sourceMap] files] count]] description]];

  [targetDirNumberField setStringValue:[[NSNumber numberWithUnsignedInteger:[[[engine targetMap] directories] count]] description]];
  [targetFileNumberField setStringValue:[[NSNumber numberWithUnsignedInteger:[[[engine targetMap] files] count]] description]];

  [sourceSizeField setStringValue:[FileObject formatSize:[[engine sourceMap] size]]];
  [targetSizeField setStringValue:[FileObject formatSize:[[engine targetMap] size]]];

  [self reportAnalysis];

  if (![engine checkFreeSpace])
    {
      NSLog(@"Maybe not enough free space");
    }

  [stopButton setEnabled:NO];
  [analyzeButton setEnabled:YES];
  [syncButton setEnabled:YES];
  [arp release];
}

- (IBAction)analyzeAction:(id)sender
{
  [engine setSourceRoot: [sourcePathField stringValue]];
  [engine setTargetRoot: [targetPathField stringValue]];

  [stopButton setEnabled:YES];
  [analyzeButton setEnabled:NO];
  [syncButton setEnabled:NO];

  [NSThread detachNewThreadSelector:@selector(performAnalyze:) toTarget:self withObject:nil];
}

- (IBAction)stopTask:(id)sender
{
  [engine stopTask];
}

- (void)reportAnalysis
{
  NSString *sepStr;
  NSAttributedString *sepAttrStr;
  NSMutableString *tempStr;
  NSMutableAttributedString *attrStrMut;
  NSAttributedString *attrStr;
  NSMutableDictionary *titleAttributes;
  NSMutableDictionary *separatorAttributes;
  NSMutableDictionary *textAttributes;
  NSUInteger i;

  titleAttributes = [NSMutableDictionary dictionaryWithObject:[NSFont userFixedPitchFontOfSize: 0] forKey:NSFontAttributeName];
  [titleAttributes  setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];

  separatorAttributes = [NSMutableDictionary dictionaryWithObject:[NSFont userFixedPitchFontOfSize: 0] forKey:NSFontAttributeName];
  [separatorAttributes  setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
  
  textAttributes = [NSMutableDictionary dictionaryWithObject:[NSFont userFixedPitchFontOfSize: 0] forKey:NSFontAttributeName];
  [textAttributes  setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];

  [self performSelectorOnMainThread:@selector(_cleanLogView:) withObject:nil waitUntilDone:NO];

  sepStr = @"----------------------------------------------------------\n";
  sepAttrStr = [[NSAttributedString alloc] initWithString: sepStr
                                            attributes: separatorAttributes];

  attrStrMut = [NSMutableAttributedString new];

  /* -- Directories present in Source but not in Target -- */
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  [tempStr appendString:@"Directories present in Source but not Target:\n"];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: titleAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  for (i = 0; i < [[engine targetMissingDirs] count]; i++)
    {
      [tempStr appendString:[[engine targetMissingDirs] objectAtIndex:i]];
      [tempStr appendString:@"\n"];
    }
  [tempStr appendString:@"\n"];

  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];

  /* Files present in Source bot not Target */
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  [tempStr appendString:@"Files present in Source but not Target:\n"];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: titleAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  [attrStrMut appendAttributedString:sepAttrStr];

  tempStr = [NSMutableString new];
  for (i = 0; i < [[engine targetMissingFiles] count]; i++)
    {
      [tempStr appendString:[[[engine targetMissingFiles] objectAtIndex:i] relativePath]];
      [tempStr appendString:@"\n"];
    }

  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];

  tempStr = [NSString stringWithFormat:@"Count: %lu\n", (unsigned long)[[engine targetMissingFiles] count]];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  
  if (nil != [engine targetMissingFiles])
    {
      tempStr = [NSString stringWithFormat:@"Size: %@\n", [[engine targetMissingFiles] sizeStr]];
      attrStr = [[NSAttributedString alloc] initWithString: tempStr
						attributes: textAttributes];
      [attrStrMut appendAttributedString:attrStr];
      [attrStr release];
    }

  attrStr = [[NSAttributedString alloc] initWithString: @"\n"
                                            attributes: textAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  
  
  /* -- Directories present in Target but not in Source */
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  [tempStr appendString:@"Directories present in Target but not Source:\n"];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: titleAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  [attrStrMut appendAttributedString:sepAttrStr];

  tempStr = [NSMutableString new];
  for (i = 0; i < [[engine sourceMissingDirs] count]; i++)
    {
      [tempStr appendString:[[engine sourceMissingDirs] objectAtIndex:i]];
      [tempStr appendString:@"\n"];
    }
  [tempStr appendString:@"\n"];

  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];

  /* -- Files present in Target but not in Source -- */
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  [tempStr appendString:@"Files present in Target but not Source:\n"];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: titleAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  [attrStrMut appendAttributedString:sepAttrStr];

  tempStr = [NSMutableString new];
  for (i = 0; i < [[engine sourceMissingFiles] count]; i++)
    {
      [tempStr appendString:[[[engine sourceMissingFiles] objectAtIndex:i] relativePath]];
      [tempStr appendString:@"\n"];
    }

  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  tempStr = [NSString stringWithFormat:@"Count: %lu\n", (unsigned long)[[engine sourceMissingFiles] count]];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];

  if (nil != [engine sourceModFiles])
    {
      tempStr = [NSString stringWithFormat:@"Size: %@\n", [[engine sourceMissingFiles] sizeStr]];
      attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
      [attrStrMut appendAttributedString:attrStr];
      [attrStr release];
    }
  attrStr = [[NSAttributedString alloc] initWithString: @"\n"
                                            attributes: textAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  

  /* -- Files are modified more recently in Source than Target -- */
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  [tempStr appendString:@"Files which are modified more recently Source than Target:\n"];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: titleAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  [attrStrMut appendAttributedString:sepAttrStr];

  tempStr = [NSMutableString new];
  for (i = 0; i < [[engine sourceModFiles] count]; i++)
    {
      [tempStr appendString:[[[engine sourceModFiles] objectAtIndex:i] relativePath]];
      [tempStr appendString:@"\n"];
    }

  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  tempStr = [NSString stringWithFormat:@"Count: %lu\n", (unsigned long)[[engine sourceModFiles]  count]];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];

  if (nil != [engine sourceModFiles])
    {
      tempStr = [NSString stringWithFormat:@"Size: %@\n", [[engine sourceModFiles] sizeStr]];
      attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
      [attrStrMut appendAttributedString:attrStr];
      [attrStr release];
    }
  attrStr = [[NSAttributedString alloc] initWithString: @"\n"
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];

  /* -- Files are modified more recently in Target than Source -- */
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  [tempStr appendString:@"Files which are modified more recently Target than Source:\n"];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: titleAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  [attrStrMut appendAttributedString:sepAttrStr];

  tempStr = [NSMutableString new];
  for (i = 0; i < [[engine targetModFiles] count]; i++)
    {
      [tempStr appendString:[[[engine targetModFiles] objectAtIndex:i] relativePath]];
      [tempStr appendString:@"\n"];
    }

  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  tempStr = [NSString stringWithFormat:@"Count: %lu\n", (unsigned long)[[engine targetModFiles]  count]];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];

  if (nil != [engine targetModFiles])
    {
      tempStr = [NSString stringWithFormat:@"Size: %@\n", [[engine targetModFiles] sizeStr]];
      attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
      [attrStrMut appendAttributedString:attrStr];
      [attrStr release];
    }
  attrStr = [[NSAttributedString alloc] initWithString: @"\n"
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];


  /* -- Files different in size between Source and Target -- */
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  [tempStr appendString:@"Files which differ in size between Source and Target but have same modification date:\n"];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: titleAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  [attrStrMut appendAttributedString:sepAttrStr];

  tempStr = [NSMutableString new];
  for (i = 0; i < [[engine sizeDiffFiles] count]; i++)
    {
      [tempStr appendString:[[[engine sizeDiffFiles] objectAtIndex:i] relativePath]];
      [tempStr appendString:@"\n"];
    }

  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  tempStr = [NSString stringWithFormat:@"Count: %lu\n", (unsigned long)[[engine sizeDiffFiles]  count]];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];

  if (nil != [engine sizeDiffFiles])
    {
      tempStr = [NSString stringWithFormat:@"Size: %@\n", [[engine sizeDiffFiles] sizeStr]];
      attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
      [attrStrMut appendAttributedString:attrStr];
      [attrStr release];
    }
  
  attrStr = [[NSAttributedString alloc] initWithString: @"\n"
					    attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];

  /* -- Files different in date between Source and Target -- */
  [attrStrMut appendAttributedString:sepAttrStr];
  
  tempStr = [NSMutableString new];
  [tempStr appendString:@"Files which differ in modification date between Source and Target but have same size:\n"];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: titleAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  [attrStrMut appendAttributedString:sepAttrStr];

  tempStr = [NSMutableString new];
  for (i = 0; i < [[engine dateDiffFiles] count]; i++)
    {
      [tempStr appendString:[[[engine dateDiffFiles] objectAtIndex:i] relativePath]];
      [tempStr appendString:@"\n"];
    }

  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];
  [tempStr release];
  
  tempStr = [NSString stringWithFormat:@"Count: %lu\n", (unsigned long)[[engine dateDiffFiles]  count]];
  attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];

  if (nil != [engine sizeDiffFiles])
    {
      tempStr = [NSString stringWithFormat:@"Size: %@\n", [[engine dateDiffFiles] sizeStr]];
      attrStr = [[NSAttributedString alloc] initWithString: tempStr
                                            attributes: textAttributes];
      [attrStrMut appendAttributedString:attrStr];
      [attrStr release];
    }
  
  attrStr = [[NSAttributedString alloc] initWithString: @"\n"
					    attributes: textAttributes];

  [attrStrMut appendAttributedString:attrStr];
  [attrStr release];

  [self performSelectorOnMainThread:@selector(_appendStringToViewAndScroll:) withObject:attrStrMut waitUntilDone:NO];

  [attrStrMut autorelease]; // used on another thread
  [sepAttrStr release];
}

- (void)performSync:(id)sender
{
  NSAutoreleasePool *arp;
  
  arp = [NSAutoreleasePool new]; // we are in a thread, have our own ARP

  if (![engine analyzed])
    [self performAnalyze:sender];

  [engine synchronize];

  [syncButton setEnabled:NO];
  [analyzeButton setEnabled:YES];
  [stopButton setEnabled:NO];
  [arp release];
}

- (IBAction)syncAction:(id)sender
{
  [engine setSourceRoot: [sourcePathField stringValue]];
  [engine setTargetRoot:[targetPathField stringValue]];

  [engine setHandleDirectories: [handleDirectoriesCheck state] == NSOnState];
  [engine setUpdateSource: [updateSourceCheck state] == NSOnState];
  [engine setInsertItems: [insertItemsCheck state] == NSOnState];
  [engine setUpdateItems: [updateItemsCheck state] == NSOnState];
  [engine setDeleteItems: [deleteItemsCheck state] == NSOnState];

  [analyzeButton setEnabled:NO];
  [syncButton setEnabled:NO];
  [stopButton setEnabled:YES];

  [NSThread detachNewThreadSelector:@selector(performSync:) toTarget:self withObject:nil];
}

- (void)_cleanLogView:(id)p
{
  NSTextStorage *ts;
  
  ts = [logView textStorage];
  [ts deleteCharactersInRange:NSMakeRange(0, [[ts mutableString] length])];
}

- (void)initProgress:(id)sender
{
  if ([engine progressIsDeterminate])
    {
      [progressBar setIndeterminate:NO];
      [progressBar stopAnimation:nil];
      [progressBar setMinValue:[engine progressMinValue]];
      [progressBar setMaxValue:(double)[engine progressMaxValue]];
    }
  else
    {
      [progressBar setIndeterminate:YES];
      [progressBar startAnimation:nil];
    }
}

- (void)updateProgress:(id)sender
{
  if ([engine progressIsDeterminate])
    {
      [progressBar setDoubleValue:[engine progressCurrentValue]];
    }
}

- (void)finishProgress:(id)sender
{
  if ([engine progressIsDeterminate] == NO)
    {
      [progressBar stopAnimation:nil];
    }
}

- (void)_appendStringToViewAndScroll:(NSAttributedString *)str
{
  [str retain];

  [[logView textStorage] appendAttributedString: str];

  /* we scroll in the next run of the event loop */
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
  [logView scrollRangeToVisible:NSMakeRange([[logView string] length], 0)];

  [str release];
}

@end
