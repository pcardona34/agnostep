/*
**  MailboxManagerCache.m
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**  Copyright (c) 2017-2020 Riccardo Mottola
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

#import "MailboxManagerCache.h"

#import "Constants.h"
#import "Utilities.h"

NSString *PathToMailboxManagerCache()
{
  return [NSString stringWithFormat: @"%@/%@",
		   GNUMailUserLibraryPath(), @"MailboxManagerCache"];
}


//
//
//
@implementation MailboxManagerCache

- (id) init
{
  self = [super init];
  if (self)
    {
      [self setAllCacheObjects: [NSDictionary dictionary]];
    }
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_cache);
  [super dealloc];
}


//
//
//
- (BOOL) synchronize
{
  return [NSArchiver archiveRootObject: self  toFile: PathToMailboxManagerCache()];
}


//
// Access / mutation methods
//
- (NSDictionary *) allCacheObjects
{
  return _cache;
}


- (void) setAllCacheObjects: (NSDictionary *) theObjects
{
  RELEASE(_cache);
  _cache = nil;
  if (theObjects)
	{
	  _cache = [[NSMutableDictionary alloc] initWithCapacity: [theObjects count]];
	  [_cache addEntriesFromDictionary: theObjects];
	}
}



//
//
//
- (void) allValuesForStoreName: (NSString *) theStoreName
                    folderName: (NSString *) theFolderName
                      username: (NSString *) theUsername
                  nbOfMessages: (NSUInteger *) theNbOfMessages
            nbOfUnreadMessages: (NSUInteger *) theNbOfUnreadMessages
{
  MailboxManagerCacheObject *aCacheObject;
  NSString *aString;
  NSUInteger v1, v2;
  
  aString = [NSString stringWithFormat: @"%@ @ %@/%@", theUsername, theStoreName, theFolderName];
  
  aCacheObject = [_cache objectForKey: aString];

  if (!aCacheObject)
    {
      v1 = v2 = 0;
    }
  else
    {
      v1 = aCacheObject->nbOfMessages;
      v2 = aCacheObject->nbOfUnreadMessages;
    }
  
  if (theNbOfMessages != NULL)
    {
      *theNbOfMessages = v1;
    }

  if (theNbOfUnreadMessages != NULL)
    {
      *theNbOfUnreadMessages = v2;
    }
}


//
//
//
- (void) setAllValuesForStoreName: (NSString *) theStoreName
                       folderName: (NSString *) theFolderName
                         username: (NSString *) theUsername
                     nbOfMessages: (NSUInteger) theNbOfMessages
               nbOfUnreadMessages: (NSUInteger) theNbOfUnreadMessages
{
  MailboxManagerCacheObject *aCacheObject;
  NSString *aString;
  
  aString = [NSString stringWithFormat: @"%@ @ %@/%@", theUsername, theStoreName, theFolderName];

  aCacheObject = [_cache objectForKey: aString];

  if (!aCacheObject)
    {
      aCacheObject = [[MailboxManagerCacheObject alloc] init];
      [_cache setObject: aCacheObject  forKey: aString];
      RELEASE(aCacheObject);
    }
  
  aCacheObject->nbOfMessages = theNbOfMessages;
  aCacheObject->nbOfUnreadMessages = theNbOfUnreadMessages;
}


//
//
//
- (void) removeAllValuesForStoreName: (NSString *) theStoreName
                          folderName: (NSString *) theFolderName
                            username: (NSString *) theUsername
{
  [_cache removeObjectForKey: [NSString stringWithFormat: @"%@ @ %@/%@", theUsername, theStoreName, theFolderName]];
}


//
// NSCoding protocol
//
- (void) encodeWithCoder: (NSCoder *) theCoder
{
  [theCoder encodeObject: _cache];
}


- (id) initWithCoder: (NSCoder *) theCoder
{
  self = [super init];
  if (self)
    {
      [self setAllCacheObjects: [theCoder decodeObject]];
    }

  return self;
}


//
// class methods
//
+ (id) cacheFromDisk
{
  MailboxManagerCache *o;
  
  NS_DURING
    {
      o = [NSUnarchiver unarchiveObjectWithFile: PathToMailboxManagerCache()];
      
      if (!o)
	{
	  NSDebugLog(@"Creating a new Mailbox Manager cache.");
	  o = [[MailboxManagerCache alloc] init];
	  AUTORELEASE(o);
	  [o synchronize];
	}
    }
  NS_HANDLER
    {
      NSLog(@"Caught exception while unarchiving the MailboxManagerCache. Ignoring.");
      o = [[MailboxManagerCache alloc] init];
      AUTORELEASE(o);
      [o synchronize];
    }
  NS_ENDHANDLER

  return o;
}

@end


//
// Our cached object
//
@implementation MailboxManagerCacheObject

- (void) encodeWithCoder: (NSCoder *) theCoder
{
  [MailboxManagerCacheObject setVersion: 2];
  [theCoder encodeValueOfObjCType: @encode(NSUInteger)  at: &nbOfMessages];
  [theCoder encodeValueOfObjCType: @encode(NSUInteger)  at: &nbOfUnreadMessages];
}


- (id) initWithCoder: (NSCoder *) theCoder
{
  int version;

  self = [super init];
  if (self)
    {
      version = [theCoder versionForClassName: @"MailboxManagerCacheObject"];
  
      if (version == 0)
        {
          int totalSize;
          NSDebugLog(@"Decoding MailboxManager Cache version 0 (compatibility)");
          [theCoder decodeValueOfObjCType: @encode(int)  at: &nbOfMessages];
          [theCoder decodeValueOfObjCType: @encode(int)  at: &nbOfUnreadMessages];
          [theCoder decodeValueOfObjCType: @encode(int)  at: &totalSize];
        }
      else if (version == 1)
        {
          NSDebugLog(@"Decoding MailboxManager Cache version 1 (compatibility)");
          [theCoder decodeValueOfObjCType: @encode(int)  at: &nbOfMessages];
          [theCoder decodeValueOfObjCType: @encode(int)  at: &nbOfUnreadMessages];
        }      
      else
        {
          NSDebugLog(@"Decoding MailboxManager Cache current version");
          [theCoder decodeValueOfObjCType: @encode(NSUInteger)  at: &nbOfMessages];
          [theCoder decodeValueOfObjCType: @encode(NSUInteger)  at: &nbOfUnreadMessages];
        }
    }
  
  return self;
}

@end
