//
//  FSTableInspectorPane.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 15-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableInspectorPane.h,v 1.1 2008/10/28 13:10:29 hns Exp $

#import <FSInspectorPane.h>


@interface FSTableInspectorPane : FSInspectorPane
{
    IBOutlet NSTextView        *comments;
    IBOutlet NSTextField       *nameField;
    IBOutlet NSTextField       *documentField;
    IBOutlet NSTableView       *categories;
    FSTable                    *table;
}

- (IBAction)setTableName:sender;
- (IBAction)inspectDocument:sender;
- (IBAction)inspectCategory:sender;

@end
