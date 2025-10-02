//
//  FSArchiving.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSArchiving.m,v 1.1 2008/10/14 15:03:43 hns Exp $

#import "FlexiSheet.h"
#import "FSArchiving.h"

@implementation FSDocument (Archiving) 


- (NSDictionary*)dictionaryForArchiving
/*" Version 2 of the FlexiSheet format writes FSDocument as an array of tables. "*/
{
    NSMutableDictionary *document = [NSMutableDictionary dictionary];
    
    [document setObject:[_tables arrayWithDictionarysForArchiving]
        forKey:@"FSDocument"];
    [document setObject:@"5" forKey:@"Version"];
    [document setObject:@"FlexiSheet" forKey:@"Creator"];
    
    return document;
}


- (BOOL)_createTableFromDictionary:(NSDictionary*)dict
{
    FSTable *table = [[FSTable alloc] init];
    [table setName:@"Generic Table Name"];
    [_tables addObject:table];
    [table release];

    [table setDocument:self];
    [table loadFromDictionary:dict];
    return YES;
}


- (BOOL)loadDocumentFromDictionary:(NSDictionary*)dictionary
{
    id        tabledata = [dictionary objectForKey:@"FSDocument"];
    
    // Version 1 documents, only one table
    if ([tabledata isKindOfClass:[NSDictionary class]]) {
        return [self _createTableFromDictionary:tabledata];
    }
    // Version 2 documents, array of tables
    if ([tabledata isKindOfClass:[NSArray class]]) {
        [tabledata iteratePerformSelector:@selector(_createTableFromDictionary:) target:self];
        return YES;
    }
    
    return NO;
}

@end


@implementation NSString (Archiving)

- (NSString*)packedDescription
{
    return [self _stringRepresentation];
}

@end


@implementation NSArray (Archiving)

- (NSArray*)arrayWithDictionarysForArchiving
/*" Returns an array containing the archiving dictionaries for all objects in the receiver. "*/
{
    NSMutableArray *arch = [NSMutableArray array];
    NSEnumerator   *cursor = [self objectEnumerator];
    id              object;
    
    while (object = [cursor nextObject]) {
        if ([object respondsToSelector:@selector(dictionaryForArchiving)]) {
            [arch addObject:[object dictionaryForArchiving]];
        }
    }
    
    return arch;
}


- (NSString*)packedDescription
{
    int              count = [self count];
    int              index = 0;
    NSMutableString *description;

    if (count == 0) return @"()";

    description = [NSMutableString stringWithFormat:@"(%@", [[self objectAtIndex:0] packedDescription]];
    while (++index < count) {
        [description appendFormat:@", %@", [[self objectAtIndex:index] packedDescription]];
    }
    [description appendString:@")"];
    return description;
}

@end


@implementation NSDictionary (Archiving)

- (NSString*)packedDescription
{
    NSMutableString *description;
    NSArray         *keys;
    NSString        *key;
    int              count = [self count];
    int              index = 0;

    if (count == 0) return @"{}";

    keys = [self allKeys];
    key = [keys objectAtIndex:0];
    description = [NSMutableString stringWithFormat:@"{\n%@ = %@;", [key packedDescription], [[self objectForKey:key] packedDescription]];
    while (++index < count) {
        key = [keys objectAtIndex:index];
        [description appendFormat:@"\n%@ = %@;", [key packedDescription], [[self objectForKey:key] packedDescription]];
    }

    [description appendString:@"\n}"];
    return description;
}

@end


@implementation NSColor (Archiving)

- (NSString*)stringForArchiving
{
    NSColor *rgbColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    return [NSString stringWithFormat:@"%f;%f;%f;%f",
        [rgbColor redComponent], [rgbColor greenComponent],
        [rgbColor blueComponent], [rgbColor alphaComponent]];
}

+ (NSColor*)colorFromArchiveString:(NSString*)colorString
{
    NSArray *components = [colorString componentsSeparatedByString:@";"];
    if ([components count] != 4) return nil;
    return [NSColor colorWithCalibratedRed:[[components objectAtIndex:0] floatValue]
                                     green:[[components objectAtIndex:1] floatValue]
                                      blue:[[components objectAtIndex:2] floatValue]
                                     alpha:[[components objectAtIndex:3] floatValue]];
}

@end
