/** 
   Copyright (C) 2009 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	February 2009
   
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
#import "GWSHash.h"
#import "WSSUsernameToken.h"
#include <config.h>
#include <stdlib.h>

#if     USE_NETTLE
#include <nettle/sha2.h>
#include <nettle/sha3.h>
#endif

static NSTimeZone	*gmt = nil;
static GWSCoder		*coder = nil;

@implementation	WSSUsernameToken

+ (NSString*) digestHashForPassword: (NSString*)password
		       andTimestamp: (NSCalendarDate**)date
			  withNonce: (NSString**)nonce
{
  return [self digestHashForPassword: password
		        andTimestamp: date
			   withNonce: nonce
                           algorithm: GWSDigestSHA1];
}

+ (NSString*) digestHashForPassword: (NSString*)password
		       andTimestamp: (NSCalendarDate**)date
			  withNonce: (NSString**)nonce
                          algorithm: (GWSDigestAlgorithm)algorithm
{
  NSCalendarDate	*d = (0 == date) ? nil : (id)*date;
  NSString		*n = (0 == nonce) ? nil : (id)*nonce;
  NSData		*nd;
  NSData		*pass;
  NSData		*when;
  NSData		*hash;
  NSMutableData		*hashable;

  if (nil == d)
    {
      d = [NSCalendarDate date];
      if (0 != date)
	{
	  *date = d;
	}
    }
  else if (NO == [d isKindOfClass: [NSCalendarDate class]])
    {
      const char	*s = [[d description] UTF8String];
      unsigned int	year, month, day, hour, minute, second;

      if (strlen(s) != 20 || s[4] != '-' || s[7] != '-'
	|| s[10] != 'T' || s[13] != ':' || s[16] != ':'
	|| s[19] != 'Z' || sscanf(s, "%u-%u-%uT%u:%u:%uZ",
	&year, &month, &day, &hour, &minute, &second) != 6)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"Bad timestamp (%@) argument", d];
	}
      d = [[[NSCalendarDate alloc] initWithYear: year
					  month: month
					    day: day
					   hour: hour
					 minute: minute
					 second: second
				       timeZone: gmt] autorelease];
      if (0 != date)
	{
	  *date = d;
	}
    }
  [d setTimeZone: gmt];
  [d setCalendarFormat: @"%Y-%m-%dT%H:%M:%SZ"];

  if (nil != n)
    {
      nd = [coder decodeBase64From: n];
      if ([nd length] != 16)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"Nonce does not decode to 16 bytes of data"];
	}
    }
  else
    {
      uint32_t	buf[4];

      [GWSHash salt: (uint8_t*)buf size: sizeof(buf)];
      nd = [NSData dataWithBytes: (const void*)buf length: 16];
      n = [coder encodeBase64From: nd];
      if (0 != nonce)
	{
	  *nonce = n;
	}
    }

  pass = [password dataUsingEncoding: NSUTF8StringEncoding];
  when = [[d description] dataUsingEncoding: NSUTF8StringEncoding];
  hashable = [[NSMutableData alloc] initWithCapacity:
    [nd length] + [when length] + [pass length]];
  [hashable appendData: nd];
  [hashable appendData: when];
  [hashable appendData: pass];
  switch (algorithm)
    {
      case GWSDigestSHA1: hash = [hashable SHA1]; break;
      case GWSDigestSHA2_256: hash = [hashable SHA2_256]; break;
      case GWSDigestSHA2_512: hash = [hashable SHA2_512]; break;
      case GWSDigestSHA3_256: hash = [hashable SHA3_256]; break;
      case GWSDigestSHA3_512: hash = [hashable SHA3_512]; break;
      default: hash = nil; break;
    }
  [hashable release];
  if (nil == hash)
    {
      [NSException raise: NSInvalidArgumentException
                  format: @"Uknown/unsupported hash algorithm requested"];
    }
  return [coder encodeBase64From: hash];
}

+ (void) initialize
{
  if (gmt == nil)
    {
      gmt = [[NSTimeZone timeZoneForSecondsFromGMT: 0] retain];
      coder = [GWSSOAPCoder new];
    }
}

- (GWSElement*) addToHeader: (GWSElement*)header
{
  GWSElement	*security;
  GWSElement	*token;
  GWSElement	*elem;
  NSString	*prefix;
  NSString	*uPrefix;
  NSString	*ns;
  NSString	*uns;
  NSString	*cName;
  NSString	*nName;
  NSString	*tName;
  NSString	*uName;
  NSString	*pName;

  uPrefix = nil;
  ns = @"http://docs.oasis-open.org/wss/2004/01/"
    @"oasis-200401-wss-wssecurity-secext-1.0.xsd";
  uns = @"http://docs.oasis-open.org/wss/2004/01/"
    @"oasis-200401-wss-wssecurity-utility-1.0.xsd";

  /* Try to find any existing WSS Security element in the header.
   */
  security = [header firstChild];
  while (security != nil)
    {
      if ([[security name] isEqualToString: @"Security"] == YES
	&& [[security namespace] isEqualToString: ns] == YES)
	{
	  break;
	}
      security = [security sibling];
    }

  /* Create a new security element if we didn't find one.
   */
  if (security == nil)
    {
      NSString	*qName;

      uPrefix = [header prefixForNamespace: uns];
      prefix = [header prefixForNamespace: ns];
      if ([prefix length] == 0)
	{
	  qName = @"wsse:Security";
	}
      else
	{
	  qName = [prefix stringByAppendingString: @":Security"];
	}
      security = [[GWSElement alloc] initWithName: @"Security"
					namespace: ns
					qualified: qName
				       attributes: nil];
      if ([prefix length] == 0)
	{
	  /* There is no prefix for our namespace, so we will used
	   * our default one ... 'wsse'.
	   */
	  prefix = @"wsse";

	  /* We need to set up the prefix to namespace mapping, and we
	   * prefer to do that in the top level (SOAP Envelope) if
	   * possible.
	   */
	  if ([[[header parent] name] isEqualToString: @"Envelope"])
	    {
              [[header parent] setNamespace: ns forPrefix: prefix];
	    }
	  else
	    {
              [security setNamespace: ns forPrefix: prefix];
	    }
	}
      if (_ttl > 0 && [uPrefix length] == 0)
	{
	  /* There is no prefix for our namespace, so we will used
	   * our default one ... 'wsu'.
	   */
	  uPrefix = @"wsu";

	  /* We need to set up the prefix to namespace mapping, and we
	   * prefer to do that in the top level (SOAP Envelope) if
	   * possible.
	   */
	  if ([[[header parent] name] isEqualToString: @"Envelope"])
	    {
              [[header parent] setNamespace: uns forPrefix: @"wsu"];
	    }
	  else
	    {
              [security setNamespace: uns forPrefix: @"wsu"];
	    }
	}
      if (header == nil)
	{
          header = security;
          [security autorelease];
	}
      else
	{
	  [header addChild: security];
	  [security release];
	}
    }
    
  if ([uPrefix isEqualToString: @"wsu"] == YES)
    {
      cName = @"wsu:Created";
    }
  else
    {
      cName = [NSString stringWithFormat: @"%@:Created", uPrefix];
    }

  prefix = [security prefix];
  if ([prefix isEqualToString: @"wsse"] == YES)
    {
      nName = @"wsse:Nonce";
      tName = @"wsse:UsernameToken";
      uName = @"wsse:Username";
      pName = @"wsse:Password";
    }
  else
    {
      nName = [NSString stringWithFormat: @"%@:Nonce", prefix];
      tName = [NSString stringWithFormat: @"%@:UsernameToken", prefix];
      uName = [NSString stringWithFormat: @"%@:Username", prefix];
      pName = [NSString stringWithFormat: @"%@:password", prefix];
    }

  token = [[GWSElement alloc] initWithName: @"UsernameToken"
				 namespace: ns
				 qualified: tName
				attributes: nil];
  [security addChild: token];
  [token release];

  elem = [[GWSElement alloc] initWithName: @"Username"
				namespace: ns
				qualified: uName
			       attributes: nil];
  [token addChild: elem];
  [elem release];
  [elem addContent: _name];

  if (_ttl > 0)
    {
      NSMutableDictionary	*attr;
      NSString			*hash;
      
      [_created release];
      _created = nil;
      [_nonce release];
      _nonce = nil;
      hash = [[self class] digestHashForPassword: _password
				    andTimestamp: &_created
				       withNonce: &_nonce
                                       algorithm: _algorithm];
      [_created retain];
      [_nonce retain];

      attr = [[NSMutableDictionary alloc] initWithCapacity: 1];
      [attr setObject: @"#PasswordDigest" forKey: @"Type"];
      elem = [[GWSElement alloc] initWithName: @"Password"
				    namespace: ns
				    qualified: pName
				   attributes: attr];
      [attr release];
      [elem addContent: hash];
      [token addChild: elem];
      [elem release];

      elem = [[GWSElement alloc] initWithName: @"Nonce"
				    namespace: ns
				    qualified: nName
				   attributes: nil];
      [elem addContent: _nonce];
      [token addChild: elem];
      [elem release];

      elem = [[GWSElement alloc] initWithName: @"Created"
				    namespace: uns
				    qualified: cName
				   attributes: nil];
      [elem addContent: [_created description]];
      [token addChild: elem];
      [elem release];
    }
  else
    {
      elem = [[GWSElement alloc] initWithName: @"Password"
				    namespace: ns
				    qualified: pName
				   attributes: nil];
      [elem addContent: _password];
      [token addChild: elem];
      [elem release];
    }

  return header;
}

- (GWSDigestAlgorithm) algorithm
{
  return _algorithm;
}

- (void) dealloc
{
  [_name release];
  [_password release];
  [_created release];
  [_nonce release];
  [super dealloc];
}

- (id) init
{
  [self release];
  return nil;
}

- (id) initWithName: (NSString*)name password: (NSString*)password
{
  return [self initWithName: name password: password timeToLive: 0];
}

- (id) initWithName: (NSString*)name
	   password: (NSString*)password
	 timeToLive: (unsigned)ttl
{
  if (nil != (self = [super init]))
    {
      _algorithm = GWSDigestSHA1;
      _name = [name copy];
      _password = [password copy];
      _ttl = ttl;
    }
  return self;
}

- (void) setAlgorithm: (GWSDigestAlgorithm)algorithm
{
  _algorithm = algorithm;
}

- (GWSElement*) tree
{
  return [self addToHeader: nil];
}
@end


@implementation	NSData (GWSDigest)
/* SHA1 based on original public domain code by Steve Reid
 */

typedef struct
{
  uint32_t A;
  uint32_t B;
  uint32_t C;
  uint32_t D;
  uint32_t E;
  uint32_t L;           // Low order byte count
  uint32_t H;           // High order byte count
  uint8_t T[64];        // Temporary buffer
} Ctxt;

static inline uint32_t
GetWord(const uint8_t *b)
{
  return ((((((b[0] << 8) + b[1]) << 8) + b[2]) << 8) + b[3]);
}

static inline void
PutWord(uint32_t w, uint8_t *b)
{                                                       \
  b[3] = (uint8_t)w;
  w >>= 8;
  b[2] = (uint8_t)w;
  w >>= 8;
  b[1] = (uint8_t)w;
  w >>= 8;
  b[0] = (uint8_t)w;
}

static void
Initialize(Ctxt *ctx)
{
  ctx->L = 0;
  ctx->H = 0;
  ctx->A = 0x67452301;
  ctx->B = 0xEFCDAB89;
  ctx->C = 0x98BADCFE;
  ctx->D = 0x10325476;
  ctx->E = 0xC3D2E1F0;
}

static void
AddBlock(Ctxt *ctx, const uint8_t data[64])
{
  uint32_t      T, W[16], A, B, C, D, E;

  W[0] = GetWord(data + 0);
  W[1] = GetWord(data + 4);
  W[2] = GetWord(data + 8);
  W[3] = GetWord(data + 12);
  W[4] = GetWord(data + 16);
  W[5] = GetWord(data + 20);
  W[6] = GetWord(data + 24);
  W[7] = GetWord(data + 28);
  W[8] = GetWord(data + 32);
  W[9] = GetWord(data + 36);
  W[10] = GetWord(data + 40);
  W[11] = GetWord(data + 44);
  W[12] = GetWord(data + 48);
  W[13] = GetWord(data + 52);
  W[14] = GetWord(data + 56);
  W[15] = GetWord(data + 60);

  A = ctx->A;
  B = ctx->B;
  C = ctx->C;
  D = ctx->D;
  E = ctx->E;

#define S(X,N) ((X<<N) | ((X&0xFFFFFFFF) >> (32-N)))

#define R(X) \
(T = W[(X-3)&0x0F]^W[(X-8)&0x0F]^W[(X-14)&0x0F]^W[X&0x0F],(W[X&0x0F]=S(T,1)))

#define P(A,B,C,D,E,X) { E += S(A,5) + F(B,C,D) + K + X; B = S(B,30); }

#define F(X,Y,Z) (Z ^ (X & (Y ^ Z)))
#define K 0x5A827999

  P(A, B, C, D, E, W[0]);
  P(E, A, B, C, D, W[1]);
  P(D, E, A, B, C, W[2]);
  P(C, D, E, A, B, W[3]);
  P(B, C, D, E, A, W[4]);
  P(A, B, C, D, E, W[5]);
  P(E, A, B, C, D, W[6]);
  P(D, E, A, B, C, W[7]);
  P(C, D, E, A, B, W[8]);
  P(B, C, D, E, A, W[9]);
  P(A, B, C, D, E, W[10]);
  P(E, A, B, C, D, W[11]);
  P(D, E, A, B, C, W[12]);
  P(C, D, E, A, B, W[13]);
  P(B, C, D, E, A, W[14]);
  P(A, B, C, D, E, W[15]);
  P(E, A, B, C, D, R(16));
  P(D, E, A, B, C, R(17));
  P(C, D, E, A, B, R(18));
  P(B, C, D, E, A, R(19));

#undef K
#undef F

#define F(X,Y,Z) (X ^ Y ^ Z)
#define K 0x6ED9EBA1

  P(A, B, C, D, E, R(20));
  P(E, A, B, C, D, R(21));
  P(D, E, A, B, C, R(22));
  P(C, D, E, A, B, R(23));
  P(B, C, D, E, A, R(24));
  P(A, B, C, D, E, R(25));
  P(E, A, B, C, D, R(26));
  P(D, E, A, B, C, R(27));
  P(C, D, E, A, B, R(28));
  P(B, C, D, E, A, R(29));
  P(A, B, C, D, E, R(30));
  P(E, A, B, C, D, R(31));
  P(D, E, A, B, C, R(32));
  P(C, D, E, A, B, R(33));
  P(B, C, D, E, A, R(34));
  P(A, B, C, D, E, R(35));
  P(E, A, B, C, D, R(36));
  P(D, E, A, B, C, R(37));
  P(C, D, E, A, B, R(38));
  P(B, C, D, E, A, R(39));

#undef K
#undef F

#define F(X,Y,Z) ((X & Y) | (Z & (X | Y)))
#define K 0x8F1BBCDC

  P(A, B, C, D, E, R(40));
  P(E, A, B, C, D, R(41));
  P(D, E, A, B, C, R(42));
  P(C, D, E, A, B, R(43));
  P(B, C, D, E, A, R(44));
  P(A, B, C, D, E, R(45));
  P(E, A, B, C, D, R(46));
  P(D, E, A, B, C, R(47));
  P(C, D, E, A, B, R(48));
  P(B, C, D, E, A, R(49));
  P(A, B, C, D, E, R(50));
  P(E, A, B, C, D, R(51));
  P(D, E, A, B, C, R(52));
  P(C, D, E, A, B, R(53));
  P(B, C, D, E, A, R(54));
  P(A, B, C, D, E, R(55));
  P(E, A, B, C, D, R(56));
  P(D, E, A, B, C, R(57));
  P(C, D, E, A, B, R(58));
  P(B, C, D, E, A, R(59));

#undef K
#undef F

#define F(X,Y,Z) (X ^ Y ^ Z)
#define K 0xCA62C1D6

  P(A, B, C, D, E, R(60));
  P(E, A, B, C, D, R(61));
  P(D, E, A, B, C, R(62));
  P(C, D, E, A, B, R(63));
  P(B, C, D, E, A, R(64));
  P(A, B, C, D, E, R(65));
  P(E, A, B, C, D, R(66));
  P(D, E, A, B, C, R(67));
  P(C, D, E, A, B, R(68));
  P(B, C, D, E, A, R(69));
  P(A, B, C, D, E, R(70));
  P(E, A, B, C, D, R(71));
  P(D, E, A, B, C, R(72));
  P(C, D, E, A, B, R(73));
  P(B, C, D, E, A, R(74));
  P(A, B, C, D, E, R(75));
  P(E, A, B, C, D, R(76));
  P(D, E, A, B, C, R(77));
  P(C, D, E, A, B, R(78));
  P(B, C, D, E, A, R(79));

#undef K
#undef F

  ctx->A += A;
  ctx->B += B;
  ctx->C += C;
  ctx->D += D;
  ctx->E += E;
}

static void
AddBytes(Ctxt *ctx, const uint8_t *input, uint32_t length)
{
  if (length > 0)
    {
      uint32_t  fill;
      uint32_t  left;

      left = ctx->L & 0x3F;
      fill = 64 - left;

      ctx->L += length;
      if (ctx->L < length)
        {
          ctx->H++;
        }

      if (left > 0 && length >= fill)
        {
          memcpy(ctx->T + left, input, fill);
          AddBlock(ctx, ctx->T);
          input += fill;
          length -= fill;
          left = 0;
        }

      while (length >= 64)
        {
          AddBlock(ctx, input);
          input += 64;
          length -= 64;
        }

      if (length > 0)
        {
          memcpy(ctx->T + left, input, length);
        }
    }
}

static void
Digest(Ctxt *ctx, uint8_t output[20])
{
  static const uint8_t Padding[64] = {
   0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  };
  uint32_t last, padn;
  uint32_t high, low;
  uint8_t msglen[8];

  /* Get length of data in *bits* and store that in big endian order.
   */
  high = (ctx->L >> 29) | (ctx->H << 3);
  low  = (ctx->L << 3);
  PutWord(high, msglen);
  PutWord(low, msglen + 4);

  /* Pad to block length - eight bytes, using a single set bit and
   * otherwise all zeros.
   */
  last = ctx->L & 0x3F;
  padn = (last < 56) ? (56 - last) : (120 - last);
  AddBytes(ctx, (uint8_t *) Padding, padn);

  /* Fill to the end of the block with the message length.
   */
  AddBytes(ctx, msglen, 8);

  /* Put the results in the output buffer.
   */
  PutWord(ctx->A, output);
  PutWord(ctx->B, output + 4);
  PutWord(ctx->C, output + 8);
  PutWord(ctx->D, output + 12);
  PutWord(ctx->E, output + 16);
}


- (NSData*) SHA1
{
  Ctxt		ctx;
  uint8_t	output[20];

  Initialize(&ctx);
  AddBytes(&ctx, [self bytes], [self length]);
  Digest(&ctx, output);
  return [NSData dataWithBytes: output length: 20];
}

#if     USE_NETTLE
- (NSData*) SHA2_256
{
  struct sha256_ctx ctx;
  uint8_t	output[32];

  sha256_init(&ctx);
  sha256_update(&ctx, [self length], [self bytes]);
  sha256_digest(&ctx, sizeof(output), output);

  return [NSData dataWithBytes: output length: sizeof(output)];
}
- (NSData*) SHA2_512
{
  struct sha512_ctx ctx;
  uint8_t	output[64];

  sha512_init(&ctx);
  sha512_update(&ctx, [self length], [self bytes]);
  sha512_digest(&ctx, sizeof(output), output);

  return [NSData dataWithBytes: output length: sizeof(output)];
}
- (NSData*) SHA3_256
{
  struct sha3_256_ctx ctx;
  uint8_t	output[32];

  sha3_256_init(&ctx);
  sha3_256_update(&ctx, [self length], [self bytes]);
  sha3_256_digest(&ctx, sizeof(output), output);

  return [NSData dataWithBytes: output length: sizeof(output)];
}
- (NSData*) SHA3_512
{
  struct sha3_512_ctx ctx;
  uint8_t	output[64];

  sha3_512_init(&ctx);
  sha3_512_update(&ctx, [self length], [self bytes]);
  sha3_512_digest(&ctx, sizeof(output), output);

  return [NSData dataWithBytes: output length: sizeof(output)];
}
#else
- (NSData*) SHA2_256
{
  return nil;
}
- (NSData*) SHA2_512
{
  return nil;
}
- (NSData*) SHA3_256
{
  return nil;
}
- (NSData*) SHA3_512
{
  return nil;
}
#endif

@end

