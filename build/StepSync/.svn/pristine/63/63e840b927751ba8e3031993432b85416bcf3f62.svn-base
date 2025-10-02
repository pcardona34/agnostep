/*
   Project: StepSync
   FileObject.h

   Copyright (C) 2017 Free Software Foundation

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

#import <Foundation/Foundation.h>

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
typedef unsigned NSUInteger;
typedef int NSInteger;
#endif

@interface FileObject : NSObject
{
  NSString *absolutePath;
  NSString *relativePath;
  unsigned long long size;
  NSDate *createdDate;
  NSDate *modifiedDate;
}

+ (NSString *)formatSize:(unsigned long long)size;

- (void)setFileAttributes:(NSDictionary *)attr;
- (NSString *)absolutePath;
- (void)setAbsolutePath:(NSString *)path;
- (NSString *)relativePath;
- (void)setRelativePath:(NSString *)path;
- (unsigned long long)size;
- (void)setSize:(unsigned long)aSize;
- (NSDate *)createdDate;
- (void)setCreatedDate:(NSDate *)date;
- (NSDate *)modifiedDate;
- (void)setModifiedDate:(NSDate *)date;

@end

