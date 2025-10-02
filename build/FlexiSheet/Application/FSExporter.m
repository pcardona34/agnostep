//
//  FSExporter.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 18-APR-2002.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSExporter.m,v 1.1 2008/10/14 15:03:45 hns Exp $

#import "FlexiSheet.h"
#import "FSExporter.h"

static FSExporter *__sharedInstance = nil;

static NSArray *__encodingNames = nil;

@implementation FSExporter

+ (FSExporter*)sharedExporter
{
    if (__sharedInstance == nil) {
        __sharedInstance = [[FSExporter alloc] init];
        if (__encodingNames == nil) {
            __encodingNames = [[NSArray alloc] initWithObjects:@"unknown",
                                     @"US-ASCII",        //  1: NSASCIIStringEncoding
                                     @"US-ASCII",        //  2: NSNEXTSTEPStringEncoding
                                     @"EUC-JP",          //  3: NSJapaneseEUCStringEncoding
                                     @"UTF-8",           //  4: NSUTF8StringEncoding
                                     @"ISO-8859-1",      //  5: NSISOLatin1StringEncoding
                                     @"US-ASCII",        //  6: NSSymbolStringEncoding
                                     @"US-ASCII",        //  7: NSNonLossyASCIIStringEncoding
                                     @"SHIFT_JIS",       //  8: NSShiftJISStringEncoding
                                     @"ISO-8859-2",      //  9: NSISOLatin2StringEncoding
                                     @"ISO-10646-UCS-2", // 10: NSUnicodeStringEncoding
                                     @"windows-1251",    // 11: NSWindowsCP1251StringEncoding Cyrillic
                                     @"windows-1252",    // 12: NSWindowsCP1252StringEncoding WinLatin1
                                     @"windows-1253",    // 13: NSWindowsCP1253StringEncoding Greek
                                     @"windows-1254",    // 14: NSWindowsCP1254StringEncoding Turkish
                                     @"windows-1250",    // 15: NSWindowsCP1250StringEncoding WinLatin2
                                     @"unknown",         // 16:
                                     @"unknown",         // 17:
                                     @"unknown",         // 18:
                                     @"unknown",         // 19:
                                     @"unknown",         // 20:
                                     @"ISO-2022-JP",     // 21: NSISO2022JPStringEncoding
                                     @"unknown",         // 22:
                                     @"unknown",         // 23:
                                     @"unknown",         // 24:
                                     @"unknown",         // 25:
                                     @"unknown",         // 26:
                                     @"unknown",         // 27:
                                     @"unknown",         // 28:
                                     @"unknown",         // 29:
                                     @"macintosh",       // 30: NSMacOSRomanStringEncoding
                nil];
        }
    }
    return __sharedInstance;
}


- (NSView*)accessoryView
{
    if (accessory == nil) {
        [NSBundle loadNibNamed:@"Export" owner:self];
        [accessory retain];
    }
    return accessory;
}


- (IBAction)changeEncoder:(id)sender
{
    BOOL csvOptionsEnabled = ([[encoder selectedItem] tag] == 0);

    [lineSeparator setEnabled:csvOptionsEnabled];
    [valueSeparator setEnabled:csvOptionsEnabled];
}


- (void)runExportSheetForWindowController:(FSWindowController*)wc
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    // Setup sheet
    [savePanel setAccessoryView:[self accessoryView]];
    
    // Run sheet
    [savePanel beginSheetForDirectory:nil file:nil modalForWindow:[wc window]
                        modalDelegate:self didEndSelector:@selector(saveDidEnd:returnCode:contextInfo:)
                          contextInfo:wc];
}


- (NSString*)exportAsCSVFromTable:(FSWindowController*)wc
{
    NSMutableArray *lines = [NSMutableArray array];
    NSMutableArray *oneLine = [[NSMutableArray alloc] init];
    BOOL            exportRowLabels = [exportRowHeaders state];
    NSString       *temp;
    NSArray        *topSets = [wc topKeySetsForTableView:[wc tableView]];
    int             tsCnt = [topSets count];
    NSArray        *rowSets = [wc sideKeySetsForTableView:[wc tableView]];
    int             rowCnt = [rowSets count];
    FSKeySet       *globalSet = [[wc tableView] keySetForTabSelection];
    FSKeySet       *rowSet = nil;
    FSTable        *table = [wc table];
    int             idx, row;
    NSTimeInterval  start = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval  end;
    unichar         tag;
    NSString       *valueSep;
    NSString       *lineSep = @"\n";

    tag = [[valueSeparator selectedItem] tag];
    valueSep = [NSString stringWithCharacters:&tag length:1];

    // export data

    if ([exportColumnItems state]) {
        if (exportRowLabels) [oneLine addObject:@""];
        for (idx = 0; idx < tsCnt; idx++) {
            [oneLine addObject:[[topSets objectAtIndex:idx] description]];
        }

        temp = [oneLine componentsJoinedByString:valueSep];
        [lines addObject:temp];
    }
    // now export all rows
    for (row = 0; row < rowCnt;  row++) {
        rowSet = [rowSets objectAtIndex:row];
        [globalSet addKeys:rowSet];
        [oneLine removeAllObjects];
        if (exportRowLabels) [oneLine addObject:[rowSet description]];
        for (idx = 0; idx < tsCnt; idx++) {
            [globalSet addKeys:[topSets objectAtIndex:idx]];
            [oneLine addObject:[[table valueForKeySet:globalSet] stringValue]];
        }
        temp = [oneLine componentsJoinedByString:valueSep];
        [lines addObject:temp];
    }

    [oneLine release];
    end = [NSDate timeIntervalSinceReferenceDate];
    [FSLog logInfo:@"%i lines exported to CSV in %3.2f seconds.", rowCnt, end-start];
    return [lines componentsJoinedByString:lineSep];
}


- (NSString*)exportAsHTMLFromTable:(FSWindowController*)wc
{
    NSMutableString *html = [NSMutableString string];
    BOOL             exportRowLabels = [exportRowHeaders state];
    NSArray         *topSets = [wc topKeySetsForTableView:[wc tableView]];
    int              tsCnt = [topSets count];
    NSArray         *rowSets = [wc sideKeySetsForTableView:[wc tableView]];
    int              rowCnt = [rowSets count];
    FSKeySet        *globalSet = [[wc tableView] keySetForTabSelection];
    FSKeySet        *rowSet = nil;
    FSTable         *table = [wc table];
    int              idx, row;

    // export data

    // write HTML header
    [html appendString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n<HTML>\n<HEAD>\n"];
    [html appendFormat:@"  <TITLE>%@ - %@, %@</TITLE>\n  <meta http-equiv=\"content-type\" content=\"text/html;charset=%@\">\n</HEAD>\n",
	 
	 // FIXME: this is not robust for htmlentities and UTF in names etc.
	 
        [(FSDocument*)[table document] displayName], [table name], [wc name],
        [__encodingNames objectAtIndex:[[encoding selectedItem] tag]]];

    // write HTML body with table
    [html appendString:@"<BODY>\n<TABLE>\n"];

    if ([exportColumnItems state]) {
        [html appendString:@"  <TR>\n"];
        if (exportRowLabels) [html appendString:@"    <TH>&nbsp;</TH>\n"];
        for (idx = 0; idx < tsCnt; idx++) {
            [html appendFormat:@"     <TH>%@</TH>\n", [[topSets objectAtIndex:idx] description]];
        }
        [html appendString:@"  </TR>\n\n"];
    }
    // now export all rows
    for (row = 0; row < rowCnt;  row++) {
        [html appendString:@"  <TR>\n"];
        rowSet = [rowSets objectAtIndex:row];
        [globalSet addKeys:rowSet];
        if (exportRowLabels) [html appendFormat:@"    <TH>%@</TH>\n", [rowSet description]];
        for (idx = 0; idx < tsCnt; idx++) {
            [globalSet addKeys:[topSets objectAtIndex:idx]];
            [html appendFormat:@"    <TD>%@</TD>\n", [[table valueForKeySet:globalSet] stringValue]];
        }
        [html appendString:@"  </TR>\n"];
    }
    [html appendString:@"</TABLE>\n</BODY>\n</HTML>\n"];
    return html;
}


- (NSString*)exportAsLaTeXFromTable:(FSWindowController*)wc
{
    NSMutableString *latexCode = [NSMutableString string];
    BOOL             exportRowLabels = [exportRowHeaders state];
    NSArray         *topSets = [wc topKeySetsForTableView:[wc tableView]];
    int              tsCnt = [topSets count];
    NSArray         *rowSets = [wc sideKeySetsForTableView:[wc tableView]];
    int              rowCnt = [rowSets count];
    FSKeySet        *globalSet = [[wc tableView] keySetForTabSelection];
    FSKeySet        *rowSet = nil;
    FSTable         *table = [wc table];
    int              idx, row;

    // export data

    // write LaTeX header
    [latexCode appendString:@"\\documentclass[12pt]{article}\n\n"];
    [latexCode appendFormat:@"\\title{%@ - %@, %@}\n\\author{%@}\n\\date{%@}\n\\begin{document}\n\\maketitle\n",
        [(FSDocument*)[table document] displayName], [table name], [wc name],
        NSFullUserName(), [NSCalendarDate calendarDate]];

    // write LaTeX body with table
    [latexCode appendString:@"\n% ---->8--- cut here ---->8---\n\n"];
    [latexCode appendFormat:@"\\begin{tabular}{%s*{%i}{|l}|}\n\n", (exportRowLabels)?"r":"", tsCnt];

    if ([exportColumnItems state]) {
        if (exportRowLabels) [latexCode appendString:@" & "];
        for (idx = 0; idx < tsCnt; idx++) {
            [latexCode appendFormat:@"%@ %s", [[topSets objectAtIndex:idx] description], (idx<tsCnt-1)?"& ":"\\\\"];
        }
    }
    // now export all rows
    [latexCode appendString:@"\n\\hline\n"];
    for (row = 0; row < rowCnt;  row++) {
        rowSet = [rowSets objectAtIndex:row];
        [globalSet addKeys:rowSet];
        if (exportRowLabels) [latexCode appendFormat:@"%@ &", [rowSet description]];
        for (idx = 0; idx < tsCnt; idx++) {
            [globalSet addKeys:[topSets objectAtIndex:idx]];
            [latexCode appendFormat:@"%@ %s", [[table valueForKeySet:globalSet] stringValue], (idx<tsCnt-1)?"& ":"\\\\"];
        }
        [latexCode appendString:@"\n\\hline\n"];
    }
    [latexCode appendString:@"\n\\end{tabular}\n\n% ---->8--- cut here ---->8---\n\n\\end{document}\n\\end\n"];
    return latexCode;
}


- (void)saveDidEnd:(NSSavePanel*)panel returnCode:(int)returnCode contextInfo:(FSWindowController*)wc
{
    if (returnCode == NSAlertDefaultReturn) {
        NSString       *filename = [panel filename];
        NSString       *temp;
        int             fileEnc = [[encoding selectedItem] tag];

        switch ([[encoder selectedItem] tag]) {
            case 0:
                temp = [self exportAsCSVFromTable:wc];
                break;
            case 1:
                temp = [self exportAsHTMLFromTable:wc];
                //if ([[[filename pathExtension] lowercaseString] isEqualToString:@"html"] == NO) {
                //filename = [filename stringByAppendingPathExtension:@"html"];
                //}
                break;
            case 2:
                temp = [self exportAsLaTeXFromTable:wc];
                break;
            default:
                temp = @"unknown encoder";
        }
        
        [[temp dataUsingEncoding:fileEnc] writeToFile:filename atomically:YES];
    }
}

@end
