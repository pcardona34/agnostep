/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2011  GNUstep Application Team
                            Riccardo Mottola

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA. 
*/

#import <RSSKit/RSSFeed+Storage.h>

#import "Feed.h"
#import "Article.h"

#ifdef GNUSTEP
#import "NSURL+Proxy.h"
#endif

#ifdef __APPLE__
#import "GNUstep.h"
#endif

// ----------------------------------------------
//    Feed Private interface.
// ----------------------------------------------

@interface Feed (Private)
-(void) beginsFetching;
@end



@implementation Feed

// ----------------------------------------------
//    Counting of unread articles
// ----------------------------------------------

-(int) unreadArticleCount
{
    int i;
    int unreadCount = 0;
    NSArray* articleArray = [[self articleSet] allObjects];
    
    for (i=0; i<[articleArray count]; i++) {
        id<Article> article = [articleArray objectAtIndex: i];
        
        if ([article isRead] == NO) {
            unreadCount ++;
        }
    }
    
    return unreadCount;
}


// ----------------------------------------------
//    Database element protocol
// ----------------------------------------------

-(NSMutableDictionary*) plistDictionary
{
    NSMutableDictionary* dict = [super plistDictionary];
    
    // The DatabaseElement protocol says there has to be a
    // isa key indicating the name of the object's class.
    [dict setObject: [[self class] description] forKey: @"isa"];
    
    // We'll also have to store our database name, if there's
    // a special one.
    if (databaseElementName != nil) {
        [dict setObject: databaseElementName forKey: @"databaseElementName"];
    }
    
    return dict;
}

-(id) initWithDictionary: (NSDictionary*) plistDictionary
{
    if ((self = [super initFromPlistDictionary: plistDictionary]) != nil) {
        ASSIGN(databaseElementName, [plistDictionary objectForKey: @"databaseElementName"]);
    }
    
    return self;
}

-(id) superElement
{
    return superElem;
}

-(void) setSuperElement: (id) superElement
{
    ASSIGN(superElem, superElement);
}

-(void) setName: (NSString*) aString
{
    ASSIGN(databaseElementName, aString);
}

-(NSString*) description
{
    if (databaseElementName != nil) {
        return databaseElementName;
    } else {
        return [super description];
    }
}


// ----------------------------------------------
//    Article Group protocol (No manual modifications allowed)
// ----------------------------------------------

-(BOOL) allowsArticleSetDrop: (NSSet*) articleSet
{
    return NO;
}

-(BOOL) dropArticleSet: (NSSet*) articleSet
{
    return NO;
}

-(BOOL) allowsArticleSetRemoval: (NSSet*) articleSet
{
    return NO;
}

-(BOOL) removeArticleSet: (NSSet*) articleSet
{
    return NO;
}


// ----------------------------------------------
//    Overridden fetching methods
// ----------------------------------------------

-(void) fetchInBackground
{
    [self beginsFetching];
    [super fetchInBackground];
}

-(enum RSSFeedError) fetch
{
    [self beginsFetching];
    return [super fetch];
}

@end


// ----------------------------------------------
//    Private methods impl
// ----------------------------------------------
@implementation Feed (Private)

// ----------------------------------------------
//    Gets executed when fetching starts
//    and applies proxy settings if possible
// ----------------------------------------------

-(void) beginsFetching
{
	// FIXME: why was this enabled only for GNUstep?
#ifdef GNUSTEP
    [feedURL applyProxySettings];
#endif
}

@end



