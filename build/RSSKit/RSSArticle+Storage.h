/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2012-2019 The Free Software Foundation, Inc.
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

#import "RSSArticle.h"

@interface RSSArticle (Storage)


/**
 * Returns the article with the URL anURL from the storage
 */
+(id<RSSMutableArticle>)articleFromStorageWithURL: (NSURL*) anURL;

/**
 * Initialises the article with the URL anURL from the storage.
 */
-(id)initFromStorageWithURL: (NSURL*) anURL;

/**
 * Initialises the article instance with the contents of the aDictionary variable.
 */
-(id)initWithDictionary: (NSDictionary*) aDictionary;

/**
 * Stores the article (usually as a file in the Reader folder).
 */
-(BOOL) store;

/**
 * Returns the dictionary that stores the information for this article object.
 */
-(NSMutableDictionary*) plistDictionary;

@end

