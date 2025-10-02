//
//  FSTableView+Selection.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 10-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableView+Selection.m,v 1.1 2008/10/28 13:10:31 hns Exp $

#import "FlexiSheet.h"
#import <FSCore/FSHashMap.h>

NSRange FSExtendRange(NSRange range, unsigned int newPos) {
    unsigned int offset;
    
    // new pos is before range, expand
    if (newPos < range.location)
        return NSMakeRange(newPos, range.location-newPos+range.length);
    // new pos is behind range, expand
    if (newPos > range.location + range.length)
        return NSMakeRange(range.location, newPos-range.location+1);
    // new pos is inbetween.  think

    offset = newPos-range.location+1;
    if (offset > range.length/2) {
        return NSMakeRange(range.location, offset);
    } else {
        return NSMakeRange(newPos, range.length-offset+1);
    }
}


@implementation FSTableView (Selection)

//
// Style
//

- (FSCellStyle*)styleForKeySet:(FSKeySet*)set
{
    if (set == nil) return nil;
    if ([set hashcode] == NULL) return nil;
    return [_styles objectForKey:[set hashcode]];
}

- (void)setStyle:(FSCellStyle*)style forKeySet:(FSKeySet*)set
{
    if (set == nil) return;
    if ([set hashcode] == NULL) return;
    if (style != nil) {
        [_styles setObject:style forKey:[set hashcode]];
    } else {
        [_styles removeObjectForKey:[set hashcode]];
    }
}

- (FSCellStyle*)defaultStyle
{
    return _defaultStyle;
}

- (void)setDefaultStyle:(FSCellStyle*)style
{
    if (style != _defaultStyle) {
        [_defaultStyle release];
        _defaultStyle = [style retain];
    }
}

- (void)setHeaderStyle:(FSCellStyle*)style
{
    if (_headerStyle != style) {
        [_headerStyle release];
        _headerStyle = [style retain];
    }
}

- (FSCellStyle*)styleForSelection:(FSSelection*)selection
{
    return _defaultStyle;
}

- (void)applyStyle:(FSCellStyle*)style forSelection:(FSSelection*)selection
{
}

//
//
//

- (FSKeySet*)_keySetForCell:(FSCell)cell
/*" Returns the complete FSKeySet for the data cell. "*/
{
    int index = cell.row*_numberOfCols+cell.column;
    if (_cachedValues[index] == nil) {
        FSKeySet *headKS = [[dataSource topKeySetsForTableView:self] objectAtIndex:cell.column];
        FSKeySet *leftKS = [[dataSource sideKeySetsForTableView:self] objectAtIndex:cell.row];
        FSKeySet *pageKS = [_pageTabs selectedKeySet];
        FSKeySet *rightKS = [_rightTabs selectedKeySet];
        FSKeySet *key = [headKS setByAddingKeys:leftKS];
        if (pageKS) [key addKeys:pageKS];
        if (rightKS) [key addKeys:rightKS];
        _cachedValues[index] = [dataSource tableView:self objectForKeySet:key];
    }
    return [_cachedValues[index] keySet];
}


- (FSKey*)_keyForTopCell:(FSCell)cell
/*" Call this when all you are intestested in is the key. "*/
{
    if (_nHTop) {
        FSHeader     *hdr = [[dataSource topHeadersForTableView:self] objectAtIndex:cell.row];
        FSKeySet     *set = [[dataSource topKeySetsForTableView:self] objectAtIndex:cell.column];
        return [set keyForHeader:hdr];
    }
    return nil;
}


- (id<FSItem>)_itemForTopCell:(FSCell)cell
/*" This method looks at the dx/dy information to
    determine which group (if any) was clicked. "*/
{
    if (_nHTop) {
        FSHeader     *hdr = [[dataSource topHeadersForTableView:self] objectAtIndex:cell.row];
        FSKeySet     *set = [[dataSource topKeySetsForTableView:self] objectAtIndex:cell.column];
        id            hlo = [self _hloTop:cell.row];
        id<FSItem>    key = [set keyForHeader:hdr];
        NSArray      *groups = [key groups];
        int           idx = 0;
        
        while (cell.dy < [hlo yOffsetForItem:key]) {
            key = [groups objectAtIndex:idx];
            idx++;
        }
        return key;
    }
    return nil;
}


- (FSKey*)_keyForSideCell:(FSCell)cell
/*" Call this when all you are intestested in is the key. "*/
{
    if (_nHSide) {
        FSHeader     *hdr = [[dataSource sideHeadersForTableView:self] objectAtIndex:cell.column];
        FSKeySet     *set = [[dataSource sideKeySetsForTableView:self] objectAtIndex:cell.row];
        return [set keyForHeader:hdr];
    }
    return nil;
}


- (id<FSItem>)_itemForSideCell:(FSCell)cell
/*" This method looks at the dx/dy information to
    determine which group (if any) was clicked. "*/
{
    if (_nHSide) {
        FSHeader     *hdr = [[dataSource sideHeadersForTableView:self] objectAtIndex:cell.column];
        FSKeySet     *set = [[dataSource sideKeySetsForTableView:self] objectAtIndex:cell.row];
        id            hlo = [self _hloSide:cell.column];
        id<FSItem>    key = [set keyForHeader:hdr];
        NSArray      *groups = [key groups];
        int           idx = 0;
        
        while (cell.dx < [hlo xOffsetForItem:key]) {
            key = [groups objectAtIndex:idx];
            idx++;
        }
        return key;
    }
    return nil;
}


- (FSKeyRange*)selectedItems
{
    if (_dataSelected) return nil;
    // If there is an item selection, 
    // it can be in one group of one header only!
    return [[_selection ranges] lastObject];
}


- (FSKeyRange*)selectedRowItems
{
    if (!_dataSelected && _selection) {
        FSKeyRange *range = [[_selection ranges] lastObject];
        NSArray    *headers = [dataSource sideHeadersForTableView:self];
        if ([headers containsObject:[range header]]) {
            return range;
        }
    }
    return nil;
}


- (FSKeyRange*)selectedColumnItems;
{
    if (!_dataSelected && _selection) {
        FSKeyRange *range = [[_selection ranges] lastObject];
        NSArray    *headers = [dataSource topHeadersForTableView:self];
        if ([headers containsObject:[range header]]) {
            return range;
        }
    }
    return nil;
}


- (void)selectItems:(FSKeyRange*)range
{
    if (range == nil) return;
    [_selection release];
    [_selRange release];
    _selRange = nil;
    _selection = [[FSSelection alloc] init];
    [_selection extendWithRange:range];
    _dataSelected = NO;
    [self setNeedsDisplay:YES];
}


- (BOOL)hasItemSelection
{
    return (!_dataSelected && _selection);
}


- (BOOL)hasDataSelection
{
    return (_dataSelected);
}

//
// FSMatrixDataSource implementation
//

- (int)numberOfRowsInMatrix:(FSMatrix*)matrix
{
    if (matrix == _topMatrix) 
        return MAX([[dataSource topHeadersForTableView:self] count],1);
    return _numberOfRows;
}

- (int)numberOfColumnsInMatrix:(FSMatrix*)matrix
{
    if (matrix == _sideMatrix)
        return MAX([[dataSource sideHeadersForTableView:self] count],1);
    return _numberOfCols;
}

- (NSSize)matrix:(FSMatrix*)matrix sizeForCell:(FSCell)cell
{
    NSSize          size;
    FSHeaderLayout *hlo;
    
    if (matrix == _sideMatrix) {
        if (_uniqueRows == 0) {
            return NSMakeSize(60,20);
        }
        assert(cell.row < _numberOfRows);
        hlo = [self _hloSide:-1];
        size = [hlo sizeAtIndex:cell.row%_uniqueRows];
        size.width = [[self _hloSide:cell.column] globalWidth];
        return size;
    }
    if (matrix == _topMatrix) {
        if (_uniqueCols == 0) {
            return NSMakeSize(120,20);
        }
        assert(cell.column < _numberOfCols);
        hlo = [self _hloTop:-1];
        size = [hlo sizeAtIndex:cell.column%_uniqueCols];
        size.height = [[self _hloTop:cell.row] globalHeight];
        return size;
    }
    assert(cell.row < _numberOfRows);
    assert(cell.column < _numberOfCols);
    size = NSMakeSize(120,20);
    if (_uniqueRows) {
        hlo = [self _hloSide:-1];
        size.height = [hlo heightAtIndex:cell.row%_uniqueRows];
    }
    if (_uniqueCols) {
        hlo = [self _hloTop:-1];
        size.width = [hlo widthAtIndex:cell.column%_uniqueCols];
    }
    return size;
}


- (NSSize)matrix:(FSMatrix*)matrix setSize:(NSSize)size forCell:(FSCell)cell
{
    FSHeaderLayout   *hlo;
    id<FSItem>        item;
    NSSize            itemSize;

    if (matrix == _sideMatrix) {
        if (_nHSide == 0) {
            return NSMakeSize(60,20);
        }
        assert(cell.row < _numberOfRows);
        hlo = [self _hloSide:cell.column];
        item = [self _itemForSideCell:cell];
        if ([item isKindOfClass:[FSKey class]]) {
            // only a key in the right-most column can resize height.
            if (cell.column == _nHSide-1) {
                [hlo setHeight:size.height atIndex:cell.row%_uniqueRows];
            }
            [hlo setGlobalWidth:size.width+[hlo xOffsetForItem:item]];
        } else {
            itemSize = [hlo sizeForItem:item];
            [hlo setGlobalWidth:[hlo globalWidth]+size.width-itemSize.width];
            itemSize.width = size.width;
            [hlo setSize:itemSize forItem:item];
        }
        [self _internalReload];
        return size;
    }
    if (matrix == _topMatrix) {
        if (_nHTop == 0) {
            return NSMakeSize(120,20);
        }
        assert(cell.column < _numberOfCols);
        hlo = [self _hloTop:cell.row];
        item = [self _itemForTopCell:cell];
        if ([item isKindOfClass:[FSKey class]]) {
            // only a key in the bottom-most row can resize width.
            if (cell.row == _nHTop-1) {
                [hlo setWidth:size.width atIndex:cell.column%_uniqueCols];
            }
            [hlo setGlobalHeight:size.height+[hlo yOffsetForItem:item]];
        } else {
            itemSize = [hlo sizeForItem:item];
            [hlo setGlobalHeight:[hlo globalHeight]+size.height-itemSize.height];
            itemSize.height = size.height;
            [hlo setSize:itemSize forItem:item];
        }
        [self _internalReload];
        return size;
    }
    if (matrix == _dataMatrix) {
        return [self matrix:matrix sizeForCell:cell];
    }
    // Not one of our Matrix objects... ???
    return NSMakeSize(0, 0);
}


- (NSRange)matrix:(FSVarioMatrix*)matrix rowRangeForCell:(FSCell)cell
{
    if (matrix == _sideMatrix) {
        int      base = 0, len = 1;
        int      index = _nHSide-1;
        if (cell.column == index)
            return NSMakeRange(cell.row,1);
        while (index > cell.column) {
            len *= [[self _hloSide:index] keyCount];
            index--;
        }
        base = cell.row/len;
        return NSMakeRange(base*len,len);
    } else 
        return NSMakeRange(cell.row,1);
}


- (NSRange)matrix:(FSVarioMatrix*)matrix columnRangeForCell:(FSCell)cell
{
    if (matrix == _topMatrix) {
        int      base = 0, len = 1;
        int      index = _nHTop-1;
        if (cell.row == index)
            return NSMakeRange(cell.column,1);
        while (index > cell.row) {
            len *= [[self _hloTop:index] keyCount];
            index--;
        }
        base = cell.column/len;
        return NSMakeRange(base*len,len);
    }  
    if (matrix == _sideMatrix) {
        return NSMakeRange(cell.column,1);
    }  
    return NSMakeRange(cell.column,1);
}


- (float)matrix:(FSVarioMatrix*)mx yOffsetInCell:(FSCell)cell
{
    if ((mx == _topMatrix) && _nHTop) {
        FSKey *key = [self _keyForTopCell:cell];
        id     hlo = [self _hloTop:cell.row];
        return [hlo yOffsetForItem:key];
    }
    return 0;
}


- (float)matrix:(FSVarioMatrix*)mx xOffsetInCell:(FSCell)cell
{
    if ((mx == _sideMatrix) && _nHSide) {
        FSKey *key = [self _keyForSideCell:cell];
        id     hlo = [self _hloSide:cell.column];
        return [hlo xOffsetForItem:key];
    }
    return 0;
}


- (int)matrix:(FSVarioMatrix*)mx additionalAreas:(CellArea**)areas inRow:(int)row
{
    if ((mx == _topMatrix) && _nHTop) {
        CellArea   *_areas = NULL;
        int         cnt = 0;
        
        if (_topCA != NULL) {
            _areas = _topCA[row];
            cnt = _topNCA[row];
            if (cnt > 0) {
                *areas = _areas;
            }
        }
        return cnt;
    }
    return 0;
}


- (int)matrix:(FSVarioMatrix*)mx additionalAreas:(CellArea**)areas inColumn:(int)col
{
    if ((mx == _sideMatrix) && _nHSide) {
        CellArea   *_areas = NULL;
        int         cnt = 0;
        
        if (_sideCA != NULL) {
            _areas = _sideCA[col];
            cnt = _sideNCA[col];
            if (cnt > 0) {
                *areas = _areas;
            }
        }
        return cnt;
    }
    return 0;
}


- (int)matrix:(FSVarioMatrix*)matrix resizeMaskForCell:(FSCell)cell
/* Pure alchemy :-) */
{
    if (matrix == _topMatrix) {
        return FSVM_HEIGHT + ((cell.row == _nHTop-1)?FSVM_WIDTH:0);
    }
    if (matrix == _sideMatrix) {
        return FSVM_WIDTH + ((cell.column == _nHSide-1)?FSVM_HEIGHT:0);
    }
    return 0;
}


- (BOOL)matrixShouldBecomeFirstResponder:(FSMatrix*)mx
{
    return [dataSource tableShouldBecomeFirstResponder];
}

//
// Selection
//

- (void)notifySelectionChange
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    FSWorksheet *ws = [[[self window] windowController] worksheet];
    id selection = nil;

    if ([self hasItemSelection]) {
        if ([dataSource tableShouldBecomeFirstResponder]) {
            NSArray *items = [[[_selection ranges] lastObject] itemsInRange];
            if ([items count] == 1) {
                selection = [items lastObject];
            } else {
                selection = items;
            }
        } else {
            selection = _selection;
        }
    } else if ([self hasDataSelection]) {
        selection = _selection;
    }

    [ws setSelection:selection];
    [nc postNotificationName:FSSelectionDidChangeNotification object:selection
                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:ws, FSWorksheetInfo,
                        self, FSTableviewInfo,
                        nil]];
}


- (FSSelection*)selection
{
    return _selection;
}


- (void)setSelection:(FSSelection*)sel
{
    [sel retain];
    [_selection release];
    [_selRange release];
    _selRange = nil;
    _selection = sel;
    // Force manual calculation of selection!
    _dataSelected = NO;
    [self setNeedsDisplay:YES];
    [self notifySelectionChange];
}


- (NSArray*)_rangesForKeySets:(FSKeySet*)ks1 :(FSKeySet*)ks2
{
    NSMutableArray *ranges = [NSMutableArray array];
    NSEnumerator   *cursor = [ks1 objectEnumerator];
    FSKey          *key1;
    FSKey          *key2;
        
    while (key1 = [cursor nextObject]) {
        key2 = [ks2 keyForHeader:[key1 header]];
        if (key2 == nil) key2 = key1;
        if (key2) {
            [ranges addObject:[FSKeyRange keyRangeFromItem:key1 toItem:key2]];
        }
    }
    return ranges;
}


- (void)matrix:(FSMatrix*)mx selectFromCell:(FSCell)c1 toCell:(FSCell)c2 extendExistingSelection:(BOOL)extend
{
    if (mx == _dataMatrix) {
        FSKeySet     *ks1 = [self _keySetForCell:c1];
        FSKeySet     *ks2 = [self _keySetForCell:c2];
        NSArray      *ranges = [self _rangesForKeySets:ks1 :ks2];
        [_selection release];
        [_selRange release];
        _selRange = nil;
        _selection = [[FSSelection selectionWithRanges:ranges] retain];
        _dataSelected = YES;
        _cellSelection = c1;
        _dataRows = NSMakeRange(MIN(c1.row,c2.row),ABS(c1.row-c2.row)+1);
        _dataCols = NSMakeRange(MIN(c1.column,c2.column),ABS(c1.column-c2.column)+1);
    } else if ((mx == _topMatrix) || (mx == _sideMatrix)) {
        id<FSItem>    k1, k2;

        if (mx == _topMatrix) {
            k1 = [self _itemForTopCell:c1];
            k2 = [self _itemForTopCell:c2];
        } else {
            k1 = [self _itemForSideCell:c1];
            k2 = [self _itemForSideCell:c2];
        }
        
        if ([k1 group] == [k2 group]) {
            FSKeyRange   *rng = [FSKeyRange keyRangeFromItem:k1 toItem:k2];
            [_selRange release];
            _selRange = nil;
            //if (!extend) {
            [_selection release];
            _selection = [[FSSelection alloc] init];
            //}
            [_selection extendWithRange:rng];
            _dataSelected = NO;
            [self setNeedsDisplay:YES];
        }
    }
    [self notifySelectionChange];
}


- (FSCell)matrix:(FSMatrix*)mx selectCell:(FSCell)cell extendExistingSelection:(BOOL)extend
{
    FSCell result = cell;
    
    if (mx == _dataMatrix) {
        FSKeySet     *key = [self _keySetForCell:cell];
        id<FSItem>    top = [key keyForHeader:[[dataSource topHeadersForTableView:self] lastObject]];
        id<FSItem>    side = [key keyForHeader:[[dataSource sideHeadersForTableView:self] lastObject]];
        FSKeyRange   *tr = [FSKeyRange keyRangeFromItem:top toItem:top];
        FSKeyRange   *sr = [FSKeyRange keyRangeFromItem:side toItem:side];

        [_selection release]; 
        [_selRange release];
        _selRange = nil;
        _selection = [[FSSelection alloc] initWithRange:tr];
        [_selection extendWithRange:sr];
        _cellSelection = cell;
        if (_dataSelected == NO)
            [self setNeedsDisplay:YES];
        _dataSelected = YES;
        if (extend) {
            _dataRows = FSExtendRange(_dataRows, cell.row);
            _dataCols = FSExtendRange(_dataCols, cell.column);
        } else {
            _dataRows = NSMakeRange(cell.row, 1);
            _dataCols = NSMakeRange(cell.column, 1);
        }
    } else if ((mx == _topMatrix) || (mx == _sideMatrix)) {
        id<FSItem>    key;
        FSKeyRange   *rng;

        if (mx == _topMatrix) {
            key = [self _itemForTopCell:cell];
        } else {
            key = [self _itemForSideCell:cell];
        }
        rng = [FSKeyRange keyRangeFromItem:key toItem:key];
        
        //if (!_selection) _selection = [[FSSelection alloc] init];
        //else if (!extend) {
        [_selection release];
        _selection = [[FSSelection selection] retain];
        //}
        [_selRange release];
        _selRange = nil;
        [_selection extendWithRange:rng];
        [self setNeedsDisplay:YES];
        _dataSelected = NO;
    }
    [self notifySelectionChange];
    return result;
}


- (BOOL)matrix:(FSMatrix*)mx cellIsSelected:(FSCell)cell
{
    if (mx == _dataMatrix) {
        if (_dataSelected) {
            if (NSLocationInRange(cell.column, _dataCols)) {
                return NSLocationInRange(cell.row, _dataRows);
            }
            return NO;
        }
        // XXX this is inefficient!
        return [_selection containsKeySet:[self _keySetForCell:cell]];
    } else
    if (_dataSelected) {
        // TODO: could highlight items even if data is selected
        return NO;
    } else
    if (mx == _topMatrix) {
        id<FSItem>   item = [self _itemForTopCell:cell];
        if (!_selRange)
            _selRange = [[[[_selection ranges] lastObject] itemsInRange] retain];
        return [_selRange containsObject:item];
    } else
    if (mx == _sideMatrix) {
        id<FSItem>   item = [self _itemForSideCell:cell];
        if (!_selRange)
            _selRange = [[[[_selection ranges] lastObject] itemsInRange] retain];
        return [_selRange containsObject:item];
    }
    return NO;
}


- (FSCell)matrixSelectedCell:(FSMatrix*)mx
{
    if (mx == _dataMatrix)
        if (_dataSelected)
            return _cellSelection;
    return FSMakeCell(-1,-1);
}

//
// Editing
//

- (BOOL)matrix:(FSMatrix*)mx shouldEditCell:(FSCell)cell
{
    if (mx == _dataMatrix) {
        FSKeySet  *headKS = [[dataSource topKeySetsForTableView:self] objectAtIndex:cell.column];
        FSKeySet  *leftKS = [[dataSource sideKeySetsForTableView:self] objectAtIndex:cell.row];
        FSKeySet  *rightKS = [_rightTabs selectedKeySet];
        FSKeySet  *pageKS = [_pageTabs selectedKeySet];
        FSKeySet  *key = [headKS setByAddingKeys:leftKS];
        FSFormula *formula;
        if (pageKS) [key addKeys:pageKS];
        if (rightKS) [key addKeys:rightKS];
        
        formula = [[[key table] valueForKeySet:key] calculatedByFormula];
        return (formula == nil);
    }
    if (mx == _sideMatrix) return (_nHSide > 0);
    if (mx == _topMatrix) return (_nHTop > 0);
    return NO;
}


- (void)matrix:(FSMatrix*)matrix willChangeWidthOfCell:(FSCell)cell
{
    if (matrix == _topMatrix) {
        if (cell.row == _nHTop-1) {
            id     hlo = [self _hloTop:-1];
            float  width = [hlo widthAtIndex:cell.column%_uniqueCols];
            [hlo undoableSetWidth:width atIndex:cell.column%_uniqueCols];
        }
    }
    if (matrix == _sideMatrix) {
        id<FSItem> item = [self _itemForSideCell:cell];
        id         hlo = [self _hloSide:cell.column];
        float      width = [hlo globalWidth];
        [hlo undoableSetGlobalWidth:width];
        if ([item isKindOfClass:[FSKeyGroup class]]) {
            NSSize size = [hlo sizeForItem:item];
            [hlo undoableSetSize:size forItem:item];
        }
    }
}


- (void)matrix:(FSMatrix*)matrix willChangeHeightOfCell:(FSCell)cell
{
    if (matrix == _sideMatrix) {
        if (cell.column == _nHSide-1) {
            id     hlo = [self _hloSide:-1];
            float  height = [hlo heightAtIndex:cell.row%_uniqueRows];
            [hlo undoableSetHeight:height atIndex:cell.row%_uniqueRows];
        }
    }
    if (matrix == _topMatrix) {
        id<FSItem> item = [self _itemForTopCell:cell];
        id         hlo = [self _hloTop:cell.row];
        float      height = [hlo globalHeight];
        [hlo undoableSetGlobalHeight:height];
        if ([item isKindOfClass:[FSKeyGroup class]]) {
            NSSize size = [hlo sizeForItem:item];
            [hlo undoableSetSize:size forItem:item];
        }
    }
}


- (FSCellStyle*)matrix:(FSMatrix*)mx styleForCell:(FSCell)cell
{
    if (mx == _dataMatrix) {
        FSCellStyle *style;
        FSKeySet    *headKS = [[dataSource topKeySetsForTableView:self] objectAtIndex:cell.column];
        FSKeySet    *leftKS = [[dataSource sideKeySetsForTableView:self] objectAtIndex:cell.row];
        FSKeySet    *rightKS = [_rightTabs selectedKeySet];
        FSKeySet    *pageKS = [_pageTabs selectedKeySet];
        FSKeySet    *key = [headKS setByAddingKeys:leftKS];
        
        if (pageKS) [key addKeys:pageKS];
        if (rightKS) [key addKeys:rightKS];

        style = [_styles objectForKey:[key hashcode]];
        if (style == nil) style = _defaultStyle;
        
        return style;
    }
    return _headerStyle;
}


- (FSLineStyle)matrix:(FSMatrix*)mx lineStyleForRow:(long)row
{
    if (mx == _topMatrix) return FSNormalLine;
    return FSNormalLine;
}


- (FSLineStyle)matrix:(FSMatrix*)mx lineStyleForColumn:(long)column
{
    if (mx == _sideMatrix) return FSNormalLine;
    return FSNormalLine;
}


- (id)matrix:(FSMatrix*)mx objectValueForCell:(FSCell)cell
{
    if (mx == _dataMatrix) {
        int index = cell.row*_numberOfCols+cell.column;
        if (_cachedValues[index] == nil) {
            FSKeySet *headKS = [[dataSource topKeySetsForTableView:self] objectAtIndex:cell.column];
            FSKeySet *leftKS = [[dataSource sideKeySetsForTableView:self] objectAtIndex:cell.row];
            FSKeySet *pageKS = [_pageTabs selectedKeySet];
            FSKeySet *rightKS = [_rightTabs selectedKeySet];
            FSKeySet *key = [headKS setByAddingKeys:leftKS];
            if (pageKS) [key addKeys:pageKS];
            if (rightKS) [key addKeys:rightKS];
            _cachedValues[index] = [dataSource tableView:self objectForKeySet:key];
        }
        return _cachedValues[index];
    }
    if (mx == _sideMatrix) {
        id<FSItem> item = [self _itemForSideCell:cell];
        return [item label];
    }
    if (mx == _topMatrix) {
        id<FSItem> item = [self _itemForTopCell:cell];
        return [item label];
    }
    return @"fail";
}

- (void)matrix:(FSMatrix*)matrix setObjectValue:(id)value forCell:(FSCell)cell
{
    if (matrix == _dataMatrix) {
        FSKeySet *headKS = [[dataSource topKeySetsForTableView:self] objectAtIndex:cell.column];
        FSKeySet *leftKS = [[dataSource sideKeySetsForTableView:self] objectAtIndex:cell.row];
        FSKeySet *pageKS = [_pageTabs selectedKeySet];
        FSKeySet *rightKS = [_rightTabs selectedKeySet];
        FSKeySet *key = [headKS setByAddingKeys:leftKS];
        if (pageKS) [key addKeys:pageKS];
        if (rightKS) [key addKeys:rightKS];
        
        [dataSource tableView:self setObject:value forKeySet:key];
    }
    if ([value isKindOfClass:[NSString class]] == NO) return;
    if ([(NSString*)value length] == 0) return;
    if (matrix == _sideMatrix) {
        id<FSItem> item = [self _itemForSideCell:cell];
        [item setLabel:value];
    }
    if (matrix == _topMatrix) {
        id<FSItem> item = [self _itemForTopCell:cell];
        [item setLabel:value];
    }
}

@end
