/*
   Grr RSS Reader
   
   Copyright (C) 2006-2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2010  GNUstep Application Team
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

#import "Article.h"
#import "Feed.h"

#import "DatabaseElement.h"
#import "ArticleGroup.h"
#import "Category.h"
#import "Components.h"

extern NSString* const DatabaseChangeNotification;

/**
 * Objects conforming to this protocol provide access to a
 * hierarchical database of article groups (e.g. a feed) and
 * categories.
 * 
 * The top level elements of the database conform to the
 * DatabaseElement protocol. The hierarchy is established by its
 * subprotocol 'Category'. A category object stores an array of
 * Database element. (Composite pattern)
 * 
 * The other subprotocol of DatabaseElement is ArticleGroup. An
 * article group stores and provides access to a set of articles.
 * The Feed protocol is also a subprotocol of ArticleGroup.
 */
@protocol Database <NSObject, OutputProvidingComponent>

// ----------------------------------------------------------
//    Retrieval
// ----------------------------------------------------------

/**
 * Returns the top level elements of the database. This
 * is an array of objects conforming to the DatabaseElement
 * protocol.
 */
-(NSArray*)topLevelElements;

/**
 * Returns the set of all articles in the database. An
 * article is an object conforming to the Article protocol.
 */
-(NSSet*)articles;


// ----------------------------------------------------------
//    Modification
// ----------------------------------------------------------

/**
 * Removes the given article object from the database. If the
 * operation succeeds, YES is returned. Otherwise, NO is
 * returned.
 *
 * @return YES on success
 */
-(BOOL)removeArticle: (id<Article>)article;

/**
 * Removed the given database element from the database. If
 * the operation succeeds, YES is returned.
 *
 * @return YES on success
 */
-(BOOL)removeElement: (id<DatabaseElement>)element;

/**
 * Starts the fetching process of all feeds contained in the
 * database. Please note that feeds are not guaranteed to be
 * done with fetching when this method returns. See the Feed
 * protocol on how to find out whether a feed is currently
 * being fetched.
 */
-(void)fetchAllFeeds;

/**
 * Subscribes to the given URL.
 * This is a convenience method for
 * -subscribeToURL:inCategory:position:.
 *
 * @return YES on success
 */
-(BOOL)subscribeToURL: (NSURL*)aURL;

/**
 * Subscribes to the given URL and inserts the newly
 * created feed in the given category. If the given category
 * is nil, the feed will be inserted as top level object in
 * the database.
 * 
 * This is a convenience method for
 * -subscribeToURL:inCategory:position:.
 *
 * @return YES on success
 */
-(BOOL)subscribeToURL: (NSURL*)aURL
           inCategory: (id<Category>)aCategory;

/**
 * Subscribes to the given URL. The newly created feed database
 * element will be created in the given category at the given
 * position. If the category is nil, it will be inserted as top
 * level object in the database. The method returns YES on success,
 * NO on failure.
 * 
 * The method fails if a feed with the given URL is already
 * subscribed. It may also fail if the insertion into the database
 * doesn't work, for example if the index is not valid for the
 * given category.
 * 
 * @return YES on success
 */
-(BOOL)subscribeToURL: (NSURL*)aURL
           inCategory: (id<Category>)aCategory
             position: (int)index;

/**
 * Creates a new category with the given name in the specified
 * category at the given position.
 * 
 * @return YES on success
 */
-(BOOL) addCategoryNamed: (NSString*)name
              inCategory: (id<Category>)aCategory
                position: (int)index;

/**
 * Creates a new category with the given name in the specified
 * category.
 * 
 * @return YES on success
 */
-(BOOL) addCategoryNamed: (NSString*)name
              inCategory: (id<Category>)aCategory;

/**
 * Moves a database element from its old position into the given
 * category.
 * 
 * @return YES on success
 */
-(BOOL)moveElement: (id<DatabaseElement>)anElement
      intoCategory: (id<Category>)aCategory;

/**
 * Moves a database element from its old position into the given
 * category at the given position.
 * 
 * This may especially fail in the case when trying to move a
 * category into itself.
 * 
 * @return YES on success
 */
-(BOOL)moveElement: (id<DatabaseElement>)anElement
      intoCategory: (id<Category>)aCategory
          position: (int)index;

// -------------------------------------------------------------------
//    Archiving
// -------------------------------------------------------------------

/**
 * Writes the database back to its central storage. This method is
 * called by the application before exiting.
 * 
 * Database implementations may also leave this method empty and
 * synchronize with the central storage on the fly.
 * 
 * @return YES on success
 */
-(BOOL)archive;

/**
 * Loads the database from a central storage.
 * 
 * Implementers of a database should call this from the
 * database's -init method.
 * 
 * @return YES on success
 */
-(BOOL)unarchive;

@end

@interface Database : NSObject
/**
 * Singleton method. Returns the one database object for the
 * application.
 */
+(id<Database>) shared;
@end

