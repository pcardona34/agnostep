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

#import "AtomParser.h"

@implementation AtomParser

/*
-(void)parseWithRootNode: (XMLNode*)root
{
  RSSArticleCreationListener* creator;
  XMLNode* toplevelnode;
  XMLNode* secondlevelnode;
  
  creator = AUTORELEASE([[RSSArticleCreationListener alloc]
			  initWithFeed: self]);
  
  for ( toplevelnode = [root firstChildElement];
	toplevelnode != nil;
	toplevelnode = [toplevelnode nextElement] )
    {
      if ([[toplevelnode name]
	    isEqualToString: @"title"])
	{
	  RELEASE(feedName);
	  feedName = RETAIN([toplevelnode content]);
	}
      else if ([[toplevelnode name]
		 isEqualToString: @"entry"])
	{
	  [creator startArticle];
	  
	  for (secondlevelnode = [toplevelnode firstChildElement];
	       secondlevelnode != nil;
	       secondlevelnode = [secondlevelnode nextElement] )
	    {
	      if ([[secondlevelnode name]
		    isEqualToString: @"title"])
		{
		  [creator setHeadline: [secondlevelnode content]];
		}
	      // FIXME: ATOM 0.3 specifies different storage
	      // modes like Base64, plain ASCII etc. Implement these!
	      else if ([[secondlevelnode name]
			 isEqualToString: @"summary"])
		{
		  [creator setSummary: [secondlevelnode content]];
		}
	      else if ([[secondlevelnode name]
			 isEqualToString: @"content"])
		{
		  register NSString* tmp =
		    (NSString*)
		    [[secondlevelnode attributes]
		      objectForKey: @"type"];
		  
		  if (tmp == nil ||
		      [tmp isEqualToString: @"text"] ||
		      [tmp isEqualToString: @"html"])
		    [creator setContent: [secondlevelnode content]];
		  else
		    {
		      if ([tmp isEqualToString: @"application/xhtml+xml"] ||
			  [tmp isEqualToString: @"xhtml"])
			{
			  [creator setContent: [self stringFromHTMLAtNode: secondlevelnode]];
			}
		    }
		}
	      / *
	       * FIXME: is 'updated' instead of 'issued'
	       * also included in ATOM 0.3? (it is in 1.0)
	       * /
	      else if ([[secondlevelnode name]
	      isEqualToString: @"issued"])
	      {
		  [creator setDateFromString: [secondlevelnode content]];
		}
	      else if ([[secondlevelnode name]
			 isEqualToString: @"link"])
		{
		  [creator
		    addLinkWithURL: [[secondlevelnode attributes]
				      objectForKey: @"href"]
		    andRel: [[secondlevelnode attributes]
				  objectForKey: @"rel"]
		    andType: [[secondlevelnode attributes]
				  objectForKey: @"type"]
		   ];
		}
	    }
	  [creator commitArticle];
	}
    }
  [creator finished];
  return RSSFeedErrorNoError;
}

*/

@end
