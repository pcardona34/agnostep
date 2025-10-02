//
//  FSController.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSController.m,v 1.2 2014/01/26 09:23:52 buzzdee Exp $

#import "FlexiSheet.h"
#import "FSImporter.h"
#import "FSInspector.h"
#import "FSFunctionHelp.h"
#import "SLSplashScreen.h"
#import "SLOutlineView.h"
#import "ImageAndTextCell.h"

static SLSplashScreen *_splashScreen;

//
// Version String
//
NSString *FSVersionString = @"$Author: buzzdee $  $Revision: 1.2 $";

//
// Preference Strings
//
NSString *FSShowInspectorPreference    = @"ShowInspector";
NSString *FSSaveCompressedPreference   = @"UseCompressedFormat";
NSString *FSDefaultFontFacePreference  = @"DefaultFontFace";
NSString *FSDefaultFontSizePreference  = @"DefaultFontSize";


@implementation FSController

#define ONE_DAY        86400
#define VALID_DAYS     91
#define TODAYSTRING    [NSString stringWithCString:__DATE__]
#define TODAY_DATE     [NSCalendarDate dateWithString:TODAYSTRING calendarFormat:@"%m/%d/%y"]
#define RELEASE_DAY    [TODAY_DATE timeIntervalSinceReferenceDate]
//#define TIMEOUT_DATE   (RELEASE_DAY + ONE_DAY*VALID_DAYS)

#define UPDATE_URL     @"http://www.materialarts.com/FlexiSheet/Beta.html"

+ (void)initialize
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:@"1"         forKey:FSShowInspectorPreference];
    [dict setObject:@"1"         forKey:FSSaveCompressedPreference];
    [dict setObject:@"Helvetica" forKey:FSDefaultFontFacePreference];
    [dict setObject:@"11"        forKey:FSDefaultFontSizePreference];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}


- (void)awakeFromNib
{
#ifdef TIMEOUT_DATE
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%y" allowNaturalLanguage:NO] autorelease];
    long daysLeft = (TIMEOUT_DATE-[NSCalendarDate timeIntervalSinceReferenceDate])/ONE_DAY;
#endif
    
    if (_splashScreen == nil) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSTableColumn *tableColumn = nil;
        ImageAndTextCell *imageAndTextCell = nil;

        // Insert custom cell types into the table view, the standard one does text only.
        // We want one column to have text and images, and one to have check boxes.
        tableColumn = [docOutline tableColumnWithIdentifier:@"ITEM"];
        imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
        [imageAndTextCell setEditable:YES];
        [tableColumn setDataCell:imageAndTextCell];

        _splashScreen = [[SLSplashScreen alloc] initWithName:@"splimg.png"];
    
        [nc addObserver:self selector:@selector(valueReverted:)
                   name:FSEditRevertedNotification object:nil];

        [nc addObserver:self selector:@selector(windowDidBecomeMain:)
                   name:NSWindowDidBecomeMainNotification object:nil];

        [nc addObserver:self selector:@selector(reloadDocOutlineFromNotification:)
                   name:NSWindowDidResignMainNotification object:nil];

        [nc addObserver:self selector:@selector(windowWillClose:)
                   name:NSWindowWillCloseNotification object:nil];

        [nc addObserver:self selector:@selector(reloadDocOutlineFromNotification:)
                   name:FSTableDidChangeNotification object:nil];

        if ([[NSUserDefaults standardUserDefaults] boolForKey:FSShowInspectorPreference]) {
            [self showInspector:nil];
        }
    }
#ifdef TIMEOUT_DATE
    if (daysLeft < 1) {
        int returnval =
        NSRunCriticalAlertPanel(FS_LOCALIZE(@"This release of FlexiSheet is too old."),
                                FS_LOCALIZE(@"The FlexiSheet Technology Preview test period is over."),
                                FS_LOCALIZE(@"Ignore"), FS_LOCALIZE(@"Update"), nil);
        if (returnval == NSAlertAlternateReturn)
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:UPDATE_URL]];
    }
    if (daysLeft < 10) {
        int returnval =
        NSRunInformationalAlertPanel(FS_LOCALIZE(@"This release of FlexiSheet will expire soon."),
                                     FS_LOCALIZE(@"The Technology Preview test period is almost over."),
                                     FS_LOCALIZE(@"OK"), FS_LOCALIZE(@"Update"), nil);
        if (returnval == NSAlertAlternateReturn)
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:UPDATE_URL]];
    }
#endif
    [FSLog logInfo:FS_LOCALIZE(@"Build date: %s"), __DATE__];
#ifdef TIMEOUT_DATE
    [FSLog logInfo:FS_LOCALIZE(@"This build will expire on %@, in %i days."),
        [formatter stringForObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:TIMEOUT_DATE]], daysLeft];
#endif
}


- (void)valueReverted:(NSNotification*)notification
{
    NSBeep();
}


- (void)importTable:(id)sender
    /*" Called from the UI, runs an open panel modal standalone. "*/
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    FSImporter  *importer = [FSImporter sharedImporter];

    [openPanel setTitle:@"Import into New Model"];
    [openPanel setPrompt:@"Import"];
    [openPanel setAccessoryView:[importer accessoryView]];

    if ([openPanel runModalForTypes:nil] == 1) {
        FSDocument           *newDoc = [self openUntitledDocumentOfType:@"FlexiSheet Document" display:NO];
        FSTableController    *controller = [[newDoc windowControllers] lastObject];
        NSString             *filename = [openPanel filename];
        NSMutableDictionary  *param = [NSMutableDictionary dictionary];
        NSString             *sepStrg = [importer separatorSelection];
        NSData               *fileContents = nil;
        NSString             *asString = nil;

        [param setObject:sepStrg forKey:FSImportValueSeparator];

        fileContents = [[NSData alloc] initWithContentsOfFile:filename];
        NS_DURING
            asString = [[NSString alloc] initWithData:fileContents encoding:[importer stringEncodingSelection]];
        NS_HANDLER
            // Failed to load with specified encoding; try system default.
            asString = [[NSString alloc] initWithContentsOfFile:filename];
        NS_ENDHANDLER
        [[controller table] setShouldPostNotifications:NO];
        [[newDoc undoManager] disableUndoRegistration];
        if ([importer importIntoTable:[controller table] fromCSV:asString parameters:param]) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [[controller table] setShouldPostNotifications:YES];
            [[controller table] setName:[filename lastPathComponent]];
            [[controller window] makeKeyAndOrderFront:self];
            [[newDoc undoManager] enableUndoRegistration];
            [nc postNotificationName:FSSelectionDidChangeNotification object:controller];
        } else {
            [newDoc close];
        }
        
        [asString release];
        [fileContents release];
    }
}


- (void)openViewFromTableBrowser:(id)sender
{
    NSInteger sel = [docOutline selectedRow];
    if (sel != NSNotFound) {
        FSWorksheet *ws = [docOutline itemAtRow:sel];
        if ([ws isKindOfClass:[FSWorksheet class]]) {
            [ws displayWindow:YES];
        }
    }
}


- (void)removeTableFromTableBrowser:(id)sender
{
    NSInteger sel = [docOutline selectedRow];
    if (sel != NSNotFound) {
        FSTable *table = [docOutline itemAtRow:sel];
        if ([table isKindOfClass:[FSTable class]]) {
			FSDocument* document = [table document];
			if ([[document tables] count] > 1)
			{
				[document performSelector:@selector(deleteTable:) withObject:table afterDelay:0.1];
			}
        }
    }
}


- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    if ([anItem action] == @selector(openViewFromTableBrowser:)) {
        NSInteger sel = [docOutline selectedRow];
        if (sel != NSNotFound) {
            id obj = [docOutline itemAtRow:sel];
            return ([obj isKindOfClass:[FSWorksheet class]]);
        }
        return NO;
    }
    if ([anItem action] == @selector(removeTableFromTableBrowser:)) {
        NSInteger sel = [docOutline selectedRow];
        if (sel != NSNotFound) {
            id obj = [docOutline itemAtRow:sel];
            return ([obj isKindOfClass:[FSTable class]]);
        }
        return NO;
    }
    if ([anItem action] == @selector(importTable:)) {
        return YES;
    }
    return [super validateUserInterfaceItem:anItem];
}


- (void)showFunctionHelp:(id)sender
{
    if (_functionHelp == nil) {
        _functionHelp = [[FSFunctionHelp alloc] init];
    }
    [_functionHelp showPanel:sender];
}


- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}


- (void)showSplash:(id)sender
{
    [[_splashScreen window] orderFrontRegardless];
}


- (void)showInspector:(id)sender
{
    [inspector showInspector:sender];
}

- (void)expandForWindow:(NSWindow*)window
{
    FSWindowController *wc = (FSWindowController*)[window windowController];
    FSDocument         *doc = [wc document];

    if (doc) {
        [docOutline reloadData];
        if ([docOutline rowForItem:doc] != NSNotFound) {
            FSTable *table = [wc table];
            [docOutline expandItem:doc];
            if (table) [docOutline expandItem:table];
        }
    }
}

- (id)openDocumentWithContentsOfFile:(NSString *)fileName display:(BOOL)display
{
    id result = [super openDocumentWithContentsOfFile:fileName display:display];
    [self expandForWindow:[NSApp mainWindow]];
    return result;
}

- (void)collapseDocument:(FSDocument*)document
{
    // This little bit of code fixes the buggy no-release behavior of NSOutlineView.
    [[document tables] iteratePerformSelector:@selector(collapseItem:) target:docOutline];
    [docOutline collapseItem:document];
}

- (void)removeDocument:(NSDocument*)document
{
    if ([document isKindOfClass:[FSDocument class]])
        [self collapseDocument:(FSDocument*)document];
    [super removeDocument:document];
    [docOutline reloadData];
}

@end


@implementation FSController (DocumentOverview)

- (id)outlineView:(NSOutlineView*)ov child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        // root object
        return [[self documents] objectAtIndex:index];
    }
    if ([item isKindOfClass:[FSDocument class]]) {
        return [[item tables] objectAtIndex:index];
    }
    if ([item isKindOfClass:[FSTable class]]) {
        return [[[item document] worksheetsForTable:item] objectAtIndex:index];
    }
    return nil;   
}

- (BOOL)outlineView:(NSOutlineView*)ov isItemExpandable:(id)item
{
    if ([item isKindOfClass:[FSDocument class]]) return YES;
    if ([item isKindOfClass:[FSTable class]]) return YES;
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView*)ov numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [[self documents] count];
    }
    if ([item isKindOfClass:[FSDocument class]]) {
        return [[item tables] count];
    }
    if ([item isKindOfClass:[FSTable class]]) {
        return [[[item document] worksheetsForTable:item] count];
    }
    return 0;
}

- (id)outlineView:(NSOutlineView*)ov objectValueForTableColumn:(NSTableColumn*)tc byItem:(id)item
{
    if ([item isKindOfClass:[FSDocument class]]) {
        return [item displayName];
    }
    if ([item isKindOfClass:[FSTable class]]) {
        return [item name];
    }
    if ([item isKindOfClass:[FSWorksheet class]]) {
        return [item name];
    }
    return @"";
}

- (BOOL)outlineView:(NSOutlineView*)outlineView shouldEditTableColumn:(NSTableColumn*)tableColumn item:(id)item
{
    if ([item isKindOfClass:[FSTable class]]) return YES;
    if ([item isKindOfClass:[FSWorksheet class]]) return YES;
    return NO;
}

- (void)outlineView:(NSOutlineView*)ov setObjectValue:(id)value forTableColumn:(NSTableColumn*)tc byItem:(id)item
{
    if ([item isKindOfClass:[FSTable class]]) {
        [(FSTable*)item setName:value];
    }
    if ([item isKindOfClass:[FSWorksheet class]]) {
        [(FSWorksheet*)item setName:value];
    }
}

- (void)outlineView:(NSOutlineView*)ov willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn*)tc item:(id)item
{
    if ([item isKindOfClass:[FSTable class]]) {
        [cell setImage:[NSImage imageNamed:@"TableSmIcon"]];
        return;
    }
    if ([item isKindOfClass:[FSWorksheet class]]) {
        [cell setImage:[NSImage imageNamed:@"TViewSmIcon"]];
        return;
    }
    [cell setImage:nil];
}

@end


@implementation FSController (WindowDelegation)

- (void)reloadDocOutlineFromNotification:(NSNotification*)notification
{
    [docOutline reloadData];
}

- (void)windowDidBecomeMain:(NSNotification*)notification
{
    [self expandForWindow:[notification object]];
}

- (void)windowWillClose:(NSNotification*)notification
{
    NSWindow    *window = [notification object];

    if ([NSApp mainWindow] == window) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:FSSelectionDidChangeNotification
                          object:nil];
    }
}

@end
