//
//  FSImporter.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 12-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSImporter.h,v 1.1 2008/10/14 15:03:46 hns Exp $

#import <AppKit/AppKit.h>

@class FSTable, FSTableView;

@interface FSImporter : NSObject {
    IBOutlet NSBox          *accessory;
    IBOutlet NSPopUpButton  *encoding;
    IBOutlet NSPopUpButton  *separator;
    IBOutlet NSPopUpButton  *lineBreaker;
    IBOutlet NSButton       *readColLabels;
    IBOutlet NSButton       *readRowLabels;

    IBOutlet NSPanel        *progressPanel;
    IBOutlet NSTextField    *importing;
    IBOutlet NSTextField    *filenameField;
    IBOutlet NSProgressIndicator *progressBar;
}

+ (FSImporter*)sharedImporter;

- (FSTable*)importTableFromFile:(NSString*)filename;

- (BOOL)importIntoTable:(FSTable*)table fromCSV:(NSString*)csvString parameters:(NSDictionary*)param;

- (NSView*)accessoryView;
- (NSPopUpButton*)separatorPopup;

- (NSStringEncoding)stringEncodingSelection;
- (NSString*)separatorSelection;
- (NSString*)linebreakSelection;
- (BOOL)shouldReadColumnLabels;
- (BOOL)shouldReadRowLabels;

- (void)runProgressPanel:(int)steps;  // 0 means indeterminate
- (void)updateProgressPanel:(int)increment;
- (void)endProgressPanel;

@end


extern NSString *FSImportValueSeparator;     /*" NSString containing one unichar "*/
