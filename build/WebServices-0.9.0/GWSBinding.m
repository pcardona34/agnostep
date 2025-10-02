/** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	January 2008
   
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

@implementation GWSBinding (Private)
- (id) _initWithName: (NSString*)name document: (GWSDocument*)document
{
  if ((self = [super init]) != nil)
    {
      GWSElement        *elem;

      _name = [name copy];
      _document = document;
      elem = [_document initializing];
      [self setTypeName: [[elem attributes] objectForKey: @"type"]];
      elem = [elem firstChild];
      if ([[elem name] isEqualToString: @"documentation"] == YES)
        {
          _documentation = [elem retain];
          elem = [elem sibling];
          [_documentation remove];
        }
      while (elem != nil && [[elem name] isEqualToString: @"operation"] == NO)
        {
	  NSString	*problem;

	  problem = [_document _validate: elem in: self];
	  if (problem != nil)
	    {
	      NSLog(@"Bad binding extensibility: %@", problem);
	    }
          if (_extensibility == nil)
            {
              _extensibility = [NSMutableArray new];
            }
          [_extensibility addObject: elem];
          elem = [elem sibling];
          [[_extensibility lastObject] remove];
        }
      while (elem != nil)
        {
          GWSElement    *used = nil;

          if ([[elem name] isEqualToString: @"operation"] == YES)
            {
              NSString          *name;

              name = [[elem attributes] objectForKey: @"name"];
              if (name == nil)
                {
                  NSLog(@"Operation without a name in WSDL!");
                }
              else
                {
                  if (_operations == nil)
                    {
                      _operations = [NSMutableDictionary new];
                    }
                  used = elem;
                  [_operations setObject: elem forKey: name];
                }
            }
          else
            {
              NSLog(@"Bad element '%@' in binding", [elem name]);
            }
          elem = [elem sibling];
          [used remove];
        }
    }
  return self;
}
- (void) _remove
{
  _document = nil;
}
@end

@implementation	GWSBinding

- (void) dealloc
{
  [_documentation release];
  [_extensibility release];
  [_operations release];
  [_type release];
  [_name release];
  [super dealloc];
}

- (GWSElement*) documentation
{
  return _documentation;
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

- (GWSElement*) operationWithName: (NSString*)name
			   create: (BOOL)shouldCreate
{
  GWSElement	*result = [_operations objectForKey: name];

  if (result == nil && shouldCreate == YES)
    {
      GWSPortType	*type = [self type];
      GWSElement	*base = [type operationWithName: name create: NO];

      if (base != nil)
	{
// FIXME ... create here
	}
    }
  return result;
}

- (NSDictionary*) operations
{
  return [[_operations copy] autorelease];
}

- (void) removeOperationNamed: (NSString*)name
{
  [_operations removeObjectForKey: name];
}

- (void) setDocumentation: (GWSElement*)documentation
{
  if (documentation != _documentation)
    {
      id        o = _documentation;

      _documentation = [documentation retain];
      [o release];
      [_documentation remove];
    }
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

- (void) setTypeName: (NSString*)type
{
  if (type != _type)
    {
      NSString  *old = _type;

      _type = [type retain];
      [old release];
    }
}

- (GWSElement*) tree
{
  GWSElement    *tree;
  GWSElement    *elem;
  NSEnumerator  *enumerator;

  tree = [[GWSElement alloc] initWithName: @"binding"
                                namespace: nil
                                qualified: [_document qualify: @"binding"]
                               attributes: nil];
  [tree setAttribute: _name forKey: @"name"];
  [tree setAttribute: _type forKey: @"type"];
  if (_documentation != nil)
    {
      elem = [_documentation mutableCopy];
      [tree addChild: elem];
      [elem release];
    }
  enumerator = [_extensibility objectEnumerator];
  while ((elem = [enumerator nextObject]) != nil)
    {
      elem = [elem mutableCopy];
      [tree addChild: elem];
      [elem release];
    }
  enumerator = [_operations objectEnumerator];
  while ((elem = [enumerator nextObject]) != nil)
    {
      elem = [elem mutableCopy];
      [tree addChild: elem];
      [elem release];
    }
  return [tree autorelease];
}

- (GWSPortType*) type
{
  if (_type != nil)
    {
      return [_document portTypeWithName: _type create: NO];
    }
  return nil;
}

@end

