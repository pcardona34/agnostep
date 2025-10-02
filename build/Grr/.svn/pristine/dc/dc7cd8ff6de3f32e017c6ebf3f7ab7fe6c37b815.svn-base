/*
   Grr RSS Reader
   
   Copyright (C) 2009-2019 The Free Software Foundation, Inc.
                 2006-2007 Guenther Noack
 
   Authors: Guenther Noack
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

#import "Article.h"

/**
 * This notification is sent when the read flag for an article changes.
 */
NSString* const ArticleReadFlagChangedNotification = @"ArticleReadFlagChangedNotification";


@implementation Article

/**
 * Initializes the object from a Plist dictionary.
 */
-(id)initWithDictionary: (NSDictionary*) aDictionary
{
    NSAssert(aDictionary != nil, @"Cannot initialise an article from the nil dictionary");
    
    if ((self = [super initWithDictionary: aDictionary]) != nil) {
        NSNumber* ratingNumber;
        NSNumber* readFlagNumber = [aDictionary objectForKey: @"readFlag"];
        
        if (readFlagNumber) {
            _read = [readFlagNumber boolValue];
        } else {
            _read = YES;
        }
        
        ratingNumber = [aDictionary objectForKey: @"rating"];
        
        if (ratingNumber) {
            _rating = [ratingNumber intValue];
        } else {
            _rating = 0;
        }
    }
    
    return self;
}

/**
 * Designated initializer
 */
-(id)initWithHeadline: (NSString*) _headline
                  url: (NSURL*) _url
          description: (NSString*) _description
                 date: (NSDate*) _date
{
    if((self = [super initWithHeadline: _headline
                                   url: _url
                           description: _description
                                  date: _date]) != nil) {
        _read = NO;
    }
    
    return self;
}

// Getter and setter for read variable
-(void)setRead: (BOOL)isRead
{
    if (_read != isRead) {
        _read = isRead;
        [self notifyChange];
        [[NSNotificationCenter defaultCenter] postNotificationName: ArticleReadFlagChangedNotification
                                                            object: self];
    }
}

-(BOOL)isRead
{
    return _read;
}

// Getter and setter for rating variable
-(void)setRating: (int)aRating
{
    if (_rating != aRating) {
        _rating = aRating;
        [self notifyChange];
    }
}

-(int)rating
{
    return _rating;
}

// Storage stuff
-(NSDictionary*)plistDictionary
{
    NSMutableDictionary* dict = [super plistDictionary];
    [dict setValue: [NSNumber numberWithBool: _read] forKey: @"readFlag"];
    [dict setValue: [NSNumber numberWithInt: _rating] forKey: @"rating"];
    return dict;
} 

-(void)willBeReplacedByArticle: (id<RSSMutableArticle>) newArticle
{
    id a;
    NSParameterAssert([newArticle conformsToProtocol: @protocol(Article)]);
    
    a = newArticle;
    [a setFeed: (id<RSSMutableFeed>)[self feed]];
    
    [super willBeReplacedByArticle: newArticle];
    
    [(id<Article>)newArticle setRating: _rating];
    [(id<Article>)newArticle setRead: _read];
}

@end
