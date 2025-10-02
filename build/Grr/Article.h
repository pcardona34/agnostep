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

#import <RSSKit/RSSArticle.h>
#import <RSSKit/RSSArticle+Storage.h>

#import "GNUstep.h"


/**
 * This notification is sent when the read flag for an article changes.
 */
extern NSString* const ArticleReadFlagChangedNotification;


@protocol Article <RSSMutableArticle>
// Getter and setter for read variable
-(void)setRead: (BOOL)isRead;
-(BOOL)isRead;

// Getter and setter for rating variable
-(void)setRating: (int)aRating;
-(int)rating;
@end

@interface Article : RSSArticle <Article>
{
    BOOL _read;
    int _rating;
}

/**
 * Initializes the object from a Plist dictionary.
 */
-(id)initWithDictionary: (NSDictionary*) aDictionary;

/**
 * Designated initializer
 */
-(id)initWithHeadline: (NSString*) _headline
                  url: (NSURL*) _url
          description: (NSString*) _description
                 date: (NSDate*) _date;

// Getter and setter for read variable
-(void)setRead: (BOOL)isRead;
-(BOOL)isRead;

// Getter and setter for rating variable
-(void)setRating: (int)aRating;
-(int)rating;

/**
 * This method is intended to make sure that the replacing article keeps
 * some fields from the old (this) article. Subclasses will probably want
 * to override this, but shouldn't forget calling the super implementation,
 * first.
 */
-(void)willBeReplacedByArticle: (id<RSSMutableArticle>) newArticle;

@end

