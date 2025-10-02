/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2010-2019 The Free Software Foundation, Inc.
 *                2006      Guenther Noack
 *
 *  Authors: Guenther Noack
 *           Riccardo Mottola
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation, in version 2.1
 *  of the License
 * 
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA
 */

#import "RSSFactory.h"
#import "RSSArticle+Storage.h"
#import "GNUstep.h"

static id<RSSFactory> sharedFactory = nil;
static NSString* RSSArticleStorageDirectory = nil;



/**
 * Converts a string to a string that's usable as a file system name. This is done
 * by removing several forbidden characters, only leaving the allowed ones. (A helper method)
 */
NSString* stringToFSString( NSString* aString )
{
    NSScanner* scanner = [NSScanner scannerWithString: aString];
    NSMutableString* string = AUTORELEASE([[NSMutableString alloc] init]);
    NSCharacterSet* allowedSet = [NSCharacterSet alphanumericCharacterSet];
    
    do {
        NSString* nextPart;
        BOOL success;

        // discard any unknown characters
        if ([scanner scanUpToCharactersFromSet: allowedSet intoString: NULL] == YES) {
            [string appendString: @"_"];
        }
        
        // scan known characters...
        success = [scanner scanCharactersFromSet: allowedSet intoString: &nextPart];
        
        // ...and add them to the string
        if (success == YES) {
            [string appendString: nextPart];
        }
    } while ([scanner isAtEnd] == NO);
    
    return [NSString stringWithString: string];
}


@implementation RSSFactory

/**
 * Returns the shared factory instance.
 */
+ (id<RSSFactory>) sharedFactory
{
    if (sharedFactory == nil) {
        ASSIGN(sharedFactory, AUTORELEASE([[RSSFactory alloc] init]));
    }
    
    return sharedFactory;
}

/**
 * Sets another shared factory instance than the currently selected one.
 */
+ (void) setFactory: (id<RSSFactory>) aFactory
{
    ASSIGN(sharedFactory, aFactory);
}


/**
 * The default implementation of this method returns a new feed of
 * the RSSFeed class.
 */
- (id<RSSFeed>) feedWithURL: (NSURL*) aURL
{
    return [RSSFeed feedWithURL: aURL];
}


/**
 * The default implementation of this method returns a new article
 * of the RSSArticle class.
 */
- (id<RSSArticle>) articleWithHeadline: (NSString*) aHeadline
                                   URL: (NSURL*) aURL
                               content: (NSString*) aContent
                                  date: (NSDate*) aDate
{
    id <RSSArticle> article = [[RSSArticle alloc] initWithHeadline: aHeadline
                                                               url: aURL
                                                       description: aContent
                                                              date: aDate];
    return AUTORELEASE(article);
}

/**
 * The default implementation of this method returns a new article
 * of the RSSArticle class.(which implements the RSSMutableArticle protocol)
 */
- (id<RSSMutableArticle>) articleFromStorageWithURL: (NSURL*) aURL
{
    return [self articleFromDictionary:
            [NSDictionary dictionaryWithContentsOfFile:
                [self storagePathForURL: aURL]]];
}



/**
 * The default implementation of this method returns a article
 * of the RSSArticle class. (which implements the RSSMutableArticle protocol)
 */
- (id<RSSMutableArticle>) articleFromDictionary: (NSDictionary*) aDictionary
{
    return AUTORELEASE([[RSSArticle alloc] initWithDictionary: aDictionary]);
}

/**
 * Returns the file path where an article with the anURL URL would be stored to.
 */
-(NSString*) storagePathForURL: (NSURL*) anURL
{
    if (RSSArticleStorageDirectory == nil) {
        NSFileManager* manager;
        BOOL isDir, exists;
        NSString *storagePath;
        
        storagePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        storagePath = [storagePath stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
        storagePath = [storagePath stringByAppendingPathComponent:@"RSSArticles"];


        ASSIGN(RSSArticleStorageDirectory, storagePath);
        
        manager = [NSFileManager defaultManager];
        
        exists = [manager fileExistsAtPath: RSSArticleStorageDirectory isDirectory: &isDir];
        
        if (exists) {
            if (isDir == NO) {
                [[NSException exceptionWithName: @"RSSArticleStorageDirectoryIsNotADirectory"
                                         reason: @"The storage directory for RSS articles is not a directory."
                                       userInfo: nil] raise];
            }
        } else {
            if ([manager createDirectoryAtPath: RSSArticleStorageDirectory
                                    attributes: nil] == NO) {
                [[NSException exceptionWithName: @"RSSArticleStorageDirectoryCreationFailed"
                                         reason: @"Creation of the storage directory for RSS Articles failed."
                                       userInfo: nil] raise];
            }
        }
    }
    
    return [NSString stringWithFormat: @"%@/%@.rssarticle", RSSArticleStorageDirectory, stringToFSString([anURL absoluteString])];
}

@end


