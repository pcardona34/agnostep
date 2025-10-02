/*
   Project: StepSync
   FileObject.m

   Copyright (C) 2017-2019 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2017-02-05

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

#import "FileObject.h"

@implementation FileObject

+ (NSString *)formatSize:(unsigned long long)size
{
  double dSize;

  if (size < 1024)
    return [NSString stringWithFormat:@"%llu Bytes", size];
  
  dSize = (double)size / 1024;
  if (dSize < 1024)
    return [NSString stringWithFormat:@"%.1lf KiB", dSize];

  dSize = dSize / 1024;
  if (dSize < 1024)
    return [NSString stringWithFormat:@"%.1lf MiB", dSize];

  dSize = dSize / 1024;
  if (dSize < 1024)
    return [NSString stringWithFormat:@"%.1lf GiB", dSize];

  dSize = dSize / 1024;
  return [NSString stringWithFormat:@"%.1lf TiB", dSize];
}

- (void)setFileAttributes:(NSDictionary *)attr
{
  size = [attr fileSize];
  createdDate = [attr fileCreationDate];
  modifiedDate = [attr fileModificationDate];
}

- (NSString *)absolutePath
{
  return absolutePath;
}

- (void)setAbsolutePath:(NSString *)path
{
  if (absolutePath != path)
    {
      [absolutePath release];
      absolutePath = path;
      [absolutePath retain];
    }
}


- (NSString *)relativePath
{
  return relativePath;
}

- (void)setRelativePath:(NSString *)path
{
  if (relativePath != path)
    {
      [relativePath release];
      relativePath = path;
      [relativePath retain];
    }
}

- (unsigned long long)size
{
  return size;
}

- (void)setSize:(unsigned long)aSize
{
  size = aSize;
}


- (NSDate *)createdDate
{
  return createdDate;
}

- (void)setCreatedDate:(NSDate *)date
{
  if (createdDate != date)
    {
      [createdDate release];
      createdDate = date;
      [createdDate retain];
    }
}


- (NSDate *)modifiedDate
{
  return modifiedDate;
}

- (void)setModifiedDate:(NSDate *)date
{
  if (modifiedDate != date)
    {
      [modifiedDate release];
      modifiedDate = date;
      [modifiedDate retain];
    }
}

- (NSString *)description
{
  NSString *d;

  d = [NSString stringWithFormat:@"%@", relativePath];
  return d;
}

@end
