//
//  FSWindowController.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 31-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//                2014 Riccardo Mottola
//
//  $Id: FSWindowController.m,v 1.5 2014/01/26 23:08:04 rmottola Exp $

#import <Foundation/NSObject.h>

#import "FlexiSheet.h"
#import "FSExporter.h"
#import "FSSortPanelController.h"


static NSArray*    __FSTCPBTYPES = nil;

@implementation FSWindowController

+ (void)initialize
{
    if (__FSTCPBTYPES == nil) {
        __FSTCPBTYPES = [[NSArray alloc] initWithObjects:
            FSTableDataPboardType,
            FSTableItemPboardType,
            NSStringPboardType,
            nil];
    }
}


- (void)_cacheLayout
/*" This implementation does nothing.  
    Subclasses can implement this method to cache layout information.
    FSWindowController calls this method whenever the document structure changed. "*/
{
}


- (void)_storeLayout
/*" This implementation does nothing.  
    Subclasses can implement this method to write back cached layout information.
    FSWindowController calls this method before the document structure changes. "*/
{
}


- (id)initWithWindow:(NSWindow *)window
/*" ??? "*/
{
    self = [super initWithWindow:window];
    if (self) {
        _pageHeaders  = [[NSMutableArray alloc] init];
        _rightHeaders = [[NSMutableArray alloc] init];
        _topHeaders   = [[NSMutableArray alloc] init];
        _sideHeaders  = [[NSMutableArray alloc] init];
        _name = @"View";
        _headerColors = [[NSMutableDictionary alloc] init];
        _sortController = nil;
        _worksheet = nil;
        [FSLog logDebug:@"%@ created.", [self className]];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_sortController release];
    [_headerColors release];

    [_pageHeaders release];
    [_pageKeySets release];
    
    [_rightHeaders release];
    [_rightKeySets release];
    
    [_topHeaders release];
    [_topKeySets release];
    
    [_sideHeaders release];
    [_sideKeySets release];

    [_name release];
    [_table release];
    [FSLog logDebug:@"%@ deallocated.", [self className]];
    [super dealloc];
}


- (void)windowDidLoad
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [super windowDidLoad];

    [headDock setDelegate:self];
    [nc addObserver:self selector:@selector(headersChangedInDock:)
               name:FSHeadersChangedInDockNotification object:headDock];
    [leftDock setDelegate:self];
    [nc addObserver:self selector:@selector(headersChangedInDock:)
        name:FSHeadersChangedInDockNotification object:leftDock];
    [pageDock setDelegate:self];
    [nc addObserver:self selector:@selector(headersChangedInDock:)
        name:FSHeadersChangedInDockNotification object:pageDock];
    [rightDock setDelegate:self];
    [nc addObserver:self selector:@selector(headersChangedInDock:)
               name:FSHeadersChangedInDockNotification object:rightDock];
}


- (FSTableView*)tableView
{
    return tableView;
}


- (FSTable*)table { return _table; }


- (void)setTable:(FSTable*)table
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [table retain];
    [_table release];
    _table = table;
    [nc removeObserver:self];
    [nc addObserver:self selector:@selector(abortEditingForUndo:)
        name:NSUndoManagerWillUndoChangeNotification object:[table undoManager]];
    [nc addObserver:self selector:@selector(abortEditingForUndo:)
        name:NSUndoManagerWillRedoChangeNotification object:[table undoManager]];
    [nc addObserver:self selector:@selector(tableWillChange:)
        name:FSTableWillChangeNotification object:table];
    [nc addObserver:self selector:@selector(tableDidChange:)
        name:FSTableDidChangeNotification object:table];
    [nc addObserver:self selector:@selector(valueDidChange:)
        name:FSValueDidChangeNotification object:table];
}


- (void)abortEditingForUndo:notification
{
    [[self window] makeFirstResponder:nil];
}


- (void)tableWillChange:(NSNotification*)notification
{
    [self _storeLayout];
}


- (void)tableDidChange:(NSNotification*)notification
{
    [self synchronizeWindowTitleWithDocumentName];
    [self syncWithDocument];
    [_table recalculateFormulaSpace];
    [self _cacheLayout];
    [self updateDisplay];
}


- (void)valueDidChange:(NSNotification*)notification
{
    [_table recalculateFormulaSpace];
}


- (void)exportTable:(id)sender
{
    [[FSExporter sharedExporter] runExportSheetForWindowController:self];
}


- (void)sortItems:(id)sender
{
    if (_sortController == nil) {
        _sortController = [[FSSortPanelController sortPanelController] retain];
    }
    [_sortController runSortSheetForWindowController:self];
}


- (void)syncWithDocument
/*" This method is called from FSDocument.
    It makes sure all headers in the page, top, left and right docks
    still exist in the table.  Additional headers are added
    to the page dock after making sure that the top and
    side docks are not empty."*/
{
    NSMutableArray *headers = [NSMutableArray arrayWithArray:[_table headers]];
    
    [_topHeaders removeObjectsNotInArray:headers];
    [headers removeObjectsInArray:_topHeaders];
    [_sideHeaders removeObjectsNotInArray:headers];
    [headers removeObjectsInArray:_sideHeaders];
    [_pageHeaders removeObjectsNotInArray:headers];
    [headers removeObjectsInArray:_pageHeaders];
    [_rightHeaders removeObjectsNotInArray:headers];
    [headers removeObjectsInArray:_rightHeaders];
    while ([headers count] > 0) {
        if ([_topHeaders count] == 0) {
            [_topHeaders addObject:[headers objectAtIndex:0]];
            [headers removeObjectAtIndex:0];
        } else if ([_sideHeaders count] == 0) {
            [_sideHeaders addObject:[headers objectAtIndex:0]];
            [headers removeObjectAtIndex:0];
        } else if ([_pageHeaders count] == 0) {
            [_pageHeaders addObject:[headers objectAtIndex:0]];
            [headers removeObjectAtIndex:0];
        } else {
            [_rightHeaders addObjectsFromArray:headers];
            [headers removeAllObjects];
        }
    }
    
    [self createHeaderSets];
}

- (void)createHeaderSets
/*" Recreates the header docks and internal information to support it.
    Must be called after the top/left association of headers changes. "*/
{
    [_topKeySets release];
    _topKeySets = [[_table keySetsForHeaders:_topHeaders] retain];
    [headDock setHeaders:_topHeaders];
    
    [_sideKeySets release];
    _sideKeySets = [[_table keySetsForHeaders:_sideHeaders] retain];
    [leftDock setHeaders:_sideHeaders];

    [_pageKeySets release];
    _pageKeySets = [[_table keySetsForHeaders:_pageHeaders] retain];
    [pageDock setHeaders:_pageHeaders];

    [_rightKeySets release];
    _rightKeySets = [[_table keySetsForHeaders:_rightHeaders] retain];
    [rightDock setHeaders:_rightHeaders];
}

- (void)setPageHeaders:(NSArray*)headers
{
    [_pageHeaders removeAllObjects];
    if (headers != nil)
        [_pageHeaders addObjectsFromArray:headers];
}

- (void)setRightHeaders:(NSArray*)headers
{
    [_rightHeaders removeAllObjects];
    if (headers != nil)
        [_rightHeaders addObjectsFromArray:headers];
}

- (void)setSideHeaders:(NSArray*)headers
{
    [_sideHeaders removeAllObjects];
    if (headers != nil)
        [_sideHeaders addObjectsFromArray:headers];
}

- (void)setTopHeaders:(NSArray*)headers
{
    [_topHeaders removeAllObjects];
    if (headers != nil)
        [_topHeaders addObjectsFromArray:headers];
}


- (void)updateDisplay
/*" Marks views as dirty.  Subclasses should overwrite and call super. "*/
{
    [leftDock setNeedsDisplay:YES];
    [headDock setNeedsDisplay:YES];
    [pageDock setNeedsDisplay:YES];
    [rightDock setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSInspectorNeedsUpdateNotification
                                                        object:self];
}


- (NSDictionary*)layoutDictionary
/*" Subclasses should implement this method
    so layout information can be saved to a file or pasteboard.
    This super implementation should be called. "*/
{
    NSMutableDictionary *layout = [NSMutableDictionary dictionary];

    [layout setObject:[[tableView defaultStyle] dictionaryForArchiving]
               forKey:@"DefaultStyle"];
    
    return layout;
}


- (void)applyLayoutDictionary:(NSDictionary*)dict
/*" Subclasses should implement this method 
    so layout information can be restored from a file or pasteboard.
    This super implementation should be called. "*/
{
    FSCellStyle *style;
    style = [FSCellStyle cellStyleWithDictionary:[dict objectForKey:@"DefaultStyle"]];
    [style setUndoManager:[_table undoManager]];
    [tableView setDefaultStyle:style];
}


- (NSString*)name /*" Returns the name for this window. "*/
{ return _name; }


- (void)setName:(NSString*)aName
/*"Sets a name for this window.
    Users can give each view on the data a different name. "*/
{
    if ([aName isEqualToString:_name]) return;
    [_name release];
    _name = [aName copy];
    [self synchronizeWindowTitleWithDocumentName];
}


- (FSWorksheet*)worksheet
{
    return _worksheet;
}


- (void)setWorksheet:(FSWorksheet*)aWorksheet
{
    _worksheet = aWorksheet;
}


- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
/*" Overwritten to combine the view name with the document title.
    "*/
{
    return [NSString stringWithFormat:@"%@ - %@, %@", displayName, [_table name], _name];
}


- (void)headersChangedInDock:(NSNotification*)notification
/*" Called from FSHeaderDock whenever one of the category panes changes location.
    Also called when a category is added from a header dock.
    This method does not modify cached values etc. "*/
{
    FSHeaderDock  *nDock = [notification object];
    FSHeader      *movedHeader = [[notification userInfo] objectForKey:@"MovedHeader"];

    [self _storeLayout];
    [_topHeaders removeAllObjects];
    [_topHeaders addObjectsFromArray:[headDock headers]];
    if (nDock != headDock) {
        [_topHeaders removeObject:movedHeader];
        [headDock setHeaders:_topHeaders];
    }
    
    [_sideHeaders removeAllObjects];
    [_sideHeaders addObjectsFromArray:[leftDock headers]];
    if (nDock != leftDock) {
        [_sideHeaders removeObject:movedHeader];
        [leftDock setHeaders:_sideHeaders];
    }

    [_pageHeaders removeAllObjects];
    [_pageHeaders addObjectsFromArray:[pageDock headers]];
    if (nDock != pageDock) {
        [_pageHeaders removeObject:movedHeader];
        [pageDock setHeaders:_pageHeaders];
    }

    [_rightHeaders removeAllObjects];
    [_rightHeaders addObjectsFromArray:[rightDock headers]];
    if (nDock != rightDock) {
        [_rightHeaders removeObject:movedHeader];
        [rightDock setHeaders:_rightHeaders];
    }
}

@end


@implementation FSWindowController (FSFirstResponder)

- (NSString*)_uniqueLabel:(NSString*)name inGroup:(FSKeyGroup*)group
{
    while ([group itemWithLabel:name]) {
        name = [name followingString];
    }
    return name;
}


- (void)insertItem:(id)sender
/*" Inserts a new row or column at the position of the current selection. "*/
{
    FSKeyRange  *sel;
    NSString    *name;
    //
    // If item selected, insert new item.
    //
    if ((sel = [tableView selectedItems])) {
        NSRange idx = [sel indexRange];
        int     pos = idx.location+idx.length;
        name = [[[sel itemsInRange] lastObject] label];
        name = [self _uniqueLabel:name inGroup:[sel group]];
        [[sel group] insertKeyWithLabel:name atIndex:pos];
        [tableView selectItems:
            [FSKeyRange keyRangeWithRange:NSMakeRange(pos,1)
                inGroup:[sel group]]];
        [tableView scrollItemSelectionToVisible];
    }
}


- (void)deleteBackward:(id)sender
{
    id           first = [[self window] firstResponder];
    FSKeyRange  *sel;

    //
    // If the first responder understands deleteSelection:
    //
    if ([first respondsToSelector:@selector(deleteSelection:)]) {
        [first deleteSelection:sender];
    } else
    //
    // If items selected, delete selected items.
    //
    if ((sel = [tableView selectedItems])) {
        FSKeyGroup *group = [sel group];
        NSRange     range = [sel indexRange];
        [group deleteItemsInRange:range];
        [tableView selectItems:
            [FSKeyRange keyRangeWithRange:NSMakeRange(MAX(1,range.location)-1,1)
                inGroup:group]];
        [tableView scrollItemSelectionToVisible];
    }
}


- (void)groupItems:(id)sender
{
    FSKeyRange  *sel;
    
    sel = [tableView selectedItems];
    if (sel) {
        FSKeyGroup *group = [[sel group] groupItemsInRange:[sel indexRange] withLabel:@"aGroup"];
        [tableView ensureSpaceForNewGroup:group];
    }
}


- (void)ungroupItems:(id)sender
{
    FSKeyRange  *sel;
    
    sel = [tableView selectedItems];
    if ([sel isSingleItem]) {
        FSKeyGroup *item = [sel singleItem];
        if ([item isKindOfClass:[FSKeyGroup class]]) {
            int index = [sel indexRange].location;
            int length = [[item items] count];
            id  group = [sel group];
            
            [group ungroupAtIndex:index];
            [tableView selectItems:
                [FSKeyRange keyRangeWithRange:NSMakeRange(index,length)
                    inGroup:group]];
            [tableView scrollItemSelectionToVisible];
        }
    }
}


- (void)moveItemUp:(id)sender
{
    FSKeyRange *sel = [tableView selectedItems];
    if ([sel isAtTop] == NO) {
        NSRange idx = [sel indexRange];
        [[sel group] moveItemFromIndex:idx.location-1 toIndex:idx.location+idx.length];
        [tableView scrollItemSelectionToVisible];
    }
}


- (void)moveItemDown:(id)sender
{
    FSKeyRange *sel = [tableView selectedItems];
    if ([sel isAtBottom] == NO) {
        NSRange idx = [sel indexRange];
        [[sel group] moveItemFromIndex:idx.location+idx.length toIndex:idx.location];
        [tableView scrollItemSelectionToVisible];
    }
}


- (void)paste:(id)sender
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSString *type = [pboard availableTypeFromArray:__FSTCPBTYPES];
    
    if ([tableView hasItemSelection]) {
        if ([type isEqualToString:FSTableItemPboardType]) {
            FSKeyRange *range;
            
            if ((range = [tableView selectedItems])) {
                NSRange idx = [range indexRange];
                int pos = (idx.location+idx.length);
                int c = [[range group] pasteAtIndex:pos];
                [tableView selectItems:
                    [FSKeyRange keyRangeWithRange:NSMakeRange(pos,c)
                        inGroup:[range group]]];
                [tableView scrollItemSelectionToVisible];
            }
        }
    } else if ([tableView hasDataSelection]) {
        FSSelection   *sel = [tableView selection];
        NSPasteboard  *pboard = [NSPasteboard generalPasteboard];
        NSArray       *data = [pboard propertyListForType:FSTableDataPboardType];
        if (data) {
            [_table setValues:data inSelection:sel];
        } else {
            NSString *valueStrg = [pboard stringForType:NSStringPboardType];
            NSArray  *values = [valueStrg valuesFromExcelPasteboard];
            
            if (values) {
                [_table setValues:values inSelection:sel];
            }
        }
    }
}


- (void)transpose:(id)sender
/*" Swaps row and column headers.

    Undo-wise this is a special case.  It does not effect the other views. "*/
{
    id temp;
    
    [[[self document] undoManager] 
        registerUndoWithTarget:self selector:@selector(transpose:) object:nil];
    [self _storeLayout];
    temp = _topHeaders;
    _topHeaders = _sideHeaders;
    _sideHeaders = temp;
    temp = _topKeySets;
    _topKeySets = _sideKeySets;
    _sideKeySets = temp;
    [leftDock setHeaders:_sideHeaders];
    [headDock setHeaders:_topHeaders];
    [self _cacheLayout];
    [self updateDisplay];
}


- (BOOL)validateUserInterfaceItem:(id <NSObject, NSValidatedUserInterfaceItem>)anItem
{
    if ([anItem action] == @selector(clear:)) {
        return ([tableView hasDataSelection]);
    } else
    if (([anItem action] == @selector(cut:))
    || ([anItem action] == @selector(copy:))) {
        return ([tableView hasItemSelection] || [tableView hasDataSelection]);
    } else
    if ([anItem action] == @selector(paste:)) {
        if ([tableView hasItemSelection]) {
            NSPasteboard *pboard = [NSPasteboard generalPasteboard];
            NSString *type = [pboard availableTypeFromArray:__FSTCPBTYPES];
            return ([type isEqualToString:FSTableItemPboardType]);
        }
        if ([tableView hasDataSelection]) {
            NSPasteboard *pboard = [NSPasteboard generalPasteboard];
            NSString *type = [pboard availableTypeFromArray:__FSTCPBTYPES];
            return ([type isEqualToString:FSTableDataPboardType]
                    || [type isEqualToString:NSStringPboardType]);
        }
    } else
    if ([anItem action] == @selector(deleteBackward:)) {
        if ([[[self window] firstResponder] respondsToSelector:@selector(deleteSelection:)]) {
            return YES;
        }
        if ([tableView hasItemSelection]) {
            return YES;
        }
    }
    if ([anItem action] == @selector(insertItem:)) {
        if ([tableView selectedRowItems]) {
            [anItem setTitle:FS_LOCALIZE(@"Insert Row")];
            return YES;
        }
        if ([tableView selectedColumnItems]) {
            [anItem setTitle:FS_LOCALIZE(@"Insert Column")];
            return YES;
        }
        [anItem setTitle:FS_LOCALIZE(@"Insert")];
    } else
    if ([anItem action] == @selector(groupItems:)) {
        if ([tableView selectedRowItems]) {
            [anItem setTitle:FS_LOCALIZE(@"Group Rows")];
            return YES;
        }
        if ([tableView selectedColumnItems]) {
            [anItem setTitle:FS_LOCALIZE(@"Group Columns")];
            return YES;
        }
        [anItem setTitle:FS_LOCALIZE(@"Group Items")];
        return NO;
    } else
    if ([anItem action] == @selector(ungroupItems:)) {
        if ([tableView selectedRowItems]) {
            [anItem setTitle:FS_LOCALIZE(@"Ungroup Rows")];
            return YES;
        }
        if ([tableView selectedColumnItems]) {
            [anItem setTitle:FS_LOCALIZE(@"Ungroup Columns")];
            return YES;
        }
        [anItem setTitle:FS_LOCALIZE(@"Ungroup Items")];
        return NO;
    } else
    if ([anItem action] == @selector(moveItemUp:)) {
        NSString   *title = @"Move Item Up";
        FSKeyRange *range = nil;
        
        if ((range = [tableView selectedRowItems])) {
            title = ([range indexRange].length>1)?@"Move Rows Up":@"Move Row Up";
        } else
        if ((range = [tableView selectedColumnItems])) {
            title = ([range indexRange].length>1)?@"Move Columns Left":@"Move Column Left";
        }
        if (title && [anItem respondsToSelector:@selector(setTitle:)])
            [anItem setTitle:FS_LOCALIZE(title)];
        return ([range isAtTop] == NO);
    } else
    if ([anItem action] == @selector(moveItemDown:)) {
        NSString   *title = @"Move Item Down";
        FSKeyRange *range = nil;
        
        if ((range = [tableView selectedRowItems])) {
            title = ([range indexRange].length>1)?@"Move Rows Down":@"Move Row Down";
        } else
        if ((range = [tableView selectedColumnItems])) {
            title = ([range indexRange].length>1)?@"Move Columns Right":@"Move Column Right";
        }
        if (title && [anItem respondsToSelector:@selector(setTitle:)])
            [anItem setTitle:FS_LOCALIZE(title)];
        return ([range isAtBottom] == NO);
    }
    if ([anItem action] == @selector(transpose:)) {
        return YES;
    }
    if ([anItem action] == @selector(exportTable:)) {
        return YES;
    }
    if ([anItem action] == @selector(sortItems:)) {
        return YES;
    }
    return NO;
}

@end
