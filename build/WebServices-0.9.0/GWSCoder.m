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

static inline void
decodebase64(unsigned char *dst, const unsigned char *src)
{
  dst[0] =  (src[0]         << 2) | ((src[1] & 0x30) >> 4);
  dst[1] = ((src[1] & 0x0F) << 4) | ((src[2] & 0x3C) >> 2);
  dst[2] = ((src[2] & 0x03) << 6) |  (src[3] & 0x3F);
}

static int
encodebase64(unsigned char *dst, const unsigned char *src, int length)
{
  static char b64[]
    = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  int	dIndex = 0;
  int	sIndex;

  for (sIndex = 0; sIndex < length; sIndex += 3)
    {
      int	c0 = src[sIndex];
      int	c1 = (sIndex+1 < length) ? src[sIndex+1] : 0;
      int	c2 = (sIndex+2 < length) ? src[sIndex+2] : 0;

      dst[dIndex++] = b64[(c0 >> 2) & 077];
      dst[dIndex++] = b64[((c0 << 4) & 060) | ((c1 >> 4) & 017)];
      dst[dIndex++] = b64[((c1 << 2) & 074) | ((c2 >> 6) & 03)];
      dst[dIndex++] = b64[c2 & 077];
    }

   /* If len was not a multiple of 3, then we have encoded too
    * many characters.  Standard base64 encoding pads, so we must
    * overwrite the excess characters with the pad character ('=').
    */
   if (sIndex == length + 1)
     {
       /* There were only 2 bytes in that last group */
       dst[dIndex - 1] = '=';
     }
   else if (sIndex == length + 2)
     {
       /* There was only 1 byte in that last group */
       dst[dIndex - 1] = '=';
       dst[dIndex - 2] = '=';
     }
  return dIndex;
}

static int
encodebase64Url(unsigned char *dst, const unsigned char *src, int length)
{
  static char b64[]
    = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
  int	dIndex = 0;
  int	sIndex;

  for (sIndex = 0; sIndex < length; sIndex += 3)
    {
      int	c0 = src[sIndex];
      int	c1 = (sIndex+1 < length) ? src[sIndex+1] : 0;
      int	c2 = (sIndex+2 < length) ? src[sIndex+2] : 0;

      dst[dIndex++] = b64[(c0 >> 2) & 077];
      dst[dIndex++] = b64[((c0 << 4) & 060) | ((c1 >> 4) & 017)];
      dst[dIndex++] = b64[((c1 << 2) & 074) | ((c2 >> 6) & 03)];
      dst[dIndex++] = b64[c2 & 077];
    }

   /* If len was not a multiple of 3, then we have encoded too
    * many characters.  Base64URL encoding uses no padding, so
    * we simply remove the excess characters.
    */
   if (sIndex == length + 1)
     {
       /* There were only 2 bytes in that last group */
       dst[--dIndex] = '\0';
     }
   else if (sIndex == length + 2)
     {
       /* There was only 1 byte in that last group */
       dst[--dIndex] = '\0';
       dst[--dIndex] = '\0';
     }
  return dIndex;
}


@class  GWSXMLRPCCoder;

static Class _defaultParserClass;
static Class _sloppyParserClass;

@implementation	GWSCoder

static id       boolN;
static id       boolY;

+ (GWSCoder*) coder
{
  GWSCoder       *coder;
  
  if (self == [GWSCoder class])
    {
      coder = [GWSXMLRPCCoder new];
    }
  else
    {
      coder = [self new];
    }
  return [coder autorelease];
}

+ (void) initialize
{
  if (self == [GWSCoder class])
    {
      boolN = [[NSNumber numberWithBool: NO] retain];
      boolY = [[NSNumber numberWithBool: YES] retain];
      _defaultParserClass = [NSXMLParser class];
      _sloppyParserClass = NSClassFromString(@"GSSloppyXMLParser");
      if (Nil == _sloppyParserClass)
        {
          _sloppyParserClass = _defaultParserClass;
#ifdef GNUSTEP
          NSWarnMLog(@"No separate class for the sloppy parser. All parsers "
                     @"will be sloppy.");
#else
          NSWarnMLog(@"No separate class for the sloppy parser. All parsers "
                     @"will be strict.");
#endif
        }
    }
}

- (BOOL) cdata
{
  return _cdata;
}

- (BOOL) compact
{
  return _compact;
}

- (void) dealloc
{
  [_stack release];
  [_nmap release];
  [_ms release];
  [_tz release];
  [super dealloc];
}

- (BOOL) debug
{
  return _debug;
}

- (NSData*) decodeBase64From: (NSString*)str
{
  NSData        *source = [str dataUsingEncoding: NSASCIIStringEncoding];
  int		length;
  int		declen;
  const unsigned char	*src;
  const unsigned char	*end;
  unsigned char *result;
  unsigned char	*dst;
  unsigned char	buf[4];
  unsigned	pos = 0;

  if (source == nil)
    {
      return nil;
    }
  length = [source length];
  if (length == 0)
    {
      return [NSData data];
    }
  declen = ((length + 3) * 3)/4;
  src = (const unsigned char*)[source bytes];
  end = &src[length];

  result = (unsigned char*)NSZoneMalloc(NSDefaultMallocZone(), declen);
  dst = result;

  while ((src != end) && *src != '\0')
    {
      int	c = *src++;

      if (isupper(c))
	{
	  c -= 'A';
	}
      else if (islower(c))
	{
	  c = c - 'a' + 26;
	}
      else if (isdigit(c))
	{
	  c = c - '0' + 52;
	}
      else if (c == '/')
	{
	  c = 63;
	}
      else if (c == '+')
	{
	  c = 62;
	}
      else if  (c == '=')
	{
	  c = -1;
	}
      else if (c == '-')
	{
	  break;		/* end    */
	}
      else
	{
	  c = -1;		/* ignore */
	}

      if (c >= 0)
	{
	  buf[pos++] = c;
	  if (pos == 4)
	    {
	      pos = 0;
	      decodebase64(dst, buf);
	      dst += 3;
	    }
	}
    }

  if (pos > 0)
    {
      unsigned	i;

      for (i = pos; i < 4; i++)
	{
	  buf[i] = '\0';
	}
      pos--;
      if (pos > 0)
	{
	  unsigned char	tail[3];
	  decodebase64(tail, buf);
	  memcpy(dst, tail, pos);
	  dst += pos;
	}
    }
  return [[[NSData allocWithZone: NSDefaultMallocZone()]
    initWithBytesNoCopy: result length: dst - result] autorelease];
}

- (NSData*) decodeBase64UrlFrom: (NSString*)str
{
  NSData        *source = [str dataUsingEncoding: NSASCIIStringEncoding];
  int		length;
  int		declen;
  const unsigned char	*src;
  const unsigned char	*end;
  unsigned char *result;
  unsigned char	*dst;
  unsigned char	buf[4];
  unsigned	pos = 0;

  if (source == nil)
    {
      return nil;
    }
  length = [source length];
  if (length == 0)
    {
      return [NSData data];
    }
  declen = ((length + 3) * 3)/4;
  src = (const unsigned char*)[source bytes];
  end = &src[length];

  result = (unsigned char*)NSZoneMalloc(NSDefaultMallocZone(), declen);
  dst = result;

  while ((src != end) && *src != '\0')
    {
      int	c = *src++;

      if (isupper(c))
	{
	  c -= 'A';
	}
      else if (islower(c))
	{
	  c = c - 'a' + 26;
	}
      else if (isdigit(c))
	{
	  c = c - '0' + 52;
	}
      else if (c == '_')
	{
	  c = 63;
	}
      else if (c == '-')
	{
	  c = 62;
	}
      else
	{
	  break;		/* end */
	}

      if (c >= 0)
	{
	  buf[pos++] = c;
	  if (pos == 4)
	    {
	      pos = 0;
	      decodebase64(dst, buf);
	      dst += 3;
	    }
	}
    }

  if (pos > 0)
    {
      unsigned	i;

      for (i = pos; i < 4; i++)
	{
	  buf[i] = '\0';
	}
      pos--;
      if (pos > 0)
	{
	  unsigned char	tail[3];
	  decodebase64(tail, buf);
	  memcpy(dst, tail, pos);
	  dst += pos;
	}
    }
  return [[[NSData allocWithZone: NSDefaultMallocZone()]
    initWithBytesNoCopy: result length: dst - result] autorelease];
}

- (NSData*) decodeHexBinaryFrom: (NSString*)str
{
  NSData        *source = [str dataUsingEncoding: NSASCIIStringEncoding];
  int		length;
  int		declen;
  const unsigned char	*src;
  const unsigned char	*end;
  unsigned char *result;
  unsigned char	*dst;
  unsigned char	val = 0;
  BOOL		hi = YES;

  if (source == nil)
    {
      return nil;
    }
  length = [source length];
  if (length == 0)
    {
      return [NSData data];
    }
  declen = length/2;
  src = (const unsigned char*)[source bytes];
  end = &src[length];

  result = (unsigned char*)NSZoneMalloc(NSDefaultMallocZone(), declen);
  dst = result;

  while ((src != end) && *src != '\0')
    {
      int	c = *src++;

      if (isxdigit(c))
	{
	  if (isdigit(c))
	    {
	      c = c - '0';
	    }
	  else if (isupper(c))
	    {
	      c = c - 'A' + 0x0a;
	    }
	  else
	    {
	      c = c - 'a' + 0x0a;
	    }
	  if (hi == YES)
	    {
	      val = c << 4;
	      hi = NO;
	    }
	  else
	    {
	      *dst++ = (0x0f & c) | val;
	      hi = YES;
	    }
	}
      else if (!isspace(c))
	{
	  hi = NO;	// Indicate problem
	  break;
	}
    }

  if (hi == NO)
    {
      /* Bad number of hex digits, or non hex data */
      NSZoneFree(NSDefaultMallocZone(), result);
      return nil;
    }
  return [[[NSData allocWithZone: NSDefaultMallocZone()]
    initWithBytesNoCopy: result length: dst - result] autorelease];
}

- (NSString*) encodeBase64From: (NSData*)source
{
  NSString      *str;
  int		length;
  int		destlen;
  unsigned char *sBuf;
  unsigned char *dBuf;

  length = [source length];
  if (length == 0)
    {
      return @"";
    }
  destlen = 4 * ((length + 2) / 3);
  sBuf = (unsigned char*)[source bytes];
  dBuf = NSZoneMalloc(NSDefaultMallocZone(), destlen);

  destlen = encodebase64(dBuf, sBuf, length);

  str = [[NSString alloc] initWithBytesNoCopy: dBuf
                                       length: destlen
                                     encoding: NSASCIIStringEncoding
                                 freeWhenDone: YES];
  return [str autorelease];
}

- (NSString*) encodeBase64UrlFrom: (NSData*)source
{
  NSString      *str;
  int		length;
  int		destlen;
  unsigned char *sBuf;
  unsigned char *dBuf;

  length = [source length];
  if (length == 0)
    {
      return @"";
    }
  destlen = 4 * ((length + 2) / 3);
  sBuf = (unsigned char*)[source bytes];
  dBuf = NSZoneMalloc(NSDefaultMallocZone(), destlen);

  destlen = encodebase64Url(dBuf, sBuf, length);

  str = [[NSString alloc] initWithBytesNoCopy: dBuf
                                       length: destlen
                                     encoding: NSASCIIStringEncoding
                                 freeWhenDone: YES];
  return [str autorelease];
}

- (NSString*) encodeHexBinaryFrom: (NSData*)source
{
  const char	*hex = "0123456789ABCDEF";
  NSString      *str;
  int		length;
  int		destlen;
  unsigned char *sBuf;
  unsigned char *dBuf;
  unsigned	dpos;
  unsigned	spos;

  length = [source length];
  if (length == 0)
    {
      return @"";
    }
  destlen = length * 2;
  sBuf = (unsigned char*)[source bytes];
  dBuf = NSZoneMalloc(NSDefaultMallocZone(), destlen);
  dpos = 0;
  for (spos = 0; spos < length; spos++)
    {
      dBuf[dpos++] = hex[sBuf[spos] >> 4];
      dBuf[dpos++] = hex[sBuf[spos] & 0x0f];
    }

  str = [[NSString alloc] initWithBytesNoCopy: dBuf
                                       length: destlen
                                     encoding: NSASCIIStringEncoding
                                 freeWhenDone: YES];
  return [str autorelease];
}

- (NSString*) escapeCDATAFrom: (NSString*)str
{
  NSUInteger	length = [str length];
  unichar	*from;
  NSUInteger	i = 0;
  BOOL		escape = NO;

  if (length == 0)
    {
      return str;
    }
  from = NSZoneMalloc(NSDefaultMallocZone(), sizeof(unichar) * length);
  [str getCharacters: from];

  for (i = 0; i < length; i++)
    {
      unichar	c = from[i];

      if ((c >= 0x20 && c <= 0xfffd)
	|| c == 0x9 || c == 0xd || c == 0xc || c == 0xa)
	{
	  if (c > 127 || strchr("\"'&<>\f\r", c) != 0)
	    {
	      escape = YES;
	      break;
	    }
        }
      else if (NO == _allUnicode)
	{
	  escape = YES;	// Need to remove bad characters
	  break;
	}
    }

  if (escape == YES)
    {
      NSRange		r = [str rangeOfString: @"]]>"];
      NSUInteger	output;
      NSString		*a;
      unichar		*to;
      NSUInteger	j = 0;

      if (r.length > 0)
	{
	  /* We have a CEND sequence in the string so we must split it across
	   * CDATA sections.
	   */
	  length = r.location + 1;
	  a = [self escapeCDATAFrom: [str substringFromIndex: length]];
	}
      else
	{
	  a = nil;
	}
      output = length + 12 + [a length];

      to = NSZoneMalloc(NSDefaultMallocZone(), sizeof(unichar) * output);
      to[j++] = '<';
      to[j++] = '!';
      to[j++] = '[';
      to[j++] = 'C';
      to[j++] = 'D';
      to[j++] = 'A';
      to[j++] = 'T';
      to[j++] = 'A';
      to[j++] = '[';
      for (i = 0; i < length; i++)
	{
	  unichar	c = from[i];

          if ((YES == _allUnicode)
	    || ((c >= 0x20 && c <= 0xfffd)
	    || c == 0x9 || c == 0xd || c == 0xc || c == 0xa))
	    {
	      to[j++] = c;
	    }
	}
      to[j++] = ']';
      to[j++] = ']';
      to[j++] = '>';
      if (nil != a)
	{
	  [a getCharacters: &to[j]];
	  j += [a length];
	}
      str = [[NSString alloc] initWithCharacters: to length: j];
      NSZoneFree(NSDefaultMallocZone(), to);
      [str autorelease];
    }
  NSZoneFree(NSDefaultMallocZone(), from);
  return str;
}

- (NSString*) escapeXMLFrom: (NSString*)str
{
  unsigned	length = [str length];
  unsigned	output = 0;
  unichar	*from;
  unsigned	i = 0;
  BOOL		escape = NO;

  if (length == 0)
    {
      return str;
    }
  from = NSZoneMalloc(NSDefaultMallocZone(), sizeof(unichar) * length);
  [str getCharacters: from];

  for (i = 0; i < length; i++)
    {
      unichar	c = from[i];

      if ((c >= 0x20 && c <= 0xfffd)
	|| c == 0x9 || c == 0xd || c == 0xc || c == 0xa)
	{
	  switch (c)
	    {
	      case '"':
	      case '\'':
		output += 6;
		escape = YES;
	        break;

	      case '&':
		output += 5;
		escape = YES;
	        break;

	      case '<':
	      case '>':
		output += 4;
		escape = YES;
	        break;

              case '\f':
              case '\r':
                output += 5;
                escape = YES;
                break;

	      default:
		/*
		 * For non-ascii characters, we can use &#nnnn; escapes
		 */
		if (c > 127)
		  {
                    uint32_t    u = c;

                    /* Code to support surrogate pairs.
                     */
                    if ((u >= 0xd800) && (u < 0xdc00) && i+1 < length
                      && (c = from[i+1]) >= 0xdc00 && c <= 0xdfff)
                      {
                        i++;
                        u = ((u - 0xd800) * 0x400) + (c - 0xdc00) + 0x10000;
                      }
		    output += 5;
		    while (u >= 1000)
		      {
			output++;
			u /= 10;
		      }
		    escape = YES;
		  }
		output++;
		break;
	    }
        }
      else if (NO == _allUnicode)
	{
	  escape = YES;	// Need to remove bad characters
	}
    }

  if (escape == YES)
    {
      unichar	*to;
      unsigned	j = 0;

      to = NSZoneMalloc(NSDefaultMallocZone(), sizeof(unichar) * output);

      for (i = 0; i < length; i++)
	{
	  unichar	c = from[i];

	  if ((c >= 0x20 && c <= 0xfffd)
	    || c == 0x9 || c == 0xd || c == 0xc || c == 0xa)
	    {
	      switch (c)
		{
		  case '"':
		    to[j++] = '&';
		    to[j++] = 'q';
		    to[j++] = 'u';
		    to[j++] = 'o';
		    to[j++] = 't';
		    to[j++] = ';';
		    break;

		  case '\'':
		    to[j++] = '&';
		    to[j++] = 'a';
		    to[j++] = 'p';
		    to[j++] = 'o';
		    to[j++] = 's';
		    to[j++] = ';';
		    break;

		  case '&':
		    to[j++] = '&';
		    to[j++] = 'a';
		    to[j++] = 'm';
		    to[j++] = 'p';
		    to[j++] = ';';
		    break;

		  case '<':
		    to[j++] = '&';
		    to[j++] = 'l';
		    to[j++] = 't';
		    to[j++] = ';';
		    break;

		  case '>':
		    to[j++] = '&';
		    to[j++] = 'g';
		    to[j++] = 't';
		    to[j++] = ';';
		    break;

                  case '\f':
		    to[j++] = '&';
		    to[j++] = '#';
		    to[j++] = '1';
		    to[j++] = '2';
		    to[j++] = ';';
		    break;

                  case '\r':
		    to[j++] = '&';
		    to[j++] = '#';
		    to[j++] = '1';
		    to[j++] = '3';
		    to[j++] = ';';
		    break;

		  default:
		    if (c > 127)
		      {
                        uint32_t        u = c;
			char	        buf[16];
			char	        *ptr = buf;

			to[j++] = '&';
			to[j++] = '#';

                        /* Code to support surrogate pairs.
                         */
                        if ((u >= 0xd800) && (u < 0xdc00) && i+1 < length
                          && (c = from[i+1]) >= 0xdc00 && c <= 0xdfff)
                          {
                            i++;
                            u = ((u - 0xd800) * 0x400) + (c - 0xdc00) + 0x10000;
                          }
			sprintf(buf, "%"PRIu32, u);
			while (*ptr != '\0')
			  {
			    to[j++] = *ptr++;
			  }
			to[j++] = ';';
		      }
		    else
		      {
			to[j++] = c;
		      }
		    break;
		}
	    }
          else if (YES == _allUnicode)
            {
              to[j++] = c;
            }
	}
      str = [[NSString alloc] initWithCharacters: to length: output];
      NSZoneFree(NSDefaultMallocZone(), to);
      [str autorelease];
    }
  NSZoneFree(NSDefaultMallocZone(), from);
  return str;
}

- (void) indent
{
  _level++;
}

- (id) init
{
  if ((self = [super init]) != nil)
    {
      NSUserDefaults *dflts = [NSUserDefaults standardUserDefaults];
      _ms = [NSMutableString new];
      _stack = [NSMutableArray new];
      _nmap = [NSMutableDictionary new];
      _debug = [dflts boolForKey: @"GWSDebug"];
      _preferSloppyParser = [dflts boolForKey: @"GWSPreferSloppyParser"];
    }
  return self;
}

- (NSString*) legalXMLFrom: (NSString*)str
{
  unsigned	length = [str length];
  unsigned	output = 0;
  unichar	*from;
  unsigned	i = 0;
  BOOL		strip = NO;

  if (length == 0)
    {
      return str;
    }
  from = NSZoneMalloc(NSDefaultMallocZone(), sizeof(unichar) * length);
  [str getCharacters: from];

  for (i = 0; i < length; i++)
    {
      unichar	c = from[i];

      if ((c >= 0x20 && c <= 0xd7ff)
	|| c == 0x9 || c == 0xd || c == 0xc || c == 0xa
	|| (c >= 0xe000 && c <= 0xfffd))
	{
          output++;
	}
      else
	{
	  strip = YES;	// Need to remove bad characters
	}
    }

  if (strip == YES)
    {
      unichar	*to;
      unsigned	j = 0;

      to = NSZoneMalloc(NSDefaultMallocZone(), sizeof(unichar) * output);

      for (i = 0; i < length; i++)
	{
	  unichar	c = from[i];

	  if ((c >= 0x20 && c <= 0xd7ff)
	    || c == 0x9 || c == 0xd || c == 0xc || c == 0xa
	    || (c >= 0xe000 && c <= 0xfffd))
	    {
              to[j++] = c;
            }
	}
      str = [[NSString alloc] initWithCharacters: to length: output];
      NSZoneFree(NSDefaultMallocZone(), to);
      [str autorelease];
    }
  NSZoneFree(NSDefaultMallocZone(), from);
  return str;
}

- (NSMutableString*) mutableString
{
  return _ms;
}

- (void) nl
{
  static NSString	*indentations[] = {
    @"  ",
    @"    ",
    @"      ",
    @"\t",
    @"\t  ",
    @"\t    ",
    @"\t      ",
    @"\t\t",
    @"\t\t  ",
    @"\t\t    ",
    @"\t\t      ",
    @"\t\t\t",
    @"\t\t\t  ",
    @"\t\t\t    ",
    @"\t\t\t      ",
    @"\t\t\t\t"
  };
  if (_compact == NO)
    {
      unsigned  index;

      if (YES == _crlf)
        {
          [_ms appendString: @"\r\n"];
        }
      else
        {
          [_ms appendString: @"\n"];
        }
      if ((index = _level) > 0)
        {
          if (index > sizeof(indentations)/sizeof(*indentations))
            {
              index = sizeof(indentations)/sizeof(*indentations);
            }
          [_ms appendString: indentations[index - 1]];
        }
    }
}

- (GWSElement*) parseXML: (NSData*)xml
{
  NSAutoreleasePool     *pool       = nil;
  NSXMLParser           *parser     = nil;
  Class                 parserClass = _defaultParserClass;

  pool = [NSAutoreleasePool new];
  [self reset];
  if (_preferSloppyParser)
    {
      parserClass = _sloppyParserClass;
    }
  parser = [[[parserClass alloc] initWithData: xml] autorelease];
  [parser setShouldProcessNamespaces: YES];
  [parser setShouldReportNamespacePrefixes: YES];
  _oldparser = NO;
  if ([parser shouldProcessNamespaces] == NO
    || [parser shouldReportNamespacePrefixes] == NO)
    {
      _oldparser = YES;
    }
  [parser setDelegate: self];
  if ([parser parse] == NO)
    {
      [_stack removeAllObjects];
      if (YES == _debug)
	{
	  NSError	*e = [parser parserError];

	  NSLog(@"XML parse error %@ %@", e, [e userInfo]);
	}
    }
  [pool release];
  return [_stack lastObject];
}

- (id) parseXSI: (NSString*)type string: (NSString*)value
{
  id	result;

  if ([type length] == 0)
    {
      type = @"xsd:string";
    }

  /* Parse simple builtin types from xsd
   */
  if ([type isEqualToString: @"xsd:string"] == YES)
    {
      result = value;
    }
  else if ([type isEqualToString: @"xsd:int"] == YES
    || [type isEqualToString: @"xsd:integer"] == YES)
    {
      result = [NSNumber numberWithInt: [value intValue]];
    }
  else if ([type isEqualToString: @"xsd:boolean"] == YES)
    {
      if ([value isEqualToString: @"true"]
	|| [value isEqualToString: @"1"])
	{
	  result = boolY;
	}
      else
	{
	  result = boolN;
	}
    }
  else if ([type isEqualToString: @"xsd:base64Binary"] == YES)
    {
      result = [self decodeBase64From: value];
    }
  else if ([type isEqualToString: @"xsd:hexBinary"] == YES)
    {
      result = [self decodeHexBinaryFrom: value];
    }
  else if ([type isEqualToString: @"xsd:dateTime"] == YES
    || [type isEqualToString: @"xsd:timeInstant"] == YES)
    {
      NSTimeZone        *tz;
      const char	*s;
      int		year;
      int		month;
      int		day;
      int		hour;
      int		minute;
      int		second;
      int               milli;

      s = [value UTF8String];
      if (0 == s)
	{
	  s = "";
	}
      else if (*s == '-')
	{
	  s++;          // Leading '-' in year is ignored.
	}
      if (sscanf(s, "%d-%d-%dT%d:%d:%d",
	&year, &month, &day, &hour, &minute, &second) != 6)
	{
	  return nil;
	}
      s = strchr(s, ':');
      s++;
      s = strchr(s, ':');
      s++;
      while (isdigit(*s)) s++;
      if ('.' == *s)
        {
          s++;
          milli = atoi(s);
          while (isdigit(*s)) s++;
        }
      else
        {
          milli = 0;
        }
      if ('Z' == *s)
	{
	  tz = [NSTimeZone timeZoneForSecondsFromGMT: 0];
	}
      else if (*s == '+' || *s == '-')
        {
          int   zh;
          int   zm;
          int   zs;
          int   l = strlen(s);

          if (l < 3 || !isdigit(s[1]) || !isdigit(s[2]))
            {
              return nil;       //Bad timezone
            }

          zh = (s[1] - '0') * 10 + s[2] - '0';

          if (3 == l)
            {
              // HH (sloppy parsing allow just hour)
              zm = 0;
            }
          else if (5 == l && isdigit(s[3]) && isdigit(s[4]))
            {
              // HHMM (sloppy parsing allow missing colon)
              zm = (s[3] - '0') * 10 + s[4] - '0';
            }
          else if (6 == l && ':' == s[3]
            && isdigit(s[4]) && isdigit(s[5]))
            {
              // HH:MM (standard format)
              zm = (s[4] - '0') * 10 + s[5] - '0';
            }
          else
            {
              return nil;
            }

          zs = ((zh * 60) + zm) * 60;

          if (*s == '-')
            {
              zs = - zs;
            }
          tz = [NSTimeZone timeZoneForSecondsFromGMT: zs];
        }
      else if (0 == *s)
	{
	  tz = [self timeZone];
	}
      else
        {
          return nil;
        }

      result = [[[NSCalendarDate alloc] initWithYear: year
					       month: month
						 day: day
					        hour: hour
					      minute: minute
					      second: second 
					    timeZone: tz] autorelease]; 
      if (0 != milli)
        {
          NSTimeInterval        ti = [result timeIntervalSinceReferenceDate];

          ti += milli;
          result = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate: ti];
          [result setTimeZone: tz];
        }
    }
  else if ([type isEqualToString: @"xsd:double"] == YES)
    {
      result = [NSNumber numberWithDouble: [value doubleValue]];
    }
  else
    {
      result = value;
    }

  return result;
}

- (void) parser: (NSXMLParser *)parser
  didStartMappingPrefix: (NSString *)prefix
  toURI: uri
{
  [_nmap setObject: uri forKey: prefix];
}
  
- (void) parser: (NSXMLParser *)parser
  didEndMappingPrefix: (NSString *)prefix
{
}
  
- (void) parser: (NSXMLParser *)parser
  foundCDATA: (NSData *)data
{
  NSString      *s;

  s = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  [[_stack lastObject] addContent: s];
  [s release];
}

- (void) parser: (NSXMLParser *)parser
  foundCharacters: (NSString *)string
{
  [[_stack lastObject] addContent: string];
}

- (void) parser: (NSXMLParser *)parser
  didStartElement: (NSString *)elementName
  namespaceURI: (NSString *)namespaceURI
  qualifiedName: (NSString *)qualifiedName
  attributes: (NSDictionary *)attributeDict
{
  GWSElement    *e;

  if (_oldparser == YES)
    {
      NSRange       r;
      NSString      *prefix = @"";

      r = [elementName rangeOfString: @":" options: NSLiteralSearch];
      qualifiedName = elementName;
      if (r.length > 0)
        {
          NSEnumerator              *enumerator = [attributeDict keyEnumerator];
          NSMutableDictionary       *attr = nil;
          NSString                  *key;
          NSString                  *uri;

          prefix = [elementName substringToIndex: r.location];
          elementName = [elementName substringFromIndex: NSMaxRange(r)];

          while ((key = [enumerator nextObject]) != nil)
            {
              NSString  *name = nil;

              if ([key rangeOfString: @"xmlns"
                options: (NSLiteralSearch | NSAnchoredSearch)].length > 0)
                {
                  NSUInteger    l = [key length];

                  if (5 == l)
                    {
                      name = @"";
                    }
                  else if (6 == l && [key characterAtIndex: 5] == ':')
                    {
                      name = [key substringFromIndex: 6];
                    }
                }
              if (name != nil)
                {
                  if (attr == nil)
                    {
                      attr = [[attributeDict mutableCopy] autorelease];
                      attributeDict = attr;
                    }
                  uri = [attributeDict objectForKey: key];
                  [self parser: parser didStartMappingPrefix: name toURI: uri];
                  [attr removeObjectForKey: key];
                }
            }
        }
      /* Get the namespace URI matching the current prefix.
       * If we can't find the namespace in the declarations at this
       * level, look in the parent element and upwards.
       */
      namespaceURI = [_nmap objectForKey: prefix];
      if (namespaceURI == nil)
	{
	  unsigned	count = [_stack count];

	  if (count > 0)
	    {
	      namespaceURI = [(GWSElement*)[_stack objectAtIndex: count - 1]
		namespaceForPrefix: prefix];
	    }
	}
    }

// NSLog(@"Element is '%@'", elementName);
// NSLog(@"Namespace is '%@'", namespaceURI);
// NSLog(@"Qualified is '%@'", qualifiedName);
// NSLog(@"Attributes '%@'", attributeDict);
  e = [[GWSElement alloc] initWithName: elementName
                             namespace: namespaceURI
                             qualified: qualifiedName
                            attributes: attributeDict];

  /* If we have new namespace mappings, we add them to this element.
   */
  if ([_nmap count] > 0)
    {
      NSEnumerator      *ne = [_nmap keyEnumerator];
      NSString          *k;

      while ((k = [ne nextObject]) != nil)
        {
          [e setNamespace: [_nmap objectForKey: k] forPrefix: k];
        }
      [_nmap removeAllObjects];
    }
  [_stack addObject: e];
  [e release];
}

- (void) parser: (NSXMLParser *)parser
  didEndElement: (NSString *)elementName
  namespaceURI: (NSString *)namespaceURI
  qualifiedName: (NSString *)qName
{
  GWSElement    *top;
  unsigned      count;

  if (_oldparser == YES)
    {
      NSRange       r;

      r = [elementName rangeOfString: @":" options: NSLiteralSearch];
      if (r.length > 0)
        {
          elementName = [elementName substringFromIndex: NSMaxRange(r)];
        }
    }

// NSLog(@"End element '%@'", elementName);

  top = [_stack lastObject];
  if ([elementName isEqual: [top name]] == NO)
    {
      [NSException raise: NSInvalidArgumentException
                  format: @"Element missmatch found '%@' expecting '%@'",
                  elementName, [top name]];
    }
  if (NO == _preserveSpace)
    {
      [top condense: NO];
    }
  count = [_stack count];
  if (count > 1)
    {
      [(GWSElement*)[_stack objectAtIndex: count - 2] addChild: top];
      [_stack removeLastObject];
    }
}

- (BOOL) permitAllUnicode
{
  return _allUnicode;
}

- (BOOL) preferSloppyParser
{
  return _preferSloppyParser;
}

- (BOOL) preserveSpace
{
  return _preserveSpace;
}

- (void) reset
{
  [_ms setString: @""];
  [_stack removeAllObjects];
  [_nmap removeAllObjects];
  _level = 0;
}

- (void) setCDATA: (BOOL)flag
{
  _cdata = (flag ? YES : NO);
}

- (void) setCompact: (BOOL)flag
{
  _compact = (flag ? YES : NO);
}

- (void) setCRLF: (BOOL)flag
{
  _crlf = (flag ? YES : NO);
}

/* Much software uses integer settings for debug levels, so to selector
 * type conflicts we use the same convention even though we are using it
 * as a boolean.
 */
- (int) setDebug: (int)flag
{
  BOOL  old = _debug;

  _debug = flag ? YES : NO;
  return old;
}

- (void) setPermitAllUnicode: (BOOL)flag
{
  _allUnicode = (flag ? YES : NO);
}

- (void) setPreferSloppyParser: (BOOL)flag
{
  _preferSloppyParser = (flag ? YES : NO);
}

- (void) setPreserveSpace: (BOOL)flag
{
  _preserveSpace = (flag ? YES : NO);
}

- (void) unindent
{
  if (_level > 0)
    {
      _level--;
    }
}

@end


@implementation GWSCoder (RPC)

- (NSData*) buildFaultWithParameters: (NSDictionary*)parameters
                               order: (NSArray*)order
{
  NSData	*result = nil;
  BOOL		old = _fault;

  _fault = YES;
  NS_DURING
    {
      result = [self buildRequest: nil parameters: parameters order: order];
      _fault = NO;
    }
  NS_HANDLER
    {
      _fault = NO;
      [localException raise];
    }
  NS_ENDHANDLER
  _fault = old;
  return result;
}

- (NSData*) buildRequest: (NSString*)method 
              parameters: (NSDictionary*)parameters
                   order: (NSArray*)order
{
  [NSException raise: NSGenericException
              format: @"[%@-%@] subclass should implement this",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd)];
  return nil;
}

- (NSData*) buildResponse: (NSString*)method
               parameters: (NSDictionary*)parameters
                    order: (NSArray*)order
{
  [NSException raise: NSGenericException
              format: @"[%@-%@] subclass should implement this",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd)];
  return nil;
}

- (id) delegate
{
  return _delegate;
}

- (BOOL) fault
{
  return _fault;
}

- (NSMutableDictionary*) parseMessage: (NSData*)data
{
  [NSException raise: NSGenericException
              format: @"[%@-%@] subclass should implement this",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd)];
  return nil;
}

- (void) setDelegate: (id)delegate
{
  _delegate = delegate;
}

- (void) setFault: (BOOL)flag
{
  _fault = (flag ? YES : NO);
}

- (void) setTimeZone: (NSTimeZone*)timeZone
{
  id    o = _tz;

  [timeZone retain];
  _tz = timeZone;
  [o release];
}

- (NSTimeZone*) timeZone
{
  if (_tz == nil)
    {
      _tz = [[NSTimeZone timeZoneForSecondsFromGMT: 0] retain];
    }
  return _tz;
}

@end

@implementation NSObject (GWSCoder)
- (id) decodeWithCoder: (GWSCoder*)coder
                  item: (GWSElement*)item
                 named: (NSString*)name
{
  return nil;
}
- (BOOL) encodeWithCoder: (GWSCoder*)coder
		    item: (id)item
		   named: (NSString*)name
		      in: (GWSElement*)ctxt
{
  return NO;
}
- (NSString*) webServiceOperation
{
  return nil;
}
- (GWSPort*) webServicePort
{
  return nil;
}
@end

