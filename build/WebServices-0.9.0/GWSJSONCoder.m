/** 
   Copyright (C) 2011 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	May 2011
   
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

NSString * const GWSJSONResultKey = @"GWSJSONResult";

static NSString * const ver1 = @"1.0";
static NSString * const ver2 = @"2.0";

static id       boolN;
static id       boolY;
static id       null;
static Class    NSArrayClass;
static Class    NSDataClass;
static Class    NSDateClass;
static Class    NSDictionaryClass;
static Class    NSNullClass;
static Class    NSNumberClass;
static Class    NSStringClass;
static NSTimeZone       *gmt;
static BOOL     useTimeZone = NO;

static NSString*
JSONQuote(NSString *str)
{
  unsigned	length = [str length];
  unsigned	output = 2;
  unichar	*from;
  unsigned	i = 0;
  unichar	*to;
  unsigned	j = 0;

  if (length == 0)
    {
      return @"\"\"";
    }
  from = NSZoneMalloc (NSDefaultMallocZone(), sizeof(unichar) * length);
  [str getCharacters: from];

  for (i = 0; i < length; i++)
    {
      unichar	c = from[i];

      if (c == '"' || c == '\\'
	|| c == '\b' || c == '\f' || c == '\n' || c == '\r' || c == '\t')
	{
	  output += 2;
	}
      else if (c < 0x20 || c > 0x7f)
	{
	  output += 6;
	}
      else
	{
	  output++;
	}
    }

  to = NSZoneMalloc (NSDefaultMallocZone(), sizeof(unichar) * output);
  to[j++] = '"';
  for (i = 0; i < length; i++)
    {
      unichar	c = from[i];

      if (c == '"' || c == '\\'
	|| c == '\b' || c == '\f' || c == '\n' || c == '\r' || c == '\t')
	{
	  to[j++] = '\\';
          switch (c)
	    {
	      case '\\': to[j++] = '\\'; break;
	      case '\b': to[j++] = 'b'; break;
	      case '\f': to[j++] = 'f'; break;
	      case '\n': to[j++] = 'n'; break;
	      case '\r': to[j++] = 'r'; break;
	      case '\t': to[j++] = 't'; break;
	      default: to[j++] = '"'; break;
	    }
	}
      else if (c < 0x20 || c > 0x7f)
	{
	  char	buf[5];

	  to[j++] = '\\';
	  to[j++] = 'u';
	  sprintf(buf, "%04x", c);
	  to[j++] = buf[0];
	  to[j++] = buf[1];
	  to[j++] = buf[2];
	  to[j++] = buf[3];
	}
      else
	{
	  to[j++] = c;
	}
    }
  to[j] = '"';
  str = [[NSStringClass alloc] initWithCharacters: to length: output];
  NSZoneFree (NSDefaultMallocZone (), to);
  [str autorelease];
  NSZoneFree (NSDefaultMallocZone (), from);
  return str;
}

typedef struct {
  const unsigned char	*buffer;
  unsigned		length;
  unsigned		line;
  unsigned		column;
  unsigned		index;
  const char		*error;
} context;

static inline int
get(context *ctxt)
{
  if (ctxt->index < ctxt->length)
    {
      int	c = ctxt->buffer[ctxt->index++];

      ctxt->column++;
      if (c == '\n')
	{
	  ctxt->line++;
	  ctxt->column = 1;
	}
      return c;
    }
  return -1;
}

static inline int
skipSpace(context *ctxt)
{
  while (ctxt->index < ctxt->length && isspace(ctxt->buffer[ctxt->index]))
    {
      get(ctxt);
    }
  if (ctxt->index < ctxt->length)
    {
      return ctxt->buffer[ctxt->index];
    }
  return -1;
}

static id
newParsed(context *ctxt)
{
  int	c;

  skipSpace(ctxt);
  c = get(ctxt);
  if (c < 0)
    {
      return nil;
    }
  else if ('"' == c)
    {
      BOOL	ascii = YES;
      BOOL	escapes = NO;
      BOOL	unicode = NO;
      unsigned	start = ctxt->index;
      NSString	*s;

      while ((c = get(ctxt)) >= 0)
	{
	  if ('\\' == c)
	    {
	      escapes = YES;
	      c = get(ctxt);
              if ('u' == c)
                {
                  unicode = YES;
                }
	      else if (c < 0)
		{
		  break;
		}
	    }
	  else if ('"' == c)
	    {
	      break;
	    }
          else if (c > 0x7f)
            {
              ascii = NO;
            }
	}
      if (c < 0)
	{
	  ctxt->error = "premature end of string";
	  ctxt->index = ctxt->length;
	  return nil;
	}
      if (NO == escapes)
	{
	  s = [NSStringClass alloc];
          if (YES == ascii)
            {
              s = [s initWithBytes: ctxt->buffer + start
                            length: ctxt->index - start - 1
                          encoding: NSASCIIStringEncoding];
            }
          else
            {
              s = [s initWithBytes: ctxt->buffer + start
                            length: ctxt->index - start - 1
                          encoding: NSUTF8StringEncoding];
            }
	}
      else if (NO == unicode)
	{
          char  *buf;
          int   len;
          int   pos = start;
          int   end = ctxt->index - 1;

          buf = malloc(ctxt->index - start - 1);
          for (len = 0; pos < end; len++)
            {
              buf[len] = ctxt->buffer[pos++];
              if ('\\' == buf[len])
                {
                  buf[len] = ctxt->buffer[pos++];
                  switch (buf[len])
                    {
		      case 'b': buf[len] = '\b'; break;
		      case 'f': buf[len] = '\f'; break;
		      case 'r': buf[len] = '\r'; break;
		      case 'n': buf[len] = '\n'; break;
		      case 't': buf[len] = '\t'; break;
                      default: break;
                    }
                }
            }
	  s = [NSStringClass alloc];
          if (YES == ascii)
            {
              s = [s initWithBytesNoCopy: buf
                                  length: len
                                encoding: NSASCIIStringEncoding
                            freeWhenDone: YES];
            }
          else
            {
              s = [s initWithBytesNoCopy: buf
                                  length: len
                                encoding: NSUTF8StringEncoding
                            freeWhenDone: YES];
            }
	}
      else
	{
	  NSMutableString	*m;

	  m = [NSMutableString alloc];
	  s = m = [m initWithBytes: ctxt->buffer + start
                            length: ctxt->index - start - 1
                          encoding: NSUTF8StringEncoding];
          if (nil != s)
            {
              NSRange       r = NSMakeRange(0, [m length]);

              r = [m rangeOfString: @"\\" options: NSLiteralSearch range: r];
              while (r.length > 0)
                {
                  unsigned	pos = r.location;
                  NSString	*rep;

                  c = [m characterAtIndex: pos + 1];
                  if ('u' == c)
                    {
                      const char	*hex;
                      unichar	        u;

                      if (pos + 6 > [m length])
                        {
                          ctxt->error = "short unicode escape in string";
                          ctxt->index = ctxt->length;
			  RELEASE(s);
                          return nil;
                        }
                      hex = [[m substringWithRange: NSMakeRange(pos + 2, 4)]
                        UTF8String];
                      if (isxdigit(hex[0]) && isxdigit(hex[1])
                        && isxdigit(hex[2]) && isxdigit(hex[3]))
                        {
                          u = (unichar) strtol(hex, 0, 16);
                        }
                      else
                        {
                          ctxt->error = "invalid unicode escape in string";
                          ctxt->index = ctxt->length;
			  RELEASE(s);
                          return nil;
                        }
                      rep = [NSStringClass stringWithCharacters: &u length: 1];
                      r.length += 5;
                    }
                  else
                    {
                      if ('"' == c) rep = @"\"";
                      else if ('\\' == c) rep = @"\\";
                      else if ('b' == c) rep = @"\b";
                      else if ('f' == c) rep = @"\f";
                      else if ('r' == c) rep = @"\r";
                      else if ('n' == c) rep = @"\n";
                      else if ('t' == c) rep = @"\t";
                      else rep = [NSStringClass
                        stringWithFormat: @"%c", (char)c];
                      r.length += 1;
                    }
                  [m replaceCharactersInRange: r withString: rep];
                  pos++;
                  r = NSMakeRange(pos, [m length] - pos);
                  r = [m rangeOfString: @"\\"
                               options: NSLiteralSearch
                                 range: r];
                }
            }
        }
      if (nil == s && 0 == ctxt->error)
	{
	  ctxt->error = "invalid string";
	  ctxt->index = start;
	}
      return s;
    }
  else if ('[' == c)
    {
      NSMutableArray	*a;

      a = [[NSMutableArray alloc] initWithCapacity: 100];
      for (;;)
	{
	  id	o;

	  if (nil != (o = newParsed(ctxt)))
	    {
	      [a addObject: o];
              [o release];
	    }
	  else if (ctxt->error != 0)
	    {
	      [a release];
	      return nil;
	    }

	  c = skipSpace(ctxt);
	  if (']' == c)
	    {
	      get(ctxt);
	      return a;
	    }

	  if (c != ',')
	    {
	      if (c < 0)
		{
		  ctxt->error = "premature end of array";
		}
	      else
		{
		  ctxt->error = "bad character in array";
		}
	      ctxt->index = ctxt->length;
              [a release];
	      return nil;
	    }
	  get(ctxt);	// Skip past comma
	}
    }
  else if ('{' == c)
    {
      NSMutableDictionary	*d;

      d = [[NSMutableDictionary alloc] initWithCapacity: 100];
      for (;;)
	{
	  id	k;
	  id	v;

	  k = newParsed(ctxt);
	  c = skipSpace(ctxt);
	  if ('}' == c && nil == k)
	    {
	      get(ctxt);
	      return d;	// Empty
	    }
	  if (NO == [k isKindOfClass: NSStringClass])
	    {
              [k release];
	      if (0 == ctxt->error)
		{
		  ctxt->error = "non-string value for key";
		  ctxt->index = ctxt->length;
		}
	      [d release];
	      return nil;
	    }
	  if (':' != c)
	    {
              [k release];
	      ctxt->error = "missing colon after key";
	      ctxt->index = ctxt->length;
	      [d release];
	      return nil;
	    }
	  get(ctxt);	// Skip the colon
	  v = newParsed(ctxt);
	  if (nil == v)
	    {
              [k release];
	      if (0 == ctxt->error)
		{
		  ctxt->error = "missing value after colon";
		  ctxt->index = ctxt->length;
		}
	      [d release];
	      return nil;
	    }
	  c = skipSpace(ctxt);
	  if (',' == c)
	    {
	      [d setObject: v forKey: k];
              [k release];
              [v release];
	      get(ctxt);
	    }
	  else if ('}' == c)
	    {
	      [d setObject: v forKey: k];
              [k release];
              [v release];
	      get(ctxt);
	      return d;
	    }
	  else
	    {
              [k release];
              [v release];
	      if (c < 0)
		{
		  ctxt->error = "premature end of object";
		}
	      else
		{
		  ctxt->error = "bad character in object";
		}
	      ctxt->index = ctxt->length;
	      [d release];
	      return nil;
	    }
	}
    }
  else if ('-' == c || isdigit(c))
    {
      const char	*s = (const char*)ctxt->buffer + ctxt->index - 1;
      char		*e = 0;
      NSNumber		*n = nil;
      double		d;
      long long		l;
      unsigned		pos = ctxt->index;
      BOOL		tryFloat = NO;

      if ('-' == 'c') pos++;
      while (pos < ctxt->length && isdigit(ctxt->buffer[pos]))
	{
	  pos++;
	}
      if (pos < ctxt->length && '.' == ctxt->buffer[pos])
	{
	  tryFloat = YES;
	  pos++;
	  while (pos < ctxt->length && isdigit(ctxt->buffer[pos]))
	    {
	      pos++;
	    }
	}
      if (pos < ctxt->length
	&& ('e' == ctxt->buffer[pos] || 'E' == ctxt->buffer[pos]))
	{
	  tryFloat = YES;
	  pos++;
	  if (pos < ctxt->length
	    && ('+' == ctxt->buffer[pos] || '-' == ctxt->buffer[pos]))
	    {
	      pos++;
	    }
	  while (pos < ctxt->length && isdigit(ctxt->buffer[pos]))
	    {
	      pos++;
	    }
	}

      if (YES == tryFloat)
	{
	  d = strtod(s, &e);
	  if (e == s)
	    {
	      ctxt->error = "unparsable numeric value";
	      ctxt->index = ctxt->length;
	      return nil;
	    }
	  n = [[NSNumberClass alloc] initWithDouble: d];
	}
      else
	{
	  l = strtoll(s, &e, 10);
	  if (e == s)
	    {
	      ctxt->error = "unparsable integer value";
	      ctxt->index = ctxt->length;
	      return nil;
	    }
	  n = [[NSNumberClass alloc] initWithLongLong: l];
	}
      if (nil == n)
	{
	  ctxt->error = "failed to parse numeric value";
	  ctxt->index = ctxt->length;
	  return nil;
	}

      /* Step past the numeric value.
       */
      while (ctxt->index < pos)
	{
	  get(ctxt);
	}
      return n;
    }
  else if ('t' == c)
    {
      if (get(ctxt) == 'r' && get(ctxt) == 'u' && get(ctxt) == 'e')
	{
	  return [boolY retain];
	}
      ctxt->error = "bad character (expecting 'true')";
      ctxt->index = ctxt->length;
      return nil;
    }
  else if ('f' == c)
    {
      if (get(ctxt) == 'a' && get(ctxt) == 'l' && get(ctxt) == 's'
	&& get(ctxt) == 'e')
	{
	  return [boolN retain];
	}
      ctxt->error = "bad character (expecting 'false')";
      ctxt->index = ctxt->length;
      return nil;
    }
  else if ('n' == c)
    {
      if (get(ctxt) == 'u' && get(ctxt) == 'l' && get(ctxt) == 'l')
	{
	  return [null retain];
	}
      ctxt->error = "bad character (expecting 'null')";
      ctxt->index = ctxt->length;
      return nil;
    }
  else
    {
      ctxt->index--;	// Push back character
      return nil;
    }
}

@implementation	GWSJSONCoder

+ (void) initialize
{
  NSArrayClass = [NSArray class];
  NSDataClass = [NSData class];
  NSDateClass = [NSDate class];
  NSDictionaryClass = [NSDictionary class];
  NSNullClass = [NSNull class];
  NSNumberClass = [NSNumber class];
  NSStringClass = [NSString class];
  boolY = [[NSNumberClass numberWithBool: YES] retain];
  boolN = [[NSNumberClass numberWithBool: NO] retain];
  null = [[NSNullClass null] retain];
  gmt = [[NSTimeZone timeZoneWithName: @"GMT"] retain];
}

- (void) appendObject: (id)o
{
  NSMutableString       *ms = [self mutableString];

  if (nil == o || null == o || [o isKindOfClass: NSNullClass])
    {
      [ms appendString: @"null"];
    }
  else if (YES == [o isKindOfClass: NSStringClass])
    {
      [ms appendString: JSONQuote(o)];
    }
  else if (o == boolY)
    {
      [ms appendString: @"true"];
    }
  else if (o == boolN)
    {
      [ms appendString: @"false"];
    }
  else if (YES == [o isKindOfClass: NSNumberClass])
    {
      const char	*t = [o objCType];

      if (strchr("cCsSiIlLqQ", *t) != 0)
        {
          long long	i = [(NSNumber*)o longLongValue];

          [ms appendFormat: @"%lld", i];
        }
      else
        {
          [ms appendFormat: @"%g", [(NSNumber*)o doubleValue]];
        }
    }
  else if (YES == [o isKindOfClass: NSDataClass])
    {
      [ms appendString: @"\""];
      [ms appendString: [self encodeBase64From: o]];
      [ms appendString: @"\""];
    }
  else if (YES == [o isKindOfClass: NSDateClass])
    {
      [ms appendString: @"\""];
      [ms appendString: [self encodeDateTimeFrom: o]];
      [ms appendString: @"\""];
    }
  else if (YES == [o isKindOfClass: NSArrayClass])
    {
      unsigned 		i;
      unsigned		c = [o count];
      
      [ms appendString: @"["];
      [self indent];
      for (i = 0; i < c; i++)
        {
	  if (i > 0)
	    {
	      [ms appendString: @","];
	    }
          [self nl];
          [self appendObject: [o objectAtIndex: i]];
        }
      [self unindent];
      [self nl];
      [ms appendString: @"]"];
    }
  else if (YES == [o isKindOfClass: NSDictionaryClass])
    {
      NSEnumerator	*kEnum;
      NSString	        *key;
      BOOL              first = YES;

      kEnum = [[o objectForKey: GWSOrderKey] objectEnumerator];
      if (kEnum == nil)
        {
          kEnum = [o keyEnumerator];
        }
      [ms appendString: @"{"];
      [self indent];
      while ((key = [kEnum nextObject]))
        {
          if (YES == first)
            {
              first = NO;
            }
          else
            {
              [ms appendString: @","];
              [self unindent];
            }
          [self nl];
          [ms appendString: JSONQuote([key description])];
          [ms appendString: @":"];
	  [self indent];
          [self nl];
          [self appendObject: [o objectForKey: key]];
        }
      if (NO == first)
        {
          [self unindent];
        }
      [self unindent];
      [self nl];
      [ms appendString: @"}"];
    }
  else
    {
      [ms appendString: JSONQuote([o description])];
    }
}

/* Build JSON-RPC request or just build a JSON object as a document.
 * Return YES if it's a JSON-RPC, NO otherwise.
 */
- (BOOL) _build: (id*)container
     parameters: (NSDictionary*)parameters
          order: (NSArray*)order
{
  NSUInteger	        c;
  NSUInteger	        i;
  id		        o;
  id                    p;
  NSString              *version;
  BOOL                  positional = YES;

  *container = [NSMutableDictionary dictionaryWithCapacity: 4];

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

  /* Get the JSON-RPC version ... nil means we just want a plain object.
   */
  version = [parameters objectForKey: GWSRPCVersionKey];
  if (nil == version)
    {
      version = [self version];
    }

  /* If we have an RPC version, we must have an RPC request/response ID too.
   */
  if (nil != version)
    {
      id        rid;

      rid = [parameters objectForKey: GWSRPCIDKey];
      if (nil == rid)
        {
          rid = [self RPCID];
          if (nil == rid)
            {
              rid = null;
            }
        }
      [*container setObject: rid forKey: @"id"];
    }

  if (ver2 == version)
    {
      [*container setObject: ver2 forKey: @"jsonrpc"];
      /* If this request has no order specified and is version 2
       * then we encode parameters by name.
       */
      if (nil == order || [order containsObject: GWSJSONResultKey])
        {
          positional = NO;
        }
    }

  if (nil != version && YES == [self fault])
    {
      NSMutableDictionary       *e;

      e = [[NSMutableDictionary alloc] initWithCapacity: 3];
      [*container setObject: e forKey: @"error"];
      [e release];

      o = [parameters objectForKey: @"code"];
      if (nil == o)
        {
          o = [parameters objectForKey: @"faultCode"];
        }
      if (nil == o || NO == [o respondsToSelector: @selector(intValue)])
        {
          [NSException raise: NSGenericException
                      format: @"Bad/missing error code"];
        }
      [e setObject: [NSNumber numberWithInt: [o intValue]] forKey: @"code"];

      o = [parameters objectForKey: @"message"];
      if (nil == o)
        {
          o = [parameters objectForKey: @"faultString"];
        }
      if (NO == [o isKindOfClass: NSStringClass])
        {
          [NSException raise: NSGenericException
                      format: @"Bad/missing error message"];
        }
      [e setObject: o forKey: @"message"];

      o = [parameters objectForKey: @"data"];
      if (nil != o)
        {
          [e setObject: o forKey: @"data"];
        }
    }
  else
    {
      if ([order count] == 0)
        {
          order = [parameters allKeys];
        }
      c = [order count];
      if (c > 0)
        {
          if (YES == positional)
            {
              p = [NSMutableArray new];
            }
          else
            {
              p = [NSMutableDictionary new];
            }
          [*container setObject: p forKey: @"params"];
          [p release];

          for (i = 0; i < c; i++)
            {
              NSString      *k = [order objectAtIndex: i];

              if (NO == [k hasPrefix: @"GWSCoder"])
                {
                  id    v = [parameters objectForKey: k];

                  if (v != nil)
                    {
                      if (YES == positional)
                        {
                          [p addObject: v];
                        }
                      else
                        {
                          [p setObject: v forKey: k];
                        }
                    }
                }
            }
          if (nil == version)
            {
              /* This is not a JSON-RPC ... make it a plain document.
               */
              if ([p count] == 1)
                {
                  /* There was a single argument ...
                   * we must use it as the whole JSON document.
                   */
                  p = [p lastObject];
                }
              *container = p;
            }
        }
    }
  if (nil == version)
    {
      return NO;        // Not a JSON-RPC
    }
  return YES;           // Built JSON-RPC
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
  NSMutableString       *ms;
  id                    container;

  [self reset];

  if (NO == [self fault] && [method length] == 0)
    {
      return nil;
    }

  ms = [self mutableString];
  [ms setString: @""];

  if (YES == [self _build: &container parameters: parameters order: order]
    && NO == [self fault])
    {
      [container setObject: method forKey: @"method"];
    }
  [self appendObject: container];

  return [ms dataUsingEncoding: NSUTF8StringEncoding];
}

- (NSData*) buildResponse: (NSString*)method
               parameters: (NSDictionary*)parameters
                    order: (NSArray*)order;
{
  NSMutableString       *ms;
  id                    container;

  [self reset];
  ms = [self mutableString];
  [ms setString: @""];

  if (YES == [self _build: &container parameters: parameters order: order])
    {
      if (YES == [container isKindOfClass: NSDictionaryClass])
        {
          id    o;

          /* If this is not a fault we must set the 'result' field rather
           * than the normal 'params' field.
           */
          if (nil == [container objectForKey: @"error"])
            {
              if (nil == (o = [container objectForKey: @"params"]))
                {
                  o = null;
                }
              else if (YES == [o isKindOfClass: [NSDictionary class]]
                && 1 == [o count] && nil != [o objectForKey: GWSJSONResultKey])
                {
                  o = [o objectForKey: GWSJSONResultKey];
                }
              [container setObject: o forKey: @"result"];
            }
          [container removeObjectForKey: @"params"];
          if (ver1 == [self version])
            {
              if (nil == [container objectForKey: @"error"])
                {
                  [container setObject: null forKey: @"error"];
                }
              if (nil == [container objectForKey: @"result"])
                {
                  [container setObject: null forKey: @"result"];
                }
            }
          o = [container objectForKey: GWSOrderKey];
          if (nil == o)
            {
              o = [[container allKeys] sortedArrayUsingSelector:
                @selector(compare:)];
              [container setObject: o forKey: GWSOrderKey];
            }
        }
    }
  [self appendObject: container];

  return [ms dataUsingEncoding: NSUTF8StringEncoding];
}

- (void) dealloc
{
  [_jsonID release];
  [super dealloc];
}

- (NSCalendarDate*) decodeDateTimeFrom: (NSString*)source
{
  int	                year;
  int	                month;
  int	                day;
  int	                hour;
  int	                minute;
  int	                second;
  int                   h;
  int                   m;
  int                   milli;
  int                   l;
  char                  c;
  NSTimeZone            *tz = nil;
  const char            *u;
  NSCalendarDate        *d;

  if (NO == [source isKindOfClass: [NSString class]])
    {
      return nil;
    }
  u = [source UTF8String];
  l = strlen(u);
  if (29 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d.%03d%c%02d:%02d",
    &year, &month, &day, &hour, &minute, &second, &milli, &c, &h, &m) == 10
    && h >= 0 && h < 24 && m >= 0 && m < 60 && ('-' == c || '+' == c))
    {
      tz = nil;
    }
  else if (28 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d.%03d%c%02d%02d",
    &year, &month, &day, &hour, &minute, &second, &milli, &c, &h, &m) == 10
    && h >= 0 && h < 24 && m >= 0 && m < 60 && ('-' == c || '+' == c))
    {
      tz = nil;
    }
  else if (26 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d.%03d%c%02d",
    &year, &month, &day, &hour, &minute, &second, &milli, &c, &h) == 9
    && h >= 0 && h < 24 && ('-' == c || '+' == c))
    {
      m = 0;
      tz = nil;
    }
  else if (24 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d.%03dZ",
    &year, &month, &day, &hour, &minute, &second, &milli) == 7)
    {
      h = m = 0;
      c = 0;
      tz = gmt;
    }
  else if (23 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d.%03d",
    &year, &month, &day, &hour, &minute, &second, &milli) == 7)
    {
      h = m = 0;
      c = 0;
      tz = [self timeZone];
    }
  else if (25 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d%c%02d:%02d",
    &year, &month, &day, &hour, &minute, &second, &c, &h, &m) == 9
    && h >= 0 && h < 24 && m >= 0 && m < 60 && ('-' == c || '+' == c))
    {
      milli = 0;
      tz = nil;
    }
  else if (24 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d%c%02d%02d",
    &year, &month, &day, &hour, &minute, &second, &c, &h, &m) == 9
    && h >= 0 && h < 24 && m >= 0 && m < 60 && ('-' == c || '+' == c))
    {
      milli = 0;
      tz = nil;
    }
  else if (22 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d%c%02d",
    &year, &month, &day, &hour, &minute, &second, &c, &h) == 8
    && h >= 0 && h < 24 && ('-' == c || '+' == c))
    {
      milli = 0;
      m = 0;
      tz = nil;
    }
  else if (20 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02dZ",
    &year, &month, &day, &hour, &minute, &second) == 6)
    {
      milli = 0;
      h = m = 0;
      c = 0;
      tz = gmt;
    }
  else if (19 == l && sscanf(u, "%04d-%02d-%02dT%02d:%02d:%02d",
    &year, &month, &day, &hour, &minute, &second) == 6)
    {
      milli = 0;
      h = m = 0;
      c = 0;
      tz = [self timeZone];
    }
  else if (15 == l && sscanf(u, "%04d%02d%02dT%02d%02d%02d",
    &year, &month, &day, &hour, &minute, &second) == 6)
    {
      milli = 0;
      h = m = 0;
      c = 0;
      tz = [self timeZone];
    }
  else
    {
      return nil;       // Bad date/time format
    }
  if (nil == tz)
    {
      int       o = h * 60 + m;

      if ('-' == c)
        {
          o = -o;
        }
      tz = [NSTimeZone timeZoneForSecondsFromGMT: o * 60];
    }
  d = [NSCalendarDate alloc];
  d = [d initWithYear: year
                month: month
                  day: day
                 hour: hour
               minute: minute
               second: second
             timeZone: tz];
  if (milli != 0)
    {
      NSTimeInterval	ti;

      ti = milli;
      ti /= 1000.0;
      ti += [d timeIntervalSinceReferenceDate];
      d = [d initWithTimeIntervalSinceReferenceDate: ti];
    }
  [d setTimeZone: tz];
  return [d autorelease];
}

- (NSString*) encodeDateTimeFrom: (NSDate*)source
{
  NSString      *s;

  if (NO == [source isKindOfClass: [NSDate class]])
    {
      s = nil;
    }
  else if (YES == useTimeZone)
    {
      s = [source descriptionWithCalendarFormat: @"%Y-%m-%dT%H:%M:%S.%F"
                                       timeZone: [self timeZone]
                                         locale: nil];
    }
  else
    {
      s = [source descriptionWithCalendarFormat: @"%Y-%m-%dT%H:%M:%S.%FZ"
                                       timeZone: gmt
                                         locale: nil];
    }
  return s;
}

- (void) _jsonrpcFrom: (NSDictionary*)o to: (NSMutableDictionary*)result
{
  id    jsonerror = [o objectForKey: @"error"];
  id    jsonmethod = [o objectForKey: @"method"];
  id    jsonparams = [o objectForKey: @"params"];
  id    jsonresult = [o objectForKey: @"result"];
  id    v;

  if (nil != jsonmethod && nil != jsonresult)
    {
      [NSException raise: NSGenericException
        format: @"Not a JSON-RPC document (has both 'method' and 'result')"];
    }
  if (nil != jsonmethod && nil != jsonerror)
    {
      [NSException raise: NSGenericException
        format: @"Not a JSON-RPC document (has both 'method' and 'error')"];
    }
  if (nil != jsonmethod)
    {
      if ([(v = jsonmethod) isKindOfClass: NSStringClass])
        {
          [result setObject: v forKey: GWSMethodKey];
          if (nil == (v = jsonparams))
            {
              if (ver1 == [self version])
                {
                  [NSException raise: NSGenericException
                    format: @"Not a valid JSON-RPC 1.0 document"
                    @" (the 'params' field is missing)"];
                }
            }
          else
            {
              if (YES == [v isKindOfClass: NSDictionaryClass])
                {
                  if (ver1 == [self version])
                    {
                      [NSException raise: NSGenericException
                        format: @"Not a valid JSON-RPC 1.0 document"
                        @" (the 'params' field is not an array)"];
                    }
                  [result setObject: v forKey: GWSParametersKey];
                  [result setObject: [v allKeys] forKey: GWSOrderKey];
                }
              else if (YES == [v isKindOfClass: NSArrayClass])
                {
                  NSMutableArray        *order;
                  NSMutableDictionary   *params;
                  NSUInteger            c;
                  NSUInteger            i;

                  c = [v count];
                  order = [NSMutableArray arrayWithCapacity: c];
                  params = [NSMutableDictionary dictionaryWithCapacity: c];
                  for (i = 0; i < c; i++)
                    {
                      NSString  *k;

                      k = [NSString stringWithFormat: @"Arg%u", (unsigned)i];
                      [order addObject: k];
                      [params setObject: [v objectAtIndex: i] forKey: k];
                    }
                  [result setObject: params forKey: GWSParametersKey];
                  [result setObject: order forKey: GWSOrderKey];
                }
              else
                {
                  [NSException raise: NSGenericException
                    format: @"Not a JSON-RPC document (params has wrong type)"];
                }
            }
        }
      else
        {
          [NSException raise: NSGenericException
            format: @"Not a JSON-RPC request ('method' is not a string)"];
        }
    }
  else
    {
      if (nil != jsonparams)
        {
          [NSException raise: NSGenericException format:
            @"Not a valid JSON-RPC response"
            @" (contains 'params' field from request)"];
        }
      if ([self version] == ver1)
        {
          if (nil == jsonresult)
            {
              [NSException raise: NSGenericException format:
                @"Not a valid JSON-RPC version 1.0 response"
                @" (missing 'result' field)"];
            }
          if (nil == jsonerror)
            {
              [NSException raise: NSGenericException format:
                @"Not a valid JSON-RPC version 1.0 response"
                @" (missing 'error' field)"];
            }
        }
      else
        {
          if (nil != jsonresult && nil != jsonerror)
            {
              [NSException raise: NSGenericException format:
                @"Not a valid JSON-RPC version 2.0 response"
                @" (both 'result' and 'error' field provided)"];
            }
        }
      if (jsonerror == null)
        {
          if ([self version] == ver1)
            {
              if (jsonresult == null || jsonresult == nil)
                {
                  [NSException raise: NSGenericException format:
                    @"Not a valid JSON-RPC version 1.0 response"
                    @" (null 'error' field without a non-null result)"];
                }
            }
        }
      if (nil != jsonerror && null != jsonerror && nil != jsonresult)
        {
          [NSException raise: NSGenericException format:
            @"Not a valid JSON-RPC response"
            @" (both non-null 'result' and non-null 'error')"];
        }
      if ((v = jsonresult) != nil)
        {
          if (YES == [v isKindOfClass: NSDictionaryClass])
            {
              [result setObject: v forKey: GWSParametersKey];
              [result setObject: [v allKeys] forKey: GWSOrderKey];
            }
          else
            {
              NSMutableArray        *order;
              NSMutableDictionary   *params;
              NSUInteger            c;
              NSUInteger            i;

              if (NO == [v isKindOfClass: NSArrayClass])
                {
                  v  = [NSArray arrayWithObject: v];
                }

              c = [v count];
              order = [NSMutableArray arrayWithCapacity: c];
              params = [NSMutableDictionary dictionaryWithCapacity: c];
              for (i = 0; i < c; i++)
                {
                  NSString  *k;

                  k = [NSString stringWithFormat: @"Arg%u", (unsigned)i];
                  [order addObject: k];
                  [params setObject: [v objectAtIndex: i] forKey: k];
                }
              [result setObject: params forKey: GWSParametersKey];
              [result setObject: order forKey: GWSOrderKey];
            }
        }
      if ((v = jsonerror) != nil)
        {
          if (YES == [(v = jsonerror) isKindOfClass: NSDictionaryClass])
            {
              [result setObject: v forKey: GWSFaultKey];
              if ([self version] == ver2)
                {
                  id    code = [v objectForKey: @"code"];
                  id    message = [v objectForKey: @"message"];

                  if (NO == [code isKindOfClass: [NSNumber class]])
                    {
                      [NSException raise: NSGenericException format:
                        @"Not a valid JSON-RPC version 2.0 response"
                        @" (fault 'code' field is not an integer)"];
                    }
                  if (NO == [message isKindOfClass: [NSString class]])
                    {
                      [NSException raise: NSGenericException format:
                        @"Not a valid JSON-RPC version 2.0 response"
                        @" (fault 'message' field is not a string)"];
                    }
                  if (YES == _jsonrpc)
                    {
                      int       expect;

                      expect = (nil == [v objectForKey: @"data"]) ? 2 : 3;
                      if ([v count] != expect)
                        {
                          v = [[v mutableCopy] autorelease];
                          [v removeObjectForKey: @"code"];
                          [v removeObjectForKey: @"message"];
                          [v removeObjectForKey: @"data"];
                          [NSException raise: NSGenericException format:
                            @"Not a valid JSON-RPC version 2.0 fault response"
                            @" ('error' has extraneous fields: %@)", v];
                        }
                    }
                }
            }
          else
            {
              [NSException raise: NSGenericException format:
                @"Not a valid JSON-RPC response"
                @" ('error' field is not a JSON object)"];
            }
        }
    }
  if (YES == _jsonrpc)
    {
      NSMutableDictionary       *m = [[o mutableCopy] autorelease];

      [m removeObjectForKey: @"id"];
      [m removeObjectForKey: @"jsonrpc"];
      [m removeObjectForKey: @"error"];
      [m removeObjectForKey: @"method"];
      [m removeObjectForKey: @"params"];
      [m removeObjectForKey: @"result"];

      if ([m count] > 0)
        {
          [NSException raise: NSGenericException format:
            @"Not a valid JSON-RPC response"
            @" (extraneous fields: %@)", m];
        }
    }
}

- (NSMutableDictionary*) parseMessage: (NSData*)data
{
  NSAutoreleasePool     *pool;
  NSMutableDictionary   *result;

  result = [NSMutableDictionary dictionaryWithCapacity: 3];

  [self reset];
  pool = [NSAutoreleasePool new];
  NS_DURING
    {
      context	x;
      id	o;
      id        v;

      x.buffer = (const unsigned char*)[data bytes];
      x.length = [data length];
      x.line = 1;
      x.column = 1;
      x.index = 0;
      x.error = 0;

      o = [newParsed(&x) autorelease];
      if (skipSpace(&x) >= 0)
	{
	  x.error = "unexpected data at end of text";
	}

      if (x.error != 0)
	{
	  [NSException raise: NSGenericException
		      format: @"Not a JSON document: %s", x.error];
	}
      if (NO == [o isKindOfClass: NSDictionaryClass])
        {
          if (nil != [self version])
            {
              [NSException raise: NSGenericException
                          format: @"Not a JSON-RPC document"];
            }
        }
      else
        {
          v = [o objectForKey: @"jsonrpc"];
          if (nil != v)
            {
              [self setVersion: v];
            }
          else if (YES == _jsonrpc)
            {
              [self setVersion: ver1];
            }
          if (nil != (v = [self version]))
            {
              [result setObject: v forKey: GWSRPCVersionKey];
            }
          if (nil != v)
            {
              v = [o objectForKey: @"id"];
              if (nil == v)
                {
                  [NSException raise: NSGenericException
                    format: @"Not a JSON-RPC document (no 'id' field)"];
                }
              if ([self version] != ver1
                && v != null
                && NO == [v isKindOfClass: [NSString class]]
                && NO == [v isKindOfClass: [NSNumber class]])
                {
                  [NSException raise: NSGenericException
                    format: @"Not a JSON-RPC version 2.0 document"
                    @" ('id' field is not a string, number or null value)"];
                }
              [self setRPCID: v];
              [result setObject: [self RPCID] forKey: GWSRPCIDKey];
            }
        }

      if (nil == [self version])
        {
          /* Not JSON-RPC ... return entire JSON document
           */
          if (nil == o)
            {
              o = null;
            }
          o = [NSDictionary dictionaryWithObject: o forKey: @"Result"];
          [result setObject: o forKey: GWSParametersKey];
          o = [NSArray arrayWithObject: @"Result"];
          [result setObject: o forKey: GWSOrderKey];
        }
      else
        {
          [self _jsonrpcFrom: o to: result];
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

- (id) RPCID
{
  return _jsonID;
}

- (void) setRPCID: (id)o
{
  if (nil == o
    || [NSNull null] == o
    || YES == [o isKindOfClass: NSStringClass]
    || YES == [o isKindOfClass: NSNumberClass])
    {
      ASSIGN(_jsonID, o);
    }
  else
    {
      [NSException raise: NSInvalidArgumentException
                  format: @"Bad type for RPC ID: ('%@')", o];
    }
}

- (void) setStrictParsing: (BOOL)isStrict
{
  _jsonrpc = (isStrict ? YES : NO);
}

- (void) setTimeZone: (NSTimeZone*)timeZone
{
  if (nil == timeZone)
    {
      timeZone = gmt;
      useTimeZone = NO;         // Use standard date/time format
    }
  else
    {
      useTimeZone = YES;        // Use timezone relative date/time format
    }
  [super setTimeZone: timeZone];
}

- (void) setVersion: (NSString*)v
{
  if (YES == [ver2 isEqual: v])
    {
      _version = ver2;
    }
  else if (nil != v)
    {
      _version = ver1;
    }
  else
    {
      _version = nil;
    }
}

- (BOOL) strictParsing
{
  return _jsonrpc;
}

- (NSString*) version
{
  return _version;
}

@end


@implementation	NSArray (JSON)
- (NSData*) JSONText
{
  NSAutoreleasePool	*pool;
  GWSJSONCoder		*coder;
  NSDictionary		*p;
  NSData		*data;

  pool = [NSAutoreleasePool new];
  coder = [[GWSJSONCoder new] autorelease];
  p = [NSDictionary dictionaryWithObject: self forKey: @"text"];
  data = [coder buildRequest: @"text" parameters: p order: nil];
  [data retain];
  [pool release];
  return [data autorelease];
}
@end

@implementation	NSData (JSON)
- (id) JSONPropertyList
{
  id			o = nil;
  
  NS_DURING
    {
      NSAutoreleasePool	*pool;
      context	x;

      pool = [NSAutoreleasePool new];
      x.buffer = (const unsigned char*)[self bytes];
      x.length = [self length];
      x.line = 1;
      x.column = 1;
      x.index = 0;
      x.error = 0;

      o = newParsed(&x);
      if (skipSpace(&x) >= 0)
	{
          [o release];
	  o = nil;	// Excess data
	}
      [pool release];
      [o autorelease];
    }
  NS_HANDLER
    {
      o = nil;		// Problem
    }
  NS_ENDHANDLER
  return o;
}
@end

@implementation	NSDictionary (JSON)
- (NSData*) JSONText
{
  NSAutoreleasePool	*pool;
  GWSJSONCoder		*coder;
  NSDictionary		*p;
  NSData		*data;

  pool = [NSAutoreleasePool new];
  coder = [[GWSJSONCoder new] autorelease];
  p = [NSDictionary dictionaryWithObject: self forKey: @"text"];
  data = [coder buildRequest: @"text" parameters: p order: nil];
  [data retain];
  [pool release];
  return [data autorelease];
}
@end

@implementation	NSString (JSON)
- (id) JSONPropertyList
{
  return [[self dataUsingEncoding: NSUTF8StringEncoding] JSONPropertyList];
}
@end

