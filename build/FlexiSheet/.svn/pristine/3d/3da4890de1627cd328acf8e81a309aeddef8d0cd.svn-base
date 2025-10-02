//  $Id: FSArchiving.h,v 1.1 2008/10/14 15:03:43 hns Exp $
//
//  FSArchiving.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-JAN-2001.
//
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.

#import "FSDocument.h"
#import "FSWorksheet.h"
#import <AppKit/NSColor.h>


@interface FSDocument (Archiving)

- (NSDictionary*)dictionaryForArchiving;
- (BOOL)loadDocumentFromDictionary:(NSDictionary*)dictionary;

@end

@interface NSString (Private)

- (NSString*)_stringRepresentation;

@end

@interface NSString (Archiving)

- (NSString*)packedDescription;

@end

@interface NSArray (Archiving)

- (NSArray*)arrayWithDictionarysForArchiving;
- (NSString*)packedDescription;

@end

@interface NSDictionary (Archiving)

- (NSString*)packedDescription;

@end

@interface FSWorksheet (Archiving)

- (NSDictionary*)dictionaryForArchiving;

@end

@interface NSColor (Archiving)

- (NSString*)stringForArchiving;
+ (NSColor*)colorFromArchiveString:(NSString*)colorString;

@end
