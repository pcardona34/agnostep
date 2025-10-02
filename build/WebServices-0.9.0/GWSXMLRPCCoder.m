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

@interface      GWSXMLRPCCoder (Private)

- (void) _appendObject: (id)o;
- (void) _checkElement: (GWSElement*)elem;

@end


@implementation	GWSXMLRPCCoder

static NSCharacterSet   *ws;
static id               boolN;
static id               boolY;

+ (void) initialize
{
  ws = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
  boolN = [[NSNumber numberWithBool: NO] retain];
  boolY = [[NSNumber numberWithBool: YES] retain];
}

- (NSData*) buildFaultWithCode: (GWSRPCFaultCode)code andText: (NSString*)text
{
  NSDictionary  *params;

  params = [NSDictionary dictionaryWithObjectsAndKeys:
    text, @"faultString",
    [NSNumber numberWithInt: code], @"faultCode",
    nil];
  return [self buildFaultWithParameters: params order: nil];
}

- (NSData*) buildRequest: (NSString*)method 
              parameters: (NSDictionary*)parameters
                   order: (NSArray*)order
{
  GWSElement		*container;
  NSMutableString       *ms;

  [self reset];
  container = [GWSElement new];

  ms = [self mutableString];
  [ms setString: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];

  if ([self fault])
    {
      [ms appendString: @"<methodResponse>"];
      [self indent];
      [self nl];
      [ms appendString: @"<fault>"];
      [self indent];
      [self nl];
      [ms appendString: @"<value>"];
      [self _appendObject: parameters];
      [self unindent];
      [self nl];
      [ms appendString: @"</value>"];
      [self unindent];
      [self nl];
      [ms appendString: @"</fault>"];
      [self unindent];
      [self nl];
      [ms appendString: @"</methodResponse>"];
    }
  else
    {
      unsigned	        c;
      unsigned	        i;
      id		o;

      o = [parameters objectForKey: GWSOrderKey];
      if (nil != o)
	{
	  if (order != nil && [order isEqual: o] == NO)
	    {
	      NSLog(@"Parameter order specified both in the 'order' argument and using GWSOrderKey.  Using the value from GWSOrderkey.");
	    }
	  order = o;
	}
      o = [parameters objectForKey: GWSParametersKey];
      if (nil != o)
	{
	  parameters = o;
	}

      if ([order count] == 0)
	{
	  order = [parameters allKeys];
	}
      c = [order count];
      if ([method length] == 0)
	{
	  [container release];
	  return nil;
	}
      else
	{
	  static NSCharacterSet	*illegal = nil;
	  NSRange		r;

	  if (illegal == nil)
	    {
	      NSMutableCharacterSet	*tmp = [NSMutableCharacterSet new];

	      [tmp addCharactersInRange: NSMakeRange('0', 10)];
	      [tmp addCharactersInRange: NSMakeRange('a', 26)];
	      [tmp addCharactersInRange: NSMakeRange('A', 26)];
	      [tmp addCharactersInString: @"_.:/"];
	      [tmp invert];
	      illegal = [tmp copy];
	      [tmp release];
	    }
	  r = [method rangeOfCharacterFromSet: illegal];
	  if (r.length > 0)
	    {
	      [container release];
	      return nil;	// Bad method name.
	    }
	}
      [ms appendString: @"<methodCall>"];
      [self indent];
      [self nl];
      [ms appendString: @"<methodName>"];
      [ms appendString: [self escapeXMLFrom: method]];
      [ms appendString: @"</methodName>"];
      [self nl];
      if (c > 0)
	{
	  [ms appendString: @"<params>"];
	  [self indent];
	  for (i = 0; i < c; i++)
	    {
	      NSString      *k = [order objectAtIndex: i];
	      id            v = [parameters objectForKey: k];
	      GWSElement    *e;

	      if (v != nil)
		{
		  [self nl];
		  [ms appendString: @"<param>"];
		  [self indent];
		  [self nl];
		  [ms appendString: @"<value>"];
		  [self indent];
		  [[self delegate] encodeWithCoder: self
					      item: v
					     named: k
					        in: container];
		  if ((e = [container firstChild]) == nil)
		    {
		      [self _appendObject: v];
		    }
		  else
		    {
		      [e encodeWith: self];
		      [e remove];
		    }
		  [self unindent];
		  [self nl];
		  [ms appendString: @"</value>"];
		  [self unindent];
		  [self nl];
		  [ms appendString: @"</param>"];
		}
	    }
	  [self unindent];
	  [self nl];
	  [ms appendString: @"</params>"];
	  [self unindent];
	  [self nl];
	}
      [ms appendString: @"</methodCall>"];
    }
  [container remove];
  [container release];
  return [ms dataUsingEncoding: NSUTF8StringEncoding];
}

- (NSData*) buildResponse: (NSString*)method
               parameters: (NSDictionary*)parameters
                    order: (NSArray*)order;
{
  GWSElement		*container;
  NSMutableString       *ms;
  
  [self reset];

  container = [GWSElement new];

  ms = [self mutableString];
  [ms setString: @""];

  [ms appendString: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
  [ms appendString: @"<methodResponse>"];
  [self indent];
  [self nl];

  /* Support building a fault as a response as well as doing it as a request.
   */
  if ([self fault])
    {
      [ms appendString: @"<fault>"];
      [self indent];
      [self nl];
      [ms appendString: @"<value>"];
      [self _appendObject: parameters];
      [self unindent];
      [self nl];
      [ms appendString: @"</value>"];
      [self unindent];
      [self nl];
      [ms appendString: @"</fault>"];
    }
  else
    {
      unsigned	        c;
      unsigned	        i;
      id		o;

      o = [parameters objectForKey: GWSOrderKey];
      if (o != nil)
	{
	  if (order != nil)
	    {
	      NSLog(@"Parameter order specified both in the 'order' argument and using GWSOrderKey");
	    }
	  order = o;
	}
      o = [parameters objectForKey: GWSParametersKey];
      if (nil != o)
	{
	  parameters = o;
	}

      if ([order count] == 0)
	{
	  order = [parameters allKeys];
	}
      c = [order count];

      [ms appendString: @"<params>"];
      [self indent];
      for (i = 0; i < c; i++)
	{
	  NSString  *k = [order objectAtIndex: i];
	  id        v = [parameters objectForKey: k];

	  if (v != nil)
	    {
	      GWSElement    *e;

	      [self nl];
	      [ms appendString: @"<param>"];
	      [self indent];
	      [self nl];
	      [ms appendString: @"<value>"];
	      [self indent];
	      [[self delegate] encodeWithCoder: self
					  item: v
					 named: @"Result"
					    in: container];
	      if ((e = [container firstChild]) == nil)
		{
		  [self _appendObject: v];
		}
	      else
		{
		  [e encodeWith: self];
		  [e remove];
		}
	      [self unindent];
	      [ms appendString: @"</value>"];
	      [self unindent];
	      [self nl];
	      [ms appendString: @"</param>"];
	    }
	}
      [self unindent];
      [self nl];
      [ms appendString: @"</params>"];
    }
  [self unindent];
  [self nl];
  [ms appendString: @"</methodResponse>"];
  [container remove];
  [container release];
  return [ms dataUsingEncoding: NSUTF8StringEncoding];
}

- (NSString*) encodeDateTimeFrom: (NSDate*)source
{
  NSString	*s;

  s = [source descriptionWithCalendarFormat: @"%Y%m%dT%H:%M:%S"
                                   timeZone: [self timeZone]
                                     locale: nil];
  return s;
}

- (id) _newParsedValue: (GWSElement*)elem
{
  unsigned      c = [elem countChildren];
  NSString      *name = [elem name];
  NSString      *s;

  if ([name isEqualToString: @"value"] == NO)
    {
      [NSException raise: NSGenericException
                  format: @"expected 'value' but got '%@'", name];
    }
  if (_strictParsing) [self _checkElement: elem];
  if (c == 0)
    {
      s = [[elem content] copy];
      return s;
    }
  if (c != 1)
    {
      [NSException raise: NSGenericException
                  format: @"value bad element count"];
    }
  elem = [elem firstChild];
  name = [elem name];
  if (_strictParsing) [self _checkElement: elem];

  if ([name isEqualToString: @"string"])
    {
      if (_strictParsing && nil != [elem firstChild])
        {
          [NSException raise: NSGenericException
                      format: @"xml element inside %@", name];
        }
      s = [[elem content] copy];
      return s;
    }

  if ([name isEqualToString: @"i4"]
    || [name isEqualToString: @"int"])
    {
      if (_strictParsing && nil != [elem firstChild])
        {
          [NSException raise: NSGenericException
                      format: @"xml element inside %@", name];
        }
      s = [elem content];
      if ([s length] == 0)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"missing %@ value", name];
	}
      return [[NSNumber alloc] initWithInt: [s intValue]];
    }

  if ([name isEqualToString: @"boolean"])
    {
      char	c;

      if (_strictParsing && nil != [elem firstChild])
        {
          [NSException raise: NSGenericException
                      format: @"xml element inside %@", name];
        }
      s = [elem content];
      if ([s length] == 0)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"missing %@ value", name];
	}
      c = [s intValue];
      if (0 == c)
        {
          return boolN;
        }
      return boolY;
    }

  if ([name isEqualToString: @"double"])
    {
      if (_strictParsing && nil != [elem firstChild])
        {
          [NSException raise: NSGenericException
                      format: @"xml element inside %@", name];
        }
      s = [elem content];
      if ([s length] == 0)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"missing %@ value", name];
	}
      return [[NSNumber alloc] initWithDouble: [s doubleValue]];
    }

  if ([name isEqualToString: @"base64"])
    {
      if (_strictParsing && nil != [elem firstChild])
        {
          [NSException raise: NSGenericException
                      format: @"xml element inside %@", name];
        }
      s = [elem content];
      if ([s length] == 0)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"missing %@ value", name];
	}
      return [[self decodeBase64From: s] retain];
    }

  if ([name isEqualToString: @"dateTime.iso8601"])
    {
      const char	*u;
      int		year;
      int		month;
      int		day;
      int		hour;
      int		minute;
      int		second;

      if (_strictParsing && nil != [elem firstChild])
        {
          [NSException raise: NSGenericException
                      format: @"xml element inside %@", name];
        }
      s = [elem content];
      if ([s length] == 0)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"missing %@ value", name];
	}
      u = [s UTF8String];
      if (sscanf(u, "%04d%02d%02dT%02d:%02d:%02d",
        &year, &month, &day, &hour, &minute, &second) != 6)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"bad date/time format '%@'", s];
	}
      return [[NSCalendarDate alloc] initWithYear: year
                                            month: month
                                              day: day
                                             hour: hour
                                           minute: minute
                                           second: second 
                                         timeZone: [self timeZone]]; 
    }

  if ([name isEqualToString: @"struct"])
    {
      NSMutableDictionary       *m;

      if (_strictParsing && [[[elem content] stringByTrimmingSpaces] length])
        {
          [NSException raise: NSGenericException
                      format: @"character content inside %@", name];
        }
      c = [elem countChildren];
      m = [NSMutableDictionary dictionaryWithCapacity: c];
      elem = [elem firstChild];
      while (elem != nil)
        {
          GWSElement    *e;
	  id		o;

          if ([[elem name] isEqualToString: @"member"] == NO)
            {
              [NSException raise: NSGenericException
                          format: @"struct with bad elment '%@'", [elem name]];
            }
          if ([elem countChildren] != 2)
            {
              [NSException raise: NSGenericException
                          format: @"member with wrong number of elements"];
            }
          if (_strictParsing) [self _checkElement: elem];

          e = [elem firstChild];
          if ([[e name] isEqualToString: @"name"] == NO)
            {
              [NSException raise: NSGenericException
                          format: @"member first element is '%@'", [e name]];
            }
          name = [e content];
          if ([name length] == 0)
            {
              [NSException raise: NSGenericException
                          format: @"member name is empty"];
            }
          if (_strictParsing) [self _checkElement: e];

          e = [e sibling];
          o = [self _newParsedValue: e];
          [m setObject: o forKey: name];
	  [o release];
          elem = [elem sibling];
        }
      return [m retain];
    }

  if ([name isEqualToString: @"array"])
    {
      NSMutableArray    *m;

      if (_strictParsing && [[[elem content] stringByTrimmingSpaces] length])
        {
          [NSException raise: NSGenericException
                      format: @"character content inside %@", name];
        }
      c = [elem countChildren];
      if (c != 1)
        {
	  [NSException raise: NSGenericException
		      format: @"array with bad number of elements"];
        }
      elem = [elem firstChild];
      if ([[elem name] isEqualToString: @"data"] == NO)
        {
	  [NSException raise: NSGenericException
		      format: @"array without 'data' element"];
        }
      if (_strictParsing) [self _checkElement: elem];
      c = [elem countChildren];
      m = [NSMutableArray arrayWithCapacity: c];
      elem = [elem firstChild];
      while (elem != nil)
        {
	  id	o = [self _newParsedValue: elem];

          [m addObject: o];
	  [o release];
          elem = [elem sibling];
        }
      return [m retain];
    }

  [NSException raise: NSGenericException
              format: @"Unknown element '%@'", name];
  return nil;
}

- (NSMutableDictionary*) parseMessage: (NSData*)data
{
  NSAutoreleasePool     *pool;
  NSMutableDictionary   *result;
  NSMutableDictionary   *params;
  NSMutableArray        *order;
  GWSElement            *tree;
  GWSElement            *elem;
  NSString              *name;

  result = [NSMutableDictionary dictionaryWithCapacity: 3];

  [self reset];
  pool = [NSAutoreleasePool new];
  NS_DURING
    {
      tree = [self parseXML: data];
      if (_strictParsing) [self _checkElement: tree];
      name = [tree name];
      if ([name isEqualToString: @"methodCall"] == YES)
        {
          if ([tree countChildren] > 2)
            {
              [NSException raise: NSGenericException
                          format: @"too many elements in methodCall"];
            }
          elem = [tree firstChild]; 
          if ([[elem name] isEqualToString: @"methodName"] == NO)
            {
              [NSException raise: NSGenericException
                          format: @"methodName missing in methodCall"];
            }
          if (_strictParsing) [self _checkElement: elem];
          [result setObject: [elem content] forKey: GWSMethodKey];
          elem = [elem sibling];
          if (elem != nil)
            {
              unsigned  c = [elem countChildren];
              unsigned  i;
              NSArray   *a = [elem children];

              if ([[elem name] isEqualToString: @"params"] == NO)
                {
                  [NSException raise: NSGenericException
		    format: @"found %@ when expecting params in methodCall",
		    [elem name]];
                }
              if (_strictParsing) [self _checkElement: elem];

              params = [NSMutableDictionary dictionaryWithCapacity: c];
              order = [NSMutableArray arrayWithCapacity: c];

              for (i = 0; i < c; i++)
                {
                  id            o;

                  elem = [a objectAtIndex: i];
                  if ([elem countChildren] != 1)
                    {
                      [NSException raise: NSGenericException
                                  format: @"bad element count in param %u", i];
                    }
                  if ([[elem name] isEqualToString: @"param"] == NO)
                    {
                      [NSException raise: NSGenericException
                                  format: @"bad element at param %u", i];
                    }
                  if (_strictParsing) [self _checkElement: elem];

                  name = [NSString stringWithFormat: @"Arg%u", i];
                  o = [[self delegate] decodeWithCoder: self
                                                  item: [elem firstChild]
                                                 named: name];
                  if (o == nil)
                    {
                      o = [self _newParsedValue: [elem firstChild]];
                      [params setObject: o forKey: name];
		      [o release];
                    }
		  else
		    {
                      [params setObject: o forKey: name];
		    }
                  [order addObject: name];
                }
              [result setObject: params forKey: GWSParametersKey];
              [result setObject: order forKey: GWSOrderKey];
            }
        }
      else if ([name isEqualToString: @"methodResponse"] == YES)
        {
          if ([tree countChildren] > 1)
            {
              [NSException raise: NSGenericException
                          format: @"too many elements in methodResponse"];
            }
          elem = [tree firstChild]; 
          name = [elem name];
          if ([name isEqualToString: @"params"] == YES)
            {
              id                o;

              if (_strictParsing) [self _checkElement: elem];
              if ([elem countChildren] != 1)
                {
                  [NSException raise: NSGenericException
                              format: @"bad element count in params"];
                }
              elem = [elem firstChild]; 
              name = [elem name];
              if ([name isEqualToString: @"param"] == NO)
                {
                  [NSException raise: NSGenericException
                              format: @"bad element in params"];
                }
              if ([elem countChildren] != 1)
                {
                  [NSException raise: NSGenericException
                              format: @"bad element count in param"];
                }
              if (_strictParsing) [self _checkElement: elem];

              o = [[self delegate] decodeWithCoder: self
                                              item: [elem firstChild]
                                             named: @"Result"];

              params = [NSMutableDictionary dictionaryWithCapacity: 1];
              if (o == nil)
                {
                  o = [self _newParsedValue: [elem firstChild]];
		  [params setObject: o forKey: @"Result"];
		  [o release];
                }
	      else
		{
		  [params setObject: o forKey: @"Result"];
		}
              [result setObject: params forKey: GWSParametersKey];

              order = [NSMutableArray arrayWithCapacity: 1];
              [order addObject: @"Result"];
              [result setObject: order forKey: GWSOrderKey];
            }
          else if ([name isEqualToString: @"fault"] == YES)
            {
	      id	o;

              if (_strictParsing) [self _checkElement: elem];
	      o = [self _newParsedValue: [elem firstChild]];
              [result setObject: o forKey: GWSFaultKey];
	      [o release];
            }
          else if (elem != nil)
            {
              [NSException raise: NSGenericException
                          format: @"bad element in methodResponse"];
            }
        }
      else
        {
          [NSException raise: NSGenericException
                      format: @"Not an XML-RPC document"];
        }
    }
  NS_HANDLER
    {
      [result setObject: [localException reason] forKey: GWSErrorKey];
    }
  NS_ENDHANDLER

  [self reset];
  [pool release];

  return result;
}

- (void) setStrictParsing: (BOOL)isStrict
{
  _strictParsing = (isStrict ? YES : NO);
}

- (BOOL) strictParsing
{
  return _strictParsing;
}
@end

@implementation GWSXMLRPCCoder (Private)

- (void) _appendObject: (id)o
{
  NSMutableString       *ms = [self mutableString];

  if (o == nil)
    {
      return;
    }
  else if (YES == [o isKindOfClass: [NSString class]])
    {
      if (YES == [self compact])
        {
          [ms appendString: [self escapeXMLFrom: o]];
        }
      else
        {
          [ms appendString: @"<string>"];
          [ms appendString: [self escapeXMLFrom: o]];
          [ms appendString: @"</string>"];
        }
    }
  else if (o == boolN)
    {
      [ms appendString: @"<boolean>0</boolean>"];
    }
  else if (o == boolY)
    {
      [ms appendString: @"<boolean>1</boolean>"];
    }
  else if (YES == [o isKindOfClass: [NSNumber class]])
    {
      const char	*t = [o objCType];


      if (strchr("cCsSiIlLqQ", *t) != 0)
        {
          long	i = [(NSNumber*)o longValue];

          [ms appendFormat: @"<i4>%ld</i4>", i];
        }
      else
        {
          [ms appendFormat: @"<double>%f</double>", [(NSNumber*)o doubleValue]];
        }
    }
  else if (YES == [o isKindOfClass: [NSData class]])
    {
      [self nl];
      [ms appendString: @"<base64>"];
      [ms appendString: [self encodeBase64From: o]];
      [self nl];
      [ms appendString: @"</base64>"];
    }
  else if (YES == [o isKindOfClass: [NSDate class]])
    {
      [ms appendString: @"<dateTime.iso8601>"];
      [ms appendString: [self encodeDateTimeFrom: o]];
      [ms appendString: @"</dateTime.iso8601>"];
    }
  else if (YES == [o isKindOfClass: [NSArray class]])
    {
      unsigned 		i;
      unsigned		c = [o count];
      
      [self nl];
      [ms appendString: @"<array>"];
      [self indent];
      [self nl];
      [ms appendString: @"<data>"];
      [self indent];
      for (i = 0; i < c; i++)
        {
          [self nl];
          [ms appendString: @"<value>"];
          [self indent];
          [self _appendObject: [o objectAtIndex: i]];
          [self unindent];
          [self nl];
          [ms appendString: @"</value>"];
        }
      [self unindent];
      [self nl];
      [ms appendString: @"</data>"];
      [self unindent];
      [self nl];
      [ms appendString: @"</array>"];
    }
  else if (YES == [o isKindOfClass: [NSDictionary class]])
    {
      NSEnumerator	*kEnum;
      NSString	        *key;

      kEnum = [[o objectForKey: GWSOrderKey] objectEnumerator];
      if (kEnum == nil)
        {
          kEnum = [o keyEnumerator];
        }
      [self nl];
      [ms appendString: @"<struct>"];
      [self indent];
      while ((key = [kEnum nextObject]))
        {
          [self nl];
          [ms appendString: @"<member>"];
          [self indent];
          [self nl];
          [ms appendString: @"<name>"];
          [ms appendString: [self escapeXMLFrom: [key description]]];
          [ms appendString: @"</name>"];
          [self nl];
          [ms appendString: @"<value>"];
          [self indent];
          [self _appendObject: [o objectForKey: key]];
          [self unindent];
          [ms appendString: @"</value>"];
          [self unindent];
          [self nl];
          [ms appendString: @"</member>"];
        }
      [self unindent];
      [self nl];
      [ms appendString: @"</struct>"];
    }
  else
    {
      [self _appendObject: [o description]];
    }
}

- (void) _checkElement: (GWSElement*)elem
{
  if (YES == _strictParsing)
    {
      NSString          *p = [elem prefix];
      NSDictionary      *a = [elem attributes];

      if ([p length] > 0)
        {
          [NSException raise: NSGenericException
                      format: @"unexpected prefix for '%@': %@",
            [[elem path] componentsJoinedByString: @"/"], p];
        }
      else if ([a count] > 0)
        {
          [NSException raise: NSGenericException
                      format: @"unexpected attributes for '%@': %@",
            [[elem path] componentsJoinedByString: @"/"], a];
        }
    }
}

@end


