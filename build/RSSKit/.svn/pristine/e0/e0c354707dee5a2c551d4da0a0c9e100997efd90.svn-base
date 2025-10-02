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

#import "FeedParser.h"
#import "GNUstep.h"

@implementation FeedParser

// instantiation

+(id) parser
{
  return AUTORELEASE([[self alloc] init]);
}

+(id) parserWithDelegate: (id)aDelegate
{
  FeedParser* p = AUTORELEASE([[self alloc] init]);
  [p setDelegate: aDelegate];
  return p;
}

-(id) init
{
  if ((self = [super init]) != nil) {
    delegate = nil;
  }
  
  return self;
}

// parsing

-(void) parseWithRootNode: (XMLNode*) root
{
  NSLog(@"XXX: called -parseWithRootNode: in FeedParser. It should have been called in a subclass!");
}



// helper methods

// FIXME: Delete this method and find a good way to remove any HTML parsing ideas from RSSKit.
// It's better to do that in the application.
-(NSString*) stringFromHTMLAtNode: (XMLNode*) root
{
  return AUTORELEASE(RETAIN([root content]));
}


/**
 * Gets called when a feed title has been found in the feed.
 */
-(void) foundFeedName: (NSString*) feedName
{
  if ([delegate respondsToSelector: @selector(setFeedName:)]) {
      [delegate setFeedName: feedName];
  }
}


@end
