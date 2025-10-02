/** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	September 2008
   
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
#import	"GWSPrivate.h"
#import	"WSSUsernameToken.h"

@interface	SimpleDelegate : NSObject
{
  WSSUsernameToken	*_token;
}
- (void) setToken: (WSSUsernameToken*)token;
@end
@implementation	SimpleDelegate
- (void) dealloc
{
  [_token release];
  [super dealloc];
}

- (void) setToken: (WSSUsernameToken*)token
{
  if (_token != token)
    {
      [_token release];
      _token = [token retain];
    }
}

- (GWSElement*) webService: (GWSService*)service
		willEncode: (GWSElement*)element
{
  if (_token != nil)
    {
      if (element == nil || [[element name] isEqualToString: @"Header"])
	{
	  element = [_token addToHeader: element];
	}
    }
  return element;
}
@end

int
main()
{
  NSAutoreleasePool     *pool;
  NSAutoreleasePool     *inner;
  NSUserDefaults	*defs;
  SimpleDelegate	*del;
  WSSUsernameToken	*token;
  GWSCoder              *coder;
  GWSService		*service;
  GWSDocument   	*document;
  NSData                *xml;
  NSString              *method;
  NSMutableArray        *order;
  NSMutableDictionary   *params;
  NSMutableArray        *norder;
  NSMutableDictionary   *nparams;
  NSMutableDictionary   *result;
  id			o;
  BOOL                  coderDebug = YES;
  BOOL                  serviceDebug = YES;

  pool = [NSAutoreleasePool new];

  defs = [NSUserDefaults standardUserDefaults];
  [defs registerDefaults:
    [NSDictionary dictionaryWithObjectsAndKeys:
      @"80", @"Port",
      nil]
    ];

  o = [defs objectForKey: @"CoderDebug"];
  if (nil != o)
    {
      coderDebug = [defs boolForKey: @"CoderDebug"];
    }

  o = [defs objectForKey: @"ServiceDebug"];
  if (nil != o)
    {
      serviceDebug = [defs boolForKey: @"ServiceDebug"];
    }

  inner = [NSAutoreleasePool new];
  document = [[GWSDocument alloc] initWithContentsOfFile: @"SMS.wsdl"];
  
  params = [NSMutableDictionary dictionaryWithCapacity: 8];
  order = [NSMutableArray arrayWithCapacity: 8];
  [params setObject: @"hello" forKey: @"string1"];
  [order addObject: @"string1"];
  [params setObject: [NSDictionary dictionaryWithObjectsAndKeys:
    @"obj1", @"key1",
    nil] forKey: @"dict1"];
  [order addObject: @"dict1"];
  service = [document serviceWithName: @"SMSService" create: NO];
  [service setDebug: serviceDebug];
  result = [service invokeMethod: @"sendSMS"
                      parameters: params
                           order: order
                         timeout: 3];
  NSLog(@"Invoke gives ... %@", result);

  result = [service invokeMethod: @"sendSMS"
                      parameters: params
                           order: order
                         timeout: 3];
  NSLog(@"Retry gives ... %@", result);

  xml = [document data];
  NSLog(@"Document:\n%*.*s", (int)[xml length], (int)[xml length], [xml bytes]);
  [document release];
  [inner release];

  // [[NSRunLoop currentRunLoop] run];

  inner = [NSAutoreleasePool new];
  coder = [GWSXMLRPCCoder new];
  [coder setDebug:coderDebug];

  /* Test encoding and decoding of an XMLRPC request.
   */
  params = [NSMutableDictionary dictionaryWithCapacity: 8];
  order = [NSMutableArray arrayWithCapacity: 8];
  [params setObject: @"hello" forKey: @"string1"];
  [order addObject: @"string1"];
  [params setObject: [NSDictionary dictionaryWithObjectsAndKeys:
    @"obj1", @"key1",
    nil] forKey: @"dict1"];
  [order addObject: @"dict1"];
  method = @"test";
  fprintf(stdout, "Request encode/decode ");
  xml = [coder buildRequest: method
                 parameters: params
                      order: order];
  result = [coder parseMessage: xml];
  norder = [result objectForKey: GWSOrderKey];
  nparams = [result objectForKey: GWSParametersKey];
  if (NO == [method isEqual: [result objectForKey: GWSMethodKey]])
    {
      fprintf(stdout, "FAIL\n");
      NSLog(@"Method does not match ... %@", result);
    }
  else if ([order count] != [norder count])
    {
      fprintf(stdout, "FAIL\n");
      NSLog(@"Counts of order array do not match ... %@", result);
    }
  else if ([params count] != [nparams count])
    {
      fprintf(stdout, "FAIL\n");
      NSLog(@"Counts of params do not match ... %@", result);
    }
  else
    {
      unsigned  c = [order count];
      BOOL      fail = NO;

      while (c-- > 0)
        {
          id    o = [params objectForKey: [order objectAtIndex: c]];
          id    n = [nparams objectForKey: [norder objectAtIndex: c]];

          if (NO == [o isEqual: n])
            {
              if (NO == fail)
                {
                  fprintf(stdout, "FAIL\n");
                  fail = YES;
                }
              NSLog(@"Parameter %u does not match", c);
            }
        }
      if (YES == fail)
        {
          NSLog(@"Parameters do not match ... %@", result);
        }
      else
        {
          fprintf(stdout, "PASS\n");
        }
    }


  [coder release];
  [inner release];


  inner = [NSAutoreleasePool new];
  coder = [[GWSSOAPCoder new] autorelease];
  [coder setDebug: coderDebug];

  /* Test encoding and decoding of a very simple SOAP request.
   */
  params = [NSMutableDictionary dictionaryWithCapacity: 8];
  order = [NSMutableArray arrayWithCapacity: 8];
  [params setObject: @"hello<" forKey: @"string1"];
  [order addObject: @"string1"];
  [params setObject: [NSArray arrayWithObjects: @"a1", @"a2", @"a3", nil]
    forKey: @"array1"];
  [order addObject: @"array1"];
  method = @"test";
  fprintf(stdout, "Request encode/decode ");
  [(GWSSOAPCoder*)coder setOperationStyle: GWSSOAPBodyEncodingStyleRPC];
  xml = [coder buildRequest: method
                 parameters: params
                      order: order];
  result = [coder parseMessage: xml];
  o = [[NSString alloc] initWithData: xml encoding: NSUTF8StringEncoding];
  [result setObject: o forKey: @"EncodedDocument"];
  [o release];
  norder = [result objectForKey: GWSOrderKey];
  nparams = [result objectForKey: GWSParametersKey];
  if (NO == [method isEqual: [result objectForKey: GWSMethodKey]])
    {
      fprintf(stdout, "FAIL\n");
      NSLog(@"Method does not match ... %@", result);
    }
  else if ([order count] != [norder count])
    {
      fprintf(stdout, "FAIL\n");
      NSLog(@"Counts of order array do not match ... %@", result);
    }
  else if ([params count] != [nparams count])
    {
      fprintf(stdout, "FAIL\n");
      NSLog(@"Counts of params do not match ... %@", result);
    }
  else
    {
      unsigned  c = [order count];
      BOOL      fail = NO;

      while (c-- > 0)
        {
          id    o = [params objectForKey: [order objectAtIndex: c]];
          id    n = [nparams objectForKey: [norder objectAtIndex: c]];

          if (NO == [o isEqual: n])
            {
              if (NO == fail)
                {
                  fprintf(stdout, "FAIL\n");
                  fail = YES;
                }
              NSLog(@"Parameter %u does not match", c);
            }
        }
      if (YES == fail)
        {
          NSLog(@"Parameters do not match ... %@", result);
        }
      else
        {
          fprintf(stdout, "PASS\n");
        }
    }
  [inner release];

  /* Now an example of encoding a complex SOAP message manually ..
   */

  inner = [NSAutoreleasePool new];
  /* First stage ... let's build a complex type with a specific
   * order of the elements and a specific namespace.
   */
  o = [NSDictionary dictionaryWithObjectsAndKeys:
    @"urn://here.there/", GWSSOAPNamespaceURIKey,
    [NSArray arrayWithObjects: @"username", @"password", nil], GWSOrderKey,
    @"myname", @"username",
    @"mypass", @"password",
    nil];

  /* Now we store that as a part called 'signin' and set the headers to
   * use literal encoding.
   */
  o = [NSDictionary dictionaryWithObjectsAndKeys:
    o, @"signin",
    GWSSOAPUseLiteral, GWSSOAPUseKey,
    nil];

  /* Now let's set that as a header for a little message containing a single
   * value (called 'parameter') with 'use' encoded.
   */
  o = [NSDictionary dictionaryWithObjectsAndKeys:
    o, GWSSOAPMessageHeadersKey,
    GWSSOAPUseEncoded, GWSSOAPUseKey,
    @"an argument", @"parameter",
    nil];

  /* Now build and display the result.
   */
  coder = [[GWSSOAPCoder new] autorelease];
  [coder setDebug: coderDebug];
  xml = [coder buildRequest: @"method"
                 parameters: o
                      order: nil];
  fprintf(stdout, "\nENCODED ... %*.*s\n\n\n",
    (int)[xml length], (int)[xml length], (char*)[xml bytes]);
  result = [coder parseMessage: xml];
  fprintf(stdout, "\nDECODED ... %s\n\n\n",
    (char*)[[result description] UTF8String]);
  [inner release];


  inner = [NSAutoreleasePool new];
  fprintf(stdout, "Expect this to produce an error ... it tries a request"
    " on the local web server:\n");
  service = [GWSService new]; 
  [service setDebug: serviceDebug];
  [service setURL: @"http://localhost/"];
  coder = [[GWSSOAPCoder new] autorelease];
  [coder setDebug: coderDebug];
  [service setCoder: coder];
  del = [SimpleDelegate new];
  token = [[WSSUsernameToken alloc] initWithName: @"me" password: @"private"];
  [del setToken: token];
  [token release];
  [service setDelegate: del];
  params = [NSMutableDictionary dictionaryWithCapacity: 8];
  order = [NSMutableArray arrayWithCapacity: 8];
  [params setObject: @"hello<" forKey: @"string1"];
  [order addObject: @"string1"];
  [params setObject: [NSArray arrayWithObjects: @"a1", @"a2", @"a3", nil]
    forKey: @"array1"];
  [order addObject: @"array1"];
  method = @"test";
  result = [service invokeMethod: method
                      parameters: params
                           order: order
                         timeout: 30];
  fprintf(stdout, "Result: %s\n", [[result description] UTF8String]);
  [service release];
  [del release];
  [inner release];

  [pool release];
  return 0;
}

