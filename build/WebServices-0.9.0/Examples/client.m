/** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	November 2008
   
   This file is part of the WebServices package.

   This is free software; you can redistribute it and/or
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

   $Date: 2007-09-14 13:54:55 +0100 (Fri, 14 Sep 2007) $ $Revision: 25485 $
   */ 

#import	<Foundation/Foundation.h>
#import	"../GWSPrivate.h"

int
main()
{
  NSAutoreleasePool     *pool;
  NSUserDefaults	*defs;
  NSString		*test;
  GWSSOAPCoder		*coder;
  GWSDocument		*document;
  GWSService		*service;
  NSString              *method;
  NSMutableArray        *order;
  NSMutableDictionary   *params;
  NSDictionary          *result;
  NSData		*data;
  unsigned		length;

  pool = [NSAutoreleasePool new];

  /* By default we use port 12345 for our test.
   */
  defs = [NSUserDefaults standardUserDefaults];
  [defs registerDefaults:
    [NSDictionary dictionaryWithObjectsAndKeys:
      @"12345", @"Port",
      nil]
    ];

#if 1
  coder = [GWSSOAPCoder new];

  /* Test encoding and decoding of a SOAP request with a single string.
   */
  test = [NSString stringWithFormat: @"https://localhost:%@/foo/",
    [defs stringForKey: @"Port"]];
  params = [NSMutableDictionary dictionaryWithCapacity: 8];
  order = [NSMutableArray arrayWithCapacity: 8];
  [params setObject: @"hello<" forKey: @"string1"];
  [order addObject: @"string1"];
  method = @"test";

  service = [GWSService new]; 
  [service setDebug: YES];
  [service setCoder: coder];
  [coder release];

  /* Send a document style message.
   */
  [service setURL: test];
/*
  [service setURL: test certificate: @"xx" privateKey: @"yy" password: @"zz"];
 */
  [coder setOperationStyle: GWSSOAPBodyEncodingStyleDocument];
  result = [service invokeMethod: method
                      parameters: params
                           order: order
                         timeout: 30];
  if ([params isEqual: [result objectForKey: GWSParametersKey]] == NO
    || [order isEqual: [result objectForKey: GWSOrderKey]] == NO)
    {
      fprintf(stdout, "Document unexpected result: %s\n",
	[[result description] UTF8String]);
    }
  else
    {
      fprintf(stdout, "Document style message test OK\n");
    }

  [service setURL: [test stringByAppendingString: @"rpc"]];
/*
  [service setURL: [test stringByAppendingString: @"rpc"]
    certificate: @"xx" privateKey: @"yy" password: @"zz"];
 */
  [coder setOperationStyle: GWSSOAPBodyEncodingStyleRPC];
  result = [service invokeMethod: method
                      parameters: params
                           order: order
                         timeout: 30];
  if ([method isEqual: [result objectForKey: GWSMethodKey]] == NO
    || [params isEqual: [result objectForKey: GWSParametersKey]] == NO
    || [order isEqual: [result objectForKey: GWSOrderKey]] == NO)
    {
      fprintf(stdout, "RPC unexpected result: %s\n",
	[[result description] UTF8String]);
    }
  else
    {
      fprintf(stdout, "RPC style message test OK\n");
    }

  [params setObject: @"there" forKey: @"string1"];
  result = [service invokeMethod: method
                      parameters: params
                           order: order
                         timeout: 30];
  if ([method isEqual: [result objectForKey: GWSMethodKey]] == NO
    || [params isEqual: [result objectForKey: GWSParametersKey]] == NO
    || [order isEqual: [result objectForKey: GWSOrderKey]] == NO)
    {
      fprintf(stdout, "RPC unexpected result: %s\n",
	[[result description] UTF8String]);
    }
  else
    {
      fprintf(stdout, "RPC style message test OK\n");
    }

{
  NSArray	*values;
  NSDictionary	*value;

  values = [NSArray arrayWithObjects:
    @"one", @"two", @"three", nil];

  value =  [NSDictionary dictionaryWithObjectsAndKeys:
    values, GWSSOAPValueKey,
    nil];
  [params setObject: value forKey: @"string1"];
  result = [service invokeMethod: method
                      parameters: params
                           order: order
                         timeout: 30];
  fprintf(stdout, "RPC array 1 result: %s\n",
    [[result description] UTF8String]);

  value =  [NSDictionary dictionaryWithObjectsAndKeys:
    values, GWSSOAPValueKey,
    @"value", GWSSOAPArrayKey,
    nil];
  [params setObject: value forKey: @"string1"];
  result = [service invokeMethod: method
                      parameters: params
                           order: order
                         timeout: 30];
  fprintf(stdout, "RPC array 2 result: %s\n",
    [[result description] UTF8String]);
}

  [service release];

#else

  document = [[[GWSDocument alloc]
    initWithContentsOfFile: @"Message.wsdl"] autorelease];

  service = [document serviceWithName: @"Message" create: NO];

  params = [NSMutableDictionary dictionaryWithCapacity: 8];
  [params setObject: [NSDictionary dictionaryWithObjectsAndKeys:
    @"Me", @"recipient",
    @"hello", @"message",
    @"1", @"messageType",
    nil] forKey: @"sendMsg"];

  [service setDebug: YES];
  result = [service invokeMethod: @"sendMsg"
                      parameters: params
                           order: nil
                         timeout: 30];
  data = [result objectForKey: GWSRequestDataKey];
  length = [data length];
  fprintf(stdout, "RPC result: %*.*s\n", length, length, [data bytes]);

#endif

  [pool release];
  return 0;
}

