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

@implementation	GWSMessage (Private)
- (id) _initWithName: (NSString*)name document: (GWSDocument*)document
{
  if ((self = [super init]) != nil)
    {
      GWSElement        *elem;

      _name = [name copy];
      _document = document;

      elem = [_document initializing];
      elem = [elem firstChild];
      if ([[elem name] isEqualToString: @"documentation"] == YES)
        {
          _documentation = [elem retain];
          elem = [elem sibling];
          [_documentation remove];
        }
      while (elem != nil)
        {
          if ([[elem name] isEqualToString: @"part"] == YES)
            {
              NSDictionary      *attrs = [elem attributes];
              NSString          *name;

              name = [attrs objectForKey: @"name"];
              if (name == nil)
                {
                  NSLog(@"Part without a name in WSDL!");
                }
              else
                {
                  NSString      *type = [attrs objectForKey: @"type"];
                  NSString      *element = [attrs objectForKey: @"element"];

                  if (type == nil && element == nil)
                    {
                      NSLog(@"Part %@ without element or type", name);
                    }
                  else if (type != nil && element != nil)
                    {
                      NSLog(@"Part %@ with both element or type", name);
                    }
                  else if (type != nil)
                    {
                      [self setType: type forPartNamed: name];
                    }
                  else
                    {
                      [self setElement: element forPartNamed: name];
                    }
                }
            }
          else
            {
              NSLog(@"Bad element '%@' in message", [elem name]);
            }
          elem = [elem sibling];
        }
    }
  return self;
}
- (void) _remove
{
  _document = nil;
}
@end

@implementation	GWSMessage

- (void) dealloc
{
  [_name release];
  [_documentation release];
  [_types release];
  [_elements release];
  [super dealloc];
}

- (GWSElement*) documentation
{
  return _documentation;
}

- (NSString*) elementOfPartNamed: (NSString*)name
{
  return [_elements objectForKey: name];
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

- (NSArray*) partNames
{
  NSMutableArray        *m;
  NSEnumerator          *e;
  NSString              *n;

  m = [NSMutableArray arrayWithCapacity: [_types count] + [_elements count]];
  e = [_types keyEnumerator];
  while ((n = [e nextObject]) != nil)
    {
      [m addObject: n];
    }
  e = [_elements keyEnumerator];
  while ((n = [e nextObject]) != nil)
    {
      [m addObject: n];
    }
  [m sortUsingSelector: @selector(compare:)];
  return m;
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

- (void) setElement: (NSString*)type forPartNamed: (NSString*)name
{
  if (type == nil)
    {
      [_elements removeObjectForKey: name];
      if ([_elements count] == 0)
        {
          [_elements release];
          _elements = nil;
        }
    }
  else
    {
      [_types removeObjectForKey: type];
      if (_elements == nil)
        {
          _elements = [NSMutableDictionary new];
        }
      [_elements setObject: type forKey: name];
    }
}

- (void) setType: (NSString*)type forPartNamed: (NSString*)name
{
  if (type == nil)
    {
      [_types removeObjectForKey: name];
      if ([_types count] == 0)
        {
          [_types release];
          _types = nil;
        }
    }
  else
    {
      [_elements removeObjectForKey: name];
      if (_types == nil)
        {
          _types = [NSMutableDictionary new];
        }
      [_types setObject: type forKey: name];
    }
}

- (GWSElement*) tree
{
  GWSElement    *tree;
  GWSElement    *elem;
  NSEnumerator  *enumerator;
  NSString      *key;
  NSString      *qual;

  tree = [[GWSElement alloc] initWithName: @"message"
                                namespace: nil
                                qualified: [_document qualify: @"message"]
                               attributes: nil];
  [tree setAttribute: _name forKey: @"name"];
  if (_documentation != nil)
    {
      elem = [_documentation mutableCopy];
      [tree addChild: elem];
      [elem release];
    }
  qual = [_document qualify: @"part"];
  enumerator = [_types keyEnumerator];
  while ((key = [enumerator nextObject]) != nil)
    {
      NSString  *val = [_types objectForKey: key];

      elem = [[GWSElement alloc] initWithName: @"part"
                                    namespace: nil
                                    qualified: qual
                                   attributes: nil];
      [elem setAttribute: key forKey: @"name"];
      [elem setAttribute: val forKey: @"type"];
      [tree addChild: elem];
      [elem release];
    }
  enumerator = [_elements keyEnumerator];
  while ((key = [enumerator nextObject]) != nil)
    {
      NSString  *val = [_elements objectForKey: key];

      elem = [[GWSElement alloc] initWithName: @"part"
                                    namespace: nil
                                    qualified: qual
                                   attributes: nil];
      [elem setAttribute: key forKey: @"name"];
      [elem setAttribute: val forKey: @"element"];
      [tree addChild: elem];
      [elem release];
    }
  return [tree autorelease];
}

- (NSString*) typeOfPartNamed: (NSString*)name
{
  return [_types objectForKey: name];
}

@end

