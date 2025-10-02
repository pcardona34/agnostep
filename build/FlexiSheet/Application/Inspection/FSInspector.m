//
//  FSInspector.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 14-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSInspector.m,v 1.1 2008/10/28 13:10:29 hns Exp $

#import "FlexiSheet.h"
#import "FSInspector.h"
#import "FSInspectorPane.h"

static NSString*   FSInspectorToolbarId  = @"FSInspectorToolbarIdentifier";

// These should be somewhere else for reuse!
static NSString*   FSShowDocumentInspectorItemID = @"Document";
static NSString*   FSShowTableInspectorItemID = @"Table";
static NSString*   FSShowWindowInspectorItemID = @"View";
static NSString*   FSShowHeaderInspectorItemID = @"Header";


@implementation FSInspector

- (void)awakeFromNib
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(selectionDidChange:)
               name:FSSelectionDidChangeNotification object:nil];
    /*
    [nc addObserver:self selector:@selector(updateSelection:)
               name:NSUndoManagerDidUndoChangeNotification object:nil];
    [nc addObserver:self selector:@selector(updateSelection:)
               name:NSUndoManagerDidRedoChangeNotification object:nil];
     */
    [nc addObserver:self selector:@selector(updateSelection:)
               name:FSInspectorNeedsUpdateNotification object:nil];
}


- (void)showInspector:(id)sender
{
    if (infoPanel == nil) {
        NSToolbar *toolbar;

        [NSBundle loadNibNamed:@"Inspector" owner:self];
        
        // Create a new toolbar instance, and attach it to the inspector panel
        toolbar = [[[NSToolbar alloc] initWithIdentifier:FSInspectorToolbarId] autorelease];

        // Set up toolbar properties: Disable customization, set text only display mode, don't write defaults.
        [toolbar setAllowsUserCustomization:NO];
        [toolbar setAutosavesConfiguration:NO];
        [toolbar setDisplayMode:NSToolbarDisplayModeLabelOnly];

        // We are the delegate
        [toolbar setDelegate:self];

        // Attach the toolbar to the inspector panel
        [infoPanel setToolbar:toolbar];
    }

    if (selection) {
        [self selectPaneWithIdentifier:[selection paneIdentifier]];
        [activePane updateWithSelection:selection];
    } else {
        [self selectPaneWithIdentifier:@"NoSelection"];
    }
    [infoPanel makeKeyAndOrderFront:sender];
}


- (void)selectPaneWithIdentifier:(NSString*)identifier
{
    activePane = [FSInspectorPane inspectorPaneForIdentifier:identifier];
    [paneContainer setContentView:[activePane paneView]];
    [infoPanel setTitle:[NSString stringWithFormat:@"Inspecting %@", [activePane inspectorName]]];
    [infoPanel setDelegate:activePane];
}


- (void)selectPaneFromToolbarItem:(NSToolbarItem*)sender
{
    [self selectPaneWithIdentifier:[sender paletteLabel]];
    [activePane updateWithSelection:selection];
}


- (void)updateSelection:(NSNotification*)notification
{
    [activePane updateWithSelection:selection];
}


- (void)selectionDidChange:(NSNotification*)notification
{
    id<FSInspectable>  newSelection = [notification object];
    NSDictionary      *info = [notification userInfo];
    id                 object;

    if (newSelection != selection) {
        [selection release];
        selection = nil;

        if (newSelection == nil) {
            [self selectPaneWithIdentifier:@"NoSelection"];
        } else if ([newSelection conformsToProtocol:@protocol(FSInspectable)]) {
            selection = [newSelection retain];
            [self selectPaneWithIdentifier:[selection paneIdentifier]];
        } else {
            [self selectPaneWithIdentifier:@"MultipleSelection"];
        }
    }

    object = [info objectForKey:FSWorksheetInfo];
    if (object) [activePane setActiveWorksheet:object];
    object = [info objectForKey:FSTableviewInfo];
    if (object) [activePane setActiveTableView:object];
    [activePane updateWithSelection:selection];
}

@end


@implementation FSInspector (NSToolbarSupport)

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
        FSShowDocumentInspectorItemID,
        FSShowWindowInspectorItemID,
        FSShowTableInspectorItemID,
        FSShowHeaderInspectorItemID,
        nil];
}


- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
        FSShowDocumentInspectorItemID,
        FSShowWindowInspectorItemID,
        FSShowTableInspectorItemID,
        FSShowHeaderInspectorItemID,
        nil];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemId willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemId];

    [toolbarItem setLabel:FS_LOCALIZE(itemId)];
    [toolbarItem setPaletteLabel:itemId];
    [toolbarItem setToolTip:nil];
    [toolbarItem setImage:nil];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(selectPaneFromToolbarItem:)];

    return [toolbarItem autorelease];
}

@end
