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


#import <objc/objc.h>
#import <Foundation/Foundation.h>

@class RSSArticle;

#import "RSSFeed.h"
#import "RSSArticleProtocol.h"



/**
 * An object of this class represents an article in an RSS Feed.
 */
@interface RSSArticle : NSObject <RSSMutableArticle>
{
  @protected
  NSString*  headline;
  NSURL*     url;
  NSString*  description;
  NSDate*    date;

  @private
  NSURL*     enclosure;
  
  /// Links and multimedia content
  NSMutableArray* links;
  
  id<RSSFeed> feed;
}

/**
 * Standard initializer. You shouldn't use this. Better use
 * initWithHeadline:url:description:date:
 *
 * @see initWithHeadline:url:description:date:
 */
-init;

/**
 * Designated initializer for the RSSArticle class.
 *
 * Don't create RSSArticle objects yourself. Create a RSSFeed
 * object and let it fetch the articles for you!
 *
 * @param myHeadline A NSString containing the headline of the article.
 * @param myUrl A NSString containing the URL of the
 *              full version of the article.
 * @param myDescription An excerpt of the article text or the full text.
 * @param myDate The date as NSDate object on which this article was posted.
 * @see RSSFeed
 */
-initWithHeadline: (NSString*) myHeadline
	      url: (NSURL*)    myUrl
      description: (NSString*) myDescription
	     date: (NSDate*)   myDate;



-(void) dealloc;


// Accessor methods (conformance to RSSArticle protocol)
-(NSString*)headline;
-(NSURL*)url;
-(NSString*)content;
-(NSString*)description;
-(NSArray*) links;
-(NSDate*) date;
-(NSURL*)enclosure;

// Mutability methods (conformance to RSSMutableArticle protocol)
-(void)addLink:(NSURL*) anURL;
-(void)setLinks: (NSArray*) someLinks;
-(void)setFeed: (id<RSSMutableFeed>) aFeed;
-(void)setDate: (NSDate*) aDate;

/**
 * Sends a change notification to the notification center.
 * Useful for subclassing.
 */
-(void)notifyChange;


// Equality and hash codes
- (BOOL) isEqual: (id)anObject;

/**
 * This method is intended to make sure that the replacing article keeps
 * some fields from the old (this) article. Subclasses will probably want
 * to override this, but shouldn't forget calling the super implementation,
 * first.
 */
-(void)willBeReplacedByArticle: (id<RSSMutableArticle>) newArticle;

@end
