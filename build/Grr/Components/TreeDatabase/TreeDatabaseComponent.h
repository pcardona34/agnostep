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


#import <Foundation/Foundation.h>

#import "Components.h"
#import "Database.h"

@interface TreeDatabaseComponent : NSObject <OutputProvidingComponent,Database>
{
    NSMutableArray* topLevelElements;
    NSMutableSet* allArticles;
    
    // contains all articles that still need to be written back
    NSMutableSet* dirtyArticles;
}

// archiving
-(BOOL)archive;
-(BOOL)unarchive;
-(NSString*)databaseStoragePath;

-(void)articleChanged: (NSNotification*)aNotification;

// helper methods
-(void)_fetchAllFeedsInDBElementArray: (NSArray*)array;
-(id<Feed>)feedForURL: (NSURL*)aURL
              inArray: (NSArray*)anArray;
-(BOOL)_removeElement: (id<DatabaseElement>)anElement
     fromMutableArray: (NSMutableArray*)array;


// ---------------------------------------------------
//    sending notifications
// ---------------------------------------------------

-(void) sendChangeNotification;

@end

