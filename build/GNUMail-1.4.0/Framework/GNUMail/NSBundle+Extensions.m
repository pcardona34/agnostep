/*
**  NSBundle+Extensions.m
**
**  Copyright (c) 2005-2007 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
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

#include "NSBundle+Extensions.h"

#include "Constants.h"
#include "ConsoleWindowController.h"
#include "PreferencesModule.h"


@implementation NSBundle (GNUMailBundleExtensions)

//
// Can be:  $GNUSTEP_INSTALATION_DIR/{Local,Network,System}/Apps/GNUMail.app/Resources or
//     or:  ANY_OTHER_DIRECTORY/GNUMail/GNUMail.app/Resources
//
+ (id) instanceForBundleWithName: (NSString *) theName
{
  NSString *aString;
  NSBundle *aBundle;
  Class aClass;

#ifdef MACOSX
  aString = [[[NSBundle mainBundle] builtInPlugInsPath] 
	      stringByAppendingPathComponent: [theName 
						stringByAppendingPathExtension: @"prefs"]];
#else
  NSArray *allPaths;
  BOOL b;
  int i;

  allPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
						 NSLocalDomainMask|
						 NSNetworkDomainMask|
						 NSSystemDomainMask|
						 NSUserDomainMask,
						 YES);
  aString = nil;

  for (i = 0; i < [allPaths count]; i++)
    {
      aString = [NSString stringWithFormat: @"%@/GNUMail/%@.prefs", [allPaths objectAtIndex: i], theName];
      
      if ([[NSFileManager defaultManager] fileExistsAtPath: aString  isDirectory: &b] && b)
	{
	  break;
	}
    }
#endif

  ADD_CONSOLE_MESSAGE(_(@"Loading preferences bundle at path %@."), aString);
  
  aBundle = [NSBundle bundleWithPath: aString];

  aClass = [aBundle principalClass];
  
  if ([aClass conformsToProtocol: @protocol(PreferencesModule)])
    {
      return [aClass singleInstance];
    }

  return nil;
}

@end
