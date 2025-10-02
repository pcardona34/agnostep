/** 
   Copyright (C) 2009 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	September 2009
   
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

static NSString *emo = @"😀😁😂🤣😃😄😅😆😉😊😋😎😍😘😗😙😚☺️🙂🤗🤩🤔🤨😐";

int
main()
{
  NSAutoreleasePool     *pool;
  NSUserDefaults	*defs;
  NSString              *file;
  NSString		*method;
  NSString		*sName;
  NSString		*wsdl;

  pool = [NSAutoreleasePool new];

  defs = [NSUserDefaults standardUserDefaults];

  if ([defs boolForKey: @"Internal"] == YES)
    {
      GWSCoder          *xml;
      GWSSOAPCoder      *soap;
      GWSElement        *elem;
      NSCalendarDate    *now;
      NSCalendarDate    *dec;
      NSString          *str;

      xml = [[GWSCoder new] autorelease];
      str = [xml escapeXMLFrom: emo];
      if (YES == [str isEqual: emo])
        {
          GSPrintf(stderr, @"Emoji escaping failure %@ %@\n", emo, str);
          [pool release];
          return 1;
        }
      str = [NSString stringWithFormat: @"<smile>%@</smile>", str];
      elem = [xml parseXML: [str dataUsingEncoding: NSUTF8StringEncoding]];
      if (NO == [emo isEqual: [elem content]])
        {
          GSPrintf(stderr, @"Emoji encoding failure %@\n", elem);
          [pool release];
          return 1;
        }

      soap = [[GWSSOAPCoder new] autorelease];
      now = [NSCalendarDate date];

      [now setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
      str = [soap encodeDateTimeFrom: now];
      dec = [soap parseXSI: @"xsd:dateTime" string: str];
      if (NO == [[dec description] isEqual: [now description]])
        {
          GSPrintf(stderr, @"Date encoding failure %@ %@ %@\n", now, str, dec);
          [pool release];
          return 1;
        }

      [now setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"PST"]];
      str = [soap encodeDateTimeFrom: now];
      dec = [soap parseXSI: @"xsd:dateTime" string: str];
      if (NO == [[dec description] isEqual: [now description]])
        {
          GSPrintf(stderr, @"Date encoding failure %@ %@ %@\n", now, str, dec);
          [pool release];
          return 1;
        }

      GSPrintf(stdout, @"Internal tests OK\n");
      [pool release];
      return 0;
    }

  file = [defs stringForKey: @"Encode"];
  if (file != nil)
    {
      method = [defs stringForKey: @"Method"];
      if (method == nil)
	{
	  file = nil;	// Can't encode without a method/operation
	}
      wsdl = [defs stringForKey: @"WSDL"];
      sName = [defs stringForKey: @"Service"];
    }
  else
    {
      method = nil;
      wsdl = nil;
      sName = nil;
      file = [defs stringForKey: @"Decode"];
      if (file == nil)
	{
          file = [defs stringForKey: @"File"];
	}
    }

  if (file == nil)
    {
      GSPrintf(stderr, @"Usage ... testGWSSOAPCoder -Decode filename\n");
      GSPrintf(stderr, @"or ...    testGWSSOAPCoder -Encode filename\n");
      GSPrintf(stderr, @"	-Record filename (to store results)\n");
      GSPrintf(stderr, @"	-Compare filename (to check results)\n");
      GSPrintf(stderr, @"	-Method name (method/operation to use)\n");
      GSPrintf(stderr, @"	-Service name (for service in WSDL)\n");
      GSPrintf(stderr, @"	-WSDL filename (for WSDL document)\n");
      GSPrintf(stderr, @"\nor	-Internal YES for coder self test\n");
      [pool release];
      return 1;
    }

  if (method == nil)
    {
      GWSSOAPCoder          *coder;
      NSData                *xml;
      NSMutableDictionary   *result;

      xml = [NSData dataWithContentsOfFile: file];
      if (xml == nil)
	{
	  GSPrintf(stderr, @"Unable to load XML from file '%@'\n", file);
          [pool release];
	  return 1;
	}

      coder = [[GWSSOAPCoder new] autorelease];
      [coder setDebug: [defs boolForKey: @"Debug"]];

      result = [coder parseMessage: xml];
      if (nil == result)
	{
	  GSPrintf(stderr, @"Failed to decode data from file '%@'\n", file);
          [pool release];
	  return 1;
	}
      
      file = [defs objectForKey: @"Record"];
      if (file != nil)
	{
	  if (NO == [result writeToFile: file atomically: NO])
	    {
	      GSPrintf(stderr, @"Failed to record result to file '%@'\n", file);
              [pool release];
	      return 1;
	    }
	}

      file = [defs objectForKey: @"Compare"];
      if (file == nil)
	{
	  GSPrintf(stdout, @"%@", result);
	}
      else
	{
	  NSDictionary	*old;

	  old = [NSDictionary dictionaryWithContentsOfFile: file];
	  if (old == nil)
	    {
	      GSPrintf(stderr, @"Failed to load dictionary from file '%@'\n",
		file);
              [pool release];
	      return 1;
	    }
	  if ([old isEqual: result] == NO)
	    {
	      GSPrintf(stderr, @"Decode result does not match file '%@'\n",
		file);
              [pool release];
	      return 1;
	    }
	}
    }
  else
    {
      NSDictionary	*parameters;
      NSArray		*order;
      GWSService	*service;
      NSData		*result;

      parameters = [NSDictionary dictionaryWithContentsOfFile: file];
      if (parameters == nil)
	{
	  GSPrintf(stderr, @"Unable to read request params from '%@'\n",
	    file);
          [pool release];
	  return 1;
	}

      if (wsdl == nil || sName == nil)
	{
          GWSSOAPCoder	*coder;

          service = [[GWSService new] autorelease];
          coder = [GWSSOAPCoder new];
          [service setCoder: coder];
          [coder release];
	}
      else
	{
          GWSDocument	*document;

	  document = [[GWSDocument alloc] initWithContentsOfFile: wsdl];
	  [document autorelease];
	  if (nil == document)
	    {
	      GSPrintf(stderr, @"Failed to load WSDL from '%@'\n", wsdl);
              [pool release];
	      return 1;
	    }
	  service = [document serviceWithName: sName create: NO];
	  if (service == nil)
	    {
	      GSPrintf(stderr, @"Failed to find service '%@' in WSDL '%@'\n",
		sName, wsdl);
              [pool release];
	      return 1;
	    }
	}

      if (nil == [parameters objectForKey: GWSOrderKey])
	{
	  /* Make sure parameteres are consistently ordered so that output
	   * will be reliable for comparison with recorded data.
	   */
	  order = [[parameters allKeys]
	    sortedArrayUsingSelector: @selector(compare:)];
	}
      else
	{
	  order = nil;	// Not needed ... already in parameters
	}
      result = [service buildRequest: method 
		          parameters: parameters
			       order: order];
      file = [defs objectForKey: @"Record"];
      if (file != nil)
	{
	  if (NO == [result writeToFile: file atomically: NO])
	    {
	      GSPrintf(stderr, @"Failed to record result to file '%@'\n", file);
              [pool release];
	      return 1;
	    }
	}

      file = [defs objectForKey: @"Compare"];
      if (file == nil)
	{
	  GSPrintf(stdout, @"%@", result);
	}
      else
	{
	  NSData	*old;

	  old = [NSData dataWithContentsOfFile: file];
	  if (old == nil)
	    {
	      GSPrintf(stderr, @"Failed to load xml data from file '%@'\n",
		file);
              [pool release];
	      return 1;
	    }
	  if ([old isEqual: result] == NO)
	    {
	      GSPrintf(stderr, @"Decode result does not match file '%@'\n",
		file);
              [pool release];
	      return 1;
	    }
	}
    }

  [pool release];
  return 0;
}

