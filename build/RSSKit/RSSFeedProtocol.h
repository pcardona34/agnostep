/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2010-2014 The Free Software Foundation, Inc.
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

#import <Foundation/Foundation.h>

// --- Notifications ---

/** 
 * When feed finishes parsing, it posts this notification
 * with itself as object and nil for userInfo.
 **/
extern NSString *const RSSFeedFetchedNotification;

/**
 * When feed fetching in background failed or feed fails to process data,
 * it posts this notification
 * with itself as object.
 * userInfo: @"Reason" for a string of failed reason. It could be nil.
 **/
extern NSString *const RSSFeedFetchFailedNotification;

/**
 * When a feed is about to fetch, it first posts this notification
 * with itself as object and nil as userInfo.
 */
extern NSString *const RSSFeedWillFetchNotification;

// ---------------------

/**
 * The errors that can occur when fetching a feed.
 */
enum RSSFeedError
  {
    RSSFeedErrorNoError = 0,         ///< No error occured
    RSSFeedErrorNoFetcherError,      ///< @deprecated
    RSSFeedErrorMalformedURL,        ///< Malformed URL
    RSSFeedErrorDomainNotKnown,      ///< Domain not known
    RSSFeedErrorServerNotReachable,  ///< Server not reachable
    RSSFeedErrorDocumentNotPresent,  ///< Document not present on server
    RSSFeedErrorMalformedRSS         ///< Malformed RSS / Parsing error
  };


/**
 * The RSS feed protocol defines the way users are supposed to talk to
 * a feed.
 */
@protocol RSSFeed

// Article access

/**
 * @return an enumerator for the articles in this feed
 */
- (NSEnumerator*) articleEnumerator;

/**
 * @return a set that contains this feed's articles
 */
- (NSSet*) articleSet;

/**
 * @return the number of articles in this feed
 */
- (int) articleCount;


/**
 * @return The name of the feed
 */
- (NSString*) feedName;

/**
 * @return the URL where the feed can be downloaded from (as NSURL object)
 * @see NSURL
 */
- (NSURL*) feedURL;


/**
 * @return YES, if the automatic clearing of the article list is
 *         enabled for this feed. NO otherwise.
 */
- (BOOL) autoClear;


@end

@protocol RSSMutableFeed <RSSFeed>
/**
 * Deletes an article from the feed.
 *
 * @param article The article to delete.
 */
- (void) removeArticle: (id) article;


/**
 * Sets the feed name
 */
- (void) setFeedName: (NSString*) aFeedName;


/**
 * Lets you decide if the feed should be cleared before new
 * articles are downloaded.
 *
 * @param autoClear YES, if the feed should clear its article list
 *                  before fetching new articles. NO otherwise
 */
- (void) setAutoClear: (BOOL) autoClear;


@end

@protocol RSSFeedFetching <RSSFeed>

/**
 * Returns YES if and only if this feed is currently being fetched.
 */
- (BOOL)isFetching;

/**
 * Fetches the feed from the web.
 *
 * @return An error number (of type enum RSSFeedError)
 * @see NSURL
 * @see RSSFeedError
 */
- (enum RSSFeedError) fetch;

/**
 * Fetches the feed from the web. Feed fetching is done
 * in the background. When the feed is fetched, the feed
 * will post a RSSFeedFetchedNotification.
 *
 * @see RSSFeedFetchedNotification
 **/
- (void) fetchInBackground;


@end

