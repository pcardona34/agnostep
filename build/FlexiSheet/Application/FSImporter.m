//
//  FSImporter.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 12-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSImporter.m,v 1.1 2008/10/14 15:03:46 hns Exp $

#import "FlexiSheet.h"
#import "FSImporter.h"

static FSImporter *__sharedInstance = nil;

NSString *FSImportValueSeparator = @"FSImportValueSeparator";


@implementation FSImporter

+ (FSImporter*)sharedImporter
{
    if (__sharedInstance == nil) {
        __sharedInstance = [[FSImporter alloc] init];
    }
    return __sharedInstance;
}


- (NSView*)accessoryView
{
    if (accessory == nil) {
        [NSBundle loadNibNamed:@"Import" owner:self];
        [accessory retain];
    }
    return accessory;
}


- (NSPopUpButton*)separatorPopup
{
    return separator;
}


- (NSStringEncoding)stringEncodingSelection
{
    return [[encoding selectedItem] tag];
}


- (NSString*)separatorSelection
{
    unichar tag = [[separator selectedItem] tag];
    return [NSString stringWithCharacters:&tag length:1];
}


- (NSString*)linebreakSelection
{
    unichar tag = [[lineBreaker selectedItem] tag];
    return [NSString stringWithCharacters:&tag length:1];
}


- (BOOL)shouldReadColumnLabels
{
    return [readColLabels state];
}


- (BOOL)shouldReadRowLabels
{
    return [readRowLabels state];
}


- (NSArray*)_arrayFromString:(NSString*)csvString separator:(unichar)sep
{
    NSMutableArray  *result = [NSMutableArray array];
    NSMutableArray  *line = [[NSMutableArray alloc] init];
    int              size = [csvString length];
    unichar          character;
    unsigned         index = 0;
    int              start = 0;
    int              length = 0;
    BOOL             insideQuote = NO;
    NSMutableString *tempString = [[NSMutableString alloc] init];

    while (index < size) {
        character = [csvString characterAtIndex:index];

        // If we are reading inside a quoted block,
        // nothing will bother us but a closing quote.
        if (insideQuote) {
            if (character != '"') {
                length++;
                index++;
            } else {
                // The closing quote.
                // Move what we have so far to tempString.
                [tempString appendString:[csvString substringWithRange:NSMakeRange(start, length)]];
                index++;
                start = index;
                length = 0;
                insideQuote = NO;
            }
        } else {
            switch (character) {
                case '"':
                    insideQuote = YES;
                    index++;
                    start = index;
                    length = 0;
                    if ([tempString length] > 0) {
                        [tempString appendString:@"\""];
                    }
                        break;
                case '\015':
                case '\n':
                    // Return: start next record
                    index++;
                    if (index < size) {
                        if ([csvString characterAtIndex:index] == '\n')
                            index++;
                    };

                    [tempString appendString:[csvString substringWithRange:NSMakeRange(start, length)]];
                    [line addObject:tempString];
                    [tempString release];

                    start = index;
                    length = 0;
                    tempString = [[NSMutableString alloc] init];

                    [result addObject:line];
                    [line release];
                    line = [[NSMutableArray alloc] init];
                    break;
                default:
                    if (character == sep) {
                        index++;
                        [tempString appendString:[csvString substringWithRange:NSMakeRange(start, length)]];
                        [line addObject:tempString];
                        start = index;
                        length = 0;
                        [tempString release];
                        tempString = [[NSMutableString alloc] init];
                    } else {
                        length++;
                        index++;
                    }
            }
        }
    }

    // We are at the end of the file.
    // Whatever is left, put it in a string and add it to the current line.
    if (length > 0) {
        [tempString appendString:[csvString substringWithRange:NSMakeRange(start, length)]];
    }
    [line addObject:tempString];
    [tempString release];

    // Add the current line to the result.
    [result addObject:line];
    [line release];

    return result;
}


- (FSTable*)importTableFromFile:(NSString*)filename
{
    return nil;
}


- (BOOL)importIntoTable:(FSTable*)table fromCSV:(NSString*)csvString parameters:(NSDictionary*)param
/*" Reads in CSV data and fills into table (after removing all headers and items).
    It is assumed that the first line contains column names
    which will be written into a category named Columns.
    Another category named Rows is created with number identifiers."*/
{
#define STEP 500
    FSHeader          *columns = [FSHeader headerNamed:@"Columns"];
    FSHeader          *rows = [FSHeader headerNamed:@"Rows"];
    NSArray           *lines = nil;
    NSMutableArray    *keys = [[NSMutableArray alloc] init];
    FSKeySet          *keySet = [[FSKeySet alloc] init]; // only one we need.
    FSKey             *lineKey;
    NSArray           *tmpArray;
    int                i;
    int                index, max, hIdx;
    NSTimeInterval     start;
    NSTimeInterval     end;
    NSString          *tempString;
    NSString          *label;
    unichar            sepChar;
    BOOL               readCols = [readColLabels state];
    BOOL               readRows = [readRowLabels state];
    NSAutoreleasePool *pool;

    tempString = [param objectForKey:FSImportValueSeparator];
    if ([tempString isKindOfClass:[NSString class]] && [tempString length]) {
        sepChar = [tempString characterAtIndex:0];
    } else {
        sepChar = ';';
    }

    [filenameField setStringValue:@"Reading file..."];
    [self runProgressPanel:0];
    // Create array of arrays:
    pool = [[NSAutoreleasePool alloc] init];
    //NSLog(@"Breaking into arrays...");
    lines = [[self _arrayFromString:csvString separator:sepChar] retain];
    //NSLog(@"Releasing pool...");
    [pool release];
    
    // do we have at least one line?
    i = 0;
    if ([lines count] < 2) {
        return NO;
    }

    // Setup:
    //
    [[table headers] iteratePerformSelector:@selector(removeHeader:) target:table];
    [table addHeader:columns];
    [table addHeader:rows];

    [filenameField setStringValue:@"Importing rows..."];
    [self runProgressPanel:[lines count]];

    //NSLog(@"Timer is started...");
    start = [NSDate timeIntervalSinceReferenceDate];

    // Number of columns to process
    max = [[lines objectAtIndex:0] count];
    
    if (readCols) {
        // take first array and make it the items
        tmpArray = [lines objectAtIndex:0];
        index = (readRows)?1:0;
        while (index < max) {
            label = [tmpArray objectAtIndex:index];
            if ([label length] == 0) label = @"1";
            [keys addObject:[columns appendKeyWithLabel:label]];
            index++;
        }
        i++;
    } else {
        index = 0;
        if (readRows) max--;
        while (index++ < max) {
            [keys addObject:[columns appendKeyWithLabel:[NSString stringWithFormat:@"%i", index]]];
        }
    }

    while (i < [lines count]) {
        tmpArray = [lines objectAtIndex:i];
        max = [tmpArray count];
        if (readRows && (max > 0)) {
            label = [tmpArray objectAtIndex:0];
            if ([label length] == 0) label = @"1";
            max--;
        } else {
            label = [NSString stringWithFormat:@"%i", i];
        }
        lineKey = [rows appendKeyWithLabel:label];
        [keySet addKey:lineKey];
        for (index = 0; index < max; index++) {
            hIdx = index;
            if (readRows) hIdx++;
            if (index < [keys count]) {
                [keySet addKey:[keys objectAtIndex:index]];
                [table setValue:[tmpArray objectAtIndex:hIdx] forKeySet:keySet];
            } else {
                [FSLog logError:@"Ignoring %i fields.", [tmpArray count]-index];
                break;
            }
        }
        if ((i % STEP) == 0) {
            [progressBar incrementBy:STEP];
            [progressBar display];
        }
        i++;
    }
    [self updateProgressPanel:(i % STEP)];
    [filenameField setStringValue:@"Done."];
    [filenameField display];
    end = [NSDate timeIntervalSinceReferenceDate];
    //NSLog(@"Timer is stopped.");
    [FSLog logInfo:@"%i lines imported in %3.2f seconds.", [lines count], end-start];

    [lines release];
    [keySet release];
    [keys release];
    [self endProgressPanel];
    return YES;
}


- (void)runProgressPanel:(int)steps // 0 means indeterminate
{
    if (steps == 0) {
        [progressBar setIndeterminate:YES];
        [progressBar setUsesThreadedAnimation:YES];
        [progressBar startAnimation:nil];
    } else {
        [progressBar setIndeterminate:NO];
        [progressBar setDoubleValue:0];
        [progressBar setMinValue:0];
        [progressBar setMaxValue:steps];
    }
    [progressPanel center];
    [progressPanel orderFront:nil];
    [progressBar display];
    [filenameField display];
}

- (void)updateProgressPanel:(int)increment
{
    [progressBar incrementBy:increment];
    [progressBar display];
}

- (void)endProgressPanel
{
    [progressPanel orderOut:nil];
}

@end
