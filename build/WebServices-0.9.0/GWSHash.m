/** 
   Copyright (C) 2013-2014 Free Software Foundation, Inc.
   
   Written by:  Niels Grewe <niels.grewe@halbordnung.de>
   Date:	May 2013
   
   This file is part of the WebServices Library. The JSON serialisation
   part of this file was written by David Chisnall for the GNUstep
   Base library. It has been modified to support stable serialisations
   for hashing.

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

   */ 
#define GWSHash_INTERNAL
#import "GWSPrivate.h"
#import "GWSHash.h"
#import "GWSConstants.h"
#import "GWSCoder.h"
#import "WSSUsernameToken.h"
#import <Foundation/NSDate.h>
#import <Foundation/NSDateFormatter.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSDictionary.h>
#ifdef GNUSTEP
#import <GNUstepBase/NSData+GNUstepBase.h>
#endif

#include "config.h"
#include <unistd.h>
#include <fcntl.h>

#if  USE_GNUTLS == 1
#include <gnutls/gnutls.h>
#include <gnutls/crypto.h>
#endif
#if     defined(__cplusplus)
extern "C" {
#endif

NSString* const kGWSHashSHA512 = @"SHA-512";
NSString* const kGWSHashSSHA512 = @"SSHA-512";
NSString* const kGWSHashSHA256 = @"SHA-256";
NSString* const kGWSHashSSHA256 = @"SSHA-256";
NSString* const kGWSHashSHA1 = @"SHA";
NSString* const kGWSHashSSHA1 = @"SSHA";
NSString* const kGWSHashMD5 = @"MD5";
NSString* const kGWSHashSMD5 = @"SMD5";

static BOOL
writeObject(id obj, NSMutableString *output);

static NSArray* algorithms = nil;

#define HASH_LENGTH_MATCH(hash, specified, method, len) \
  (((method == specified) \
    || [method isEqualToString: specified]) \
    && ([theHash length] == len))

#define IS_METHOD(method, specified) \
  (((kGWSHash ## specified == method) \
   || [kGWSHash ## specified isEqualToString: method]) \
   || ((kGWSHashS ## specified == method) \
   || [kGWSHashS ## specified isEqualToString: method])) 



#ifdef __clang__
#define FOR_IN(type, var, collection) \
  for (type var in collection)\
   {
#define END_FOR_IN(collection) }
#else
#define FOR_IN(type, var, collection) \
  NSEnumerator* collection ## Enumerator = [collection objectEnumerator];\
  type var = nil; \
  while (nil != (var = [collection ## Enumerator nextObject]))\
   {

#define END_FOR_IN(collection) }
#endif

static Class NSArrayClass;
static Class NSDateClass;
static Class NSDataClass;
static Class NSDictionaryClass;
static Class NSMutableDictionaryClass;
static Class NSNullClass;
static Class NSNumberClass;
static Class NSStringClass;
static id boolN;
static id boolY;

static inline BOOL isSalted(NSString *method)
{
  return ((method == kGWSHashSMD5)
   || (method == kGWSHashSSHA1)
   || (method == kGWSHashSSHA256)
   || (method == kGWSHashSSHA512)
   || [method isEqualToString: kGWSHashSMD5]
   || [method isEqualToString: kGWSHashSSHA1]
   || [method isEqualToString: kGWSHashSSHA256]
   || [method isEqualToString: kGWSHashSSHA512]);
}

static BOOL
writeJSON(id obj, NSMutableString *output, NSArray* order);

static inline BOOL
writeDictionary(NSDictionary* dict, NSMutableString *output, NSArray* order)
{
  if (nil == order)
    {
      order = [dict objectForKey: GWSOrderKey];
    }

  if (nil == order)
    {
      order = [[dict allKeys] sortedArrayUsingSelector: @selector(compare:)];
    }
  if ([dict isKindOfClass: NSMutableDictionaryClass] 
    && (nil == [dict objectForKey: GWSOrderKey])) 
    {
      [(NSMutableDictionary*)dict setObject: order forKey: GWSOrderKey];
    }
  BOOL writeComma = NO;
  [output appendString: @"{"];
  FOR_IN(id, o, order)
    // Keys in dictionaries must be strings
    if (![o isKindOfClass: NSStringClass]) { return NO; }
    // Skip the order key
    if ((GWSOrderKey == o) || [GWSOrderKey isEqualToString: o])
      {
        continue;
      }
    if (writeComma)
      {
        [output appendString: @","];
      }
    writeComma = YES;
    writeObject(o, output);
    [output appendString: @":"];
    writeObject([dict objectForKey: o], output);
  END_FOR_IN(obj)
  [output appendString: @"}"];
  return YES;
}

static BOOL
writeObject(id obj, NSMutableString *output)
{
  return writeJSON(obj, output, nil);
}

static BOOL
writeJSON(id obj, NSMutableString *output, NSArray* order)
{
  if ([obj isKindOfClass: NSArrayClass])
    {
      BOOL writeComma = NO;
      [output appendString: @"["];
      FOR_IN(id, o, obj)
        if (writeComma)
          {
            [output appendString: @","];
          }
        writeComma = YES;
        writeObject(o, output);
      END_FOR_IN(obj)
      [output appendString: @"]"];
    }
  else if ([obj isKindOfClass: NSDictionaryClass])
    {
      writeDictionary(obj, output, order);
    }
  else if ([obj isKindOfClass: NSStringClass])
    {
      NSString  *str = (NSString*)obj;
      unsigned	length = [str length];

      if (length == 0)
        {
          [output appendString: @"\"\""];
        }
      else
        {
          unsigned	size = 2;
          unichar	*from;
          unsigned	i = 0;
          unichar	*to;
          unsigned	j = 0;

          from = NSZoneMalloc (NSDefaultMallocZone(), sizeof(unichar) * length);
          [str getCharacters: from];

          for (i = 0; i < length; i++)
            {
              unichar	c = from[i];

              if (c == '"' || c == '\\' || c == '\b'
                || c == '\f' || c == '\n' || c == '\r' || c == '\t')
                {
                  size += 2;
                }
              else if (c < 0x20)
                {
                  size += 6;
                }
              else
                {
                  size++;
                }
            }

          to = NSZoneMalloc (NSDefaultMallocZone(), sizeof(unichar) * size);
          to[j++] = '"';
          for (i = 0; i < length; i++)
            {
              unichar	c = from[i];

              if (c == '"' || c == '\\' || c == '\b'
                || c == '\f' || c == '\n' || c == '\r' || c == '\t')
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
              else if (c < 0x20)
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
          str = [[NSStringClass alloc] initWithCharacters: to length: size];
          NSZoneFree (NSDefaultMallocZone (), to);
          NSZoneFree (NSDefaultMallocZone (), from);
          [output appendString: str];
          [str release];
        }
    }
  else if (obj == boolN) 
    {
      [output appendString: @"false"];
    }
  else if (obj == boolY) 
    {
      [output appendString: @"true"];
    }
  else if ([obj isKindOfClass: NSNumberClass])
    {
      [output appendFormat: @"%g", [obj doubleValue]];
    }
  else if ([obj isKindOfClass: NSNullClass])
    {
      [output appendString: @"null"];
    }
  else if ([obj isKindOfClass: NSDateClass])
    {
      static NSDateFormatter* formatter = nil;
 
      if (nil == formatter) 
        {
          formatter = [[NSDateFormatter alloc] init];
          [formatter setTimeStyle: NSDateFormatterFullStyle];
          [formatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ssZ"];
        }
      [output appendString: [formatter stringFromDate: obj]];
    }
  else if ([obj isKindOfClass: NSDataClass])
    {
      writeObject([[GWSCoder coder] encodeBase64From: obj], output);
    }
  else
    {
      // Mimick GWSCoder behaviour
      return writeObject([obj description], output);
    }
  return YES;
}

static inline NSString* generateSalt(NSUInteger length)
{
  uint8_t stack[32];
  void *buffer;

  if (length <= 32)
    {
      // Use the stack as a buffer
      buffer = &stack[0];
    }
  else 
    {
      buffer = malloc(length);
      if (NULL == buffer)
	{
	  [NSException raise: NSMallocException
	              format: @"Out of memory when allocating buffer for RNG"];
	}
    }
  [GWSHash salt: buffer size: length];
  NSString *salt = [[GWSCoder coder] encodeHexBinaryFrom: 
    [NSData dataWithBytesNoCopy: buffer length: length freeWhenDone: NO]];
  if (length > 32)
    {
      free(buffer);
    }
  return [salt lowercaseString];
}


#if USE_GNUTLS == 1
#define computeDigest(alg, dataToHash)\
  computeDigestGnuTLS(alg, dataToHash)
#define computeHMAC(alg, dataToHash, key)\
   computeHMACGnuTLS(alg, dataToHash, key)


static NSData*
computeDigestGnuTLS(NSString *algorithm, NSData *data)
{
  const void* input = [data bytes];
  NSUInteger length = [data length];
  NSData *hash = nil;
  uint8_t buffer[64]; // 64 bytes is the largest size we need.

  if (IS_METHOD(algorithm, SHA256))
    {
      if (gnutls_hash_fast(GNUTLS_DIG_SHA256, input, length, &buffer[0]) == 0)
        {
          hash = [NSData dataWithBytes: &buffer[0] length: 32];
        }
    }
  else if (IS_METHOD(algorithm, SHA512))
    {
      if (gnutls_hash_fast(GNUTLS_DIG_SHA512, input, length, &buffer[0]) == 0)
        {
          hash = [NSData dataWithBytes: &buffer[0] length: 64];
        }
    }
  else if (IS_METHOD(algorithm, SHA1))
    {
      if (gnutls_hash_fast(GNUTLS_DIG_SHA1, input, length, &buffer[0]) == 0)
        {
          hash = [NSData dataWithBytes: &buffer[0] length: 20];
        }
    }
  else if (IS_METHOD(algorithm, MD5))
    { 
      if (gnutls_hash_fast(GNUTLS_DIG_MD5, input, length, &buffer[0]) == 0)
        {
          hash = [NSData dataWithBytes: &buffer[0] length: 16];
        }
    }
  return hash;
}


static NSData*
computeHMACGnuTLS(NSString *algorithm, NSData *data, NSData *key)
{
  const void* input = [data bytes];
  NSUInteger length = [data length];
  const void* inKey = [key bytes];
  NSUInteger keyLen = [key length];
  NSData *hash = nil;
  uint8_t buffer[64]; // 64 bytes is the largest size we need.

  if (IS_METHOD(algorithm, SHA256))
    {
      if (gnutls_hmac_fast(GNUTLS_MAC_SHA256,
        inKey, keyLen, input, length, &buffer[0]) == 0)
        {
          hash = [NSData dataWithBytes: &buffer[0] length: 32];
        }
    }
  else if (IS_METHOD(algorithm, SHA512))
    {
      if (gnutls_hmac_fast(GNUTLS_MAC_SHA512,
        inKey, keyLen, input, length, &buffer[0]) == 0)
        {
          hash = [NSData dataWithBytes: &buffer[0] length: 64];
        }
    }
  else if (IS_METHOD(algorithm, SHA1))
    {
      if (gnutls_hmac_fast(GNUTLS_MAC_SHA1,
        inKey, keyLen, input, length, &buffer[0]) == 0)
        {
          hash = [NSData dataWithBytes: &buffer[0] length: 20];
        }
    }
  else if (IS_METHOD(algorithm, MD5))
    { 
      if (gnutls_hmac_fast(GNUTLS_MAC_MD5,
        inKey, keyLen, input, length, &buffer[0]) == 0)
        {
          hash = [NSData dataWithBytes: &buffer[0] length: 16];
        }
    }    
  return hash;
}
#else

  #define computeDigest(alg, dataToHash)\
  computeDigestInternal(alg, dataToHash)
#define computeHMAC(alg, dataToHash, key)\
  computeHMACInternal(alg, dataToHash, key)

static NSData*
computeDigestInternal(NSString *algorithm, NSData *data)
{
  NSData *hash = nil;

  if (IS_METHOD(algorithm, SHA1))
    {
      hash = [data SHA1];
    }
  else if (IS_METHOD(algorithm, MD5))
    { 
#ifdef GNUSTEP
      hash = [data md5Digest]; 
#else
      [NSException raise: NSInvalidArgumentException
                  format: @"MD5 generation disabled."];
#endif
    }

  return hash;
}

static NSData*
computeHMACInternal(NSString* algorithm, NSData* message, NSData* key)
{
  [NSException raise: NSInvalidArgumentException
              format: @"HMAC generation disabled."];
  return nil;
} 
#endif

static NSString*
getStringToHash(NSString *method, id rpcID, 
  NSDictionary *parameters, NSArray* order, NSString *extra, NSString *salt)
{
  NSMutableString *output = [NSMutableString string];

  if (nil != salt)
    {
      [output appendString: salt];
    }
  [output appendString: method];
  if (nil != rpcID)
    {
      if ([rpcID isKindOfClass: NSNumberClass])
        {
          [output appendFormat: @"%g", [rpcID doubleValue]];
        }
      else if ([rpcID isKindOfClass: NSStringClass])
        {
          [output appendString: rpcID];
        }
      else
        {
          [output appendString: [rpcID description]];
        }
    }
  if (NO == writeJSON(parameters, output, order))
    {
       NSLog(@"Could not serialise parameters");
       return nil;
    }
  NSDebugFLog(@"Created the following string to hash: %@ "
              @"(plus %ld characters from secret string)", output, (long int)[extra length]);
  [output appendString: extra];
  return output;
}


@implementation GWSHash

+ (NSData*) computeDigest: (NSString*)hashAlgorithm
                     from: (NSData*)data
{
  return computeDigest(hashAlgorithm, data);
}

+ (NSData*) computeHMAC: (NSString*)hashAlgorithm
                   from: (NSData*)data
                    key: (NSData*)key
{
  return computeHMAC(hashAlgorithm, data, key);
}

+ (void) initialize
{
  if ([GWSHash class] == self)
    {
      algorithms = [[NSArray alloc] initWithObjects: kGWSHashMD5,
        kGWSHashSMD5, kGWSHashSHA1, kGWSHashSSHA1, 
        kGWSHashSHA256, kGWSHashSSHA256,
        kGWSHashSHA512, kGWSHashSSHA512, nil];
      NSNullClass = [NSNull class];
      NSArrayClass = [NSArray class];
      NSStringClass = [NSString class];
      NSDictionaryClass = [NSDictionary class];
      NSMutableDictionaryClass = [NSMutableDictionary class];
      NSNumberClass = [NSNumber class];
      NSDateClass = [NSDate class];
      NSDataClass = [NSData class];
      boolN = [[NSNumber alloc] initWithBool: NO];
      boolY = [[NSNumber alloc] initWithBool: YES];
    }
}

- (NSString*) hashAlgorithm
{
  return method;
}

- (NSString*) salt
{
  return salt;
}

- (NSString*) hashValue
{
  return hash;
}

- (NSString*) stringValue
{
  return [self description];
}

- (NSString*) description
{
  return [NSString stringWithFormat: @"{%@}%@%@",
    method, hash, (salt) ? (NSString*)salt : (NSString*)@""];
}

- (id) initWithAlgorithm: (NSString*)algorithm
                    hash: (NSString*)theHash
                    salt: (NSString*)theSalt
{
  if (nil == (self = [super init]))
    {
      return nil;
    }
  if (NO == [algorithms containsObject: algorithm])
    {
      algorithm = [algorithm uppercaseString];
      if (NO == [algorithms containsObject: algorithm])
        {
          NSDebugMLog(@"No such algorithm (%@)", algorithm);
          [self release];
          return nil;
        }
    }
  // Make sure we use the constant version
  method = [[algorithms objectAtIndex: [algorithms indexOfObject: algorithm]]
   retain];
  // Check whether the hash length is sane
  if (NO == 
    (HASH_LENGTH_MATCH(theHash, method, kGWSHashSHA1, 40)
    || HASH_LENGTH_MATCH(theHash, method, kGWSHashSSHA1, 40)
    || HASH_LENGTH_MATCH(theHash, method, kGWSHashSHA256, 64)
    || HASH_LENGTH_MATCH(theHash, method, kGWSHashSSHA256, 64)
    || HASH_LENGTH_MATCH(theHash, method, kGWSHashSHA512, 128)
    || HASH_LENGTH_MATCH(theHash, method, kGWSHashSSHA512, 128)
    || HASH_LENGTH_MATCH(theHash, method, kGWSHashMD5, 32)
    || HASH_LENGTH_MATCH(theHash, method, kGWSHashSMD5, 32)))
    {
      NSDebugMLog(@"Length of hash (%ld) invalid for %@",
                  (long int)[theHash length], algorithm);
      [self release];
      return nil;
    }
  hash = [[theHash lowercaseString] copy];
  salt = [[theSalt lowercaseString] copy];
  return self;
}


- (id) copyWithZone: (NSZone*)zone
{
  return [[GWSHash allocWithZone: zone] initWithAlgorithm: method
                                                     hash: hash
                                                     salt: salt]; 
}

- (NSUInteger) hash
{
  return [[self description] hash];
}

- (BOOL) isEqual: (id)obj
{
  if ([obj isKindOfClass: [GWSHash class]])
    {
      return [[self description] isEqual: [obj description]];
    }
  return [super isEqual: obj];
}

- (void) dealloc
{
  [method release];
  [hash release];
  [salt release];
  [super dealloc];
}

+ (GWSHash*) hashWithString: (NSString*)string
{
  if (nil == string)
    {
      return nil;
    }
  NSScanner *scanner = [NSScanner scannerWithString: string];
  NSInteger strLen = [string length];
  NSInteger hashLen = 0;
  NSString *method = nil;
  NSString *hash = nil;
  NSString *salt = nil;;

  if (NO == [scanner scanString: @"{" intoString: NULL])
    {
      return nil;
    }
  if ([scanner scanUpToString: @"}" intoString: &method])
    {
      // Special case '{foo' will evaluate as yes, but is in fact invalid.
      if ([scanner isAtEnd])
        {
          return nil;
        }
    }
  else
    {
      return nil;
    }
  if (NO == [scanner scanString: @"}" intoString: NULL])
    {
      return nil;
    }
  if (nil == method)
    {
      return nil;
    }

  if (IS_METHOD(method, MD5))
    {
      hashLen = 32;
    }
  else if (IS_METHOD(method, SHA1))
    {
      hashLen = 40;
    }
  else if (IS_METHOD(method, SHA256))
    {
      hashLen = 64;
    }
  else if (IS_METHOD(method, SHA512))
    {
      hashLen = 128;
    }
  NSInteger loc = [scanner scanLocation];
  if ((strLen - loc) < hashLen)
    {
      return nil;
    }
  hash = [string substringWithRange: NSMakeRange(loc, hashLen)];
  if (strLen > (loc + hashLen))
    {
      salt = [string substringFromIndex: (loc + hashLen)];
    } 
  return [[[GWSHash alloc] initWithAlgorithm: method
                                        hash: hash
                                        salt: salt] autorelease];
}

+ (GWSHash*) hashWithAlgorithm: (NSString*)hashAlgorithm
                        method: (NSString*)rpcMethod
                    parameters: (NSDictionary*)parameters
                         order: (NSArray*)order
                         extra: (id)additionalValue
			asHMAC: (BOOL)extraIsKey
{
  NSDictionary *dict = [parameters objectForKey: GWSFaultKey];
  NSArray *o = [parameters objectForKey: GWSOrderKey];
  id rpcID = [parameters objectForKey: GWSRPCIDKey];
  NSString *salt = nil;

  if (isSalted(hashAlgorithm))
    {
      salt = generateSalt(32);
    }
  if (nil == dict)
    {
      dict = [parameters objectForKey: GWSParametersKey];
    }
  if (nil == dict)
    {
      dict = parameters;
    }
  if (o == nil)
    {
      o = order;
    }
   
  NSString      *toHash = getStringToHash(rpcMethod, rpcID,
    dict, o, (extraIsKey) ? nil : additionalValue, salt);
  NSString      *hash = nil;
  NSData        *data = [toHash dataUsingEncoding: NSUTF8StringEncoding];
  if (extraIsKey)
    {
      hash = [[GWSCoder coder] encodeHexBinaryFrom:
        computeHMAC(hashAlgorithm, data, additionalValue)];
    }
  else
    {
      hash = [[GWSCoder coder] encodeHexBinaryFrom:
        computeDigest(hashAlgorithm, data)];
    }
  return [[[GWSHash alloc] initWithAlgorithm: hashAlgorithm
                                        hash: hash
                                        salt: salt] autorelease];
}

+ (void) salt: (uint8_t*)buffer size: (unsigned)length
{
  unsigned      pos = 0;

#if  USE_GNUTLS == 1
  if (0 == gnutls_rnd(GNUTLS_RND_NONCE, buffer, length))
    {
      pos = length;     // We managed to get data from gnutls
    }
#endif

  if (pos < length)
    {
      int       desc;

      /* Try to read random data from /dev/urandom ... the preferred
       * source for cryptographically random data.
       */
      if ((desc = open("/dev/urandom", O_RDONLY)) > 0)
        {
          while (pos < length)
            {
              ssize_t result = read(desc, buffer + pos, length - pos);

              if (result < 0)
                {
                  break;    // Failed to read random data
                }
              pos += (unsigned)result;
            }
          close(desc);
        }
    }

  if (pos < length)
    {
      uint32_t  r;

#ifdef __MINGW__
#define RANDOM()   rand()
#define SRANDOM(s)  srand(s)
#else
#define RANDOM()   random()
#define SRANDOM(s)  srandom(s)
#endif

      /* Anything we couldn't get from /dev/urandom comes from the C library
       * pseudo-random data function instead.
       */
      SRANDOM((unsigned)[[NSDate date] timeIntervalSinceReferenceDate]);
      while (length - pos >= 4)
        {
          r = (uint32_t)RANDOM();
          memcpy(buffer + pos, &r, 4);
          pos += 4;
        }
      if (pos < length)
        {
          r = (uint32_t)RANDOM();
          memcpy(buffer + pos, &r, length - pos);
        }
    }
}

- (BOOL) verifyWithParameters: (NSDictionary*)parameters
                        order: (NSArray*)order
                        extra: (id)additionalValue
		       asHMAC: (BOOL)extraIsKey
                    excluding: (NSString*)hashKey
		   
{
  NSDictionary *dict = [parameters objectForKey: GWSFaultKey];
  NSString *rpcMethod = [parameters objectForKey: GWSMethodKey];
  NSArray *o = [parameters objectForKey: GWSOrderKey];
  id rpcID = [parameters objectForKey: GWSRPCIDKey];

  if (nil == dict)
    {
      dict = [parameters objectForKey: GWSParametersKey];
    }
  if (nil == dict)
    {
      dict = parameters;
    }
  if (o == nil)
    {
      o = order;
    }

  // Remove the hash itself from the dict.
  if (nil != hashKey)
    {
      dict = [[dict mutableCopy] autorelease];
      o = [[o mutableCopy] autorelease];
      [(NSMutableArray*)o removeObject: hashKey];
      [(NSMutableDictionary*)dict removeObjectForKey: hashKey];
    }
  NSDebugMLog(@"Verifying hash with parameters."
    @" Method: %@, RPCID: %@, Dict: %@, Order: %@, Salt: %@",
    rpcMethod, rpcID, dict, o, salt);

  NSString *toHash = getStringToHash(rpcMethod, rpcID,
    dict, o, (extraIsKey) ? nil : additionalValue, salt);
  
  NSString *otherHash = nil;
  NSData    *data = [toHash dataUsingEncoding: NSUTF8StringEncoding];

  if (extraIsKey)
    { 
      otherHash = [[GWSCoder coder] encodeHexBinaryFrom:
        computeHMAC(method, data, additionalValue)];
    }
  else
    {
      otherHash = [[GWSCoder coder] encodeHexBinaryFrom:
        computeDigest(method, data)];
    }
  return (NSOrderedSame
    == [[self hashValue] caseInsensitiveCompare: otherHash]);
}
@end

#if	defined(__cplusplus)
}
#endif


