//
//  FSTableController+Toolbar.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 22-FEB-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableController+Toolbar.m,v 1.1 2008/10/14 15:03:47 hns Exp $

#import "FlexiSheet.h"

static NSString*   FSTableToolbarID  = @"FSTableToolbarIdentifier";
static NSString*   FSFormulaToolbarID  = @"FSFormulaToolbarIdentifier";

// These should be somewhere else for reuse!
static NSString*   FSSaveDocumentItemID = @"FSSaveDocumentItem";
static NSString*   FSInspectItemID = @"FSInspectItem";
static NSString*   FSEditItemID = @"FSEditItem";
static NSString*   FSUndoItemID = @"FSUndoItem";
static NSString*   FSRedoItemID = @"FSRedoItem";
static NSString*   FSDeleteCommandItemID = @"FSDeleteCommandItem";
static NSString*   FSRecalculateItemID = @"FSRecalculateItem";

// These identifiers are for formula components
static NSString*   FSEqualElementItemId = @"FSEqualElementItem";
static NSString*   FSIfBlockElementItemId = @"FSIfBlockElementItem";


@implementation FSTableController (ToolbarDelegate)

- (void)setupTableToolbar
{
    // Create a new toolbar instance, and attach it to our document window
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: FSTableToolbarID] autorelease];

    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconOnly];

    // We are the delegate
    [toolbar setDelegate: self];

    // Attach the toolbar to the document window
    [[self window] setToolbar:toolbar];
}


- (void)setupFormulaToolbar
{
    // Create a new toolbar instance, and attach it to our document window
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: FSFormulaToolbarID] autorelease];

    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeLabelOnly];

    // We are the delegate
    [toolbar setDelegate: self];

    // Attach the toolbar to the document window
    [[self window] setToolbar:toolbar];
}


- (NSToolbarItem*)formulaItemForItemIdentifier:(NSString*)itemId
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemId] autorelease];

    if ([itemId isEqualToString:FSEqualElementItemId]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"=")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"=")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"Equal sign")];
        [toolbarItem setImage:nil];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(insertEqualSign:)];
    } else if ([itemId isEqualToString:FSIfBlockElementItemId]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"if (cond, true, false)")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"if (cond, true, false)")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"if Block")];
        [toolbarItem setImage:nil];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(insertIfBlock:)];
    } else {
        toolbarItem = nil;
    }
    
    return toolbarItem;
}


- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar
     itemForItemIdentifier:(NSString*)itemId
 willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
    NSToolbarItem *toolbarItem;

    //
    // If this is the formula toolbar, we have our own means to create items.
    //
    if ([[toolbar identifier] isEqualToString:FSFormulaToolbarID])
        return [self formulaItemForItemIdentifier:itemId];

    //
    // else the 
    //
    toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemId] autorelease];

    if ([itemId isEqualToString:FSSaveDocumentItemID]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"Save")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"Save")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"Save Your Document")];
        [toolbarItem setImage: [NSImage imageNamed:@"TBSaveDocument"]];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(saveDocument:)];
    } else if ([itemId isEqualToString:FSDeleteCommandItemID]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"Delete")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"Delete")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"Delete")];
        [toolbarItem setImage: [NSImage imageNamed:@"TBDelete"]];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(deleteBackward:)];
    } else if ([itemId isEqualToString:FSRecalculateItemID]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"Recalculate")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"Recalculate")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"Recalculate")];
        [toolbarItem setImage: [NSImage imageNamed:@"TBRecalc"]];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(recalculate:)];
    } else if ([itemId isEqualToString:FSInspectItemID]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"Inspect")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"Inspect")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"Inspect")];
        [toolbarItem setImage: [NSImage imageNamed:@"TBInspect"]];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(showInspector:)];
    } else if ([itemId isEqualToString:FSEditItemID]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"Edit")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"Edit")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"Edit")];
        [toolbarItem setImage: [NSImage imageNamed:@"TBEdit"]];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(startEditing:)];
    } else if ([itemId isEqualToString:FSUndoItemID]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"Undo")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"Undo")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"Undo")];
        [toolbarItem setImage: [NSImage imageNamed:@"TBUndo"]];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(undo:)];
    } else if ([itemId isEqualToString:FSRedoItemID]) {
        [toolbarItem setLabel:FS_LOCALIZE(@"Redo")];
        [toolbarItem setPaletteLabel:FS_LOCALIZE(@"Redo")];
        [toolbarItem setToolTip:FS_LOCALIZE(@"Redo")];
        [toolbarItem setImage: [NSImage imageNamed:@"TBRedo"]];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(redo:)];
    } else {
        toolbarItem = nil;
    }

    return toolbarItem;
}

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    if ([[toolbar identifier] isEqualToString:FSTableToolbarID]) {
        return [NSArray arrayWithObjects:
            FSSaveDocumentItemID,
            NSToolbarSeparatorItemIdentifier,
            FSUndoItemID,
            FSRedoItemID,
            FSDeleteCommandItemID,
            NSToolbarSeparatorItemIdentifier,
            FSRecalculateItemID,
            NSToolbarFlexibleSpaceItemIdentifier,
            NSToolbarShowColorsItemIdentifier,
            NSToolbarShowFontsItemIdentifier,
            NSToolbarSeparatorItemIdentifier,
            NSToolbarCustomizeToolbarItemIdentifier,
            nil];
    }
    if ([[toolbar identifier] isEqualToString:FSFormulaToolbarID]) {
        return [NSArray arrayWithObjects:
            // FSShowFunctionPanelIdentifier,
            NSToolbarSeparatorItemIdentifier,
            FSEqualElementItemId,
            FSIfBlockElementItemId,
            nil];
    }
    return [NSArray array];
}

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    if ([[toolbar identifier] isEqualToString:FSTableToolbarID]) {
        return [NSArray arrayWithObjects:
            FSSaveDocumentItemID,
            FSInspectItemID,
            FSEditItemID,
            FSUndoItemID,
            FSRedoItemID,
            FSDeleteCommandItemID,
            FSRecalculateItemID,
            NSToolbarShowColorsItemIdentifier,
            NSToolbarShowFontsItemIdentifier,
            NSToolbarPrintItemIdentifier,
            NSToolbarSeparatorItemIdentifier,
            NSToolbarSpaceItemIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            NSToolbarCustomizeToolbarItemIdentifier,
            nil];
    }
    if ([[toolbar identifier] isEqualToString:FSFormulaToolbarID]) {
        return [NSArray arrayWithObjects:
            FSEqualElementItemId,
            FSIfBlockElementItemId,
            NSToolbarSeparatorItemIdentifier,
            nil];
    }
    return [NSArray array];
}

@end
