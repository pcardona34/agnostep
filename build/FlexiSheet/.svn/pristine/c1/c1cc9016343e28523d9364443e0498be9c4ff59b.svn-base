//
//  FSFirstResponder.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 06-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSFirstResponder.h,v 1.1 2008/10/14 15:03:45 hns Exp $
//

#import <AppKit/AppKit.h>


@protocol FSFirstResponder
/*"  Contains the action methods that First Responder defines.
  This protocol is actually never fully implemented. "*/

// File operations
- (void)open:(id)sender;
- (void)save:(id)sender;

- (void)newTable:(id)sender;
- (void)showTableBrowser:(id)sender;
- (void)exportTable:(id)sender;
- (void)importTable:(id)sender;

- (void)groupItems:(id)sender;
- (void)ungroupItems:(id)sender;
- (void)insertItem:(id)sender;
- (void)sortItems:(id)sender;

- (void)moveItemUp:(id)sender;
- (void)moveItemDown:(id)sender;

// View operations
- (void)addNewTableWindow:(id)sender;
- (void)addDimension:(id)sender;
- (void)transpose:(id)sender;

// Misc

@end

@protocol FSEditableSelection
/*" Methods implemented by selectable UI elements. "*/

- (void)deleteSelection:(id)sender;
- (void)startEditing:(id)sender;
- (BOOL)hasSelection;

@end
