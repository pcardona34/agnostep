//
//  Engine.h
//  StepSync
//
//  Created by Riccardo Mottola on 19/10/2018.
//  Copyright 2018-2021 GNUstep. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileMap;
@class FileArray;

@interface Engine : NSObject
{
  id controller;

  BOOL analyzed;
  BOOL stopTask;
  FileMap *sourceMap;
  FileMap *targetMap;
  NSMutableArray *targetMissingDirs;
  NSMutableArray *sourceMissingDirs;
  FileArray *targetMissingFiles;
  FileArray *sourceMissingFiles;
  FileArray *sourceModFiles;
  FileArray *targetModFiles;
  FileArray *dateDiffFiles; // files with same size but different mod date
  FileArray *sizeDiffFiles; // files with same mod date but different size

  BOOL handleDirectories;
  BOOL updateSource;
  BOOL insertItems;
  BOOL updateItems;
  BOOL deleteItems;
  BOOL skipHiddenFolders;
  BOOL skipHiddenFiles;
  BOOL skipThumbFiles;
  BOOL forceUpdateIfOnlyDateDiffers;
  unsigned dateTimeTolerance;
  NSString *sourceRoot;
  NSString *targetRoot;
  
  /* progress status */
  BOOL progressIsDeterminate;
  NSUInteger progressMinValue;
  NSUInteger progressMaxValue;
  NSUInteger progressCurrentValue;
}

- (void)setController:(id)ac;

- (BOOL)analyzed;
- (void)setHandleDirectories:(BOOL)flag;
- (void)setUpdateSource:(BOOL)flag;
- (void)setInsertItems:(BOOL)flag;
- (void)setUpdateItems:(BOOL)flag;
- (void)setDeleteItems:(BOOL)flag;

- (BOOL)skipHiddenFolders;
- (void)setSkipHiddenFolders:(BOOL)flag;
- (BOOL)skipHiddenFiles;
- (void)setSkipHiddenFiles:(BOOL)flag;
- (BOOL)skipThumbFiles;
- (void)setSkipThumbFiles:(BOOL)flag;
- (BOOL)forceUpdateIfOnlyDateDiffers;
- (void)setForceUpdateIfOnlyDateDiffers:(BOOL)flag;
- (unsigned)dateTimeTolerance;
- (void)setDateTimeTolerance: (unsigned)delta;

- (NSString *)sourceRoot;
- (void)setSourceRoot: (NSString *)path;

- (NSString *)targetRoot;
- (void)setTargetRoot: (NSString *)path;

- (FileMap *)sourceMap;
- (FileMap *)targetMap;


- (void)stopTask;

- (NSMutableArray *)targetMissingDirs;
- (NSMutableArray *)sourceMissingDirs;
- (FileArray *)targetMissingFiles;
- (FileArray *)sourceMissingFiles;
- (FileArray *)sourceModFiles;
- (FileArray *)targetModFiles;
- (FileArray *)sizeDiffFiles;
- (FileArray *)dateDiffFiles;

- (void)analyze;
- (BOOL)checkFreeSpace;
- (void)synchronize;

- (BOOL) progressIsDeterminate;
- (NSUInteger) progressMinValue;
- (NSUInteger) progressMaxValue;
- (NSUInteger) progressCurrentValue;

@end
