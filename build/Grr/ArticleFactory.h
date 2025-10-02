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

#import <Foundation/NSObject.h>
#import <RSSKit/RSSFactory.h>
#import "Article.h"

@interface ArticleFactory : RSSFactory

- (id<Article>) articleWithHeadline: (NSString*) aHeadline
                                   URL: (NSURL*) aURL
                               content: (NSString*) aContent
                                  date: (NSDate*) aDate;

- (id<Article>) articleFromDictionary: (NSDictionary*) aDictionary;

@end
