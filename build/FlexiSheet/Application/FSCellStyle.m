//
//  FSCellStyle.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 21-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSCellStyle.m,v 1.1 2008/10/14 15:03:43 hns Exp $

#import "FSArchiving.h"
#import "FSCellStyle.h"
#import "FSController.h"

// default font (settable through preferences) is stored here.
static NSFont *__defaultFont = nil;

// Alignment paragraph styles
static NSMutableParagraphStyle *__leftAligned = nil;
static NSMutableParagraphStyle *__rightAligned = nil;
static NSMutableParagraphStyle *__centered = nil;
static NSMutableParagraphStyle *__justified = nil;
static NSMutableParagraphStyle *__natural = nil;

@implementation FSCellStyle

+ (void)recacheDefaultFont
{
    NSUserDefaults          *defaults = [NSUserDefaults standardUserDefaults];
    NSString                *fontname = [defaults stringForKey:FSDefaultFontFacePreference];
    int                      fontsize = [defaults integerForKey:FSDefaultFontSizePreference];

    [__defaultFont release];
    __defaultFont = [[NSFont fontWithName:fontname size:fontsize] retain];
    if (__defaultFont == nil) {
        __defaultFont = [[NSFont systemFontOfSize:12] retain];
    }
}


+ (void)initialize
{
    [self recacheDefaultFont];

    __leftAligned = [[NSMutableParagraphStyle alloc] init];
    [__leftAligned setAlignment:NSLeftTextAlignment];
    __rightAligned = [[NSMutableParagraphStyle alloc] init];
    [__rightAligned setAlignment:NSRightTextAlignment];
    __centered = [[NSMutableParagraphStyle alloc] init];
    [__centered setAlignment:NSCenterTextAlignment];
    __justified = [[NSMutableParagraphStyle alloc] init];
    [__justified setAlignment:NSJustifiedTextAlignment];
    __natural = [[NSMutableParagraphStyle alloc] init];
    [__natural setAlignment:NSNaturalTextAlignment];
}


- (id)init
{
    self = [super init];

    if (self != nil) {
        _negativeColor = [[NSColor redColor] retain];
        _backgroundColor = nil;
        _numberFormat = @"#,###.00;0.00;(#,##0.00)";
        _numberFormatter = nil;
        _dateFormat = @"%m/%d/%Y";
        _dateFormatter = nil;

        _attributes = [[NSMutableDictionary alloc] init];
        [_attributes setObject:__rightAligned forKey:NSParagraphStyleAttributeName];
        [_attributes setObject:__defaultFont forKey:NSFontAttributeName];
        [_attributes setObject:[[NSColor blackColor] retain] forKey:NSForegroundColorAttributeName];
    }

    return self;
}


- (void)dealloc
{
    [_undoManager removeAllActionsWithTarget:self];
    [_undoManager release];
    [_numberFormatter release];
    [_dateFormatter release];
    [_attributes release];
    [_backgroundColor release];
    [_negativeColor release];
    [super dealloc];
}


- (NSUndoManager*)undoManager
{
    return _undoManager;
}


- (void)setUndoManager:(NSUndoManager*)um
{
    if (_undoManager && (_undoManager != um)) {
        [FSLog logInfo:@"UndoManager for FSCellStyle is reset.  Flushing entries."];
        [_undoManager removeAllActionsWithTarget:self];
    }
    [um retain];
    [_undoManager release];
    _undoManager = um;
}


- (void)recacheFormatters
{
    [_numberFormatter release];
    _numberFormatter = nil;
    [_dateFormatter release];
    _dateFormatter = nil;
}


+ (FSCellStyle*)defaultCellStyle
{
    return [[[self alloc] init] autorelease];
}


- (NSNumberFormatter*)numberFormatter
{
    if (_numberFormatter == nil) {
        NSMutableDictionary *negAttr = _attributes;

        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setFormat:_numberFormat];
        [_numberFormatter setTextAttributesForPositiveValues:_attributes];

        if (_negativeColor) {
            negAttr = [NSMutableDictionary dictionaryWithDictionary:_attributes];
            [negAttr setObject:_negativeColor forKey:NSForegroundColorAttributeName];
        }

        [_numberFormatter setTextAttributesForNegativeValues:negAttr];
    }
    return _numberFormatter;
}


- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:_dateFormat allowNaturalLanguage:NO];
    }
    return _dateFormatter;
}


- (NSDictionary*)textAttributes
{
    return _attributes;
}


- (NSTextAlignment)alignment
{
    return [[_attributes objectForKey:NSParagraphStyleAttributeName] alignment];
}


- (void)setAlignment:(NSTextAlignment)newAlignment
{
    [[_undoManager prepareWithInvocationTarget:self] setAlignment:[self alignment]];
    switch (newAlignment) {
        case NSRightTextAlignment:
            [_attributes setObject:__rightAligned forKey:NSParagraphStyleAttributeName];
            break;
        case NSCenterTextAlignment:
            [_attributes setObject:__centered forKey:NSParagraphStyleAttributeName];
            break;
        case NSJustifiedTextAlignment:
            [_attributes setObject:__justified forKey:NSParagraphStyleAttributeName];
            break;
        case NSLeftTextAlignment:
            [_attributes setObject:__leftAligned forKey:NSParagraphStyleAttributeName];
        case NSNaturalTextAlignment:
            [_attributes setObject:__natural forKey:NSParagraphStyleAttributeName];
    }
    [self recacheFormatters];
}


- (NSColor*)foregroundColor
{
    return [_attributes objectForKey:NSForegroundColorAttributeName];
}


- (void)setForegroundColor:(NSColor*)color
{
    [[_undoManager prepareWithInvocationTarget:self] setForegroundColor:[self foregroundColor]];
    [_attributes setObject:color forKey:NSForegroundColorAttributeName];
    [self recacheFormatters];
}


- (NSColor*)backgroundColor
{
    return _backgroundColor;
}


- (void)setBackgroundColor:(NSColor*)color
{
    [[_undoManager prepareWithInvocationTarget:self] setBackgroundColor:_backgroundColor];
    [color retain];
    [_backgroundColor release];
    _backgroundColor = color;
}


- (NSColor*)negativeColor
{
    return _negativeColor;
}


- (void)setNegativeColor:(NSColor*)color
{
    [[_undoManager prepareWithInvocationTarget:self] setNegativeColor:_negativeColor];
    [color retain];
    [_negativeColor release];
    _negativeColor = color;
    [self recacheFormatters];
}


- (NSFont*)font
{
    return [_attributes objectForKey:NSFontAttributeName];
}


- (void)setFont:(NSFont*)font
{
    [[_undoManager prepareWithInvocationTarget:self] setFont:[self font]];
    [_attributes setObject:font forKey:NSFontAttributeName];
    [self recacheFormatters];
}


- (BOOL)isEqual:(id)obj
{
    if ([obj isKindOfClass:[FSCellStyle class]]) {
        return YES;
    } else {
        return NO;
    }
}

//
// Archiving
//

+ (FSCellStyle*)cellStyleWithDictionary:(NSDictionary*)dict
{
    FSCellStyle *instance = [[self alloc] initWithDictionary:dict];
    return [instance autorelease];
}


- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [self init]; // This is not very efficient, but save.
    if (self && dict) {
        [self copyStyleFromDictionary:dict];
    }
    return self;
}


- (void)copyStyleFromDictionary:(NSDictionary*)dict
{
    NSString *fontname = [dict objectForKey:@"TextFontFace"];
    int       fontsize = [[dict objectForKey:@"TextFontSize"] intValue];
    NSFont   *font = [NSFont fontWithName:fontname size:fontsize];

    [self setFont:font];
    [self setAlignment:[[dict objectForKey:@"TextAlignment"] intValue]];
    [self setForegroundColor:[NSColor colorFromArchiveString:[dict objectForKey:@"TextColor"]]];
    [self setBackgroundColor:[NSColor colorFromArchiveString:[dict objectForKey:@"CellColor"]]];
    [self setNegativeColor:[NSColor colorFromArchiveString:[dict objectForKey:@"NegativeColor"]]];
}


- (NSDictionary*)dictionaryForArchiving
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSFont              *font = [self font];

    [dict setObject:[NSString stringWithFormat:@"%i", [self alignment]] forKey:@"TextAlignment"];
    [dict setObject:[[self foregroundColor] stringForArchiving] forKey:@"TextColor"];
    if (_backgroundColor)
        [dict setObject:[_backgroundColor stringForArchiving] forKey:@"CellColor"];
    if (_negativeColor)
        [dict setObject:[_negativeColor stringForArchiving] forKey:@"NegativeColor"];
    [dict setObject:[font fontName] forKey:@"TextFontFace"];
    [dict setObject:[NSString stringWithFormat:@"%i", (int)[font pointSize]] forKey:@"TextFontSize"];

    return dict;
}

@end
