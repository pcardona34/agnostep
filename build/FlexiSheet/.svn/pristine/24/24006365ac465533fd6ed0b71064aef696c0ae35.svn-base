//
//  FSPasteboardHandling.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 01-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSPasteboardHandling.h,v 1.1 2008/10/14 15:03:46 hns Exp $

#import <FSCore/FSKeyGroup.h>


@interface FSKeyGroup (PasteboardHandling)

- (BOOL)cutRange:(NSRange)range;
- (BOOL)copyRange:(NSRange)range;
- (int)pasteAtIndex:(int)index;

@end

//
// Pasteboard type
//

extern NSString* FSTableDataPboardType;
extern NSString* FSTableItemPboardType;
extern NSString *FSFormulaPboardType;
