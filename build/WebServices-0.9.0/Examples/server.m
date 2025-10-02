/** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	November 2008
   
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

   $Date: 2007-09-14 13:54:55 +0100 (Fri, 14 Sep 2007) $ $Revision: 25485 $
   */ 

#import	<Foundation/Foundation.h>
#import	<GNUstepBase/GSMime.h>
#import	<WebServer/WebServer.h>
#import	"../WebServices.h"

@interface	Handler: NSObject
- (BOOL) processRequest: (GSMimeDocument*)request
               response: (GSMimeDocument*)response
		    for: (WebServer*)http;
@end
@implementation	Handler
- (BOOL) processRequest: (GSMimeDocument*)request
               response: (GSMimeDocument*)response
		    for: (WebServer*)http
{
  GWSSOAPCoder		*coder;
  NSMutableDictionary	*parsed;
  NSString		*path;
  NSString		*method;
  NSMutableDictionary	*params;
  NSMutableArray	*order;
  NSData		*xml;

  xml = [request convertToData];
  coder = [GWSSOAPCoder new];

  NSLog(@"Unparsed request: %@", [request convertToText]);
  path = [[request headerNamed: @"x-http-path"] value];
  if ([path isEqualToString: @"/rpc"] == YES)
    {
      [coder setOperationStyle: GWSSOAPBodyEncodingStyleRPC];
      parsed = [coder parseMessage: xml];
      method = [parsed objectForKey: GWSMethodKey];
      params = [parsed objectForKey: GWSParametersKey];
      order = [parsed objectForKey: GWSOrderKey];
    }
  else
    {
      [coder setOperationStyle: GWSSOAPBodyEncodingStyleDocument];
      parsed = [coder parseMessage: xml];
      method = nil; // No method name needed/used
      params = [parsed objectForKey: GWSParametersKey];
      order = [parsed objectForKey: GWSOrderKey];
    }
  NSLog(@"Parsed request: %@", parsed);

  xml = [coder buildResponse: method
		  parameters: params
		       order: order];

  [response setContent: xml type: @"text/xml" name: nil];
  [coder release];

  return YES;
}
@end

int
main()
{
  CREATE_AUTORELEASE_POOL(pool);
  WebServer		*server;
  Handler		*handler;
  NSUserDefaults	*defs;

  defs = [NSUserDefaults standardUserDefaults];
  [defs registerDefaults:
    [NSDictionary dictionaryWithObjectsAndKeys:
      @"12345", @"Port",
      [NSDictionary dictionaryWithObjectsAndKeys:
	@"server.crt", @"CertificateFile",
	@"server.key", @"KeyFile",
	nil], @"Security",
      nil]
    ];

  server = [WebServer new];

  handler = [Handler new];
  [server setDelegate: handler];
  [server setPort: [defs stringForKey: @"Port"]
	   secure: [defs dictionaryForKey: @"Security"]];

  [[NSRunLoop currentRunLoop] run];

  RELEASE(pool);
  return 0;
}

