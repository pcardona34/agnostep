//
//  FSTableController.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 31-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableController.m,v 1.3 2014/01/26 09:23:52 buzzdee Exp $

#import "FlexiSheet.h"

static NSArray*    __FSFTPBTYPES = nil;

@implementation FSTableController

+ (void)initialize
{
    if (__FSFTPBTYPES == nil) {
        __FSFTPBTYPES = [[NSArray alloc] initWithObjects:
            FSFormulaPboardType, nil];
    }
}


- (id)initWithWindow:(NSWindow *)window
/*" ??? "*/
{
    self = [super initWithWindow:window];
    if (self) {
        [self setName:@"Table View"];
        _storedSplitPosition = 0;
    }
    return self;
}


- (int)formulaSplitPosition
{
    if (_storedSplitPosition > 0) {
        return _storedSplitPosition;
    }
    return [[[splitView subviews] objectAtIndex:0] frame].size.height;
}


- (void)setFormulaSplitPosition:(int)pos
{
    NSRect  newRect = [splitView frame];
    NSRect  ctxRect;
    NSView *subview;
    int     split;
    float   height = 0;
    float   dividerThickness = [splitView dividerThickness];

    split = MIN(pos, newRect.size.height-dividerThickness-150);

    subview = [[splitView subviews] objectAtIndex:0];
    ctxRect = newRect;

    height = split;
    if ((newRect.size.height - height - dividerThickness) < 150) {
        height = newRect.size.height-dividerThickness-150;
        split = height;
    }
    ctxRect.size.height = height;
    [subview setFrame:ctxRect];

    ctxRect.origin.y = height + dividerThickness;
    ctxRect.size.height = newRect.size.height - ctxRect.origin.y;
    subview = [[splitView subviews] objectAtIndex:1];
    [subview setFrame:ctxRect];
    
    [splitView setNeedsDisplay:YES];
}


- (void)dealloc
{
    [tableView removeFromSuperviewWithoutNeedingDisplay];
    [super dealloc];
}


- (void)setTable:(FSTable*)table
{
    [super setTable:table];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(itemWillCangeName:)
        name:FSItemWillChangeNotification object:table];
}


- (void)itemWillCangeName:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    FSHeader     *header = [dict objectForKey:@"FSHeader"];
    if (header) {
        [tableView renameLayoutHintsForHeader:header
            newName:[dict objectForKey:FSNewNameUserInfo]];
    }
}


- (void)_cacheLayout
{
    [tableView cacheLayout];
}


- (void)_storeLayout
{
    [tableView storeLayout];
}


- (void)syncWithDocument
{
    [super syncWithDocument];
    [tableView cacheLayout]; 
}


- (void)valueDidChange:(NSNotification*)notification
{
    [super valueDidChange:notification];
    [tableView setNeedsDisplay:YES];
    [formulaTable reloadData];
    [formulaTable setNeedsDisplay:YES];
}


- (void)_selectRange:(NSRange)range inGroup:(FSKeyGroup*)group
{
    [tableView selectItems:[FSKeyRange keyRangeWithRange:range inGroup:group]];
}


- (void)tableWillChange:(NSNotification*)notification
{
    // Save selection in undo buffer
    FSKeyRange *sel;
    
    sel = [tableView selectedItems];
    if (sel) {
        [[[_table undoManager] prepareWithInvocationTarget:self] 
            _selectRange:[sel indexRange] inGroup:[sel group]];
    } else {
        // do we have to preserve a cell selection?
    }
    
    [super tableWillChange:notification];
}


- (void)tableDidChange:(NSNotification*)notification
{
    [super tableDidChange:notification];
    [formulaTable reloadData];
    [formulaTable setNeedsDisplay:YES];
}


- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview
{
    return (subview == [[sender subviews] objectAtIndex:0]);
}

- (CGFloat)splitView:(NSSplitView *)sender
	constrainMinCoordinate:(CGFloat)proposedCoord
		   ofSubviewAt:(NSInteger)offset
{
    if (offset == 0) {
        return MAX(proposedCoord, 50);
    }
    return proposedCoord;
}


- (CGFloat)splitView:(NSSplitView *)sender
	constrainMaxCoordinate:(CGFloat)proposedCoord
		   ofSubviewAt:(NSInteger)offset
{
    if (offset == 0) {
        return MIN(proposedCoord, [sender frame].size.height-150);
    }
    return proposedCoord;
}


- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    NSRect  newRect = [sender frame];
    NSRect  ctxRect;
    NSView *subview;
    float   height = 0;
    float   dividerThickness = [sender dividerThickness];
    
    subview = [[sender subviews] objectAtIndex:0];
    ctxRect = newRect;
    if ([sender isSubviewCollapsed:subview] == NO) {
        height = [subview frame].size.height;
        if ((newRect.size.height - height - dividerThickness) < 150) {
            height = newRect.size.height-dividerThickness-150;
        }
        ctxRect.size.height = height;
        [subview setFrame:ctxRect];
    }
    
    ctxRect.origin.y = height + dividerThickness;
    ctxRect.size.height = newRect.size.height - ctxRect.origin.y;
    subview = [[sender subviews] objectAtIndex:1];
    [subview setFrame:ctxRect];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setupTableToolbar];
    [self createHeaderSets];
    _numberColumn = [formulaTable tableColumnWithIdentifier:@"NUMBER"];
    if (_numberColumn) {
        ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
        [imageAndTextCell setEditable:NO];
        [imageAndTextCell setAlignment:NSRightTextAlignment];
        [_numberColumn setDataCell:imageAndTextCell];
        [imageAndTextCell release];
    }
    [formulaTable registerForDraggedTypes:
        [NSArray arrayWithObject:FSFormulaPboardType]];
    [formulaTable reloadData];
    [tableView reloadData];
    [[tableView window] makeFirstResponder:tableView];
    [self setFormulaSplitPosition:60];
}


- (void)updateDisplay
{
    [super updateDisplay];
    [tableView reloadData];
    [tableView setNeedsDisplay:YES];
}


- (NSDictionary*)layoutDictionary
{
    NSMutableDictionary *layout = [NSMutableDictionary dictionary];
    NSString            *split = [NSString stringWithFormat:@"%i", [self formulaSplitPosition]];
    
    [layout addEntriesFromDictionary:[super layoutDictionary]];
    [layout addEntriesFromDictionary:[tableView layoutDictionary]];
    [layout setObject:split forKey:@"FormulaSplitPosition"];
    if (_storedSplitPosition > 0) {
        [layout setObject:@"YES" forKey:@"FormulaAreaHidden"];
    } else {
        [layout removeObjectForKey:@"FormulaAreaHidden"];
    }
    
    return layout;
}


- (void)applyLayoutDictionary:(NSDictionary*)dict
{
    NSString *split = [dict objectForKey:@"FormulaSplitPosition"];
    if (split) {
        [self setFormulaSplitPosition:[split intValue]];
    }

    split = [dict objectForKey:@"FormulaAreaHidden"];
    if ([split isEqualToString:@"YES"]) {
        [self toggleFormulaArea:nil];
    }

    [super applyLayoutDictionary:dict];
    [tableView applyLayoutDictionary:dict];
}


- (void)toggleFormulaArea:(id)unused
{    
    if (_storedSplitPosition > 0) {
        [self setFormulaSplitPosition:_storedSplitPosition];
        _storedSplitPosition = 0;
    } else {
        _storedSplitPosition = [self formulaSplitPosition];
        [self setFormulaSplitPosition:0];
    }
}


- (BOOL)tableShouldBecomeFirstResponder
{
    if ([formulaTable isEditing]) {
        return NO;
    } else {
        return [super tableShouldBecomeFirstResponder];
    }
}

// UI responder

- (void)keyDown:(NSEvent*)event
{
    if ([[event characters] characterAtIndex:0] == 127) { // DELETE
        [self deleteBackward:nil];
    } else
    // Start editing in formula editor
    if ([[self window] firstResponder] == formulaTable) {
        int row = [formulaTable selectedRow];
        if (row != -1) {
            [formulaTable editColumn:1 row:row withEvent:event select:YES];
        }
    } else
    [super keyDown:event];
}


- (void)_fillPasteboardWithDataCells
{
    FSSelection   *sel = [tableView selection];
    NSPasteboard  *pboard = [NSPasteboard generalPasteboard];

    // TODO: fill NSStringPboardType also
    
    [pboard declareTypes:[NSArray arrayWithObjects:FSTableDataPboardType,nil]
                   owner:self];
    [pboard setPropertyList:[_table valuesInSelection:sel]
                    forType:FSTableDataPboardType];
}


- (void)cut:(id)sender
{
    FSKeyRange *range;
    if ((range = [tableView selectedItems])) {
        NSRange     idx = [range indexRange];
        FSKeyGroup *group = [range group];
        [group cutRange:idx];
        [tableView selectItems:
            [FSKeyRange keyRangeWithRange:NSMakeRange(MAX(1,idx.location)-1,1)
                inGroup:group]];
        [tableView scrollItemSelectionToVisible];
    } else if ([tableView hasDataSelection]) {
        FSSelection   *sel = [tableView selection];
        [self _fillPasteboardWithDataCells];
        [_table setValues:nil inSelection:sel]; 
    }
}


- (void)clear:(id)sender
{
    if ([tableView hasDataSelection]) {
        [_table setValues:nil inSelection:[tableView selection]]; 
    }
}


- (void)copy:(id)sender
{
    FSKeyRange *range;
    if ((range = [tableView selectedItems])) {
        [[range group] copyRange:[range indexRange]]; 
    } else if ([tableView hasDataSelection]) {
        [self _fillPasteboardWithDataCells];
    }
}


- (BOOL)validateUserInterfaceItem:(id)anItem
{
    id fr = [[self window] firstResponder];

    if ([anItem action] == @selector(showInspector:)) {
        return YES;
    } else
    if ([anItem action] == @selector(recalculate:)) {
        return YES;
    } else
    if (([anItem action] == @selector(cut:))
        || ([anItem action] == @selector(copy:))) {
        if (fr == formulaTable) {
            return ([formulaTable selectedRow] != -1);
        }
    } else
    if ([anItem action] == @selector(paste:)) {
        if (fr == formulaTable) {
            NSPasteboard *pboard = [NSPasteboard generalPasteboard];
            NSString *type = [pboard availableTypeFromArray:__FSFTPBTYPES];
            return ([type isEqualToString:FSFormulaPboardType]);
        }
    } else
    if ([anItem action] == @selector(toggleFormulaArea:)) {
        if (_storedSplitPosition > 0) {
            [anItem setTitle:FS_LOCALIZE(@"Show Formula Area")];
        } else {
            [anItem setTitle:FS_LOCALIZE(@"Hide Formula Area")];
        }
        return YES;
    } else
    if ([anItem action] == @selector(addFormula:)) {
        return YES;
    } else
    if ([anItem action] == @selector(insertItem:)) {
        if (fr == formulaTable) {
            [anItem setTitle:FS_LOCALIZE(@"Insert Formula")];
            return YES;
        }
    } else
    if ([anItem action] == @selector(deleteBackward:)) {
        if ([[self window] firstResponder] == formulaTable) {
            return ([formulaTable selectedRow] != -1);
        }
    }
    return [super validateUserInterfaceItem:anItem];
}


- (void)insertItem:(id)sender
/*" Overwriten to insert a new formula. "*/
{
    // If formula table is first responder, insert new formula.
    //
    if ([[self window] firstResponder] == formulaTable) {
        [self insertFormula:sender];
    } else {
        [super insertItem:sender];
    }
}


- (void)deleteBackward:(id)sender
/*" Overwrite to delete the selected formula. "*/
{
    if ([[self window] firstResponder] == formulaTable) {
        [self deleteFormula:sender];
    } else {
        [super deleteBackward:sender];
    }
}

@end


@implementation FSWindowController (FSTableDataSource)

- (NSArray*)topHeadersForTableView:(FSTableView*)tv
{
    return _topHeaders;
}

- (NSArray*)sideHeadersForTableView:(FSTableView*)tv
{
    return _sideHeaders;
}

- (NSArray*)pageHeadersForTableView:(FSTableView*)tv
{
    return _pageHeaders;
}

- (NSArray*)rightHeadersForTableView:(FSTableView*)tv
{
    return _rightHeaders;
}

- (NSArray*)topKeySetsForTableView:(FSTableView*)tv
{
    return _topKeySets;
}

- (NSArray*)sideKeySetsForTableView:(FSTableView*)tv
{
    return _sideKeySets;
}

- (NSArray*)pageKeySetsForTableView:(FSTableView*)tv
{
    return _pageKeySets;
}

- (NSArray*)rightKeySetsForTableView:(FSTableView*)tv
{
    return _rightKeySets;
}

- (id)tableView:(FSTableView*)tv objectForKeySet:(FSKeySet*)aKeySet
{
    return [_table valueForKeySet:aKeySet];
}

- (id)tableView:(FSTableView*)tv setObject:(id)anObject forKeySet:(FSKeySet*)aKeySet
{
    FSValue *value = [_table valueForKeySet:aKeySet];
    [value setValue:anObject];
    return value;
}

- (BOOL)tableShouldBecomeFirstResponder
{
    return YES;
}


- (NSFont*)defaultFont
{
    return [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
}

@end
