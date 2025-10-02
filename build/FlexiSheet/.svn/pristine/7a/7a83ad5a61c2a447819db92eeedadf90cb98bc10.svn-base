//
//  FSTableView.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 24-AUG-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableView.h,v 1.1 2008/10/28 13:10:31 hns Exp $

#import <AppKit/AppKit.h>
#import <FSVarioMatrix.h>
#import <FSTableTabs.h>
#import <FSMatrixDataSource.h>

@class FSKeyRange, FSKeySet, FSHeader, FSHeaderLayout, FSKey, FSKeyGroup;
@class FSSelection;

@interface FSTableView : NSControl {
    FSMatrix            *_dataMatrix;    /*" containing value cells "*/
    FSTableTabs         *_pageTabs;      /*" containing tabs at bottom "*/
    FSTableTabs         *_rightTabs;     /*" containing tabs at right "*/
    FSVarioMatrix       *_topMatrix;     /*" containing header cells "*/
    FSVarioMatrix       *_sideMatrix;    /*" containing header cells "*/
    NSScrollView        *_dataSV;        /*" containing the data matrix "*/
    NSClipView          *_topClip;       /*" containing the top matrix "*/
    NSClipView          *_sideClip;      /*" containing the side matrix "*/
    IBOutlet id          dataSource;     /*" Has to be an FSTableController! "*/
    
    // Selection
    //
    FSSelection         *_selection;     /*" Selection "*/
    NSArray             *_selRange;      /*" Selection "*/
    FSCell               _cellSelection; /*" The cell currently selected"*/
    BOOL                 _dataSelected;  /*" Selection is in data matrix (no items) "*/
    NSRange              _dataRows;      /*" Set with every new data selection "*/
    NSRange              _dataCols;      /*" Set with every new data selection "*/

    // Style
    //
    FSCellStyle         *_defaultStyle;  /*" Default style for data cells "*/
    FSCellStyle         *_headerStyle;   /*" Default style for headers "*/
    
    id                  *_cachedValues;
    
    // Stuff used by the Layout category
    //
    FSHashMap           *_styles;        /*" Stores all FSCellStyle objects that belong to individual cells. "*/
    NSMutableDictionary *_hlObjects;     /*" HeaderLayout objects for headers "*/
    
    // Cached tab information
    //
    int                  _pageTabCount;  /*" count of objects in pageHeaders "*/
    int                  _rightTabCount; /*" count of objects in page2Headers "*/
    
    // Cached column/top header information
    //
    int                  _numberOfCols;  /*" number of columns in the data matrix "*/
    int                  _uniqueCols;    /*" number of unique columns in topMatrix "*/
    int                  _nHTop;         /*" number of headers in topMatrix "*/
    CellArea           **_topCA;         /*" cached cell areas in topMatrix "*/
    int                 *_topNCA;        /*" number of cached cell areas per row "*/
    
    // Cached row/side header information
    int                  _numberOfRows;  /*" number of rows in the data matrix "*/
    int                  _uniqueRows;    /*" number of uniqe rows in sideMatrix "*/
    int                  _nHSide;        /*" number of headers in sideMatrix "*/
    CellArea           **_sideCA;        /*" cached cell areas in sideMatrix "*/
    int                 *_sideNCA;       /*" number of cached cell areas per col "*/
}

- (id)initWithFrame:(NSRect)frameRect;

- (id)dataSource;
- (void)setDataSource:(id)aDataSource;

- (void)reloadData;
- (void)_internalReload;
- (void)reflectPageTabChange;
- (FSKeySet*)keySetForTabSelection;

@end

@interface FSTableView (Layout)

- (void)adjustSizes;
- (void)adjustAllCells;
- (void)ensureSpaceForNewGroup:(FSKeyGroup*)group;

- (void)renameLayoutHintsForHeader:(FSHeader*)header newName:(NSString*)newName;

- (NSDictionary*)layoutDictionary;
- (void)applyLayoutDictionary:(NSDictionary*)dict;

- (void)cacheLayout;
- (void)storeLayout;

- (int)_factorForTopRow:(int)row;
- (int)_factorForSideCol:(int)col;

- (FSHeaderLayout*)_hloTop:(int)idx;
- (FSHeaderLayout*)_hloSide:(int)idx;

@end

@interface FSTableView (Scrolling)

- (void)scrollItemSelectionToVisible;

- (void)reflectScrolledDataTable;

@end

@interface FSTableView (Selection) <FSVarioMatrixDataSource>

// Select data cells
- (BOOL)hasDataSelection;
- (FSSelection*)selection;
- (void)setSelection:(FSSelection*)sel;

// Select item rows/columns
- (BOOL)hasItemSelection;
- (FSKeyRange*)selectedItems;
- (FSKeyRange*)selectedRowItems;
- (FSKeyRange*)selectedColumnItems;
- (void)selectItems:(FSKeyRange*)range;

- (FSCellStyle*)styleForKeySet:(FSKeySet*)set;
- (FSCellStyle*)defaultStyle;
- (void)setDefaultStyle:(FSCellStyle*)style;
- (void)setHeaderStyle:(FSCellStyle*)style;

- (FSCellStyle*)styleForSelection:(FSSelection*)selection;
- (void)applyStyle:(FSCellStyle*)style forSelection:(FSSelection*)selection;

@end

@interface FSTableView (Keyboard)
- (NSRect)rectForSelectionInDataMatrix;
@end

@interface NSObject (FSTableDataSource)

- (NSArray*)pageHeadersForTableView:(FSTableView*)tv;
- (NSArray*)rightHeadersForTableView:(FSTableView*)tv;
- (NSArray*)topHeadersForTableView:(FSTableView*)tv;
- (NSArray*)sideHeadersForTableView:(FSTableView*)tv;

- (NSArray*)pageKeySetsForTableView:(FSTableView*)tv;
- (NSArray*)rightKeySetsForTableView:(FSTableView*)tv;
- (NSArray*)topKeySetsForTableView:(FSTableView*)tv;
- (NSArray*)sideKeySetsForTableView:(FSTableView*)tv;

- (id)tableView:(FSTableView*)tv objectForKeySet:(FSKeySet*)aKeySet;
- (id)tableView:(FSTableView*)tv setObject:(id)anObject forKeySet:(FSKeySet*)aKeySet;

- (BOOL)tableShouldBecomeFirstResponder;

- (NSFont*)defaultFont;

@end

