/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2006 Guenther Noack
 *                2010-2019 Free Software Foundation, Inc
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


#import "RSSFeed.h"
#import "RSSFeed+Fetching.h"
#import "GNUstep.h"



// --------------------------------------------------------
//    the main part of the RSSFeed class
// --------------------------------------------------------

@implementation RSSFeed

+ (RSSFeed *) feed
{
  return AUTORELEASE([[self alloc] init]);
}

+ (RSSFeed *) feedWithURL: (NSURL*) aURL
{
  return AUTORELEASE([[self alloc] initWithURL: aURL]);
}

- (id) init
{
  return [self initWithURL: nil];
}


/**
 * Designated initializer
 */
- (id) initWithURL: (NSURL*) aURL
{
  self = [super init];
  if (self)
    {
#ifdef DEBUG
      NSLog(@"(newFeed) initWithURL: %@", aURL);
#endif
  
      ASSIGN(feedURL, aURL);
      ASSIGN(articles, AUTORELEASE([NSMutableArray new]));
      ASSIGN(lastRetrieval, [NSDate dateWithTimeIntervalSince1970: 0.0]);
      clearFeedBeforeFetching = YES;
      lastError = RSSFeedErrorNoError;
      feedName = nil;
      articleClass = [RSSArticle class];
      rssVersion = nil;
      status = RSSFeedIsIdle;
    }
  return self;
}

- (void) dealloc
{
  DESTROY(feedURL);
  DESTROY(articles);
  DESTROY(lastRetrieval);
  DESTROY(cacheData);
  [super dealloc];
}


-(NSString*) description
{
  return [self feedName];
}



// access to the status, deprecated
- (enum RSSFeedStatus) status
{
  return status;
}


- (BOOL) isFetching
{
  return (status == RSSFeedIsFetching) ? YES : NO;
}



/**
 * Implementation of the NewRSSArticleListener protocol.
 */
-(void) newArticleFound: (id) anArticle
{
  NSUInteger oldArticleIdx;
  NSAssert([articles isKindOfClass: [NSMutableArray class]], @"articles not mutable!");
  
  oldArticleIdx = [articles indexOfObject: anArticle];
  if (oldArticleIdx != NSNotFound) {
      // replace the found older version with the new one, but first
      // make sure local changes to the old version get transferred to
      // the new version. (This is why this method is passed a mutable
      // article.)
      id<RSSArticle> oldArticle = [articles objectAtIndex: oldArticleIdx];
      
      // lets oldArticle transfer some of its preferences to anArticle.
      [oldArticle willBeReplacedByArticle: anArticle];
      
      [articles replaceObjectAtIndex: oldArticleIdx
                          withObject: anArticle];
  } else {
      // article was not known yet - so we can just add it.
      [articles addObject: anArticle];
  }
}



// access to the articles


- (NSEnumerator*) articleEnumerator
{  
  return AUTORELEASE(RETAIN([articles objectEnumerator]));
}


/**
 * @return a set that contains this feed's articles
 */
- (NSSet*) articleSet
{
  return [NSSet setWithArray: articles];
}

/**
 * @return the number of articles in this feed
 */
- (int) articleCount
{
  return [articles count];
}


- (void) removeArticle: (RSSArticle*) article
{
  [articles removeObject: article];
}



// preferences

/**
 * Sets the feed name
 */
- (void) setFeedName: (NSString*) aFeedName
{
  ASSIGN(feedName, aFeedName);
}


- (NSString*) feedName
{
  if (feedName == nil)
    {
      return @"Unnamed feed";
    }
  else
    {
      return AUTORELEASE(RETAIN(feedName));
    }
}

- (NSURL*) feedURL
{
  if (feedURL == nil)
    {
      return nil;
    }
  else
    {
      return AUTORELEASE(RETAIN(feedURL));
    }
}

// Equality and hash codes
- (NSUInteger) hash
{
  return [feedURL hash];
}

- (BOOL) isEqual: (id)anObject
{
  if ([self class] != [anObject class]) {
    return NO;
  }
  
  return [feedURL isEqual: [anObject feedURL]];
}


// Sets the automatic clearing of the feed.
- (void) setAutoClear: (BOOL) autoClear
{
  clearFeedBeforeFetching = autoClear;
}

- (BOOL) autoClear;
{
  return clearFeedBeforeFetching;
}

/**
 * Clears the article list.
 * NOT SYNCHRONIZED!
 */
- (void) clearArticles
{
  // Delete and recreate the list of articles.
  ASSIGN(articles, AUTORELEASE([NSMutableArray new]));
  
  // FIXME: Find out why I did this! -GN
  ASSIGN(lastRetrieval, [NSDate dateWithTimeIntervalSince1970: 0.0]);
}


-(void) setArticleClass:(Class)aClass
{
  if ([aClass isSubclassOfClass: [RSSArticle class]])
    {
      articleClass = aClass;
    }
}

/**
 * Returns the class of the article objects. This needs to be a subclass
 * of RSSArticle. (Also needed to implement the NewRSSArticleListener
 * class)
 *
 * @return the article class
 */
-(Class) articleClass
{
  return articleClass;
}


-(NSDate*) lastRetrieval
{
  return AUTORELEASE(RETAIN(lastRetrieval));
}

@end

