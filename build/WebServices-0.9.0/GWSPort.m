/** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	November 2008
   
   This file is part of the WebServices Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

   $Date: 2007-09-24 14:19:12 +0100 (Mon, 24 Sep 2007) $ $Revision: 25500 $
   */ 

#import <Foundation/Foundation.h>
#import "GWSPrivate.h"

@implementation	GWSPort (Private)

- (id) _initWithName: (NSString*)name
	    document: (GWSDocument*)document
		from: (GWSElement*)elem
{
  if ((self = [super init]) != nil)
    {
      _name = [name copy];
      _document = document;
      _binding = [[[elem attributes] objectForKey: @"binding"] copy];
      elem = [elem firstChild];
      while (elem != nil)
        {
	  NSString	*problem;

	  problem = [_document _validate: elem in: self];
	  if (problem != nil)
	    {
	      NSLog(@"Bad port extensibility: %@", problem);
	    }
          if (_extensibility == nil)
            {
              _extensibility = [NSMutableArray new];
            }
          [_extensibility addObject: elem];
          elem = [elem sibling];
          [[_extensibility lastObject] remove];
        }
    }
  return self;
}
- (void) _remove
{
  _document = nil;
}
@end

@implementation	GWSPort

- (GWSBinding*) binding
{
  return [_document bindingWithName: _binding create: NO];
}

- (void) dealloc
{
  [_extensibility release];
  [_binding release];
  [_name release];
  [super dealloc];
}

- (NSArray*) extensibility
{
  return [[_extensibility copy] autorelease];
}

- (id) init
{
  [self release];
  return nil;
}

- (NSString*) name
{
  return _name;
}

- (void) setExtensibility: (NSArray*)extensibility
{
  NSMutableArray	*m;
  unsigned		c;

  c = [extensibility count];
  while (c-- > 0)
    {
      NSString		*problem;
      GWSElement	*element;

      element = [extensibility objectAtIndex: c];
      problem = [_document _validate: element in: self];
      if (problem != nil)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"%@", problem];
	}
    }

  m = [extensibility mutableCopy];
  [_extensibility release];
  _extensibility = m;
}

- (GWSElement*) tree
{
  GWSElement    *tree;
  GWSElement    *elem;
  NSEnumerator  *enumerator;

  tree = [[GWSElement alloc] initWithName: @"port"
                                namespace: nil
                                qualified: [_document qualify: @"port"]
                               attributes: nil];
  [tree setAttribute: _name forKey: @"name"];
  [tree setAttribute: _binding forKey: @"binding"];
  enumerator = [_extensibility objectEnumerator];
  while ((elem = [enumerator nextObject]) != nil)
    {
      elem = [elem mutableCopy];
      [tree addChild: elem];
      [elem release];
    }
  return [tree autorelease];
}
@end

