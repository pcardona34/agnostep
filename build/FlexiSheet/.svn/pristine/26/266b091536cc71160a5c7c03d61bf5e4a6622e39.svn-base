//
//  FSDocument.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSDocument.m,v 1.2 2014/01/26 09:23:52 buzzdee Exp $

#import "FlexiSheet.h"
#import "FSArchiving.h"
#import "FSImporter.h"

@interface FSDocument (QuantrixImport)

- (BOOL)_importQuantrixFromWrapper:(NSFileWrapper*)wrapper;

@end


@interface NSString(Bugfixes)

- (NSString*)_fix055FormatProblem;

@end


@implementation FSDocument

- (NSString*)_uniqueTableName:(NSString*)name
{
    while ([self tableWithName:name]) {
        name = [name followingString];
    }
    return name;
}

- (FSTable*)_setupDefaultTable
{
    id        hdr;
    int       idx;
    NSString *prefix;
    
    FSTable  *table = [[FSTable alloc] init];
    [table setName:[self _uniqueTableName:@"Table 1"]];
    [_tables addObject:table];
    [table release];

    prefix = [table nextAvailableHeaderName];
    hdr = [FSHeader headerNamed:prefix];
    [table addHeader:hdr];
    for (idx = 0; idx < 3; idx++) {
        [hdr appendKeyWithLabel:[NSString stringWithFormat:@"%@%i", prefix, idx+1]];
    }

    prefix = [table nextAvailableHeaderName];
    hdr = [FSHeader headerNamed:prefix];
    [table addHeader:hdr];
    for (idx = 0; idx < 3; idx++) {
        [hdr appendKeyWithLabel:[NSString stringWithFormat:@"%@%i", prefix, idx+1]];
    }

    [table setDocument:self];
    return table;
}


- (void)importTable:(id)sender
/*" Called from the UI, runs an open panel relative to the current window. "*/
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    FSImporter  *importer = [FSImporter sharedImporter];
    NSArray     *types = nil;

    [openPanel setTitle:@"Import"];
    [openPanel setPrompt:@"Import"];
    [openPanel setAccessoryView:[importer accessoryView]];
    [openPanel beginSheetForDirectory:nil file:nil types:types modalForWindow:[NSApp mainWindow]
                        modalDelegate:self didEndSelector:@selector(importPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:importer];
}


- (void)importPanelDidEnd:(NSOpenPanel*)sheet returnCode:(int)retCode contextInfo:(FSImporter*)importer
{
    if (retCode == 1) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        FSTableController    *controller = [[FSTableController alloc] initWithWindowNibName:@"FSTable"];
        FSTable              *table;
        NSString             *filename = [sheet filename];
        NSMutableDictionary  *param = [NSMutableDictionary dictionary];
        NSString             *sepStrg = [importer separatorSelection];
        NSData               *fileContents;
        NSString             *asString;

        [sheet orderOut:nil];
        //NSLog(@"Items separated by '%@'", sepStrg);
        [param setObject:sepStrg forKey:FSImportValueSeparator];

        fileContents = [[NSData alloc] initWithContentsOfFile:filename];
        NS_DURING
            asString = [[NSString alloc] initWithData:fileContents encoding:[importer stringEncodingSelection]];
        NS_HANDLER
            // Failed to load with specified encoding; try system default.
            asString = [[NSString alloc] initWithContentsOfFile:filename];
        NS_ENDHANDLER
        table = [[FSTable alloc] init];
        if ([importer importIntoTable:table fromCSV:asString parameters:param]) {
            [table setName:[filename lastPathComponent]];
            [_tables addObject:table];
            [table setDocument:self];
            [self addWindowController:controller];
            [controller setTable:table];
            [controller syncWithDocument];
            [[controller tableView] adjustAllCells];
            [[controller window] makeKeyAndOrderFront:self];

            [[self undoManager] registerUndoWithTarget:self
                                              selector:@selector(deleteTable:)
                                                object:table];

            [nc postNotificationName:FSSelectionDidChangeNotification
                              object:controller];
        } else {
        }

        [table release]; // Either unused or retained by someone else by now.
        
        [asString release];
        [fileContents release];
        [controller release];
    }
}


- (id)init
{
    self = [super init];
    
    _tables = [[NSMutableArray alloc] init];
    _worksheets = [[NSMutableArray alloc] init];
    _globalCategories = [[NSMutableArray alloc] init];

    [FSLog logDebug:@"FSDocument created."];

    return self;
}


- (id)retain
{
    [FSLog logDebug:@"FSDocument %X retained (now at %i).", self, [self retainCount]+1];
    return [super retain];
}


- (oneway void)release
{
    [FSLog logDebug:@"FSDocument %X released (now at %i).", self, [self retainCount]-1];
    [super release];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tables makeObjectsPerformSelector:@selector(setDocument:) withObject:nil];
    [_tables release];
    [_globalCategories release];
    [_worksheets release];
    [super dealloc];
    [FSLog logDebug:@"FSDocument deallocated."];
}


- (NSUndoManager*)undoManager
{
    return [super undoManager];
}


- (void)addToGlobalCategories:(FSGlobalHeader*)aGlobalHeader
{
    [_globalCategories addObject:aGlobalHeader];
}


- (void)removeFromGlobalCategories:(FSGlobalHeader*)aGlobalHeader
{
    [_globalCategories removeObject:aGlobalHeader];
}


- (NSArray*)globalCategories
{
    return _globalCategories;
}


- (void)document:(NSDocument *)doc shouldClose:(BOOL)shouldClose
     contextInfo:(void *)contextInfo
{
    if (shouldClose) 
        [self close];
}


- (void)closeDocument:(id)sender
{
    [self canCloseDocumentWithDelegate:self 
        shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
        contextInfo:NULL];
}


- (IBAction)newTable:(id)sender
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    FSWorksheet          *worksheet = [[FSWorksheet alloc] init];
    FSTable              *table = [self _setupDefaultTable];

    [_worksheets addObject:worksheet];
    [worksheet setTable:table];
    [worksheet displayWindow:YES];

    [[self undoManager] registerUndoWithTarget:self
                                      selector:@selector(deleteTable:)
                                        object:table];

    [nc postNotificationName:FSSelectionDidChangeNotification object:worksheet];
    
    [worksheet release];
}


- (void)deleteTable:(FSTable*)aTable
{
    NSArray     *sheets;
    FSWorksheet *sheet;
    int          index;

    if ([_tables count] < 2)
        return; // cannot delete the last table.
    if ([_tables containsObject:aTable] == NO)
        return; // table not in this document.

    // Close all open views for this table.
    sheets = [self worksheetsForTable:aTable];
    index = [sheets count];
    while (index-- > 0) {
        sheet = [sheets objectAtIndex:index];
        [sheet closeWindow];
        [_worksheets removeObject:sheet];
    }

    // Remove the table itself.
    [_tables removeObject:aTable];
    [FSLog logDebug:@"Table %x removed from document.\n", aTable];
}


- (void)makeWindowControllers
{
    NSString *fn = [self fileName];
    
    if ([[fn pathExtension] isEqualToString:@"quantrix"]) {
        [self setFileName:[[fn stringByDeletingPathExtension] stringByAppendingPathExtension:@"fsd"]];
    }
    if ([_tables count] == 0) {
        [[self undoManager] disableUndoRegistration];
        [self newTable:nil];
        [[self undoManager] enableUndoRegistration];
    }
}


- (NSArray*)tables
{
    return _tables;
}


- (FSTable*)tableWithName:(NSString*)name
{
    FSTable *table;
    int      idx = 0;
    
    while (idx < [_tables count]) {
        table = [_tables objectAtIndex:idx];
        if ([name isEqualToString:[table name]])
            return table;
        idx++;
    }
    return nil;
}


- (NSArray*)worksheetsForTable:(FSTable*)table
{
    NSMutableArray *result = [NSMutableArray array];
    FSWorksheet    *worksheet;
    int             idx = 0; // running from 0 up to preserve order.

    while (idx < [_worksheets count]) {
        worksheet = [_worksheets objectAtIndex:idx++];
        if ([worksheet table] == table) {
            [result addObject:worksheet];
        }
    }

    return result;
}


- (void)_makeWorksheetsFromArray:(NSArray*)views
{
    FSWorksheet        *worksheet;
    int                 index;
    NSDictionary       *dict;
    FSTable            *table;
    
    for (index = 0; index < [views count]; index++) {
        dict = [views objectAtIndex:index];
        table = [self tableWithName:[dict objectForKey:@"Table"]];
        if (nil == table) {
            if ([_tables count] == 1) {
                [FSLog logInfo:@"Table not specified in view.  Using default."];
                table = [_tables lastObject];
            } else {
                [FSLog logError:@"Unknown table while loading view."];
            }
        }
        if (table) {
            worksheet = [[FSWorksheet alloc] init];
            [worksheet loadFromDictionary:dict forTable:table];
            [_worksheets addObject:worksheet];
            [worksheet release];
        }
    }
}


- (void)displayView:(NSString*)name forTable:(FSTable*)table
{
    FSWorksheet        *worksheet;
    int                 idx = [_worksheets count];
    
    while (idx-- > 0) {
        worksheet = [_worksheets objectAtIndex:idx];
        if (([worksheet table] == table) && ([[worksheet name] isEqualToString:name])) {
            [worksheet displayWindow:YES];
            return;
        }
    }
}


- (void)updateWindows
{
    [[self windowControllers] makeObjectsPerformSelector:@selector(syncWithDocument)];
}


- (void)removeWindowController:(NSWindowController*)windowController
{
    FSWorksheet *ws;
    int          index = [_worksheets count];
    while (index-- > 0) {
        ws = [_worksheets objectAtIndex:index];
        if ([ws windowController] == windowController) {
            [ws closeWindow];
        }
    }
    
    [super removeWindowController:windowController];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSInspectorNeedsUpdateNotification
                                                        object:nil];
    [[NSApp mainWindow] becomeMainWindow]; // Reloads the table browser
}


- (IBAction)newTableView:(id)sender
/*" Wrong name here.  Creates a new table view, not a new table! "*/
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    FSWindowController   *currentWC = [[NSApp mainWindow] windowController];
    FSWorksheet          *worksheet;
    
    if (currentWC == nil) {
        NSBeep(); 
        return;
    }
    
    worksheet = [[FSWorksheet alloc] init];
    [_worksheets addObject:worksheet];
    [worksheet setTable:[currentWC table]];
    [worksheet displayWindow:YES];
    [worksheet release];
    [nc postNotificationName:FSInspectorNeedsUpdateNotification object:nil];
}


- (IBAction)XXXnewChartView:(id)sender
/*" Wrong name here.  Creates a new table view, not a new table! "*/
{
    FSWindowController *currentWC = [[NSApp mainWindow] windowController];
    FSTableController  *controller;
    
    if (currentWC == nil) {
        NSBeep(); 
        return;
    }

    controller = nil; //[[FSChartController alloc] initWithWindowNibName:@"FSChart"];
    [self addWindowController:controller];
    [controller setTable:[currentWC table]];
    [controller syncWithDocument];
    [controller showWindow:sender];
    [controller release];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSInspectorNeedsUpdateNotification
                                                        object:nil];
}


- (void)deleteWorksheet:(FSWorksheet*)worksheet
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
#warning -deleteWorksheet is not implemented.

    [nc postNotificationName:FSInspectorNeedsUpdateNotification object:nil];
}


- (NSDictionary*)_addWorksheetsToDictionary:(NSDictionary*)dataDict
{
    NSMutableDictionary *viewInfo = [NSMutableDictionary dictionary];
    int                  index = 0;
    NSMutableArray      *views = [NSMutableArray array];
    
    while (index < [_worksheets count]) {
        [views addObject:[[_worksheets objectAtIndex:index] dictionaryForArchiving]];
        index++;
    }
    [viewInfo addEntriesFromDictionary:dataDict];
    [viewInfo setObject:views forKey:@"FSViews"];
    return viewInfo;
}

- (NSData *)dataRepresentationOfType:(NSString*)aType
{
    // NSData       *output; // unused variable
    NSDictionary *dataDict = [self dictionaryForArchiving];
    // dataDict now only contains the core data.
    // Add the worksheets:
    dataDict = [self _addWorksheetsToDictionary:dataDict];
    
	// FIXME: should allow to specify XML format
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FSSaveCompressedPreference]) {
		return [NSPropertyListSerialization dataFromPropertyList:dataDict format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    }
		// This is the old code that would create the good old plist format.
	return [[dataDict packedDescription] dataUsingEncoding:NSUTF8StringEncoding];
}


- (BOOL)loadFileWrapperRepresentation:(NSFileWrapper*)wrapper ofType:(NSString*)type
{
    if ([wrapper isRegularFile]) {
        return [super loadFileWrapperRepresentation:wrapper ofType:type];
    }
    if ([wrapper isDirectory]) {
        BOOL result = [self _importQuantrixFromWrapper:wrapper];
        if (result) {
            if ([[self windowControllers] count] == 0) {
                NSRunAlertPanel(FS_LOCALIZE(@"Imported document contains no views."),
                    FS_LOCALIZE(@"This document only contains views that FlexiSheet cannot display."), 
                    FS_LOCALIZE(@"Close"), nil, nil);
                result = NO;
            }
            [_tables makeObjectsPerformSelector:@selector(recalculateFormulaSpace)];
        }
        return result;
    }
    return NO;
}


- (BOOL)loadDataRepresentation:(NSData*)data ofType:(NSString*)aType
{
    NSDictionary      *dataDict = nil;
    // char               twobytes[2]; // unused variable
    NSTimeInterval     start = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval     end;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSPropertyListFormat format;
	NSString *error;
	dataDict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainers format:&format errorDescription:&error];
	if(!dataDict)
		{ // try after fixing
			NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#if 1
			NSLog(@"trying to fix format problem");
#endif
			str = [str _fix055FormatProblem];
			dataDict = [NSPropertyListSerialization propertyListFromData:[str dataUsingEncoding:NSUTF8StringEncoding] mutabilityOption:NSPropertyListMutableContainers format:&format errorDescription:&error];			
#if 1
			if(!dataDict)
				NSLog(@"   failed.");
			else
				NSLog(@"   successful.");
#endif
		}
    NS_DURING
    [[self undoManager] disableUndoRegistration];
        if ([self loadDocumentFromDictionary:dataDict]) {
            [self _makeWorksheetsFromArray:[dataDict objectForKey:@"FSViews"]];
            [_tables makeObjectsPerformSelector:@selector(recalculateFormulaSpace)];
        }
        [[self undoManager] enableUndoRegistration];
    NS_HANDLER
        NSRunAlertPanel(FS_LOCALIZE(@"LOAD FAILED"),
            FS_LOCALIZE(@"INVALID FORMAT"), 
            FS_LOCALIZE(@"OK"), nil, nil);
        return NO;
    NS_ENDHANDLER
    
    [pool release];
    
    end = [NSDate timeIntervalSinceReferenceDate];
    [FSLog logInfo:@"File loaded in %3.2f seconds.", end-start];

    return YES;
}

@end


@implementation NSString(Bugfixes)

- (NSString*)_fix055FormatProblem
{
    NSMutableString *buffer = [NSMutableString stringWithString:self];
    [buffer replaceOccurrencesOfString:@"\n}" withString:@";\n}" options:0 range:NSMakeRange(0, [buffer length])];
    [buffer replaceOccurrencesOfString:@";;" withString:@";" options:0 range:NSMakeRange(0, [buffer length])];
    return buffer;
}

@end
