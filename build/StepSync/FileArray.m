/*
   Project: StepSync
   FileArray.m

   Copyright (C) 2019 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2019-11-17

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

#import "FileArray.h"
#import "FileObject.h"

@implementation FileArray

/* --- Subclassed Methods --- */

- (id) init
{
  if ((self = [super init]))
    {
      storageArray = [[NSMutableArray alloc] init];
    }
  return self;
}

- (id) initWithCapacity: (NSUInteger)capacity
{
  if ((self = [super init]))
    {
      storageArray = [[NSMutableArray alloc] initWithCapacity: capacity];
    }
  return self;
}

- (void) dealloc
{
  [storageArray release];
  [super dealloc];
}

- (NSUInteger) count
{
  return [storageArray count];
}

- (id) objectAtIndex:(NSUInteger)index
{
  return [storageArray objectAtIndex:index];
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index
{
  [storageArray insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
  [storageArray removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject
{
  [storageArray addObject:anObject];
}

- (void)removeLastObject
{
  [storageArray removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
  [storageArray replaceObjectAtIndex:index withObject:anObject];
}


/* --- Custom Methods --- */

- (unsigned long long)size
{
  NSUInteger i;
  unsigned long long result;
  
  result = 0;
  for (i = 0; i < [self count]; i++)
    result += [[self objectAtIndex:i] size];
  return result;
}

- (NSString *)sizeStr
{
  return [FileObject formatSize:[self size]];
}

@end
