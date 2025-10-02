/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2010-2017 The Free Software Foundation, Inc.
 *                2006      Guenther Noack
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

#import <objc/objc.h>
#import <Foundation/Foundation.h>

#import "RSSFeedProtocol.h"


#import "RSSArticle.h"

/**
 * The states that the RSS feed can have.
 */
enum RSSFeedStatus
  {
    RSSFeedIsFetching,
    RSSFeedIsIdle
  };


/**
 * Objects of this class represent a RSS/ATOM feed, which is basically
 * just a source for new articles. When creating a RSSFeed object, you'll
 * just have to provide it with the URL, where the feed can be downloaded
 * from.
 * 
 * This is the generic way to read feeds:
 *
 * <ul>
 *  <li>Create a URL object with the location of the feed.<br>
 *    <code>
 *      NSURL*   url =
 *         [NSURL URLWithString:@"http://www.example.com/feed.xml"];
 *    </code>
 *  </li>
 *  <li>Create a RSSFeed object with the URL:<br>
 *    <code>
 *      RSSFeed* feed = [RSSFeed initWithURL: url];
 *    </code>
 *  </li>
 *  <li>Fetch the contents of the feed:<br>
 *    <code>
 *      [feed fetch]; // alternatively [feed fetchInBackground];
 *    </code>
 *  </li>
 *  <li>Optionally tell the RSSFeed to keep old articles.<br>
 *    <code>
 *      [feed setAutoClear: NO];
 *    </code>
 *  </li>
 *  <li>Retrieve the set of articles.
 *    <code>
 *      NSSet* articles = [feed articleSet];
 *    </code>
 *  </li>
 * </ul>
 *
 *
 * @see initWithURL:
 * @see fetch
 * @see setAutoClear:
 *
 * @see RSSArticle
 * @see NSURL
 */
@interface RSSFeed : NSObject <RSSMutableFeed>
{
@protected
  NSDate*           lastRetrieval;
  BOOL              clearFeedBeforeFetching;
  NSMutableArray*   articles;
  enum RSSFeedError lastError;
  NSString*         feedName;
  NSURL*            feedURL;
  Class             articleClass;
  NSString*         rssVersion;
  
  enum RSSFeedStatus status;

  NSMutableData *cacheData; // Used only when load in background.
}


+ (RSSFeed *) feed;
+ (RSSFeed *) feedWithURL: (NSURL*) aURL;

- (id) init;

/**
 * Designated initializer.
 * 
 * @param aURL The URL where the feed can be downloaded from.
 */
- (id) initWithURL: (NSURL*) aURL;


/**
 * @return Description of the Feed (the feed name)
 */
-(NSString*) description;


// ----------------------------------------------------------------------
// Status access
// ----------------------------------------------------------------------

/**
 * Returns YES if and only if this feed is currently being fetched.
 */
- (BOOL)isFetching;

// ----------------------------------------------------------------------
// Access to the articles
// ----------------------------------------------------------------------

// Note: please refer to RSSFeed protocol instead.

/**
 * @return an enumerator for the articles in this feed
 */
- (NSEnumerator*) articleEnumerator;

/**
 * Deletes an article from the feed.
 *
 * @param article The index of the article to delete.
 */
- (void) removeArticle: (RSSArticle*) article;



// ----------------------------------------------------------------------
// Access to the preferences
// ----------------------------------------------------------------------

/**
 * Sets the feed name
 */
- (void) setFeedName: (NSString*) aFeedName;

/**
 * @return The name of the feed
 */
- (NSString*) feedName;

/**
 * @return the URL where the feed can be downloaded from (as NSURL object)
 * @see NSURL
 */
- (NSURL*) feedURL;



// --------------------------------------------------------------------
// Equality and hash codes
// --------------------------------------------------------------------
- (BOOL) isEqual: (id)anObject;


// --------------------------------------------------------------------
// Accessor and Mutator for the automatic clearing
// --------------------------------------------------------------------



/**
 * Clears the list of articles.
 */
- (void) clearArticles;



// ------------------------------------------------------------------
// Extensions that make subclassing RSSFeed and RSSArticle easier.
// ------------------------------------------------------------------

/**
 * Sets the class of the article objects. This needs to be a subtype
 * of RSSArticle.
 *
 * @param aClass The class newly created article objects should have.
 */
-(void) setArticleClass:(Class)aClass;

/**
 * Returns the class of the article objects. This will be a subtype
 * of RSSArticle.
 *
 * @return the article class
 */
-(Class) articleClass;


// ------------------------------------------------------------------
// Dirtyness, now implemented via the date of last retrieval
// ------------------------------------------------------------------

/**
 * Returns the date of last retrieval of this feed.
 * If the feed hasn't been retrieved yet, this method returns nil.
 *
 * @return The date of last retrieval as a NSDate pointer.
 */
-(NSDate*) lastRetrieval;


/**
 * RSSFeed also implements the NewRSSArticleListener informal protocol.
 */
-(void) newArticleFound: (id) anArticle;

@end


