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

NSString * const GWSSOAPBodyEncodingStyleKey
  = @"GWSSOAPBodyEncodingStyleKey";
NSString * const GWSSOAPBodyEncodingStyleDocument
  = @"GWSSOAPBodyEncodingStyleDocument";
NSString * const GWSSOAPBodyEncodingStyleRPC
  = @"GWSSOAPBodyEncodingStyleRPC";
NSString * const GWSSOAPBodyEncodingStyleWrapped
  = @"GWSSOAPBodyEncodingStyleWrapped";
NSString * const GWSSOAPNamespaceURIKey
  = @"GWSSOAPNamespaceURIKey";
NSString * const GWSSOAPNamespaceNameKey
  = @"GWSSOAPNamespaceNameKey";
NSString * const GWSSOAPMessageHeadersKey
  = @"GWSSOAPMessageHeadersKey";
NSString * const GWSSOAPArrayKey
  = @"GWSSOAPArrayKey";
NSString * const GWSSOAPTypeKey
  = @"GWSSOAPTypeKey";
NSString * const GWSSOAPUseEncoded
  = @"encoded";
NSString * const GWSSOAPUseKey
  = @"GWSSOAPUseKey";
NSString * const GWSSOAPUseLiteral
  = @"literal";
NSString * const GWSSOAPValueKey
  = @"GWSSOAPValueKey";


#if	!defined(GNUSTEP)
/* Older versions of MacOS-X don't have -boolValue as an NSString method,
 * so we add it here if we might be building with one of those versions.
 */
@implementation	NSString(GWSCoder)
- (BOOL) boolValue
{
  unsigned	length = [self length];

  if (length > 0)
    {
      unsigned	index;
      SEL	sel = @selector(characterAtIndex:);
      unichar	(*imp)() = (unichar (*)())[self methodForSelector: sel];

      for (index = 0; index < length; index++)
	{
	  unichar	c = (*imp)(self, sel, index);

	  if (c > 'y')
	    {
	      break;
	    }
          if (strchr("123456789yYtT", c) != 0)
	    {
	      return YES;
	    }
	  if (!isspace(c) && c != '0' && c != '-' && c != '+')
	    {
	      break;
	    }
	}
    }
  return NO;
}
@end
#endif


@interface      GWSSOAPCoder (Private)

- (void) _createElementFor: (id)o named: (NSString*)name in: (GWSElement*)ctct;
- (id) _simplify: (GWSElement*)elem;

@end

@implementation	GWSSOAPCoder

static NSCharacterSet	*illegal = nil;
static id               boolN;
static id               boolY;

+ (void) initialize
{
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
      boolN = [[NSNumber numberWithBool: NO] retain];
      boolY = [[NSNumber numberWithBool: YES] retain];
    }
}

/* Build a new header using the specified namespace prefix or the prefix
 * and namespace specified in o (if it is a dictionary specifying them).
 */
static GWSElement*
newHeader(NSString *prefix, id o)
{
  NSString	*hdrNamespace = nil;
  NSString	*hdrPrefix = prefix;
  NSString	*qualified;
  GWSElement	*header;

  /* Get namespace and prefix from dictionary if possible.
   */
  if ([o isKindOfClass: [NSDictionary class]])
    {
      hdrNamespace = [o objectForKey: GWSSOAPNamespaceURIKey];
      if ([o objectForKey: GWSSOAPNamespaceNameKey] != nil)
	{
	  hdrPrefix = [o objectForKey: GWSSOAPNamespaceNameKey];
	}
    }
  qualified = @"Header";
  if (hdrPrefix != nil)
    {
      qualified = [NSString stringWithFormat: @"%@:%@",
	hdrPrefix, qualified];
    }
  header = [[GWSElement alloc] initWithName: @"Header"
				  namespace: hdrPrefix
				  qualified: qualified
				 attributes: nil];
  if (hdrNamespace != nil && hdrPrefix == nil)
    {
      /* We have a namespace but no name ... make it the default
       * namespace for the body.
       */
      [header setNamespace: hdrNamespace forPrefix: @""];
    }
  return header;
}

- (NSData*) buildRequest: (NSString*)method 
              parameters: (NSDictionary*)parameters
                   order: (NSArray*)order
{
  NSAutoreleasePool	*pool;
  NSString              *nsName;
  NSString              *nsURI;
  GWSElement            *envelope;
  GWSElement            *header;
  GWSElement            *body;
  GWSElement            *container;
  NSString              *prefix;
  NSString              *qualified;
  NSString		*use;
  NSMutableString       *ms;
  id			o;
  unsigned	        c;
  unsigned	        i;

  [self reset];
  pool = [NSAutoreleasePool new];

  /* Determine the order of the parameters in the message body.
   */
  o = [parameters objectForKey: GWSOrderKey];
  if (o != nil)
    {
      if (order != nil && [order isEqual: o] == NO)
	{
	  NSLog(@"Parameter order specified both in the 'order' argument and using GWSOrderKey.  Using the value from GWSOrderKey.");
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
      NSEnumerator      *kEnum = [parameters keyEnumerator];
      NSString          *k;
      NSMutableArray    *a = [NSMutableArray array];

      while ((k = [kEnum nextObject]) != nil)
	{
	  if (NO == [k hasPrefix: @"GWSCoder"]
	    && NO == [k hasPrefix: @"GWSSOAP"])
	    {
	      [a addObject: k];
	    }
	}
      order = a;
    }

  /* Set the operation style if it's specified (otherwise we keep it
   * unchanged).
   */
  if ((o = [parameters objectForKey: GWSSOAPBodyEncodingStyleKey]) != nil)
    {
      [self setOperationStyle: o];
    }

  /* The method name is required for RPC operations ...
   * for document style operations the method is implicit in the URL
   * that the document is sent to.
   * We therefore check the method name only if we are doing an RPC.
   */
  if (_style == GWSSOAPBodyEncodingStyleRPC && [self fault] == NO)
    {
      if ([method length] == 0)
	{
	  return nil;
	}
      else
	{
	  NSRange	r;

	  r = [method rangeOfCharacterFromSet: illegal];
	  if (r.length > 0)
	    {
	      if ([self debug])
		{
		  NSLog(@"Illegal character in method name '%@'", method);
		}
	      return nil;	// Bad method name.
	    }
	}
    }

  envelope = [[[GWSElement alloc] initWithName: @"Envelope"
                                     namespace: nil
                                     qualified: @"soapenv:Envelope"
                                    attributes: nil] autorelease];
  [envelope setNamespace: @"http://schemas.xmlsoap.org/soap/envelope/"
               forPrefix: @"soapenv"];
  [envelope setNamespace: @"http://www.w3.org/2001/XMLSchema"
               forPrefix: @"xsd"];
  [envelope setNamespace: @"http://www.w3.org/2001/XMLSchema-instance"
               forPrefix: @"xsi"];

  /* Check the method namespace ... if we have a URI and a name then we
   * want to specify the namespace in the envelope.
   */
  nsName = [parameters objectForKey: GWSSOAPNamespaceNameKey];
  nsURI = [parameters objectForKey: GWSSOAPNamespaceURIKey];
  if (_style == GWSSOAPBodyEncodingStyleRPC && nsName != nil && nsURI != nil)
    {
      [envelope setNamespace: nsURI forPrefix: nsName];
    }

  if ([self delegate] != nil)
    {
      envelope = [[self delegate] coder: self willEncode: envelope];
    }
  if ([[envelope qualified] isEqualToString: @"Envelope"])
    {
      prefix = nil;
    }
  else
    {
      prefix = [envelope qualified];
      prefix = [prefix substringToIndex: [prefix rangeOfString: @":"].location];
    }

  /* Now look for a value listing the headers to be encoded.
   * If there is no value, we see if there are header values provided in
   * the parameters dictionary which are not part of the message body,
   * and build a headers dictionary from them.
   */
  o = [parameters objectForKey: GWSSOAPMessageHeadersKey];
  if (o == nil)
    {
      NSEnumerator     	*kEnum;
      NSString         	*k;

      kEnum = [parameters keyEnumerator];
      while ((k = [kEnum nextObject]) != nil)
	{
	  if (NO == [k hasPrefix: @"GWSCoder"]
	    && NO == [k hasPrefix: @"GWSSOAP"]
	    && NO == [order containsObject: k])
	    {
	      if (o == nil)
		{
		  o = [NSMutableDictionary new];
		}
	      [o setObject: [parameters objectForKey: k] forKey: k];
	    }
	}
      if (o != nil)
	{
	  NSMutableDictionary	*m = [parameters mutableCopy];

	  kEnum = [m keyEnumerator];
	  while ((k = [kEnum nextObject]) != nil)
	    {
	      [m removeObjectForKey: k];
	    }
	  [m setObject: o forKey: GWSSOAPMessageHeadersKey];
	  [o release];
	  parameters = [m autorelease];
	}
    }

  if (o == nil)
    {
      /* If we still have no headers, just don't create a Header element.
       */
      header = nil;
    }
  else
    {
      header = newHeader(prefix, o);
      [envelope addChild: header];
      [header release];
      if ([o isKindOfClass: [NSDictionary class]] && [o count] > 0)
	{
	  NSDictionary	*d = (NSDictionary*)o;
	  NSArray	*order = [o objectForKey: GWSOrderKey];

	  /* See if we have a key in the parameters to specify how the header
	   * should be encoded.
	   */
	  use = [d objectForKey: GWSSOAPUseKey];
	  if ([use isEqualToString: GWSSOAPUseLiteral] == YES)
	    {
	      [self setUseLiteral: YES];
	    }
	  else if ([use isEqualToString: GWSSOAPUseEncoded] == YES)
	    {
	      [self setUseLiteral: NO];
	    }

	  if ([order count] == 0)
	    {
	      NSEnumerator      *kEnum = [d keyEnumerator];
	      NSString          *k;
	      NSMutableArray    *a = [NSMutableArray array];

	      while ((k = [kEnum nextObject]) != nil)
		{
		  if (NO == [k hasPrefix: @"GWSCoder"]
		    && NO == [k hasPrefix: @"GWSSOAP"])
		    {
		      [a addObject: k];
		    }
		}
	      order = a;
	    }
          c = [order count];
	
	  /* The dictionary contains header elements by name.
	   */
	  for (i = 0; i < c; i++)
	    {
	      NSString          *k = [order objectAtIndex: i];
	      id                v = [d objectForKey: k];

	      if (v == nil)
		{
		  [NSException raise: NSInvalidArgumentException
			      format: @"Header '%@' missing", k];
		}
	      [self _createElementFor: v named: k in: header];
	    }
	}
    }

  /* Now we give the delegate a chance to entirely replace the header
   * (which may be nil) with an element of its own.
   */
  if ([[self delegate] respondsToSelector: @selector(coder:willEncode:)])
    {
      GWSElement        *elem;

      elem = [[self delegate] coder: self willEncode: header];
      if (elem != header)
        {
          [header remove];
	  if (elem != nil)
	    {
	      /* If we have the content of a header rather than a
	       * complete header, we put it inside a standard header.
	       */
	      if ([[elem name] isEqualToString: @"Header"] == NO)
		{
		  header = [newHeader(prefix, o) autorelease];
		  [header addChild: elem];
		}
	      else
		{
	          header = elem;
		}
              [envelope addChild: header];
	    }
        }
    }

  /* See if we have a key in the parameters to specify how the body
   * should be encoded.
   */
  use = [parameters objectForKey: GWSSOAPUseKey];
  if ([use isEqualToString: GWSSOAPUseLiteral] == YES)
    {
      [self setUseLiteral: YES];
    }
  else if ([use isEqualToString: GWSSOAPUseEncoded] == YES)
    {
      [self setUseLiteral: NO];
    }

  qualified = @"Body";
  if (prefix != nil)
    {
      qualified = [NSString stringWithFormat: @"%@:%@", prefix, qualified];
    }
  body = [[GWSElement alloc] initWithName: @"Body"
                                namespace: nil
                                qualified: qualified
                               attributes: nil];
  [envelope addChild: body];
  [body release];
  if ([self delegate] != nil)
    {
      GWSElement        *elem;

      elem = [[self delegate] coder: self willEncode: body];
      if (elem != body)
        {
          [body remove];
          body = elem;
          [envelope addChild: body];
        }
    }

  if ([self fault] == YES)
    {
      GWSElement	*fault;

      qualified = @"Fault";
      if (prefix != nil)
	{
	  qualified = [NSString stringWithFormat: @"%@:%@", prefix, qualified];
	}
      fault = [[GWSElement alloc] initWithName: @"Fault"
				     namespace: nil
				     qualified: qualified
				    attributes: nil];
      [body addChild: fault];
      [fault release];
      if ([self delegate] != nil)
	{
	  GWSElement        *elem;

	  elem = [[self delegate] coder: self willEncode: fault];
	  if (elem != fault)
	    {
	      [fault remove];
	      fault = elem;
	      [body addChild: fault];
	    }
	}

      c = [order count];
      for (i = 0; i < c; i++)
	{
	  NSString          *k = [order objectAtIndex: i];
	  id                v = [parameters objectForKey: k];

	  [self _createElementFor: v named: k in: fault];
	}
    }
  else
    {
      if (_style == GWSSOAPBodyEncodingStyleRPC)
	{
	  if (nil == nsName)
	    {
	      qualified = method;
	      if (YES == [qualified isEqualToString: method]
		&& [qualified rangeOfString: @":"].length > 0)
		{
		  method = [qualified substringFromIndex:
		    NSMaxRange([qualified rangeOfString: @":"])];
		}
	    }
	  else
	    {
	      qualified = [NSString stringWithFormat: @"%@:%@", nsName, method];
	    }
	  container = [[GWSElement alloc] initWithName: method
					     namespace: nsName
					     qualified: qualified
					    attributes: nil];
	  [body addChild: container];
	  [container release];
	  qualified = @"encodingStyle";
	  if (prefix != nil)
	    {
	      qualified = [NSString stringWithFormat: @"%@:%@",
		prefix, qualified];
	    }
	  [container setAttribute: @"http://schemas.xmlsoap.org/soap/encoding/"
			   forKey: qualified];

	  if (nsURI != nil && nsName == nil)
	    {
	      /* We have a namespace but no name ... make it the default
	       * namespace for the body.
	       */
	      [container setNamespace: nsURI forPrefix: @""];
	    }

	  if ([self delegate] != nil)
	    {
	      GWSElement        *elem;

	      elem = [[self delegate] coder: self willEncode: container];
	      if (elem != container)
		{
		  [container remove];
		  container = elem;
		  [body addChild: container];
		}
	    }
	}
      else if (_style == GWSSOAPBodyEncodingStyleWrapped)
	{
	  NSLog(@"FIXME GWSSOAPBodyEncodingStyleWrapped not implemented");
	  container = body;
	}
      else
	{
	  container = body;    // Direct encoding inside the body.
	}

      c = [order count];
      for (i = 0; i < c; i++)
	{
	  NSString          *k = [order objectAtIndex: i];
	  id                v = [parameters objectForKey: k];

	  if (v == nil)
	    {
	      [NSException raise: NSInvalidArgumentException
			  format: @"Value '%@' (order %u) missing", k, i];
	    }
	  [self _createElementFor: v named: k in: container];
	}
    }

  if ([[self delegate] respondsToSelector: @selector(coder:didEncode:)])
    {
      envelope = [[self delegate] coder: self didEncode: envelope];
    }

  ms = [self mutableString];
  [ms setString: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
  [envelope encodeWith: self];
  [pool release];
  return [ms dataUsingEncoding: NSUTF8StringEncoding];
}

- (NSData*) buildResponse: (NSString*)method
               parameters: (NSDictionary*)parameters
                    order: (NSArray*)order;
{
  /* For SOAP a request and a response look the same ... both are just
   * messages.
   */
  return [self buildRequest: method parameters: parameters order: order];
}

- (NSString*) encodeDateTimeFrom: (NSDate*)source
{
  NSTimeZone    *tz;
  int           t;

  if ([source isKindOfClass: [NSCalendarDate class]] == YES)
    {
      tz = [(NSCalendarDate*)source timeZone];
    }
  else
    {
      tz = [self timeZone];
    }
  source = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:
    [source timeIntervalSinceReferenceDate]];
  [(NSCalendarDate*)source setTimeZone: tz];
  t = [tz secondsFromGMTForDate: source];
  if (t != 0)
    {
      char      sign;
      NSString  *fmt;

      if (t < 0)
        {
          sign = '-';
          t = -t;
        }
      else
        {
          sign = '+';
        }
      t /= 60;
      fmt = [NSString stringWithFormat: @"%%Y-%%m-%%dT%%H:%%M:%%S%c%02d:%02d",
        sign, t / 60, t % 60];
      [(NSCalendarDate*)source setCalendarFormat: fmt];
    }
  else
    {
      [(NSCalendarDate*)source setCalendarFormat: @"%Y-%m-%dT%H:%M:%SZ"];
    }
  return [source description];
}

- (id) init
{
  if ((self = [super init]) != nil)
    {
      _style = GWSSOAPBodyEncodingStyleDocument;
    }
  return self;
}

- (NSString*) operationStyle
{
  return _style;
}

- (NSMutableDictionary*) parseMessage: (NSData*)data
{
  NSAutoreleasePool     *pool;
  NSMutableDictionary   *result;

  result = [NSMutableDictionary dictionaryWithCapacity: 3];
  pool = [NSAutoreleasePool new];

  NS_DURING
    {
      GWSCoder                  *parser;
      NSEnumerator              *enumerator;
      GWSElement                *elem;
      GWSElement                *envelope;
      GWSElement                *header;
      GWSElement                *body;
      NSMutableDictionary       *p;
      NSMutableArray            *o;
      NSArray                   *children;
      unsigned                  c;
      unsigned                  i;

      parser = [[GWSCoder new] autorelease];
      envelope = [parser parseXML: data];
      if (envelope == nil)
	{
          [NSException raise: NSInvalidArgumentException
                      format: @"Document is NOT parsable as XML"];
	}
      if ([self delegate] != nil)
        {
          envelope = [[self delegate] coder: self willDecode: envelope];
        }

      if ([[envelope name] isEqualToString: @"Envelope"] == NO)
        {
          [NSException raise: NSInvalidArgumentException
                      format: @"Document is not Envelope but '%@'",
                      [envelope name]];
        }

      enumerator = [[envelope children] objectEnumerator];
      elem = [enumerator nextObject];
      if (elem == nil)
        {
          [NSException raise: NSInvalidArgumentException
                      format: @"Envelope is empty"];
        }

      if ([[elem name] isEqualToString: @"Header"] == YES)
        {
          header = elem;
          elem = [enumerator nextObject];
          if ([self delegate] != nil)
            {
              [[self delegate] coder: self willDecode: header];
            }
        }
      if (elem == nil)
        {
          [NSException raise: NSInvalidArgumentException
                      format: @"Envelope contains no Body"];
        }
      else if ([[elem name] isEqualToString: @"Body"] == NO)
        {
          [NSException raise: NSInvalidArgumentException
                      format: @"Envelope contains '%@' where Body was expected",
                      [elem name]];
        }
      body = elem;
      if ([self delegate] != nil)
        {
          body = [[self delegate] coder: self willDecode: body];
        }

      children = [body children];
      c = [children count];
      elem = [children lastObject];
      if (c == 1 && [[elem name] isEqualToString: @"Fault"] == YES)
        {
          NSMutableDictionary   *f;
          GWSElement            *fault = elem;

          f = [[NSMutableDictionary alloc] initWithCapacity: 4];
          [result setObject: f forKey: GWSFaultKey];
          [f release];

          if ([self delegate] != nil)
            {
              fault = [[self delegate] coder: self willDecode: fault];
            }
          children = [fault children];
          c = [children count];
          i = 0;
          while (i < c)
            {
              NSString          *n;
              NSString          *v;

              elem = [children objectAtIndex: i++];
              n = [elem name];
              v = [elem content];
              if ([n isEqualToString: @"faultcode"] == YES
		&& [v length] > 0)
                {
                  [f setObject: v forKey: @"faultcode"];
                }
              else if ([n isEqualToString: @"faultstring"] == YES)
                {
                  /* faultstring must be present but may be empty. */
                  [f setObject: v forKey: @"faultstring"];
                }
              else if ([n isEqualToString: @"faultactor"] == YES
		&& [v length] > 0)
                {
                  [f setObject: v forKey: @"faultactor"];
                }
              else if ([n isEqualToString: @"detail"] == YES)
                {
                  if ([v length] > 0)
                    {
                      [f setObject: v forKey: @"detail"];
                    }
                  else
                    {
                      id        arg;

                      arg = [[self delegate] decodeWithCoder: self
                                                        item: elem
                                                       named: n];
                      if (arg == nil)
                        {
                          /*
                           * FIXME ... convert subelements to the sort of type
                           * we should really have.
                           */
                          arg = [self _simplify: elem];
                        }
                      [f setObject: arg forKey: @"detail"];
                    }
                }
            }
        }
      else
        {
	  NSCountedSet	*cs;

          /* If the body contains a single element with no content,
           * we assume it is a method and its children are the
           * parameters.  Otherwise we assume that the parameters
           * are found directly inside the body.
           */
          if (c == 1 && [[elem content] length] == 0)
            {
              if ([self delegate] != nil)
                {
                  elem = [[self delegate] coder: self willDecode: elem];
                }
              [result setObject: [elem name] forKey: GWSMethodKey];
              children = [elem children];
            }
          cs = [[NSCountedSet alloc] initWithCapacity: c];
          c = [children count];
          for (i = 0; i < c; i++)
	    {
	      [cs addObject: [[children objectAtIndex: i] name]];
	    }
          p = [[NSMutableDictionary alloc] initWithCapacity: [cs count]];
          [result setObject: p forKey: GWSParametersKey];
          [p release];
          o = [[NSMutableArray alloc] initWithCapacity: [cs count]];
          [result setObject: o forKey: GWSOrderKey];
          [o release];
          c = [children count];
          for (i = 0; i < c; i++)
            {
              id                arg;
              NSString          *n;
	      unsigned		rCount;

              elem = [children objectAtIndex: i];
              n = [elem name];
	      if ((rCount = [cs countForObject: n]) == 1)
		{
		  [o addObject: n];
		  arg = [[self delegate] decodeWithCoder: self
						    item: elem
						   named: n];
		  if (arg == nil)
		    {
		      arg = [self _simplify: elem];
		    }
		  [p setObject: arg forKey: n];
		}
	      else
		{
		  NSMutableArray	*ma;

		  ma = [p objectForKey: n];
		  if (ma == nil)
		    {
		      ma = [[NSMutableArray alloc] initWithCapacity: rCount];
		      [p setObject: ma forKey: n];
		      [ma release];
		      [o addObject: n];
		    }
		  arg = [[self delegate] decodeWithCoder: self
						    item: elem
						   named: n];
		  if (arg == nil)
		    {
		      arg = [self _simplify: elem];
		    }
		  [ma addObject: arg];
		}
            }
	  [cs release];
        }
    }
  NS_HANDLER
    {
      [result setObject: [localException description] forKey: GWSErrorKey];
    }
  NS_ENDHANDLER
  [pool release];

  return result;
}

- (void) setOperationStyle: (NSString*)style
{
  if (style == nil)
    {
      return;
    }
  if ([GWSSOAPBodyEncodingStyleDocument isEqualToString: style])
    {
      _style = GWSSOAPBodyEncodingStyleDocument;
    }
  else if ([GWSSOAPBodyEncodingStyleWrapped isEqualToString: style])
    {
      _style = GWSSOAPBodyEncodingStyleWrapped;
    }
  else if ([GWSSOAPBodyEncodingStyleRPC isEqualToString: style])
    {
      _style = GWSSOAPBodyEncodingStyleRPC;
    }
}

- (void) setUseLiteral: (BOOL)use
{
  _useLiteral = use;
}

- (BOOL) useLiteral
{
  return _useLiteral;
}

@end

@implementation GWSSOAPCoder (Private)

- (void) _createElementFor: (id)o
		     named: (NSString*)name
		        in: (GWSElement*)ctxt
{
  id		v;
  GWSElement    *e;
  NSString      *q;     // Qualified name
  NSString      *x;     // xsi:type if any
  NSString      *c;     // Content if any
  NSString	*a;	// Array item name
  NSString	*nsURI = nil;
  NSString	*nsName = nil;
  BOOL          array = NO;
  BOOL          dictionary = NO;

  if (o == nil)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"Value for '%@' (in %@) is nil", name, ctxt];
    }
  if ([[self delegate] encodeWithCoder: self item: o named: name in: ctxt])
    {
      return;
    }

  x = nil;
  c = nil;
  a = nil;
  q = name;

  /* If this is a dictionary describing a single value, rather than a
   * complex value, we can get the information we need now.
   */
  if (YES == [o isKindOfClass: [NSDictionary class]]
    && (v = [o objectForKey: GWSSOAPValueKey]) != nil)
    {
      /* If our value is a sequence of items, we can handle that now.
       */
      a = [o objectForKey: GWSSOAPArrayKey];
      if (a == nil && [v isKindOfClass: [NSArray class]] == YES)
	{
	  NSMutableDictionary	*m = [[o mutableCopy] autorelease];

	  v = [v objectEnumerator];
	  while ((o = [v nextObject]) != nil)
	    {
	      [m setObject: o forKey: GWSSOAPValueKey];
	      [self _createElementFor: m named: name in: ctxt];
	    }
	  return;
	}
      nsURI = [o objectForKey: GWSSOAPNamespaceURIKey];
      nsName = [o objectForKey: GWSSOAPNamespaceNameKey];
      x = [o objectForKey: GWSSOAPTypeKey];
      o = v;
    }

  if (YES == [o isKindOfClass: [NSString class]])
    {
      if (NO == _useLiteral && x == nil)
        {
          x = @"xsd:string";
        }
      c = o;
    }
  else if (o == boolN)
    {
      if (NO == _useLiteral && x == nil)
        {
          x = @"xsd:boolean";
        }
      c = @"false";
    }
  else if (o == boolY)
    {
      if (NO == _useLiteral && x == nil)
        {
          x = @"xsd:boolean";
        }
      c = @"true";
    }
  else if (YES == [o isKindOfClass: [NSNumber class]])
    {
      const char	*t = [o objCType];

      if (strchr("cCsSiIlLqQ", *t) != 0)
        {
          long	i = [(NSNumber*)o longValue];

          if (*t == 'l' || *t == 'L')
            {
              if (NO == _useLiteral && x == nil)
                {
                  x = @"xsd:long";
                }
              c = [NSString stringWithFormat: @"%ld", i];
            }
          else
            {
              if (NO == _useLiteral && x == nil)
                {
                  x = @"xsd:int";
                }
              c = [NSString stringWithFormat: @"%ld", i];
            }
        }
      else
        {
          if (NO == _useLiteral && x == nil)
            {
              x = @"xsd:double";
            }
          c = [NSString stringWithFormat: @"%f", [(NSNumber*)o doubleValue]];
        }
    }
  else if (YES == [o isKindOfClass: [NSData class]])
    {
      if (NO == _useLiteral && x == nil)
        {
          x = @"xsd:base64Binary";
        }
      c = [self encodeBase64From: o];
    }
  else if (YES == [o isKindOfClass: [NSDate class]])
    {
      if (NO == _useLiteral && x == nil)
        {
          x = @"xsd:timeInstant";
        }
      c = [self encodeDateTimeFrom: o];
    }
  else if (YES == [o isKindOfClass: [NSDictionary class]])
    {
      dictionary = YES;
    }
  else if (YES == [o isKindOfClass: [NSArray class]])
    {
      array = YES;
    }
  else
    {
      if (NO == _useLiteral && x == nil)
        {
          x = @"xsd:string";
        }
      c = [o description];
    }

  if (nsName != nil)
    {
      q = [NSString stringWithFormat: @"%@:%@", nsName, name];
    }
  if (nil == q)
    {
      q = name;
    }
  if (YES == [q isEqualToString: name] && [q rangeOfString: @":"].length > 0)
    {
      name = [q substringFromIndex: NSMaxRange([q rangeOfString: @":"])];
    }
  e = [[GWSElement alloc] initWithName: name
			     namespace: nil
			     qualified: q
			    attributes: nil];
  if (nsURI != nil)
    {
      [e setNamespace: nsURI forPrefix: @""];
    }
  if (x != nil)
    {
      [e setAttribute: x forKey: @"xsi:type"];
    }
  if (c != nil)
    {
      [e addContent: c];
    }
  [ctxt addChild: e];
  [e release];

  if (dictionary == YES)
    {
      NSArray   *order = [o objectForKey: GWSOrderKey];
      NSString  *namespace = [o objectForKey: GWSSOAPNamespaceURIKey];
      NSString  *prefix = [o objectForKey: GWSSOAPNamespaceNameKey];
      unsigned  count;
      unsigned  i;

      if (namespace != nil)
	{
	  /* We have been told to specify a new namespace ... so do it.
	   */
	  [e setNamespace: namespace forPrefix: prefix];
	}
      else if (prefix != nil)
	{
	  /* We have been given a namespace prefix for this element.
	   */
	  [e setPrefix: prefix];
	}

      if ([order count] == 0)
	{
	  order = [o allKeys];
	}
      count = [order count];
      for (i = 0; i < count; i++)
	{
	  NSString      *k = [order objectAtIndex: i];

	  if (NO == [k hasPrefix: @"GWSCoder"]
	    && NO == [k hasPrefix: @"GWSSOAP"])
	    {
	      id	v = [o objectForKey: k];

	      if (nil == v)
		{
		  [NSException raise: NSInvalidArgumentException
		    format: @"Parameter '%@' (order %u) missing", k, i];
		}
	      [self _createElementFor: v named: k in: e];
	    }
	}
    }
  else if (array == YES)
    {
      unsigned  count;
      unsigned  i;

      /* Use supplied item name if it is legal.
       */
      if ([a length] == 0 || [a rangeOfCharacterFromSet: illegal].length > 0)
	{
	  a = @"item";
	}

      /* For an array, we simply create a sequence of elements with the
       * same name for the items in the array.
       */
      count = [o count];
      for (i = 0; i < count; i++)
	{
	  id	v = [o objectAtIndex: i];

	  [self _createElementFor: v named: a in: e];
	}
    }
}

- (id) _simplify: (GWSElement*)elem
{
  NSArray       *a;
  unsigned      c;
  id            result;

  a = [elem children];
  c = [a count];
  if (c == 0)
    {
      NSString  *t;

      /* No child elements ... use the content of this element.
       */
      result = [elem content];
      t = [[elem attributes] objectForKey: @"xsi:type"];
      result = [self parseXSI: t string: result];
    }
  else
    {
      NSMutableArray            *names;
      NSMutableArray            *order;
      NSMutableArray            *values;
      NSCountedSet		*keys;
      unsigned                  i;

      keys = [[NSCountedSet alloc] initWithCapacity: c];
      names = [[NSMutableArray alloc] initWithCapacity: c];
      order = [[NSMutableArray alloc] initWithCapacity: c];
      values = [[NSMutableArray alloc] initWithCapacity: c];
      for (i = 0; i < c; i++)
        {
          NSString      *n;
          id            v;

          elem = [a objectAtIndex: i];
          n = [elem name];
          v = [self _simplify: elem];
	  [names addObject: n];
	  if ([keys member: n] == nil)
	    {
	      [order addObject: n];
	    }
          [keys addObject: n];
	  [values addObject: v];
        }
      if ([keys count] == 0)
	{
	  /* As there is nothing decoded, we return an empty dictionary.
	   */
	  result = [NSMutableDictionary dictionary];
	}
      else if ([keys count] == 1 && [names count] > 1)
        {
	  /* As there is only a single name but multiple values,
	   * this must be an array.
	   */
	  result = [[values retain] autorelease];
	}
      else
	{
          NSMutableDictionary	*md;

	  /* This is a structure containing individual elements and/or
	   * possibly arrays of elements.
	   */
	  md = [NSMutableDictionary dictionaryWithCapacity: [order count] + 1];
	  c = [names count];
	  for (i = 0; i < c; i++)
	    {
	      NSString	*n = [names objectAtIndex: i];
	      unsigned	a = [keys countForObject: n];

	      if (a == 1)
		{
		  [md setObject: [values objectAtIndex: i] forKey: n];
		}
	      else
		{
		  NSMutableArray	*ma = [md objectForKey: n];

		  if (ma == nil)
		    {
		      ma = [[NSMutableArray alloc] initWithCapacity: a];
		      [md setObject: ma forKey: n];
		      [ma release];
		    }
		  [ma addObject: [values objectAtIndex: i]];
		}
	    }
	  [md setObject: order forKey: GWSOrderKey];
          result = md;
        }
      [keys release];
      [names release];
      [order release];
      [values release];
    }
  return result;
}

@end


@implementation NSObject (GWSSOAPCoder)

- (GWSElement*) coder: (GWSSOAPCoder*)coder didEncode: (GWSElement*)element
{
  return element;
}

- (GWSElement*) coder: (GWSSOAPCoder*)coder willDecode: (GWSElement*)element
{
  return element;
}

- (GWSElement*) coder: (GWSSOAPCoder*)coder willEncode: (GWSElement*)element
{
  return element;
}

@end

