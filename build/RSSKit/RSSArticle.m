
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

#import "RSSLinks.h"
#import "RSSArticle.h"
#import "RSSArticle+Storage.h"

#import "GNUstep.h"


// change notification
NSString* RSSArticleChangedNotification = @"RSSArticleChangedNotification";



@implementation RSSArticle


- (id) init
{
  return [self initWithHeadline: @"no headline"
	       url: nil
	       description: @"no description"
	       date: AUTORELEASE([NSDate new]) ];
}


- (id) initWithHeadline: (NSString*) myHeadline
	      url: (NSURL*)    myUrl
      description: (NSString*) myDescription
	     date: (NSDate*)   myDate
{
  self = [super init];
  if (self)
    {
      ASSIGN(headline, myHeadline);
      ASSIGN(url, myUrl);
      ASSIGN(description, myDescription);
      ASSIGN(date, myDate);
      ASSIGN(links, AUTORELEASE([[NSMutableArray alloc] init]));
    }
  return self;
}


- (void) dealloc
{
  RELEASE(headline);
  RELEASE(url);
  RELEASE(description);
  RELEASE(date);
  RELEASE(links);
  
  [super dealloc];
}

- (NSString *) headline
{
  return headline;
}

- (NSURL *) url
{
  return url;
}

- (NSString *) description
{
  return headline;
}

- (NSString*) content
{
  return AUTORELEASE(RETAIN(description));
}

- (NSDate*) date
{
  return date;
}

- (void) setDate: (NSDate*) aDate
{
    ASSIGN(date, aDate);
}

- (void) setFeed:(id<RSSMutableFeed>)aFeed
{
  // Feed is NON-RETAINED!
  feed = aFeed;
  [self notifyChange];
}

-(void)notifyChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName: RSSArticleChangedNotification
                                                        object: self];
}

- (id<RSSFeed>) feed
{
  // Feed is NON-RETAINED!
  return feed;
}


/**
 * This method is intended to make sure that the replacing article keeps
 * some fields from the old (this) article. Subclasses will probably want
 * to override this, but shouldn't forget calling the super implementation,
 * first.
 */
-(void) willBeReplacedByArticle: (id<RSSMutableArticle>) newArticle
{
    NSParameterAssert(newArticle != nil);
    NSParameterAssert(self != newArticle);
    NSParameterAssert([self isEqual: newArticle] == YES);
    
    // Date stays the same. For everything else, the newer version is better.
    [newArticle setDate: date];
}


- (NSURL*) enclosure
{
    return [[enclosure retain] autorelease];
}

/*
 * This method checks if the specified link is a enclosure. If it is, it is
 * stored in the article's enclosure field so that it can be easily returned
 * using the -enclosure method.
 */
-(void)_checkLinkForEnclosure: (NSURL*)link
{
    if ([link isKindOfClass: [RSSEnclosureLink class]]) {
        ASSIGN(enclosure, link);
    }
}

- (void) setLinks: (NSArray *) someLinks
{
  int i;
  DESTROY(enclosure);
  
  [links setArray: someLinks];
  
  for (i=0; i<[links count]; i++) {
      [self _checkLinkForEnclosure: [links objectAtIndex: i]];
  }
  
  [self notifyChange];
}

- (void) addLink: (NSURL *) anURL
{
  if (anURL == nil)
    return;
  
  [links addObject: anURL];
  
  [self _checkLinkForEnclosure: anURL];
  
  [self notifyChange];
}

- (NSArray *) links
{
  return links;
}

// Equality and hash codes
- (NSUInteger) hash
{
  return [headline hash] ^ [url hash];
}

/**
 * RSS Articles are equal if both the article headlines
 * and the article URLs are equal. If they are equal is
 * tested by calling the isEqual: method on those.
 */
- (BOOL) isEqual: (id)anObject
{
  if ( ( [headline isEqualToString: [anObject headline]] == YES ) &&
       ( [url      isEqualTo:       [anObject url]]      == YES ) )
    {
      return YES;
    }
  else
    {
      return NO;
    }
}


@end

