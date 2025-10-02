/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2012  GNUstep Application Team
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

#import "ArticleTablePlugin.h"

#import "Article.h"
#import "GNRatingCell.h"

#ifdef __APPLE__
#import "GNUstep.h"
#endif

NSComparisonResult compareArticleHeadlines( id articleA, id articleB, void* context ) {
    id<Article> a = (id<Article>) articleA;
    id<Article> b = (id<Article>) articleB;
    
    return [[a headline] caseInsensitiveCompare: [b headline]];
}

NSComparisonResult compareArticleDates( id articleA, id articleB, void* context ) {
    id<Article> a = (id<Article>) articleA;
    id<Article> b = (id<Article>) articleB;
    
    return [[a date] compare: [b date]];
}

NSComparisonResult compareArticleRatings( id articleA, id articleB, void* context) {
    id<Article> a = (id<Article>) articleA;
    id<Article> b = (id<Article>) articleB;
    
    int ratingA = [a rating];
    int ratingB = [b rating];
    
    if (ratingA == ratingB) {
        return NSOrderedSame;
    } else if (ratingA > ratingB) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

@implementation ArticleTablePlugin

-(id) init
{
    [super init];
    [_view retain];
    return self;
}

-(void)awakeFromNib
{
  GNRatingCell *ratingCell;
  
  ASSIGN(table, [(NSScrollView*)_view documentView]);
  ASSIGN(headlineCol, [table tableColumnWithIdentifier: @"headline"]);
  ASSIGN(dateCol, [table tableColumnWithIdentifier: @"date"]);
  ASSIGN(ratingCol, [table tableColumnWithIdentifier: @"rating"]);
  
  ratingCell = [[GNRatingCell alloc] init]; 
  [ratingCol setDataCell:ratingCell];
  [ratingCell release];
  
  // Register for change notifications
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(articleChanged:)
                                               name: RSSArticleChangedNotification
                                             object: nil];

    [table setAutoresizesAllColumnsToFit: YES];

    // Ensure table is autosaved
    [table setAutosaveName: @"Article Table"];
    [table setAutosaveTableColumns: YES];
}

-(void) setNewArrayWithoutNotification: (NSArray*) newArray
{
    NSMutableIndexSet* indexSet;
    NSUInteger i;

    if ([newArray isEqual: articles]) {
        return;  // nothing changed
    }
    
    // Calculates the indexes of the currently selected articles
    // in the new table (if they are present)
    indexSet = [NSMutableIndexSet new];
    
    for (i=0; i<[articles count]; i++) { // for all row numbers in table
        if ([table isRowSelected: i]) {
            id article = [articles objectAtIndex: i];
            NSUInteger newIndex = [newArray indexOfObject: article];
            if (newIndex != NSNotFound) {
                [indexSet addIndex: newIndex];
            }
        }
    }
    
    ASSIGN(articles, newArray);
    
    // Important: reload *before* selecting, or the selection will be not appliable!
    [table reloadData];
    [table selectRowIndexes: indexSet byExtendingSelection: NO];
}

// --------------- MVC Model Change Listening --------------

-(void) articleChanged: (NSNotification*) aNotification
{
    // If we currently display the feed that changed, reload the data
    if ([articles containsObject: [aNotification object]]) {
        [table reloadData];
    }
}

// -------------- Component connections -------------------

-(NSSet*) objectsForPipeType: (id<PipeType>)aPipeType;
{
    NSAssert2(
        aPipeType == [PipeType articleType],
        @"%@ component does not support %@ output",
        self, aPipeType
    );
    
    if (articleSelection == nil) {
        NSUInteger i;
        articleSelection = [[NSMutableSet alloc] init];
        for (i=0; i<[articles count]; i++) {
            if ([table isRowSelected: i]) {
                [articleSelection addObject: [articles objectAtIndex: i]];
            }
        }
    }
    
    return articleSelection;
}

-(void)componentDidUpdateSet: (NSNotification*) aNotification
{
    // Update articles
    ASSIGN(articles, [[[aNotification object] objectsForPipeType: [PipeType articleType]] allObjects]);
    
    // Reload table contents
    [table reloadData];
    
    [table deselectAll: self];
    
    // Notify listeners of change
    // Done automatically because of the above deselectAll: call and the notifyChanges in the
    // selection changed delegate method
    // [self notifyChanges];
}


// ---------------- NSTableView data source ----------------------

- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView
{
    return [articles count];
}

- (id)           tableView: (NSTableView *)aTableView
 objectValueForTableColumn: (NSTableColumn *)aTableColumn
                       row: (NSInteger)rowIndex;
{
    id<Article> article = [articles objectAtIndex: rowIndex];
    
    if (aTableColumn == headlineCol) {
        return [article headline];
    } else if (aTableColumn == dateCol) {
        // FIXME: Make the date format configurable!
        return [[article date] descriptionWithCalendarFormat: @"%Y-%m-%d"
                               timeZone: nil
                               locale: nil];
    } else {
        NSAssert1(aTableColumn == ratingCol, @"Unknown table column \"%@\"", aTableColumn);
        return [NSNumber numberWithInt: [article rating]];
    }
}

// ------------------- NSTableView delegate ------------------------

- (void) tableViewSelectionDidChange: (NSNotification*) notif
{
    // clear article selection set
    DESTROY(articleSelection);
    
    [self notifyChanges];
}

-(void) tableView: (NSTableView*) aTableView
    willDisplayCell: (id)aCell
    forTableColumn: (NSTableColumn*) aTableColumn
    row: (NSInteger)rowIndex
{
    NSCell* cell = aCell;
    id<Article> article = [articles objectAtIndex: rowIndex];
    
    if ([article isRead]) {
        [cell setFont: [NSFont systemFontOfSize: [NSFont systemFontSize]]];
    } else {
        [cell setFont: [NSFont boldSystemFontOfSize: [NSFont systemFontSize]]];
    }
}

-(void) tableView: (NSTableView*) aTableView
  mouseDownInHeaderOfTableColumn: (NSTableColumn*) aTableColumn
{
    NSArray* newArray = nil;
    if (aTableColumn == headlineCol) {
        newArray = [articles sortedArrayUsingFunction: compareArticleHeadlines context: nil];
    } else if (aTableColumn == dateCol) {
        newArray = [articles sortedArrayUsingFunction: compareArticleDates context: nil];        
    } else if (aTableColumn == ratingCol) {
        newArray = [articles sortedArrayUsingFunction: compareArticleRatings context: nil];
    } else {
        [NSException raise: @"BadColumnException"
                    format: @"Unknown column %@", [aTableColumn identifier]];
    }
    
    [self setNewArrayWithoutNotification: newArray];
    [self notifyChanges];
}

-(void) tableView: (NSTableView*) aTableView
   setObjectValue: (id) anObj
   forTableColumn: (NSTableColumn*) aTableColumn
              row: (NSInteger) rowIndex
{
    if (aTableColumn == ratingCol) {
	id article;

        /* We can't keep that as an assertion now, as it can easily fail when
         * the broken GNUstep NSTableView lets you edit the string value for the cell.
         */
        if ([anObj isKindOfClass: [NSNumber class]] == NO) {
            NSLog(@"Warning: %@ is not a number value.", anObj);
        }
        
        article = [articles objectAtIndex: rowIndex];
        [article setRating: [anObj intValue]];
    }
}

@end
