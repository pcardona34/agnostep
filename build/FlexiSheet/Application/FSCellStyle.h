//
//  FSCellStyle.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 21-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSCellStyle.h,v 1.1 2008/10/14 15:03:43 hns Exp $

#import <AppKit/AppKit.h>

@interface FSCellStyle : NSObject
{
    NSUndoManager           *_undoManager;
    NSMutableDictionary     *_attributes;
    NSString                *_numberFormat;
    NSString                *_dateFormat;
    NSColor                 *_backgroundColor;
    NSColor                 *_negativeColor;

    // Cached calculated values
    NSNumberFormatter       *_numberFormatter;
    NSDateFormatter         *_dateFormatter;
}

+ (FSCellStyle*)defaultCellStyle;
+ (FSCellStyle*)cellStyleWithDictionary:(NSDictionary*)dict;

- (NSUndoManager*)undoManager;
- (void)setUndoManager:(NSUndoManager*)um;

- (NSNumberFormatter*)numberFormatter;
- (NSDateFormatter*)dateFormatter;
- (NSDictionary*)textAttributes;

- (NSTextAlignment)alignment;
- (void)setAlignment:(NSTextAlignment)newAlignment;

- (NSColor*)foregroundColor;
- (void)setForegroundColor:(NSColor*)color;

- (NSColor*)backgroundColor;
- (void)setBackgroundColor:(NSColor*)color;

- (NSColor*)negativeColor;
- (void)setNegativeColor:(NSColor*)color;

- (NSFont*)font;
- (void)setFont:(NSFont*)font;

//
// Archiving
//

- (void)copyStyleFromDictionary:(NSDictionary*)dict;

- (NSDictionary*)dictionaryForArchiving;
- (id)initWithDictionary:(NSDictionary*)dict;

@end
