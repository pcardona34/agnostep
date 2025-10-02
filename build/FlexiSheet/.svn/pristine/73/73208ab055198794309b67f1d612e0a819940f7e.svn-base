//
//  FSSortPanelController.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 27-APR-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSSortPanelController.h,v 1.1 2008/10/14 15:03:46 hns Exp $

#import <AppKit/AppKit.h>

@class FSTable, FSWindowController;

@interface FSSortPanelController : NSObject
{
    IBOutlet NSWindow          *sortPanel;
    IBOutlet NSPopUpButton     *categoryPopup;      // sort these items
    IBOutlet NSButton          *sortByValue;        // NSButton
    IBOutlet NSPopUpButton     *valueCatPopup;      // sort by values from
    IBOutlet NSButton          *sortButton;         // disabled sometimes
    IBOutlet NSPopUpButton     *sortFirstPopup;     // first criteria; also used for by name
    IBOutlet NSPopUpButton     *reverseFirstPopup;  // revert sort order?
    IBOutlet NSPopUpButton     *sortSecondPopup;    // second criteria
    IBOutlet NSPopUpButton     *reverseSecondPopup; // revert sort order?
    IBOutlet NSPopUpButton     *sortThirdPopup;     // third criteria
    IBOutlet NSPopUpButton     *reverseThirdPopup;  // revert sort order?

    FSTable                    *_table;
}

+ (FSSortPanelController*)sortPanelController;

- (void)setupWithTable:(FSTable*)table;

- (void)selectCategory:(id)sender;
- (void)selectValueCategory:(id)sender;
- (void)selectSortByValue:(id)sender;

- (void)selectFirstCriteria:(id)sender;
- (void)selectSecondCriteria:(id)sender;
- (void)selectThirdCriteria:(id)sender;

- (void)runSortSheetForWindowController:(FSWindowController*)wc;
- (void)endSheetFromControl:(id)sender;

@end
