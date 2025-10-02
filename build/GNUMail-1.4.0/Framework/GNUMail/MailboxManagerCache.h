/*
**  MailboxManagerCache.h
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**  Copyright (C) 2017      Riccardo Mottola
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

#ifndef _GNUMail_H_MailboxManagerCache
#define _GNUMail_H_MailboxManagerCache

#import <Foundation/Foundation.h>
#import "Constants.h"

NSString *PathToMailboxManagerCache();

@interface MailboxManagerCache : NSObject <NSCoding>
{
  @private
    NSMutableDictionary *_cache;
}

- (BOOL) synchronize;

//
// Access / mutation methods
//
- (NSDictionary *) allCacheObjects;
- (void) setAllCacheObjects: (NSDictionary *) theObjects;

- (void) allValuesForStoreName: (NSString *) theStoreName
                    folderName: (NSString *) theFolderName
                      username: (NSString *) theUsername
                  nbOfMessages: (NSUInteger *) theNbOfMessages
            nbOfUnreadMessages: (NSUInteger *) theNbOfUnreadMessages;

- (void) setAllValuesForStoreName: (NSString *) theStoreName
                       folderName: (NSString *) theFolderName
                         username: (NSString *) theUsername
                     nbOfMessages: (NSUInteger) theNbOfMessages
               nbOfUnreadMessages: (NSUInteger) theNbOfUnreadMessages;

- (void) removeAllValuesForStoreName: (NSString *) theStoreName
                          folderName: (NSString *) theFolderName
                            username: (NSString *) theUsername;

//
// class methods
//
+ (id) cacheFromDisk;

@end


//
// Our cached object
//
@interface MailboxManagerCacheObject : NSObject <NSCoding>
{
  @public
    NSUInteger nbOfMessages;
    NSUInteger nbOfUnreadMessages;
}

@end

#endif // _GNUMail_H_MailboxManagerCache
