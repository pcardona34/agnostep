/*
   Project: StepSync
   FileMap.m

   Copyright (C) 2017-2020 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2017-02-03

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

#import "FileMap.h"
#import "FileObject.h"

@implementation FileMap

- (id) init
{
  if ((self = [super init]))
    {
      rootPath = nil;
      directories = [NSMutableArray new];
      files = [NSMutableDictionary new];
      fm = [NSFileManager defaultManager];

      thumbFilesArray = [NSArray arrayWithObjects:
				   @"Thumbs.db",
				 @"ehthumbs.db",
				 @"index.sqlite",
				 @"thumbnails.data",
				 nil
			 ];
      [thumbFilesArray retain];

      skipHiddenFolders = NO;
      skipHiddenFiles = NO;
      skipThumbFiles = NO;
      size = 0;
    }
  return self;
}

- (void) dealloc
{
  [rootPath release];
  [directories release];
  [files release];
  [thumbFilesArray release];
  [super dealloc];
}

- (void)setSkipHiddenFolders:(BOOL)flag
{
  skipHiddenFolders = flag;
}

- (void)setSkipHiddenFiles:(BOOL)flag
{
  skipHiddenFiles = flag;
}

- (void)setSkipThumbFiles:(BOOL)flag
{
  skipThumbFiles = flag;
}

/* pass last component of path: directory or file name */
- (BOOL)checkIfToSkip:(NSString *)item isDir:(BOOL)dir
{
  BOOL isHidden;

  // we assume standard Unix convention that hidden Files/Dirs start with .
  isHidden = [item hasPrefix:@"."];

  if (dir && skipHiddenFolders && isHidden)
    return YES;

  if (!dir && skipHiddenFiles && isHidden)
    return YES;

  if (skipThumbFiles && [thumbFilesArray containsObject:item])
    return YES;

  return NO;
}

- (NSString *)rootPath
{
  return rootPath;
}

- (void)setRootPath:(NSString *)path
{
  if (rootPath != path)
    {
      [rootPath release];
      rootPath = [path stringByStandardizingPath];
      [rootPath retain];
    }
}

- (NSMutableArray *)directories
{
  return directories;
}

- (NSMutableDictionary *)files
{
  return files;
}

- (unsigned long long)size
{
  return size;
}

- (void)analyzeRecursePath:(NSString *)path currentDepth:(unsigned)depth
{
  NSArray *dirContents;
  NSUInteger i;
  NSDictionary *attr;
  
  dirContents = [fm directoryContentsAtPath:path];
  for (i = 0; i < [dirContents count]; i++)
    {
      NSString *element;
      NSString *fullPath;
      NSString *fileType;
      NSString *relPath;
      
      element = [dirContents objectAtIndex:i];
      fullPath = [path stringByAppendingPathComponent:element];
      relPath = [fullPath substringFromIndex:[rootPath length]+1];
      attr = [fm fileAttributesAtPath:fullPath traverseLink:NO];
      fileType = [attr fileType];
      if (fileType == NSFileTypeDirectory)
        {
	  if (![self checkIfToSkip:element isDir:YES])
	    {
	      [directories addObject:relPath];
	      if (depth > 0)
		[self analyzeRecursePath:fullPath currentDepth:depth-1];
	      else
		NSLog(@"Max recurse depth reached in %@", path);
	    }
        }
      else if (fileType == NSFileTypeRegular)
        {
	  if (![self checkIfToSkip:element isDir:NO])
	    {
	      FileObject *fo;
          
	      fo = [[FileObject alloc] init];
	      [fo setAbsolutePath:fullPath];
	      [fo setRelativePath:relPath];
	      [fo setFileAttributes:attr];
	      [files setObject:fo forKey:relPath];
              size += [fo size];
	      [fo release];
	    }
        }
      else if (fileType == NSFileTypeSymbolicLink)
        {
          NSLog(@"%@ link not handled", element);
        }
      else
        {
          NSLog(@"unknown not handled file type");
        }
    }
}

- (void)analyze
{
  BOOL isDir;
  
  if (nil == rootPath)
    return;
  
  /* check if root is dir and exists */
  if (!([fm fileExistsAtPath:rootPath isDirectory:&isDir] && isDir))
    {
      NSLog(@"Root path is not a directory or does not exist: %@", rootPath);
      return;
    }
  [self analyzeRecursePath:rootPath currentDepth:1024];
}

@end
