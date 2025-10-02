/*
   Grr RSS Reader
   
   Copyright (C) 2006-2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2010 GNUstep Application Team
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

#import <AppKit/AppKit.h>

#import "Components.h"
#import "Feed.h"

/**
 * The database outline view component used to manage feeds and article groups.
 */
@interface DatabaseTreeViewController : ViewProvidingComponent
{
    IBOutlet NSOutlineView* outlineView;
}

// -------------------------------------------------------------------
//    Retrieving the update notification from the database
// -------------------------------------------------------------------

-(void) databaseChanged: (NSNotification*) notif;


// ---------------------------------------------------------------------
//    Retrieving feed fetching related ("did" and "will") notifications
// ---------------------------------------------------------------------

-(void) redrawFeedNotification: (NSNotification*) notif;


// -------------------------------------------------------------------
//    Retrieving focus request notifications for database elements
// -------------------------------------------------------------------

-(void) databaseElementRequestsFocus: (NSNotification*) notif;


// -------------------------------------------------------------------
//    Redraws a feed in the outline view
// -------------------------------------------------------------------

-(void) redrawFeed: (id<Feed>) feed;

// -------------------------------------------------------------------
//    NSOutlineView data source
// -------------------------------------------------------------------

/**
 * Implementation of this method is required.  Returns the child at
 * the specified index for the given item.
 */
- (id)outlineView: (NSOutlineView *)outlineView
            child: (NSInteger)index
           ofItem: (id)item;

/**
 * This is a required method.  Returns whether or not the outline view
 * item specified is expandable or not.
 */
- (BOOL)outlineView: (NSOutlineView *)outlineView
   isItemExpandable: (id)item;

/*
 * This is a required method.  Returns the number of children of
 * the given item.
 */
- (NSInteger)outlineView: (NSOutlineView *)outlineView
numberOfChildrenOfItem: (id)item;

/**
 * This is a required method.  Returns the object corresponding to the
 * item representing it in the outline view.
 */
- (id)outlineView: (NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item;


@end


