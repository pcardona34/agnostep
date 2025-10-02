/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2010-2019 The Free Software Foundation, Inc.
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

#import <Foundation/NSObject.h>
#import <Foundation/NSURL.h>
#import "RSSFeedProtocol.h"

/**
 * When an article changes, it sends this notification with itself
 * as notification object.
 */
extern NSString* RSSArticleChangedNotification;



/**
 * Classes implementing this protocol can be used as RSSArticles.
 */
@protocol RSSArticle <NSObject>
/// @return The headline of the article
- (NSString*) headline;

/// @return The URL of the full version of the article
- (NSURL*) url;

/// @return The full text, an excerpt or a summary from the article
- (NSString*) content;

/** 
 * Returns an NSArray containing NSURL objects or nil,
 * if there are none. The contained NSURL objects often
 * have the "type" and "rel" properties set. See the
 * documentation for addLink: for details.
 *
 * @return The links of the article.
 */
- (NSArray*) links;

/**
 * Returns the date of the publication of the article.
 * If the source feed of this article didn't contain information
 * about this date, the fetching date is usually returned.
 *
 * @return The date of the publication of the article
 */
- (NSDate*) date;

/**
 * Returns the Enclosure object of this article as URL.
 * If there is no enclosure object, nil is returned.
 * 
 * @return the URL of this article's enclosure object
 */
- (NSURL*) enclosure;


/**
 * Returns the source feed of this article.
 *
 * @warning It's not guaranteed that this object actually exists.
 *          Be aware of segmentation faults!
 *
 * If you want to make sure the object exists, you have to follow
 * these rules:
 *
 * <ul>
 *  <li>Don't retain any article!</li>
 *  <li>Don't call the (undocumented) <code>setFeed:</code> (Colon!) method.</li>
 * </ul>
 * 
 * @return The source feed of this article
 */
- (id<RSSFeed>) feed;
 
/**
 * This method is intended to make sure that the replacing article keeps
 * some fields from the old (this) article. Subclasses will probably want
 * to override this, but shouldn't forget calling the super implementation,
 * first.
 */
- (void) willBeReplacedByArticle: (id) newArticle;

@end

/**
 * Instances conforming to this protocol can be modified. Applications
 * usually don't want to modify articles, as they are already created by the
 * feeds, so handing around articles as id<RSSArticle> is a good way to ensure
 * nobody (without malicious intentions) is going to change them.
 */
@protocol RSSMutableArticle <RSSArticle>

/**
 * Adds a new link to this article.
 * This is a RSSLink object, which usually has
 * the "type" property set to an NSString which
 * represents the resource's MIME type. You may
 * also specify the "rel" property, which should
 * be one of "enclosure", "related", "alternate",
 * "via".
 */
- (void) addLink:(NSURL*) anURL;

/**
 * Replaces the list of links with a new one.
 * See the documentation for addLink: for details.
 * Hint: The parameter may also be nil.
 */
- (void) setLinks: (NSArray*) someLinks;

// only used internally
- (void) setFeed: (id) aFeed;

/**
 * Sets the article's date.
 */
- (void) setDate: (NSDate*) aDate;

@end

