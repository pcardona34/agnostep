//
//  FSWorksheet.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 15-MAY-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSWorksheet.h,v 1.1 2008/10/14 15:03:49 hns Exp $

#import <FSCore/FSCore.h>

@class FSWindowController;

@interface FSWorksheet : NSObject {
    FSTable             *_table;      /*" The table this view displays. "*/
    FSSelection         *_selection;  /*" The current selection. "*/
    NSString            *_name;       /*" A given name for this worksheet. "*/
    NSData              *_comment;    /*" A comment the user types in. "*/

    FSWindowController  *_winController; /*" nil if window is closed. "*/
    NSString            *_windowFrame;
    NSDictionary        *_storedWinProps;
    NSMutableArray      *_pageHeaders;
    NSMutableArray      *_rightHeaders;
    NSMutableArray      *_topHeaders;
    NSMutableArray      *_sideHeaders;
}

- (BOOL)loadFromDictionary:(NSDictionary*)archive forTable:(FSTable*)table;

- (NSWindowController*)windowController;
- (FSWindowController*)displayWindow:(BOOL)create;
- (void)closeWindow;
- (void)storeWindowInformation;

// Attributes

- (FSTable*)table;
- (void)setTable:(FSTable*)table;
- (FSDocument*)document;

- (NSString *)name;
- (void)setName:(NSString*)name;

- (NSData*)comment;
- (void)setComment:(NSData*)comment;

- (FSSelection*)selection;
- (void)setSelection:(FSSelection*)selection;

- (void)setPageHeaders:(NSArray*)headers;
- (void)setRightHeaders:(NSArray*)headers;
- (void)setTopHeaders:(NSArray*)headers;
- (void)setSideHeaders:(NSArray*)headers;

- (void)setWindowLocationString:(NSString*)string;
- (void)storeWindowProperties:(NSDictionary*)dict;

@end
