//
//  FSDocumentInspectorPane.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 15-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSDocumentInspectorPane.m,v 1.2 2014/01/26 09:23:52 buzzdee Exp $

#import "FSDocumentInspectorPane.h"
#import "SLCornerMenu.h"

@implementation FSDocumentInspectorPane

+ (void)initialize
{
    [FSInspectorPane registerInspectorPane:self];
}


- (void)awakeFromNib
{
    SLCornerMenu *cv;
    NSMenu       *menu;

    if ([tables target] != self) {
        [tables setTarget:self];
        [tables setAction:@selector(selectTable:)];
        [tables setDoubleAction:@selector(inspectTable:)];
        cv = [[SLCornerMenu alloc] initWithFrame:NSMakeRect(0,0,16,16)];
        [cv addItemWithTitle:@""]; // Empty label
        menu = [cv menu];
        [menu addItemWithTitle:@"Create New Table" action:@selector(newTable:) keyEquivalent:@""];
        [menu addItemWithTitle:@"Remove Table"     action:@selector(removeTable:) keyEquivalent:@""];
        [menu addItemWithTitle:@"Inspect Table"    action:@selector(inspectTable:) keyEquivalent:@""];
        [tables setCornerView:cv];
        [cv release];
    }

    if ([views target] != self) {
        [views setTarget:self];
        [views setDoubleAction:@selector(inspectView:)];
        cv = [[SLCornerMenu alloc] initWithFrame:NSMakeRect(0,0,16,16)];
        [cv addItemWithTitle:@""]; // Empty label
        menu = [cv menu];
        [menu addItemWithTitle:@"Create New View"   action:@selector(newTableView:) keyEquivalent:@""];
        [menu addItemWithTitle:@"Remove View"       action:@selector(removeView:) keyEquivalent:@""];
        [menu addItemWithTitle:@"Inspect View"      action:@selector(inspectView:) keyEquivalent:@""];
        [menu addItemWithTitle:@"Display View"      action:@selector(displayView:) keyEquivalent:@""];
        [views setCornerView:cv];
        [cv release];
    }
}


- (BOOL)validateUserInterfaceItem:(id)anItem
{
    if ([anItem action] == @selector(removeTable:)) {
        return (([[document tables] count] > 1) && (-1 != [tables selectedRow]));
    }
    if ([anItem action] == @selector(inspectTable:)) {
        return (-1 != [tables selectedRow]);
    }
    if ([anItem action] == @selector(removeView:)) {
        return (([worksheets count] > 1) && (-1 != [views selectedRow]));
    }
    if ([anItem action] == @selector(inspectView:)) {
        return (-1 != [views selectedRow]);
    }
    if ([anItem action] == @selector(displayView:)) {
        return (-1 != [views selectedRow]);
    }
    return NO;
}


- (NSString*)paneNibName
{
    return @"DocumentInspector";
}


- (NSString*)inspectorName
{
    return @"Document";
}


- (NSString*)paneIdentifier
{
    return @"Document";
}


- (void)updateWithSelection:(id<FSInspectable>)selection
{
    // if selection changed, release cached information.
    if (selection != document) {
        [worksheets release];
        worksheets = nil;
        [[viewColumn headerCell] setStringValue:@"No Selection"];
    }

    if ([selection isKindOfClass:[FSDocument class]] == NO) {
        document = nil;
        if ([selection respondsToSelector:@selector(document)]) {
            document = (FSDocument*)[(id)selection document];
            if ([document isKindOfClass:[FSDocument class]] == NO)
                document = nil;
        }
    } else {
        document = (FSDocument*)selection;
    }

    if (document != nil) {
        [header setStringValue:[document displayName]];
        [[tableColumn headerCell] setStringValue:[NSString stringWithFormat:@"Tables in '%@'", [document displayName]]];
    } else {
        [header setStringValue:@""];
        [[viewColumn headerCell] setStringValue:@"No Document"];
    }
    [tables reloadData];
    [self selectTable:nil];
}


- (IBAction)selectTable:(id)notUsed
{
    int index = [tables selectedRow];
    if (index >= 0) {
        FSTable *table = [[document tables] objectAtIndex:index];
        [worksheets release];
        worksheets = [[document worksheetsForTable:table] retain];
        [[viewColumn headerCell] setStringValue:[NSString stringWithFormat:@"Views on '%@'", [table name]]];
    } else {
        [worksheets release];
        worksheets = nil;
        [[viewColumn headerCell] setStringValue:@"No Table Selection"];
    }
    [views reloadData];
}


- (IBAction)removeTable:(id)notUsed
{
    NSArray *tableArray = [document tables];
    int      index = [tables selectedRow];
    if ([tableArray count] > 1) {
        if (index != -1) {
            int result;
            result = NSRunInformationalAlertPanel(@"Delete Table",
                                                  @"Deleting a table also removes all its views and cannot be undone.",
                                                  @"Delete Table", @"Abort Delete", nil);

            if (result == NSAlertDefaultReturn) {
                [document deleteTable:[tableArray objectAtIndex:index]];
            }
        }
    }
}


- (IBAction)inspectTable:(id)notUsed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FSSelectionDidChangeNotification
                                                        object:[[document tables] objectAtIndex:[tables selectedRow]]];
}


- (IBAction)removeView:(id)notUsed
{
    int index = [views selectedRow];
    
    if ([worksheets count] > 1) {
        if (index != -1) {
            int result;
            result = NSRunInformationalAlertPanel(@"Delete View",
                                                  @"Deleting a view cannot be undone.",
                                                  @"Delete View", @"Abort Delete", nil);

            if (result == NSAlertDefaultReturn) {
                [document deleteWorksheet:[worksheets objectAtIndex:index]];
                [self selectTable:tables];
            }
        }
    }
}


- (IBAction)inspectView:sender
{
    FSWorksheet *ws = [worksheets objectAtIndex:[views selectedRow]];

    [ws displayWindow:YES];
#warning -inspectView: is broken.
}


- (IBAction)displayView:(id)sender
{
    FSWorksheet *ws = [worksheets objectAtIndex:[views selectedRow]];

    [ws displayWindow:YES];
}

//
// TableDataSource
//

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (aTableView == tables) {
        return [[document tables] count];
    } else if (aTableView == views) {
        return [worksheets count];
    }
    return 0;
}


- (id)tableView:(NSTableView *)aTableView
	objectValueForTableColumn:(NSTableColumn *)column
			      row:(NSInteger)row
{
    if (column == tableColumn) {
        return [[[document tables] objectAtIndex:row] name];
    }
    if (column == viewColumn) {
        return [[worksheets objectAtIndex:row] name];
    }
    return @"Entry";
}

@end
