//
//  FSPasteboardHandling.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 01-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSPasteboardHandling.m,v 1.1 2008/10/14 15:03:46 hns Exp $

#import "FlexiSheet.h"
#import "FSPasteboardHandling.h"


NSString *FSFormulaPboardType = @"FSFormulaPboardType";
/*" A pasteboard of FSFormulaPboardType contains
    an array of formula strings. "*/

NSString* FSTableDataPboardType = @"FSTableDataPboard";
/*" A pasteboard of FSTableDataPboardType contains
    a dictionary with keys:
        columns:   NSNumber (int value) number of 
        rows:      NSNumber (int value) number of
        values:    NSArray containing object values. "*/

NSString* FSTableItemPboardType = @"FSTableItemPboard";
/*" A pasteboard of FSTableItemPboardType contains
    a dictionary with keys:
        items:     NSArray containing names of items 
        values:    NSArray containing NSArray of object values
    for every item . "*/


@implementation FSKeyGroup (PasteboardHandling)

- (BOOL)cutRange:(NSRange)range
{
    if (range.location + range.length > [_items count]) {
        [FSLog logError:@"Cut from invalid range."];
        return NO;
    }
    
    if ([self copyRange:range]) {
        [self deleteItemsInRange:range];
        return YES;
    }
    return NO;
}


- (BOOL)copyRange:(NSRange)range
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];

    if (range.location + range.length > [_items count]) {
        [FSLog logError:@"Copy from invalid range."];
        return NO;
    }
    [pboard declareTypes:[NSArray arrayWithObject:FSTableItemPboardType] owner:self];
    [pboard setPropertyList:[self pboardDataFromRange:range] 
        forType:FSTableItemPboardType];
    return YES;
}


- (int)pasteAtIndex:(int)index
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSDictionary *data = [pboard propertyListForType:FSTableItemPboardType];
    
    if ([data isKindOfClass:[NSDictionary class]]) {
        
        return [self pasteData:data atIndex:index];
    }
    return 0;
}

@end
