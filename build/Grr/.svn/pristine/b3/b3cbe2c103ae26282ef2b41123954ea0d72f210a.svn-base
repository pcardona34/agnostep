/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009  GNUstep Application Team
                       Riccardo Mottola

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA. 
*/

#import "NSSet+ArticleFiltering.h"
#import "Article.h"

@implementation NSSet (ArticleFiltering)

/**
 * Searches the articles contained in the receiver for the given string.
 * Returns the result set of articles that matched the search string.
 * If the search string is nil or empty, the receiver itself is returned.
 */
- (NSSet*) subsetFilteredForString: (NSString*) searchString
{
	NSArray* articles;
	NSUInteger subsetSize = 0;
	id<Article>* subsetObjects;
	NSUInteger i;
	NSSet* resultSet;

	if (searchString == nil || [searchString length] == 0) {
		return self;
	}
	
	articles = [self allObjects];

	subsetObjects = malloc( sizeof(id) * [articles count] );
	
	for (i=0; i<[articles count]; i++) {
	    id<Article> article = [articles objectAtIndex: i];
	    
	    NSString* headline = [article headline];
	    if (headline != nil) {
	        if ([headline rangeOfString: searchString].location != NSNotFound) {
	            subsetObjects[subsetSize] = article;
	            subsetSize ++;
	        }
	    }
	}
	NSLog(@"filtered down to %lu of %lu articles.", (unsigned long)subsetSize, (unsigned long)[articles count]);
	resultSet = [NSSet setWithObjects: subsetObjects count: subsetSize];

	free( subsetObjects );

	return resultSet;
}

@end

