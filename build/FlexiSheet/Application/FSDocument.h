//
//  FSDocument.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSDocument.h,v 1.1 2008/10/14 15:03:44 hns Exp $

#import <Cocoa/Cocoa.h>
#import <FSDocumentProtocol.h>

@class FSTable, FSGlobalHeader, FSHeader, FSKeySet, FSValue, FSWorksheet;

@interface FSDocument : NSDocument <FSDocument>
{
    NSMutableArray     *_tables;           /*" Contains FSTable instances. "*/
    NSMutableArray     *_globalCategories; /*" Contains linked header information. "*/
    NSMutableArray     *_worksheets;       /*" Contains FSWorksheet objects. "*/
    BOOL                _autoRecalc;       /*" Flag: Automatically recalculate formulas. "*/
    BOOL                _needsRecalc;      /*" Flag: Need recalculate of formulas. "*/
}

- (IBAction)newTableView:(id)sender;

- (IBAction)newTable:(id)sender;
- (void)deleteTable:(FSTable*)aTable;

- (IBAction)newTableView:(id)sender;
//- (IBAction)newChartView:(id)sender;
- (void)deleteWorksheet:(FSWorksheet*)worksheet;

- (NSArray*)tables;
- (FSTable*)tableWithName:(NSString*)name;

- (NSArray*)worksheetsForTable:(FSTable*)table;
- (void)displayView:(NSString*)name forTable:(FSTable*)table;

@end


@interface FSDocument (Spreadsheet)

//
// Handling the Spreadsheet
//

@end

