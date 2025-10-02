/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2006 Guenther Noack
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as
 *  published by the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA
 */

#import "RSSArticle.h"

/**
 * This protocol is intended to be implemented by classes which want to
 * be notified of articles found when parsing RSS feeds.
 */
@interface NSObject (NewRSSArticleListener)

/**
 * This method gets called when a new article has been found.
 */
-(void) newArticleFound: (id<RSSArticle>) anArticle;

/**
 * Returns the class of the article objects. This needs to be a subclass
 * of RSSArticle.
 *
 * @return the article class
 */
-(Class) articleClass;

/**
 * Gets called when a feed title has been found in a feed.
 */
-(void) feedTitleFound: (NSString*) aTitle;

@end
