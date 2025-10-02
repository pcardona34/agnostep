/*
**  GetURLScriptCommand.m
**
**  Copyright (c) 2003 Ujwal S. Sathyam
**
**  Author: Ujwal S. Sathyam
**
**  Project: GNUMail
**
**  Description: Implements Applescript support for GNUMail.
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "GetURLScriptCommand.h"

#include "GNUMail.h"


//
//
//
@implementation GetURLScriptCommand

- (id) scriptError: (int) errorNumber 
       description: (NSString *) description
{
  [self setScriptErrorNumber: errorNumber];
  [self setScriptErrorString: description];
  return nil;
}


- (id)performDefaultImplementation
{
  NSString *command;
  NSString *parameter;
  
  command = [[self commandDescription] commandName];
  parameter = [self directParameter];
  
  if ([command isEqualToString: @"GetURL"] && [parameter length])
    {
      NSString *anAddress;
      NSRange aRange;
      NSURL *aURL;
      NSString *absoluteString;

      aURL = [NSURL URLWithString: parameter];
      if(aURL == nil)
      {
	  NSLog(@"GetURLScriptCommand: received malformed URL '%@'", parameter);
	  return (nil);
      }
      absoluteString = [aURL absoluteString];
      
      // Search for "mailto" token
      aRange = [absoluteString rangeOfString: @"mailto:" options: NSCaseInsensitiveSearch];
     
      if (aRange.length <= 0)
	{
	  NSLog(@"URL '%@' is not a mailto URL", aURL);
	  return nil;
	}
      absoluteString = [absoluteString substringFromIndex: (aRange.location + aRange.length)];

      // Check if we have a parameter string
      aRange = [absoluteString rangeOfString: @"?" options: NSCaseInsensitiveSearch];
      if(aRange.length > 0)
      {
	  absoluteString = [absoluteString substringToIndex: aRange.location];
      }
      
      
      anAddress = (NSString *) CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef) absoluteString, (CFStringRef) @"");
      
      // Open an mail composer window addressed to to "anAddress"
      if ([anAddress length] > 0)
	{
	  GNUMail *gnumail;
	  
	  gnumail = [NSApp delegate];
	  
	  [gnumail newMessageWithRecipient: anAddress];
	}
    [anAddress release];
    }
  
  return (nil);
}

@end
