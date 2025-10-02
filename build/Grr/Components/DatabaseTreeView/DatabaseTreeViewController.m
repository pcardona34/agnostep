/*
   Grr RSS Reader
   
   Copyright (C) 2006-2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2012 GNUstep Application Team
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

#import "DatabaseTreeViewController.h"
#import "Database.h"
#import "NumberedImageTextCell.h"

#ifdef __APPLE__
#import "GNUstep.h"
#endif

/**
 * Identify GNUstep versions with NSOutlineView selection bug
 * 
 * In GNUstep-gui 0.11.0, NSOutlineView's selection mechanism is broken.
 * When running reloadItem: or reloadData, it breaks internal consistency and
 * messes up the selection. (It doesn't fill the internally used _selectedItems array.)
 * 
 * The OUTLINEVIEW_SELECTION_HACK define enables a hack that tries to
 * circumvent the broken NSOutlineView behaviour by saving the selection
 * before a call to a broken NSOutlineView method.
 */
#ifdef GNUSTEP // All GNUstep versions
#define OUTLINEVIEW_SELECTION_HACK YES
#endif // GNUSTEP


/*
 * A Pasteboard type which encapsulates pointers to DatabaseElement objects.
 *
 * This pasteboard type has a data element that contains a pointer to the
 * element. It's not very elegant, but it does the job for now. If there's
 * a cleaner solution to do this, I'll adopt it ASAP, as this code here
 * doesn't work on 64 bit architectures (I assume pointers to be 4 byte).
 */
static NSString* const DatabaseElementRefPboardType =
    @"Grr Database Element Reference Pboard Type";


static NSImage* arrowRight = nil;
static NSImage* arrowDown = nil;

@implementation DatabaseTreeViewController

// -------------------------------------------------------------------
//    Initialisation
// -------------------------------------------------------------------

+(void) initialize
{
    if (self == [DatabaseTreeViewController class]) {
        arrowDown = [NSImage imageNamed: @"arrowDown"];
        arrowRight = [NSImage imageNamed: @"arrowRight"];
    }
}

-(id) init
{
    if ((self = [super init]) != nil) {
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(databaseChanged:)
            name: DatabaseChangeNotification
            object: nil];
    }
    
    return self;
}


// -------------------------------------------------------------------
//    Awaking from the Nib loading process
// -------------------------------------------------------------------
-(void) awakeFromNib
{
  NumberedImageTextCell *imageTextCell;
  
  imageTextCell = [[NumberedImageTextCell alloc] initTextCell:@""];
  [[outlineView outlineTableColumn] setDataCell:imageTextCell];
  
    // Dropping
    [outlineView registerForDraggedTypes: [NSArray arrayWithObjects:
        NSURLPboardType,
        DatabaseElementRefPboardType,
        nil
    ]];
    
    // Autosaving
    [outlineView setAutosaveName: @"Feed and Category Outline"];
    [outlineView setAutosaveTableColumns: YES];
    
    // Get notifications when articles change their read flag
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(articleReadFlagChanged:)
                                                 name: ArticleReadFlagChangedNotification
                                               object: nil];
    
    // Get notifications when database elements request the focus
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(databaseElementRequestsFocus:)
                                                 name: DatabaseElementFocusRequestNotification
                                               object: nil];
    
    // Register for two notifications where a specific feed needs to be redrawn
    // in the outline view
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(redrawFeedNotification:)
                                                 name: RSSFeedWillFetchNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(redrawFeedNotification:)
                                                 name: RSSFeedFetchedNotification
                                               object: nil];
}


// -------------------------------------------------------------------
//    Retrieving notifications
// -------------------------------------------------------------------

-(void) databaseChanged: (NSNotification*) notif
{
    NSInteger index;
    NSAssert(outlineView != nil, @"No outline view");
    
#ifdef OUTLINEVIEW_SELECTION_HACK
    // FIXME: This strange hack tries to keep the selection. (Needed for -gui 0.11.0)
    index = [outlineView selectedRow];
#endif
    [outlineView reloadData];
#ifdef OUTLINEVIEW_SELECTION_HACK
    if (index != -1) {
        [outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: index]
                 byExtendingSelection: NO];
    }
#endif
}

-(void) articleReadFlagChanged: (NSNotification*) notification
{
  id<Feed> feed = (id<Feed>)[(id<Article>)[notification object] feed];
    
    [self redrawFeed: feed];
}

/*
 * This method is called when a database element requests the focus.
 * The outline view will select it.
 */
-(void) databaseElementRequestsFocus: (NSNotification*) notif
{
    id<DatabaseElement> databaseElement = [notif object];
    NSInteger index;
    
    // First iterate through all parent elements and expand them all
    id<Category> parent = [databaseElement superElement];
    while (parent != nil) {
        [outlineView expandItem: parent expandChildren: NO];
        parent = [parent superElement];
    }
    
    // Get row index and select
    [outlineView reloadData];
    index = [outlineView rowForItem: databaseElement];
    if (index != -1) {
        [outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: index]
                 byExtendingSelection: NO];
    }
}

/*
 * Gets FeedFetched- and FeedWillFetchNotifications.
 */
-(void) redrawFeedNotification: (NSNotification*) notif
{
    NSInteger index;
    id<Feed> feed = [notif object];
    
    [self redrawFeed: feed];

    index = [outlineView selectedRow];
    if ((index < 0) || (index == NSNotFound))
	return;
    if (feed == [outlineView itemAtRow: index])
	[self notifyChanges];
}


/*
 * Does the actual work for the notification methods where something needs
 * to be redrawn in the outline view.
 */
-(void) redrawFeed: (id<Feed>) feed
{
    NSParameterAssert(feed != nil);
    
    if ([outlineView rowForItem: feed] != -1) {
        // This feed is currently shown in our outline view, reload it!
#ifdef OUTLINEVIEW_SELECTION_HACK
        // FIXME: This strange hack tries to keep the selection. (Needed for -gui 0.11.0)
        NSInteger index = [outlineView selectedRow];
#endif
        [outlineView reloadItem: feed];
#ifdef OUTLINEVIEW_SELECTION_HACK
        if (index != -1) {
            [outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: index]
                     byExtendingSelection: NO];
        }
#endif
    }
}

// -------------------------------------------------------------------
//    NSOutlineView data source
// -------------------------------------------------------------------

/**
 * Implementation of this method is required.  Returns the child at
 * the specified index for the given item.
 */
- (id)outlineView: (NSOutlineView *)outlineView
            child: (NSInteger)index
           ofItem: (id)item
{
    if (item == nil) {
        return [[[Database shared] topLevelElements] objectAtIndex: index];
    } else {
        NSParameterAssert([item conformsToProtocol: @protocol(Category)]);
        
        return [[(id<Category>)item elements] objectAtIndex: index];
    }
}

/**
 * Sets the object value of the given item in the given table column to the object provided.
 */
- (void)outlineView: (NSOutlineView *)outlineView
     setObjectValue: (id)object
     forTableColumn: (NSTableColumn *)tableColumn
             byItem: (id)item
{
    if ([item conformsToProtocol: @protocol(DatabaseElement)]) {
        [(id<DatabaseElement>)item setName: [object description]];
    }
}

/**
 * This is a required method.  Returns whether or not the outline view
 * item specified is expandable or not.
 */
- (BOOL)outlineView: (NSOutlineView *)outlineView
   isItemExpandable: (id)item
{
    return item == nil || [item conformsToProtocol: @protocol(Category)];
}

/*
 * This is a required method.  Returns the number of children of
 * the given item.
 */
- (NSInteger)outlineView: (NSOutlineView *)outlineView
numberOfChildrenOfItem: (id)item
{
    if (item == nil) {
        return [[[Database shared] topLevelElements] count];
    } else if ([item conformsToProtocol: @protocol(Category)]) {
        return [[(id<Category>)item elements] count];
    } else {
        return 0;
    }
}

/**
 * This is a required method.  Returns the object corresponding to the
 * item representing it in the outline view.
 */
- (id)outlineView: (NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
    NSParameterAssert([item conformsToProtocol: @protocol(DatabaseElement)]);
    
    return [item description];
}

// ------------------------------------------------------------
//    Output providing component things
// ------------------------------------------------------------

-(NSSet*) objectsForPipeType: (id<PipeType>)aPipeType
{
    id elem;
    NSSet* result;

    // If nothing is selected, just return nothing
    int index = [outlineView selectedRow];

    if (index == -1) {
        return [NSSet new];
    }
    
    elem = [outlineView itemAtRow: index];
    
    if (aPipeType == [PipeType articleType]) {
        if ([elem conformsToProtocol: @protocol(ArticleGroup)]) {
            result = [(id<ArticleGroup>)elem articleSet];
        } else {
            result = [NSSet new];
        }
    } else if (aPipeType == [PipeType feedType]) {
        if ([elem conformsToProtocol: @protocol(Feed)]) {
            result = [NSSet setWithObject: elem];
        } else {
            result = [NSSet new];
        }
    } else if (aPipeType == [PipeType databaseElementType]) {
        NSAssert(
            [elem conformsToProtocol: @protocol(DatabaseElement)],
            @"chosen outline element is not a database element"
        );
        
        result = [NSSet setWithObject: elem];
    } else {
        result = [NSSet new];
    }

    // In any other case, return the empty set
    return result;
}

// ------------------------------------------------------------
//    Outline view delegate methods
// ------------------------------------------------------------

/**
 * Called when the selection has changed.
 */
- (void) outlineViewSelectionDidChange: (NSNotification *)aNotification
{
    static id currentSelection = nil;
    id newSelection = nil;
    
    int rowIndex = [outlineView selectedRow];
    
    if (rowIndex != -1) {
        newSelection = [outlineView itemAtRow: rowIndex];
    }
    
    if (newSelection != currentSelection) {
        ASSIGN(currentSelection, newSelection);
        [self notifyChanges];
    }
}

/**
 * Called when the given cell is about to be displayed.  This method is
 * useful for making last second modifications to what will be shown.
 */
- (void)  outlineView: (NSOutlineView *)outlineView
      willDisplayCell: (id)cell
       forTableColumn: (NSTableColumn *)tableColumn
                 item: (id)item
{
    if ([cell isKindOfClass: [NumberedImageTextCell class]]) {
        NumberedImageTextCell* numCell = cell;
        
        if ([item conformsToProtocol: @protocol(Feed)]) {
            id<Feed> feed = item;
            if ([feed isFetching]) {
                [numCell setImage: [NSImage imageNamed: @"FeedFetching"]];
            } else {
                [numCell setImage: [NSImage imageNamed: @"Feed"]];
            }
            
            [numCell setNumber: [feed unreadArticleCount]];
        } else if ([item conformsToProtocol: @protocol(Category)]) {
            [numCell setImage: nil];
            [numCell setNumber: 0]; // FIXME: Add up all numbers from subelements?
        } else {
            [numCell setImage: nil];
            [numCell setNumber: 0];
        }
    }
}


#ifndef MACOSX
- (void)    outlineView: (NSOutlineView *) aOutlineView
 willDisplayOutlineCell: (id) aCell
         forTableColumn: (NSTableColumn *) aTbleColumn
                   item: (id)item
{
  if (![aOutlineView isExpandable: item])
    {
      [aCell setImage: nil];
    }
  else
    {
      if ([aOutlineView isItemExpanded: item])
        {
          [aCell setImage: arrowDown];
        }
      else
        {
          [aCell setImage: arrowRight];
        }
    }
}
#endif



// ------------------------------------------------------------
//    Outline view dropping
// ------------------------------------------------------------

- (NSDragOperation)outlineView: (NSOutlineView*)outlineView
                  validateDrop: (id <NSDraggingInfo>)info
                  proposedItem: (id)item
            proposedChildIndex: (NSInteger)index
{
    NSPasteboard* pboard = [info draggingPasteboard];
    
    if ([[pboard types] containsObject: DatabaseElementRefPboardType]) {
        return NSDragOperationMove;
    } else if ([[pboard types] containsObject: NSURLPboardType]) {
        return NSDragOperationCopy;
    } else {
        return NSDragOperationNone;
    }
}


- (BOOL)outlineView: (NSOutlineView *)theOutlineView
         acceptDrop: (id <NSDraggingInfo>)info
               item: (id)item
         childIndex: (NSInteger)index
{
    NSPasteboard* pboard = [info draggingPasteboard];
    if ([[pboard types] containsObject: DatabaseElementRefPboardType]) {
        BOOL result;
        NSData* data = [pboard dataForType: DatabaseElementRefPboardType];
        
        id elem = nil;
        [data getBytes: &elem length: 4]; // FIXME: Won't work with 64 bit processors!
        
        // I hope that's a pointer. :-]
        result = [[Database shared] moveElement: elem
                                        intoCategory: item
                                            position: index];
        return result;
    } else if ([[pboard types] containsObject: NSURLPboardType]) {
        NSURL* url = [NSURL URLFromPasteboard: pboard];
        
        return [[Database shared] subscribeToURL: url
                                      inCategory: item
                                        position: index];
    } else {
        return NO;
    }
}


// ------------------------------------------------------------
//    Outline view dragging
// ------------------------------------------------------------

- (BOOL)outlineView: (NSOutlineView *)outlineView
         writeItems: (NSArray*)items
       toPasteboard: (NSPasteboard*)pboard
{
    NSMutableArray* types;
    NSData* databaseElemData;
    id item;
    NSURL* url;
    
    if ([items count] != 1)
      return NO;
    
    item = [items objectAtIndex: 0];
    types = [[NSMutableArray alloc] initWithCapacity:1];
    url = nil;
    if ([item conformsToProtocol: @protocol(Feed)])
      {
        id feed = item;
        NSURL* url = [feed feedURL];
        if (url != nil) {
            [types addObject: NSURLPboardType];
        }
      }
    
    databaseElemData = nil;
    if ([item conformsToProtocol: @protocol(DatabaseElement)]) {
        // FIXME: This works only on systems with 32 bit pointers. What is the clean solution?
        databaseElemData = [NSData dataWithBytes: &item length: 4];
        
        [types addObject: DatabaseElementRefPboardType];
    }
    
    // Set types for pasteboard
    [pboard declareTypes: types owner: nil];
    
    // Write things to pasteboard
    if ([types containsObject: NSURLPboardType]) {
        [url writeToPasteboard: pboard];
    }
    
    if ([types containsObject: DatabaseElementRefPboardType]) {
        [pboard setData: databaseElemData forType: DatabaseElementRefPboardType];
    }
    
    return [types count] > 0 ? YES : NO;
}



@end
