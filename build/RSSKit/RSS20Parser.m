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

#import "RSS20Parser.h"
#import "DublinCore.h"

#define URI_PURL_CONTENT    @"http://purl.org/rss/1.0/modules/content/"
#define URI_PODCAST         @"http://www.itunes.com/dtds/podcast-1.0.dtd"
#define URI_PURL_DUBLINCORE @"http://purl.org/dc/elements/1.1/"

@implementation RSS20Parser

- (void) parseWithRootNode: (XMLNode*) root
{
  XMLNode* toplevelnode;
  XMLNode* secondlevelnode;
  XMLNode* thirdlevelnode;
  
  for ( toplevelnode = [root firstChildElement];
	toplevelnode != nil;
	toplevelnode = [toplevelnode nextElement] )
    {
      if ([[toplevelnode name]
	    isEqualToString: @"channel"])
	{
	  for (secondlevelnode = [toplevelnode firstChildElement];
	       secondlevelnode != nil;
	       secondlevelnode = [secondlevelnode nextElement] )
	    {
	      if ([[secondlevelnode name]
		    isEqualToString: @"title"])
		{
             [self foundFeedName: [secondlevelnode content]];
		}
	      // FIXME: Add support for tags: link,
	      // language,managingEditor,webMaster
	      else if ([[secondlevelnode name]
		    isEqualToString: @"item"])
		{
		  [self startArticle];
		  
		  for (thirdlevelnode =[secondlevelnode firstChildElement];
		       thirdlevelnode != nil;
		       thirdlevelnode =[thirdlevelnode nextElement])
		    {
		      if ([[thirdlevelnode name]
			    isEqualToString: @"title"])
			{
			  [self setHeadline: [thirdlevelnode content]];
			}
		      else if ([[thirdlevelnode name]
				 isEqualToString: @"link"])
			{
			  [self addLinkWithURL: [thirdlevelnode content]];
			}
		      else if ([[thirdlevelnode name]
				 isEqualToString: @"description"])
			{
			  [self setSummary: [thirdlevelnode content]];
			}
                 else if ([[thirdlevelnode name] isEqualToString: @"pubDate"])
                 {
                     [self setDateFromString: [thirdlevelnode content]];
                 }
		      else if ([[thirdlevelnode name]
				 isEqualToString: @"enclosure"])
			{
			  [self
			    addLinkWithURL: [[thirdlevelnode attributes]
					      objectForKey: @"url"]
			    andRel: @"enclosure"
			    andType: [[thirdlevelnode attributes]
				       objectForKey: @"type"]
			   ];
			}
                 else if ([[thirdlevelnode name] isEqualToString: @"summary"] &&
                          [[thirdlevelnode namespace] isEqualToString: URI_PODCAST])
                 {
                   [self setContent: [thirdlevelnode content]];
                 }
		      else if ([[thirdlevelnode name]
				 isEqualToString: @"encoded"])
			{
			  if ([[thirdlevelnode namespace]
				isEqualToString: URI_PURL_CONTENT])
			    {
			      [self setContent: [thirdlevelnode content]];
			    }
			}
		      else if ([[thirdlevelnode name]
				 isEqualToString: @"date"] &&
			       [[thirdlevelnode namespace]
				 isEqualToString: URI_PURL_DUBLINCORE])
			{
			  [self setDateFromString: [thirdlevelnode content]];
			}
		    }
		  
		  [self commitArticle];
		}
	    }
	}
    }
  [self finished];
}
@end
