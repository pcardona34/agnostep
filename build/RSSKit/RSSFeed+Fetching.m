/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2006 Guenther Noack
 *                2017 Free Software Foundation, Inc
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


#import "RSSFeed+Fetching.h"
#import "RSSFeedProtocol.h"
#import "DublinCore.h"
#import "GNUstep.h"

// #define DEBUG 1


#import "DOMParser.h"

#import "FeedParser.h"
#import "Atom03Parser.h"
#import "Atom10Parser.h"
#import "RSS10Parser.h"
#import "RSS20Parser.h"

NSString *const RSSFeedFetchedNotification = @"RSSFeedFetchedNotification";
NSString *const RSSFeedWillFetchNotification = @"RSSFeedWillFetchNotification";
NSString *const RSSFeedFetchFailedNotification = @"RSSFeedFetchFailedNotification";

#define URI_ATOM10              @"http://www.w3.org/2005/Atom"
#define URI_PURL_CONTENT        @"http://purl.org/rss/1.0/modules/content/"
#define URI_PODCAST             @"http://www.itunes.com/dtds/podcast-1.0.dtd"
#define URI_PURL_CONTENT        @"http://purl.org/rss/1.0/modules/content/"
#define URI_PODCAST             @"http://www.itunes.com/dtds/podcast-1.0.dtd"
#define URI_PURL_DUBLINCORE     @"http://purl.org/dc/elements/1.1/"



@interface RSSFeed (PrivateFetching)
-(NSData*) fetchDataFromURL: (NSURL*) myURL;
-(enum RSSFeedError) fetchWithData: (NSData*)data;

-(enum RSSFeedError) parseATOM03WithRootNode: (XMLNode*) root;
-(enum RSSFeedError) parseATOM10WithRootNode: (XMLNode*) root;
-(enum RSSFeedError) parseRSS10WithRootNode: (XMLNode*) root;
-(enum RSSFeedError) parseRSS20WithRootNode: (XMLNode*) root;

- (enum RSSFeedError) setError: (enum RSSFeedError) err;
@end




@implementation RSSFeed (PrivateFetching)
/**
 * URL client 
 */
- (void) URL: (NSURL *) sender 
         resourceDidFailedLoadingWithReason: (NSString *) reason
{
  /* Make sure it is ours */
  if (sender != feedURL) 
    return;

  NSLog(@"URL %@ failed loading because of %@", sender, reason);
  [self setError: RSSFeedErrorMalformedURL];
  [cacheData setLength: 0]; /* Clean up cache */
  status = RSSFeedIsIdle;
  [[NSNotificationCenter defaultCenter]
       postNotificationName: RSSFeedFetchFailedNotification
       object: self
       userInfo: [NSDictionary dictionaryWithObject: reason forKey: @"Reason"]];
}

- (void) URL: (NSURL *) sender
         resourceDataDidBecomeAvailable: (NSData *) newBytes
{
  /* Make sure it is ours */
  if (sender != feedURL) 
    return;

  if (cacheData == nil) {
    ASSIGN(cacheData, [NSMutableData data]);
  }
  [cacheData appendData: newBytes];
}

- (void) URLResourceDidFinishLoading: (NSURL *) sender
{
  /* Make sure it is ours */
  if (sender != feedURL) 
    return;

  NSLog(@"%@ finished loading %@", self, sender);
  
  if ((cacheData == nil) && [cacheData length] == 0) {
    NSLog(@"No Data");
  }
  [self fetchWithData: cacheData];
  status = RSSFeedIsIdle;
  
  /* Clean up cache */
  [cacheData setLength: 0];
  NSLog(@"Process Done");
}

/**
 * Fetches the feed from the URL which is stored in the myURL
 * argument
 */
-(NSData*) fetchDataFromURL: (NSURL*) myURL
{
   NSData* data;
   
   if (myURL == nil) {
       [self setError: RSSFeedErrorMalformedURL];
   }
   
   data = [myURL resourceDataUsingCache: NO];
   
   if (data == nil) {
       [self setError: RSSFeedErrorServerNotReachable];
   }
   
   return [[data retain] autorelease];
}




// parse ATOM 1.0
-(enum RSSFeedError) parseATOM10WithRootNode: (XMLNode*) root
{
  FeedParser* parser = [Atom10Parser parserWithDelegate: self];
  [parser parseWithRootNode: root];
  return RSSFeedErrorNoError;
}

// parse ATOM 0.3
-(enum RSSFeedError) parseATOM03WithRootNode: (XMLNode*) root
{
  FeedParser* parser = [Atom03Parser parserWithDelegate: self];
  [parser parseWithRootNode: root];
  return RSSFeedErrorNoError;
}

// parse RSS 2.0
-(enum RSSFeedError) parseRSS20WithRootNode: (XMLNode*) root
{
  FeedParser* parser = [RSS20Parser parserWithDelegate: self];
  [parser parseWithRootNode: root];
  return RSSFeedErrorNoError;
}

// parse RSS 1.0
-(enum RSSFeedError) parseRSS10WithRootNode: (XMLNode*) root
{
  FeedParser* parser = [RSS10Parser parserWithDelegate: self];
  [parser parseWithRootNode: root];
  return RSSFeedErrorNoError;
}



/**
 * @private
 * Uses the feed contained in data instead of the URL.
 */
-(enum RSSFeedError) fetchWithData: (NSData*)data
{ 
  NSXMLParser* parser;
  XMLNode* root;
  XMLNode* document;
  int i;
  
  parser = AUTORELEASE([[NSXMLParser alloc] initWithData: data]);
  
  document = AUTORELEASE([[XMLNode alloc]
			   initWithName: nil
			   namespace: nil
			   attributes: nil
			   parent: nil]);
  
  [parser setDelegate: document];
  [parser setShouldProcessNamespaces: YES]; 
  
  if ([parser parse] == NO)
    {
      return [self setError: RSSFeedErrorMalformedRSS];
    }
  
  root = [document firstChildElement]; // finds the root node
  
  if (clearFeedBeforeFetching == YES)
    {
      status = RSSFeedIsIdle;
      [self clearArticles];
    }  
  
  // FIXME: Catch errors here which are returned from parsing methods!
  if ([[root name] isEqualToString: @"RDF"]) // RSS 1.0 detected
    {
      rssVersion = @"RSS 1.0";
      [self parseRSS10WithRootNode: root];
    }
  else if ([[root name] isEqualToString: @"rss"] &&
	   [[[root attributes] objectForKey: @"version"]
	     isEqualToString: @"2.0"]) // RSS 2.0 detected
    {
      rssVersion = @"RSS 2.0";
      [self parseRSS20WithRootNode: root];
    }
  else if ([[root name] isEqualToString: @"rss"] &&
	   [[[root attributes] objectForKey: @"version"] isEqualToString: @"0.91"]) // RSS 0.91 detected
    {
      rssVersion = @"RSS 0.91";
      NSLog(@"WARNING: RSS 0.91 support is a *hack* at the moment");
      [self parseRSS20WithRootNode: root];
    }
  else if ([[root name] isEqualToString: @"rss"] &&
	   [[[root attributes] objectForKey: @"version"] isEqualToString: @"0.92"]) // RSS 0.92 detected
    {
      rssVersion = @"RSS 0.92";
      NSLog(@"WARNING: RSS 0.92 support is a *hack* at the moment");
      [self parseRSS20WithRootNode: root];
    }
  else if ([[root name] isEqualToString: @"feed"] &&
	   [[root namespace] isEqualToString: URI_ATOM10]) // ATOM 1.0
    {
      rssVersion = @"ATOM 1.0";
      [self parseATOM10WithRootNode: root];
    }
  else if ([[root name] isEqualToString: @"feed"] &&
	   [[[root attributes] objectForKey: @"version"]
	     isEqualToString: @"0.3"])   // ATOM 0.3 detected
    {
      rssVersion = @"ATOM 0.3";
      [self parseATOM03WithRootNode: root];      
    }
  else
    {
      NSLog(@"Failed to decide RSS version");
      NSLog(@"Root name: %@", [root name]);
      rssVersion = @"Malformed RSS?";
      status = RSSFeedIsIdle;
      [[NSNotificationCenter defaultCenter]
          postNotificationName: RSSFeedFetchFailedNotification
                        object: self
       userInfo: [NSDictionary dictionaryWithObject: @"Malformed RSS"
                                             forKey: @"Reason"]];
      return [self setError: RSSFeedErrorMalformedRSS];
    }
  
  // make sure all articles know their parent feed
  for (i=0; i<[articles count]; i++) {
      // We're in a RSSFeed, so we can assume this is a RSSArticle object.
      [(RSSArticle*)[articles objectAtIndex: i] setFeed: self];
  }
  
  [[NSNotificationCenter defaultCenter]
          postNotificationName: RSSFeedFetchedNotification
                        object: self];
  
  status = RSSFeedIsIdle;
  return [self setError: RSSFeedErrorNoError];
}



// sets the error for the feed (see RSSFeed.h)
-(enum RSSFeedError) setError: (enum RSSFeedError) err
{
  lastError = err;
  return err;
}

@end




@implementation RSSFeed (Fetching)



/**
 * Returns the last error.
 * Guaranteed to return the last fetching result.
 */
-(enum RSSFeedError) lastError
{
  return lastError;
}

/**
 * Fetches the feed from its feed URL, parses it and adds the found
 * articles to the list of articles contained in this feed (if they
 * are new).
 */
-(enum RSSFeedError) fetch
{
   NSData* data;
   
   status = RSSFeedIsFetching;
   
   // no errors at first :-)
   [self setError: RSSFeedErrorNoError];
   [[NSNotificationCenter defaultCenter] 
                      postNotificationName: RSSFeedWillFetchNotification
                      object: self];
   
   data = [self fetchDataFromURL: feedURL];
   
   status = RSSFeedIsIdle;
   
   return [self fetchWithData: data];
}


- (void) fetchInBackground
{
  if (feedURL == nil) 
  {
    [self setError: RSSFeedErrorMalformedURL];
    return;
  }
  
  if (status == RSSFeedIsFetching)
  {
    // FIXME: need an error for repeated loading.
    // GN: Be careful. When you assign an error to that feed while it
    //     is actually already being fetched in the background, the
    //     thread that fetches the data in the background will probably
    //     set the feed's error code, too. You will never know which
    //     fetching process set the error message.
    return;
  }
  
  status = RSSFeedIsFetching;
  [self setError: RSSFeedErrorNoError];
  [[NSNotificationCenter defaultCenter] 
                       postNotificationName: RSSFeedWillFetchNotification
                       object: self];
  
  [feedURL loadResourceDataNotifyingClient: self usingCache: NO];
}

@end


