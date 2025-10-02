//
//  FSTableController+Formula.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 05-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableController+Formula.m,v 1.2 2014/01/26 09:23:52 buzzdee Exp $

#import "FlexiSheet.h"

@implementation FSTableController (FormulaEditing)

- (void)recalculate:(id)sender
{
    [_table recalculateFormulaSpace];
}

- (void)addFormula:(id)sender
/*" Adds a formula to the table controlled by this instance. "*/
{
    NSInteger row = [formulaTable numberOfRows];
    [_table addFormula:@""];
    [formulaTable selectRow:row byExtendingSelection:NO];
    [formulaTable editColumn:1 row:row withEvent:nil select:YES];
}

- (void)insertFormula:(id)sender
{
    int row = [formulaTable selectedRow];
    [_table insertFormula:@"" atIndex:row+1];
    [formulaTable selectRow:row+1 byExtendingSelection:NO];
    [formulaTable editColumn:1 row:row+1 withEvent:nil select:YES];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tv
{
    NSArray *formulae = [_table formulae];
    NSInteger   index = [formulae count];
    NSInteger   count = 0;

    while (index-- > 0) 
        count += [[formulae objectAtIndex:index] isOK]?1:2;

    return count;
}

- (FSFormula*)_formulaInRow:(NSInteger)row nextLine:(BOOL*)displayError
{
    NSArray   *formulae = [_table formulae];
    id        object;
    NSInteger index = 0;
    NSInteger count = 0;
    BOOL      error = NO;

    if ([formulae count] == 0) return nil;
    object = [formulae objectAtIndex:index];
    while (count < row) {
        if (NO == [object isOK]) {
            count++;
        }
        if (count == row) {
            error = YES;
        } else {
            count++;
            index++;
            object = [formulae objectAtIndex:index];
        }
    }

    if (displayError)
        *displayError = error;
    return object;
}

- (void)deleteFormula:(id)sender
{
    NSInteger row = [formulaTable selectedRow];
    if (row != -1) {
        BOOL       error;
        FSFormula *formula = [self _formulaInRow:row nextLine:&error];
        [_table removeFormula:formula];
        return;
    }
    NSBeep();
    return;
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    BOOL       error;
    FSFormula *formula = [self _formulaInRow:row nextLine:&error];

    if (tableColumn == _numberColumn) {
        if (error) return @"";
        return [NSString stringWithFormat:@"%i.", [[_table formulae] indexOfObject:formula]+1];
    } else {
        if (error)
            return [formula errorString];
        return [formula description];
    }
}

- (void)tableView:(NSTableView *)tv setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableColumn != _numberColumn) {
        BOOL       error;
        FSFormula *formula = [self _formulaInRow:row nextLine:&error];
        
        if (error) return;
        if (NO == [[formula description] isEqualToString:object]) {
            [_table setCreator:object forFormula:formula];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tv shouldSelectRow:(NSInteger)row
{
    BOOL       error;
    [self _formulaInRow:row nextLine:&error];
    return (error == NO);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [[notification object] selectedRow];
    FSFormula *formula = [self _formulaInRow:row nextLine:NULL];
    if ([formula isOK]) {
        [tableView setSelection:[formula touchedSelection]];
    }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    BOOL       error;
    FSFormula *formula = [self _formulaInRow:row nextLine:&error];

    if (tableColumn == _numberColumn) {
        if (![formula isOK] && !error) {
            [cell setImage:[NSImage imageNamed:@"FormulaError"]];
        } else {
            [cell setImage:nil];
        }
    } else {
        if (!error) {
            [cell setFont:[NSFont systemFontOfSize:13]];
        } else {
            [cell setFont:[NSFont boldSystemFontOfSize:13]];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableColumn == _numberColumn) {
        return NO;
    } else {
        BOOL       error;
        
        [self _formulaInRow:row nextLine:&error];
        return (!error);
    }
}

//
// Dragging
//

static int _XXX_dragIndex;

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    if ([rows count] == 1) {
        int        row = [[rows lastObject] intValue];
        BOOL       error;
        FSFormula *formula = [self _formulaInRow:row nextLine:&error];
        
        if (error == NO) {
            [pboard declareTypes:[NSArray arrayWithObject:FSFormulaPboardType] owner:self];
            [pboard setPropertyList:[NSArray arrayWithObject:[formula description]]
                forType:FSFormulaPboardType];
            _XXX_dragIndex = row;
            return YES;
        }
    }
    return NO;
}


- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info
    proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
    if (row == -1) row = [formulaTable numberOfRows];
    if ([info draggingSource] != formulaTable) return NSDragOperationNone;
    if (row == _XXX_dragIndex) return NSDragOperationNone;
    if (row == _XXX_dragIndex+1) return NSDragOperationNone;
    if (op == NSTableViewDropOn) {
        [tv setDropRow:row dropOperation:NSTableViewDropAbove];
    }
    return NSDragOperationMove;
}


- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info
    row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op;
{
    FSFormula *formula = nil;
    
    if (op == NSTableViewDropOn) return NO;
    [_table moveFormulaAtIndex:_XXX_dragIndex toIndex:row];
    formula = [self _formulaInRow:[tv selectedRow] nextLine:NULL];
    if ([formula isOK]) {
        [tableView setSelection:[formula touchedSelection]];
    }
    return YES;
}

@end


