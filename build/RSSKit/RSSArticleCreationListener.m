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

#import <Foundation/Foundation.h>

#import "RSSLinks.h"
#import "NewRSSArticleListener.h"
#import "RSSArticleCreationListener.h"
#import "DublinCore.h"
#import "RSSFactory.h"

#import "GNUstep.h"

#define REL_KEY @"rel"
#define TYPE_KEY @"type"


@implementation RSSArticleComposer

-(id) init
{
  return [super init];
}

-(void) dealloc
{
  DESTROY(headline);
  DESTROY(url);
  DESTROY(summary);
  DESTROY(content);
  DESTROY(date);
  
  DESTROY(links);
  
  [super dealloc];
}


//delegate accessor methods

- (void) setDelegate: (id)aDelegate
{
  ASSIGN(delegate, aDelegate);
}

- (id) delegate
{
  return delegate;
}



/**
 * Adds the article to the feed
 */
- (void) commitArticle
{
  id<RSSArticle> article = nil;
  NSDate* articleDate = nil;
  NSString* desc = nil;
  id<RSSMutableArticle> mutArt;
  
  // date
  if( date == nil )
    {
      ASSIGN(articleDate, [NSDate date]);
    }
  else
    {
      ASSIGN(articleDate, date);
    }
  
  // description
  if (content != nil)
    {
      ASSIGN(desc, content);
    }
  else if (summary != nil)
    {
      ASSIGN(desc, summary);
    }
  else
    {
      ASSIGN(desc, @"No content.");
    }
 
  // url
  if (url == nil) {
      NSAssert1([links count] > 0, @"Article %@ has no links!", headline);
      
      // better use a bad (="random") link as article URL than none
      ASSIGN(url, [links objectAtIndex: 0]);
  } 
  
  // create
  article = [[RSSFactory sharedFactory] articleWithHeadline: headline
	                                                  URL: url
	                                              content: desc
	                                                 date: articleDate];
  // FIXME: This article creation was retained before, but it seems okay like that?
  // Was it a memory leak or am I having memory management problems now?
  
  NSAssert1(
      [article conformsToProtocol: @protocol(RSSMutableArticle)],
      @"Article %@ must be mutable for proper creation!", article
  );
  
  mutArt = (id<RSSMutableArticle>) article;
  // add links
  if ([links count] > 0)
    {
      [mutArt setLinks: links];
    }
  
  if (delegate != nil)
    [delegate newArticleFound: article];
  
  DESTROY(articleDate);
  DESTROY(desc);
}


/**
 * Gets called whenever a feed has been parsed completely.
 */
-(void) finished
{
  #ifdef DEBUG
  NSLog(@"%@ finished, rc=%"PRIuPTR"", self, [self retainCount]);
  #endif
  
  // empty at the moment, may be useful for things like thread locking
  // in the future.
}


/**
 * Starts a new article
 */
-(void) startArticle
{
  #ifdef DEBUG
  NSLog(@"start article");
  
  NSLog(@"retain counts in start article: %"PRIuPTR" %"PRIuPTR" %"PRIuPTR"",
	[headline retainCount],
	[links retainCount],
	[date retainCount]);
  #endif
  
  // Free all old stuff
  DESTROY(headline);
  DESTROY(url);
  DESTROY(summary);
  DESTROY(content);
  DESTROY(date);
  
  DESTROY(links);
  
  // Set default values
  [self setHeadline: @"No headline"];
  
  ASSIGN(links, AUTORELEASE([[NSMutableArray alloc] initWithCapacity: 1]));
}

// don't use this, use commitArticle
// and startArticle directly instead!
-(void) nextArticle
{
  #ifdef DEBUG
  NSLog(@"Warning: nextArticle should not be called.");
  #endif
  
  [self commitArticle];
  [self startArticle];
}


-(void)setHeadline: (NSString*) aHeadline
{
  ASSIGN(headline, aHeadline);
}

-(void) addLinkWithURL: (NSString*) anURL
{
  // default is 'alternate', see ATOM specification!
  [self addLinkWithURL: anURL
	andRel: @"alternate"];
}

-(void) addLinkWithURL: (NSString*) anURL
		andRel: (NSString*) aRelation
{
  [self addLinkWithURL: anURL
	andRel: aRelation
	andType: nil];
}

/**
 * Adds a link with a specified URL, relation type and file type.
 * 
 * Relation type is one of:
 * <ul>
 *  <li>"alternate": This link leads to an alternative location where
 *                   this article's contents can be found.</li>
 *  <li>"enclosure": A related resource which is probably large in size.
 *                   This may link to a movie, a mp3 file, etc.</li>
 *  <li>"related":   A related document</li>
 *  <li>"self":      The feed itself</li>
 *  <li>"via":       The source of the information provided in the entry.</li>
 * </ul>
 *
 * The <tt>nil</tt> relation type defaults to "related".
 * 
 * These relation types are compatible with the ones of the ATOM
 * specification. For details, see
 * <a href="http://www.atomenabled.org/developers/syndication/#link">
 * the ATOM specification.</a>
 */
-(void) addLinkWithURL: (NSString*) anURL
		andRel: (NSString*) aRelation
	       andType: (NSString*) aType
{
  RSSLink* link;

#ifdef DEBUG
  NSLog(@"addLinkWithURL: %@ andRel: %@ andType: %@",
	anURL, aRelation, aType);
#endif
  link = [RSSLink linkWithString: anURL
			     andRel: aRelation
			     andType: aType];
  /* Keep the default URL */
  if (url == nil && [aRelation isEqualToString: @"alternate"]) {
    ASSIGN(url, [NSURL URLWithString:anURL]);
  }
  
  if (link) {
    [links addObject: link];
  } else {
    NSLog(@"Link is nil: href: %@; rel: %@; type: %@", anURL, aRelation, aType);
  }
  
  
#ifdef DEBUG
  NSLog(@"links is now %@", links);
#endif
}

-(void) setContent: (NSString*) aContent
{
  ASSIGN(content, aContent);
}

-(void) setSummary: (NSString*) aSummary
{
  ASSIGN(summary, aSummary);
}

-(void) setDate: (NSDate*) aDate
{
  ASSIGN(date, aDate);
}

-(void) setDateFromString: (NSString*) str
{
    int i;
    NSDate* d;
    static NSArray* timeformats = nil;
    
    if (timeformats == nil) {
        // Everything that can be found in the wild is considered 'verified'.
        timeformats = [[NSArray alloc] initWithObjects:
            @"%a, %d %b %Y %H:%M:%S %z", // blogspot

            @"%a, %d %b %Y %H:%M:%S %Z", // found in thedailywtf, RFC822?
            @"%a, %d %b %Y %H:%M %Z",
            @"%a, %d %B %Y %H:%M:%S %Z", // same with full month name
            @"%a, %d %b %Y %H:%M:%S %z", 
            @"%a, %d %B %Y %H:%M:%S %z",

            @"%B %d, %Y", 
            @"%b %d, %Y", // verified by example
            @"%d %b %Y %H:%M:%S %Z", // verified by example (Joel on Software)
            @"%d %b %Y %H:%M:%S",    // not verified, derived from the upper
            @"%d %b %Y",             // not verified, derived from the upper
            // Dublin Core
            @"%Y-%m-%dT%H:%M:%S%Z",
            @"%Y-%m-%dT%H:%M:%S",
            @"%Y-%m-%dT%H:%M", 
            @"%Y-%m-%d", 
            @"%Y-%m", 
            @"%Y", 
            nil
        ];
    }
    
    d = nil;
    for (i=0; i<[timeformats count] && d == nil; i++) {
        d = [NSCalendarDate dateWithString: str
                            calendarFormat: [timeformats objectAtIndex: i]
        ];
    }
    if (d!=nil)
        NSLog(@"Date=%@, calc'd from %@, which matched to %@ (%dth try)", d, str, [timeformats objectAtIndex: i], i);
    else
        NSLog(@"Could not parse Date: %@", str);
    
   
    if (d==nil) {
        d = parseDublinCoreDate(str); // resistance is futile, nasty timezone definition!
    }
    
    if (d != nil) {
        [self setDate: d];
    }
}

@end
