/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2006 Guenther Noack
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

/**
 * The ,,Fetching'' category of RSSFeed contains methods
 * for the RSSFeed class, which are responsible for fetching
 * and parsing feeds.
 */
@interface RSSFeed (Fetching)

/**
 * Returns the last fetching error.
 */
- (enum RSSFeedError) lastError;

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
