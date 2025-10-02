/** 
   Copyright (C) 2011 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	may 2011
   
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

int
main()
{
  NSAutoreleasePool     *pool;
  NSUserDefaults	*defs;
  NSString              *file;
  BOOL			decode = NO;

  pool = [NSAutoreleasePool new];

  defs = [NSUserDefaults standardUserDefaults];

  file = [defs stringForKey: @"Encode"];
  if (nil == file)
    {
      decode = YES;
      file = [defs stringForKey: @"Decode"];
    }

  if (file == nil)
    {
      GSPrintf(stderr, @"Usage ... testGWSJSONCoder -Decode filename\n");
      GSPrintf(stderr, @"or ...    testGWSJSONCoder -Encode filename\n");
      GSPrintf(stderr, @"	-Record filename (to store results)\n");
      GSPrintf(stderr, @"	-Compare filename (to check results)\n");
      [pool release];
      return 1;
    }

  if (YES == decode)
    {
      GWSJSONCoder          *coder;
      NSData                *data;
      NSMutableDictionary   *result;

      data = [NSData dataWithContentsOfFile: file];
      if (data == nil)
	{
	  GSPrintf(stderr, @"Unable to load data from file '%@'\n", file);
          [pool release];
	  return 1;
	}

      coder = [[GWSJSONCoder new] autorelease];
      [coder setDebug: [defs boolForKey: @"Debug"]];

      result = [coder parseMessage: data];
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
      GWSJSONCoder	*coder;
      id		object;
      NSData		*result;

      object = [[NSString stringWithContentsOfFile: file] propertyList];
      if (nil == object)
	{
	  GSPrintf(stderr, @"Unable to read object to encode from '%@'\n",
	    file);
          [pool release];
	  return 1;
	}

      coder = [[GWSJSONCoder new] autorelease];
      result = [coder buildRequest: nil
		        parameters: object
			     order: nil];
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
	      GSPrintf(stderr, @"Failed to load data from file '%@'\n",
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

