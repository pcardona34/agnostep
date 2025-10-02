/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2019      The Free Software Foundation, Inc.
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


#import "RSSFeed.h"

/*
 * The RSSArticleCreationListener is a object which collects things
 * to put into a new article and puts the articles together.
 * It does what otherwise every individual RSS-style parser had to do
 * for itself.
 */
@interface RSSArticleComposer : NSObject
{
  //RSSFeed* currentFeed;
  id delegate;
  
  NSString* headline;
  NSURL* url;
  NSString* summary;
  NSString* content;
  NSDate* date;
  
  NSMutableArray* links;
  
  //NSMutableArray* currentArticleList;
}

// Initializers & Deallocation
//-(id) initWithFeed: (RSSFeed*) aFeed;
-(id) init;
-(void) dealloc;

// delegate accessors
-(void) setDelegate: (id)aDelegate;
-(id) delegate;

// Basic control
-(void) nextArticle;
-(void) startArticle;
-(void) commitArticle;
-(void) finished;

//-(void) setFeed: (RSSFeed*) aFeed;

// Collecting of article content
-(void) setHeadline: (NSString*) aHeadline;
-(void) addLinkWithURL: (NSString*) anURL;
-(void) addLinkWithURL: (NSString*) anURL
		andRel: (NSString*) aRelation;
-(void) addLinkWithURL: (NSString*) anURL
		andRel: (NSString*) aRelation
	       andType: (NSString*) aType;
-(void) setContent: (NSString*) aContent;
-(void) setSummary: (NSString*) aSummary;
-(void) setDate: (NSDate*) aDate;

// setDate:, but also converts date.
-(void) setDateFromString: (NSString*) str;


@end

