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

static NSMutableDictionary	*extDict = nil;
static NSLock			*extLock = nil;

@implementation GWSDocument (Private)

/* Make sure that a name is the local version without the target prefix.
 */
- (NSString*) _local: (NSString*)name
{
  NSRange	r = [name rangeOfString: @":"];

  if (r.length > 0)
    {
      return [name substringFromIndex: NSMaxRange(r)];
    }
  return name;
}


- (NSString*) _validate: (GWSElement*)element in: (id)section
{
  NSString		*n;

  n = [element namespace];
  if (n != nil)
    {
      GWSExtensibility	*e = [_ext objectForKey: n];

      if (e != nil)
	{
	  return [e validate: element for: self in: section setup: nil];
	}
    }
  return nil;
}
@end

@implementation GWSDocument

+ (void) initialize
{
  if (extLock == nil)
    {
      GWSSOAPExtensibility	*e;

      extLock = [NSLock new];
      extDict = [NSMutableDictionary new];
      e = [GWSSOAPExtensibility	new];
      [self registerExtensibility: e forNamespace:
        @"http://schemas.xmlsoap.org/wsdl/soap/"];
      [e release];
    }
}

+ (GWSExtensibility*) extensibilityForNamespace: (NSString*)namespaceURL
{
  GWSExtensibility	*e;

  if (namespaceURL == nil)
    {
      e = nil;
    }
  else
    {
      [extLock lock];
      e = [[extDict objectForKey: namespaceURL] retain];
      [extLock unlock];
    }
  return [e autorelease];
}

+ (void) registerExtensibility: (GWSExtensibility*)extensibility
		  forNamespace: (NSString*)namespaceURL
{
  if (namespaceURL != nil)
    {
      [extLock lock];
      if (extensibility == nil)
	{
	  [extDict removeObjectForKey: namespaceURL];
	}
      else
	{
	  [extDict setObject: extensibility forKey: namespaceURL];
	}
      [extLock unlock];
    }
}

- (NSArray*) bindingNames
{
  NSArray       *result;

  [_lock lock];
  result = [_bindings allKeys];
  [_lock unlock];
  return result;
}

- (GWSBinding*) bindingWithName: (NSString*)name
                         create: (BOOL)shouldCreate
{
  GWSBinding    *binding;

  name = [self _local: name];
  [_lock lock];
  binding = [_bindings objectForKey: name];
  if (binding == nil && shouldCreate == YES)
    {
      binding = [[GWSBinding alloc] _initWithName: name document: self];
      [_bindings setObject: binding forKey: name];
    }
  else
    {
      [binding retain];
    }
  [_lock unlock];
  return [binding autorelease];
}

- (NSData*) data
{
  NSAutoreleasePool     *pool;
  GWSElement            *tree;
  GWSCoder              *coder;
  NSData                *data;

  pool = [NSAutoreleasePool new];
  tree = [self tree];
  coder = [[GWSCoder new] autorelease];
  [[coder mutableString]
    appendString: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
  [tree encodeWith: coder];
  data = [[coder mutableString] dataUsingEncoding: NSUTF8StringEncoding];
  [data retain];
  [pool release];
  return [data autorelease];
}

- (void) dealloc
{
  NSEnumerator  *e;
  id            o;

  [_ext release];
  [_name release];
  [_prefix release];
  [_targetNamespace release];
  [_documentation release];
  [_extensibility release];
  e = [_portTypes objectEnumerator];
  while ((o = [e nextObject]) != nil) [o _remove];
  [_portTypes release];
  e = [_bindings objectEnumerator];
  while ((o = [e nextObject]) != nil) [o _remove];
  [_bindings release];
  e = [_services objectEnumerator];
  while ((o = [e nextObject]) != nil) [o _remove];
  [_services release];
  e = [_messages objectEnumerator];
  while ((o = [e nextObject]) != nil) [o _remove];
  [_messages release];
  e = [_types objectEnumerator];
  while ((o = [e nextObject]) != nil) [o _remove];
  [_types release];
  [_namespaces release];
  [_lock release];
  [super dealloc];
}

- (GWSElement*) documentation
{
  return _documentation;
}

- (GWSExtensibility*) extensibilityForNamespace: (NSString*)namespaceURL
{
  return [_ext objectForKey: namespaceURL];
}

- (NSArray*) extensibility
{
  NSArray	*a;

  [_lock lock];
  a = [_extensibility copy];
  [_lock unlock];
  return [a autorelease];
}

- (id) init
{
  if ((self = [super init]) != nil)
    {
      _lock = [NSRecursiveLock new];
      _portTypes = [NSMutableDictionary new];
      _bindings = [NSMutableDictionary new];
      _services = [NSMutableDictionary new];
      _messages = [NSMutableDictionary new];
      _namespaces = [NSMutableDictionary new];
      _types = [NSMutableDictionary new];
      _extensibility = [NSMutableArray new];
      [extLock lock];
      _ext = [extDict copy];
      [extLock unlock];
    }
  return self;
}

- (GWSElement*) initializing
{
  return _elem;
}

- (id) initWithContentsOfFile: (NSString*)file
{
  NSData        *data = [NSData dataWithContentsOfFile: file];

  return [self initWithData: data];
}

- (id) initWithContentsOfURL: (NSURL*)url
{
  NSData        *data = [NSData dataWithContentsOfURL: url];

  return [self initWithData: data];
}

- (id) initWithData: (NSData*)xml
{
  if ([xml length] == 0)
    {
      NSLog(@"No data passed to -initWithData:");
      [self release];
      self = nil;
    }
  else
    {
      NS_DURING
        {
          GWSCoder      *parser;
          GWSElement    *root = nil;

          parser = [[GWSCoder new] autorelease];
	  [parser setDebug: YES];
          root = [parser parseXML: xml];
          if (root == nil)
            {
              NSLog(@"Data could not be parsed as XML in -initWithData:");
              [self release];
              self = nil;
            }
          else
            {
              self = [self initWithTree: root];
            }
        }
      NS_HANDLER
        {
          NSLog(@"Problem parsing WSDL ... %@", localException);
          [self release];
          self = nil;
        }
      NS_ENDHANDLER
    }
  return self;
}

- (id) initWithTree: (GWSElement*)tree
{
  if (tree == nil)
    {
      [self release];
      self = nil;
    }
  else if ((self = [self init]) != nil)
    {
      NS_DURING
        {
          NSString      *name;

          if ([[tree name] isEqualToString: @"definitions"] == NO)
            {
              [NSException raise: NSInvalidArgumentException
                          format: @"root element is '%@', not 'definitions'",
                          [tree name]];
            }
          else
            {
              NSDictionary      *d;
              NSEnumerator      *e;
              NSString          *k;

              k = [tree qualified];
              [_prefix release];
              if ([k isEqualToString: @"definitions"])
                {
                  _prefix = nil;
                }
              else
                {
                  _prefix = [[k substringToIndex:
                    [k rangeOfString: @":"].location] retain];
                }
              d = [tree attributes];
              e = [d keyEnumerator];
              while ((k = [e nextObject]) != nil)
                {
                  if ([k isEqualToString: @"name"] == YES)
                    {
                      [_name release];
                      _name = [[d objectForKey: k] copy];
                    }
                  else if ([k isEqualToString: @"targetNamespace"] == YES)
                    {
                      [_targetNamespace release];
                      _targetNamespace = [[d objectForKey: k] copy];
                    }
                  else if ([k hasPrefix: @"xmlns:"] == YES)
                    {
                      [_namespaces setObject: [d objectForKey: k]
                                      forKey: [k substringFromIndex: 6]];
                    }
                  else if ([k isEqualToString: @"xmlns"] == YES)
                    {
                      [_namespaces setObject: [d objectForKey: k]
                                      forKey: @""];
                    }
                  else
                    {
                      NSLog(@"Unexpected attribute: %@", k);
                    }
                }

	      /* Now parse the namespaces and their prefixes so we have
	       * those mappings available.
	       */
              d = [tree namespaces];
              e = [d keyEnumerator];
              while ((k = [e nextObject]) != nil)
                {
                  [_namespaces setObject: [d objectForKey: k] forKey: k];
                }

              /* Make sure that we have a default namespace ... that of
               * the WSDL schema.
               */
              if ([_namespaces objectForKey: @""] == nil)
                {
                  [_namespaces setObject: @"http://schemas.xmlsoap.org/wsdl/"
                                  forKey: @""];
                }
            }
          _elem = [tree firstChild];

          /* Handle imports.
           */
          while ([(name = [_elem name]) isEqualToString: @"import"])
            {
              NSLog(@"Argh ... 'import' not handled");
              _elem = [_elem sibling];
            }

          /* Extract documentation.
           */
          if ([(name = [_elem name]) isEqualToString: @"documentation"])
            {
              _documentation = [_elem retain];
              _elem = [_elem sibling];
              [_documentation remove];
            }

          /* Handle types.
           */
          if ([(name = [_elem name]) isEqualToString: @"types"])
            {
              GWSElement        *next = [_elem sibling];

              _elem = [_elem firstChild];
              if ([(name = [_elem name]) isEqualToString: @"documentation"])
                {
                  _elem = [_elem sibling];
                }

              /* FIXME ... need to parse schema info etc for types.
               */
              _elem = next;
            }

          while ([(name = [_elem name]) isEqualToString: @"message"])
            {
              GWSMessage   *message;

              name = [[_elem attributes] objectForKey: @"name"];
              message = [[GWSMessage alloc] _initWithName: name
                                                 document: self];
              if (message != nil)
                {
                  [_messages setObject: message
                                forKey: [message name]];
                  [message release];
                }
              _elem = [_elem sibling];
            }

          while ([(name = [_elem name]) isEqualToString: @"portType"])
            {
              GWSPortType   *portType;

              name = [[_elem attributes] objectForKey: @"name"];
              portType = [[GWSPortType alloc] _initWithName: name
                                                   document: self];
              if (portType != nil)
                {
                  [_portTypes setObject: portType
                                 forKey: [portType name]];
                  [portType release];
                }
              _elem = [_elem sibling];
            }

          while ([(name = [_elem name]) isEqualToString: @"binding"])
            {
              GWSBinding   *binding;

              name = [[_elem attributes] objectForKey: @"name"];
              binding = [[GWSBinding alloc] _initWithName: name
                                                 document: self];
              if (binding != nil)
                {
                  [_bindings setObject: binding
                                forKey: [binding name]];
                  [binding release];
                }
              _elem = [_elem sibling];
            }

          while ([(name = [_elem name]) isEqualToString: @"service"])
            {
              GWSService   *service;

              name = [[_elem attributes] objectForKey: @"name"];
              service = [[GWSService alloc] _initWithName: name
                                                 document: self];
              if (service != nil)
                {
                  [_services setObject: service
                                forKey: [service name]];
                  [service release];
                }
              _elem = [_elem sibling];
            }

          while (_elem != nil)
            {
	      NSString	*problem;

	      problem = [self _validate: _elem in: self];
	      if (problem != nil)
		{
		  [NSException raise: NSInvalidArgumentException
			      format: @"%@", problem];
		}
	      [_extensibility addObject: _elem];
              _elem = [_elem sibling];
              [[_extensibility lastObject] remove];
            }
        }
      NS_HANDLER
        {
          _elem = nil;
          NSLog(@"Problem in -initWithTree: ... %@", localException);
          [self release];
          self = nil;
        }
      NS_ENDHANDLER
    }
  return self;
}

- (NSArray*) messageNames
{
  NSArray       *result;

  [_lock lock];
  result = [_messages allKeys];
  [_lock unlock];
  return result;
}

- (GWSMessage*) messageWithName: (NSString*)name
                         create: (BOOL)shouldCreate
{
  GWSMessage    *message;

  name = [self _local: name];
  [_lock lock];
  message = [_messages objectForKey: name];
  if (message == nil && shouldCreate == YES)
    {
      message = [[GWSMessage alloc] _initWithName: name document: self];
      [_messages setObject: message forKey: name];
    }
  else
    {
      [message retain];
    }
  [_lock unlock];
  return [message autorelease];
}

- (NSString*) name
{
  return _name;
}

- (NSString*) namespaceForPrefix: (NSString*)prefix
{
  if (prefix == nil) prefix = @"";
  return [_namespaces objectForKey: prefix];
}

- (NSString*) namespacePrefix
{
  return _prefix;
}

- (NSArray*) portTypeNames
{
  NSArray       *result;

  [_lock lock];
  result = [_portTypes allKeys];
  [_lock unlock];
  return result;
}

- (GWSPortType*) portTypeWithName: (NSString*)name
                           create: (BOOL)shouldCreate
{
  GWSPortType   *portType;

  name = [self _local: name];
  [_lock lock];
  portType = [_portTypes objectForKey: name];
  if (portType == nil && shouldCreate == YES)
    {
      portType = [[GWSPortType alloc] _initWithName: name document: self];
      [_portTypes setObject: portType forKey: name];
    }
  else
    {
      [portType retain];
    }
  [_lock unlock];
  return [portType autorelease];
}

- (NSString*) prefixForNamespace: (NSString*)url
{
  NSEnumerator	*e = [_namespaces keyEnumerator];
  NSString	*k;

  while ((k = [e nextObject]) != nil)
    {
      if ([[_namespaces objectForKey: k] isEqual: url])
	{
	  break;
	}
    }
  return k;
}

- (void) removeBindingNamed: (NSString*)name
{
  [_lock lock];
  [[_bindings objectForKey: name] _remove];
  [_bindings removeObjectForKey: name];
  [_lock unlock];
}

- (void) removeMessageNamed: (NSString*)name
{
  [_lock lock];
  [[_bindings objectForKey: name] _remove];
  [_messages removeObjectForKey: name];
  [_lock unlock];
}

- (void) removePortTypeNamed: (NSString*)name
{
  [_lock lock];
  [[_bindings objectForKey: name] _remove];
  [_portTypes removeObjectForKey: name];
  [_lock unlock];
}

- (void) removeServiceNamed: (NSString*)name
{
  [_lock lock];
  [[_bindings objectForKey: name] _remove];
  [_services removeObjectForKey: name];
  [_lock unlock];
}

- (void) removeTypeNamed: (NSString*)name
{
  [_lock lock];
  [[_bindings objectForKey: name] _remove];
  [_types removeObjectForKey: name];
  [_lock unlock];
}

- (NSString*) qualify: (NSString*)name
{
  if (_prefix != nil)
    {
      return [NSString stringWithFormat: @"%@:%@", _prefix, name];
    }
  return name;
}

- (NSArray*) serviceNames
{
  NSArray       *result;

  [_lock lock];
  result = [_services allKeys];
  [_lock unlock];
  return result;
}

- (GWSService*) serviceWithName: (NSString*)name
                         create: (BOOL)shouldCreate
{
  GWSService    *service;

  name = [self _local: name];
  [_lock lock];
  service = [_services objectForKey: name];
  if (service == nil && shouldCreate == YES)
    {
      service = [[GWSService alloc] _initWithName: name document: self];
      [_services setObject: service forKey: name];
    }
  else
    {
      [service retain];
    }
  [_lock unlock];
  return [service autorelease];
}

- (void) setDocumentation: (GWSElement*)documentation
{
  if (_documentation != documentation)
    {
      id        o = _documentation;

      _documentation = [documentation retain];
      [o release];
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
      problem = [self _validate: element in: self];
      if (problem != nil)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"%@", problem];
	}
    }

  m = [extensibility mutableCopy];
  [_lock lock];
  [_extensibility release];
  _extensibility = m;
  [_lock unlock];
}

- (void) setName: (NSString*)name
{
  if (_name != name)
    {
      id        o = _name;

      _name = [name copy];
      [o release];
    }
}

- (void) setTargetNamespace: (NSString*)uri
{
  if (_targetNamespace != uri)
    {
      id        o = _targetNamespace;

      _targetNamespace = [uri copy];
      [o release];
    }
}

- (NSString*) targetNamespace
{
  return _targetNamespace;
}

- (GWSElement*) tree
{
  GWSElement    *tree;
  GWSElement	*elem;
  NSEnumerator  *enumerator;
  NSString      *key;
  NSString      *uri;

  key = @"";
  uri = [_namespaces objectForKey: key];
  if (uri == nil)
    {
      uri = @"http://schemas.xmlsoap.org/wsdl/";
    }
  tree = [[GWSElement alloc] initWithName: @"definitions"
                                namespace: uri
                                qualified: [self qualify: @"definitions"]
                               attributes: nil];
  [tree autorelease];

  if (_name != nil)
    {
      [tree setAttribute: _name forKey: @"name"];
    }

  if (_targetNamespace != nil)
    {
      [tree setAttribute: _targetNamespace forKey: @"targetNamespace"];
    }

  enumerator = [_namespaces keyEnumerator];
  while ((key = [enumerator nextObject]) != nil)
    {
      if ([key length] > 0)
        {
          [tree setNamespace: [_namespaces objectForKey: key] forPrefix: key];
        }
    }

  // FIXME ... imports

  if (_documentation != nil)
    {
      [tree addChild: _documentation];
    }

  if ([_types count] > 0)
    {
      elem = [[GWSElement alloc] initWithName: @"types"
                                    namespace: nil
                                    qualified: @"types"
                                   attributes: nil];
      [tree addChild: elem];
      [elem release];

      enumerator = [_types keyEnumerator];
      while ((key = [enumerator nextObject]) != nil)
        {
          [elem addChild: [[_types objectForKey: key] tree]]; 
        }
    }

  enumerator = [_messages keyEnumerator];
  while ((key = [enumerator nextObject]) != nil)
    {
      [tree addChild: [[_messages objectForKey: key] tree]]; 
    }

  enumerator = [_portTypes keyEnumerator];
  while ((key = [enumerator nextObject]) != nil)
    {
      [tree addChild: [[_portTypes objectForKey: key] tree]]; 
    }

  enumerator = [_bindings keyEnumerator];
  while ((key = [enumerator nextObject]) != nil)
    {
      [tree addChild: [[_bindings objectForKey: key] tree]];
    }

  enumerator = [_services keyEnumerator];
  while ((key = [enumerator nextObject]) != nil)
    {
      [tree addChild: [[_services objectForKey: key] tree]];
    }

  enumerator = [_extensibility objectEnumerator];
  while ((elem = [enumerator nextObject]) != nil)
    {
      [tree addChild: elem];
    }

  return tree;
}

- (NSArray*) typeNames
{
  NSArray       *result;

  [_lock lock];
  result = [_types allKeys];
  [_lock unlock];
  return result;
}

- (GWSType*) typeWithName: (NSString*)name
                   create: (BOOL)shouldCreate
{
  GWSType       *type;

  name = [self _local: name];
  [_lock lock];
  type = [_types objectForKey: name];
  if (type == nil && shouldCreate == YES)
    {
      type = [[GWSType alloc] _initWithName: name document: self];
      [_types setObject: type forKey: name];
    }
  else
    {
      [type retain];
    }
  [_lock unlock];
  return [type autorelease];
}

- (BOOL) writeToFile: (NSString*)file atomically: (BOOL)atomically
{
  return [[self data] writeToFile: file atomically: atomically];
}

- (BOOL) writeToURL: (NSURL*)anURL atomically: (BOOL)atomically
{
  return [[self data] writeToURL: anURL atomically: atomically];
}

@end


