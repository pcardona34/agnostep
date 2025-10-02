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

#import "RSS10Parser.h"
#import "DublinCore.h"

#define URI_PURL_DUBLINCORE     @"http://purl.org/dc/elements/1.1/"

@implementation RSS10Parser

- (void) parseWithRootNode: (XMLNode*) root
{
  XMLNode* toplevelnode;
  XMLNode* secondlevelnode;
  
  for ( toplevelnode = [root firstChildElement];
	toplevelnode != nil;
	toplevelnode = [toplevelnode nextElement] )
    {
      if ([[toplevelnode name] isEqualToString: @"channel"])
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
	      /* you could add here: link, description, image,
	       * items, textinput
	       */
	    }
	}
      else
	if ([[toplevelnode name]
	      isEqualToString: @"item"])
	  {
	    [self startArticle];
	    
	    for (secondlevelnode = [toplevelnode firstChildElement];
		 secondlevelnode != nil;
		 secondlevelnode = [secondlevelnode nextElement] )
	      {
		if ([[secondlevelnode name]
		      isEqualToString: @"title"])
		  {
		    [self setHeadline: [secondlevelnode content]];
		  }
		else if ([[secondlevelnode name]
			   isEqualToString: @"description"])
		  {
		    [self setSummary: [secondlevelnode content]];
		  }
		else if ([[secondlevelnode name]
			   isEqualToString: @"link"])
		  {
		    [self addLinkWithURL: [secondlevelnode content]
			     andRel: @"alternate"];
		  }
		else if ([[secondlevelnode name]
			   isEqualToString: @"date"] &&
			 [[secondlevelnode namespace]
			   isEqualToString: URI_PURL_DUBLINCORE])
		  {
		    [self setDateFromString: [secondlevelnode content]];
		  }
	      }
	    [self commitArticle];
	  }
    }
  
  [self finished];
}
@end
