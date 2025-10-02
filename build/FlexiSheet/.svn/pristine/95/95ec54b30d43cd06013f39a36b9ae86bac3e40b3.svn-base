//
//  FSDocument+Quantrix.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 28-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//                2012 Free Software Foundation
//
//  $Id: FSDocument+Quantrix.m,v 1.3 2012/01/25 09:58:38 rmottola Exp $

#import "FlexiSheet.h"
#import "FSArchiving.h"


@implementation FSDocument (QuantrixImport)
/*" Importing Quantrix file wrappers.
    
    There are three files inside the wrapper.
    - modelFile contains the tables including data and formulae.
      We read table/category/item/value information at this point.
    - formatFile contains general formatting information.
      We don't read this.
    - interfaceFile contains information about the views.
      We respect this only vaguely. 
    "*/

- (NSArray*)_keySetsForQHeaders:(NSArray*)headers
/*" Returns an array of key sets. 
    This method is different from the one in FSTable in that
    it gives exactly the order dataspaces are saved in Quantrix. 
    "*/
{
    int             index = [headers count];
    FSHeader       *header;
    NSArray        *labels;
    FSKeySet       *set = nil;
    FSKey          *key;
    NSArray        *result = [NSArray arrayWithObject:[FSKeySet keySet]];
    NSEnumerator   *keyCursor, *setCursor;
    NSMutableArray *temp;
    
    while (index-- > 0) {
        header = [headers objectAtIndex:index];
        labels = [header keys];
        if ([labels count]) {
            temp = [NSMutableArray array];
            setCursor = [result objectEnumerator];
            while ((set = [setCursor nextObject]))
	      {
                keyCursor = [labels objectEnumerator];
                while ((key = [keyCursor nextObject]))
		  {
                    [temp addObject:[set setByAddingKey:key]];
		  }
	      }
            result = temp;
        }
    }
    
    return result;
}

- (void)_alsoImportGroup:(NSArray*)kids intoGroup:(FSKeyGroup*)group withLabel:(NSString*)label
{
    int           index = [[group items] count];
    int           count = 0;
    NSEnumerator *nc;
    id            no;
    NSArray      *subarray;
    NSString     *name;

    nc = [kids objectEnumerator];
    while ((no = [nc nextObject]))
      {
        name = [no objectForKey:@"name"];
        subarray = [no objectForKey:@"children"];
        if ([subarray isKindOfClass:[NSArray class]]) {
            [self _alsoImportGroup:subarray intoGroup:group withLabel:name];
        } else {
            [group appendKeyWithLabel:name];
        }
        count++;
    }
    [group groupItemsInRange:NSMakeRange(index, count) withLabel:label];
}

- (BOOL)_importQuantrixFromWrapper:(NSFileWrapper*)wrapper
{
    NSMutableDictionary *globalCategories = [NSMutableDictionary dictionary];
    FSGlobalHeader      *gh;
    NSDictionary        *files = [wrapper fileWrappers];
    NSData              *data = [[files objectForKey:@"modelFile"] regularFileContents];
    NSDictionary        *model;
    NSDictionary        *interface;
    NSDictionary        *format;
    NSString            *strg;  // temp storage
    NSDictionary        *dict;  // temp storage
    NSEnumerator        *tc, *cc, *nc;
    id                   to, co, no;
    FSTable             *table;
    FSHeader            *header;
        
    NS_DURING
        data = [[files objectForKey:@"modelFile"] regularFileContents];
        strg = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
        model = [strg propertyList];
        [strg release];
        
        data = [[files objectForKey:@"interfaceFile"] regularFileContents];
        strg = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
        interface = [strg propertyList];
        [strg release];
        
        data = [[files objectForKey:@"formatFile"] regularFileContents];
        strg = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
        format = [strg propertyList];
        [strg release];
    NS_HANDLER
        [strg release];
        NSRunAlertPanel(FS_LOCALIZE(@"Quantrix import failed."),
            FS_LOCALIZE(@"This document is not in a format that FlexiSheet can import."), 
            FS_LOCALIZE(@"OK"), nil, nil);
        return NO;
    NS_ENDHANDLER
    
    //[FSLog log:(@"Importing .quantrix file from %@...", [wrapper filename]);
    //[FSLog log:(@"Quantrix version: %@", [model objectForKey:@"Quantrix Version"]);
    
    tc = [[model objectForKey:@"tables"] objectEnumerator];
    while ((to = [tc nextObject])) {
        NSArray *values = [to objectForKey:@"dataspace"];
        NSArray *formulae = [[to objectForKey:@"formulaspace"] objectForKey:@"formulae"];
        id       kids;
        
        table = [[FSTable alloc] init];
        [table setName:[to objectForKey:@"name"]];
        [_tables addObject:table];
        
        cc = [[to objectForKey:@"categories"] objectEnumerator];
        while ((co = [cc nextObject]))
	  {
            header = [FSHeader headerNamed:[co objectForKey:@"name"]];
            [table addHeader:header];

            strg = [co objectForKey:@"globalCategoryNumber"];
            if (strg) {
                gh = [globalCategories objectForKey:strg];
                if (gh == nil) {
                    gh = [[FSGlobalHeader alloc] init];
                    [globalCategories setObject:gh forKey:strg];
                    [gh release];
                }
                [gh addHeader:header];
            }
            
            nc = [[co objectForKey:@"nodes"] objectEnumerator];
            while ((no = [nc nextObject])) {
                kids = [no objectForKey:@"children"];
                if ([kids isKindOfClass:[NSArray class]]) {
                    [self _alsoImportGroup:kids intoGroup:header
                        withLabel:[no objectForKey:@"name"]];
                } else {
                    [header appendKeyWithLabel:[no objectForKey:@"name"]];
                }
            }
        }
        
        if (values != nil) {
            NSArray *keySets = [self _keySetsForQHeaders:[table headers]];
            
            if ([keySets count] == [values count]) {
                int index = [keySets count];
                while (index-- > 0) {
                    [[table valueForKeySet:[keySets objectAtIndex:index]] setValue:[values objectAtIndex:index]];
                }
            } else {
                [FSLog logError:@"dataspace (%i) is not equal to keyset count (%i).", [values count], [keySets count]];
            }
        }
        
        if (formulae) {
            int index = 0;
            int num = [formulae count];
            while (index < num) {
                [table addFormula:[[formulae objectAtIndex:index] objectForKey:@"formula"]];
                index++;
            }
        }
        
        [table setDocument:self];
        
        // We autorelease table so it is still around when misc data
        // gets deallocated in the run loop.
        [table autorelease];
    }
    [[globalCategories allValues] iteratePerformSelector:@selector(addToGlobalCategories:) target:self];

    tc = [[[interface objectForKey:@"document"] objectForKey:@"dataDepictions"] objectEnumerator];
    while ((to = [tc nextObject])) {
        strg = [to objectForKey:@"name"];
        if (strg == nil) {
            TEST_DBG [FSLog logDebug:@"Using default table (no name given)."];
            // Assuming that there is only one.
            table = [_tables lastObject];
        } else {
            table = [self tableWithName:strg];
        }
        if (table) {
            strg = [to objectForKey:@"rtfcomment"];
            if (strg) {
                NSData *data = [strg dataUsingEncoding:NSNEXTSTEPStringEncoding];
                [table setComment:data];
            } else {
                strg = [to objectForKey:@"comment"];
                if (strg) {
                    id astr = [[NSAttributedString alloc] initWithString:strg];
                    NSData *data = [astr RTFFromRange:NSMakeRange(0,[strg length])
                        documentAttributes:nil];
                    [table setComment:data];
                    [astr release];
                }
            }
            cc = [[to objectForKey:@"depictions"] objectEnumerator];
            while ((co = [cc nextObject])) {
                strg = [co objectForKey:@"class"];
            
                // A Quantrix formulaDepiction is what we call TableView.
                if ((strg == nil) || [strg isEqualToString:@"formulaDepiction"]) {
                    NSMutableArray     *headers;
                    
                    // Create the table controller
                    FSTableController  *controller =
                        [[FSTableController alloc] initWithWindowNibName:@"FSTable"];
                    [self addWindowController:controller];
                    [controller release];

                    // Read category distribution
                    [controller setTable:table];
                    dict = [co objectForKey:@"worksheetView"];
                    // Top
                    headers = [NSMutableArray array];
                    nc = [[dict objectForKey:@"xCategories"] objectEnumerator];
                    while ((no = [nc nextObject])) {
                        [headers addObject:[[table headers] objectAtIndex:[no intValue]]];
                    }
                    if ([headers count] > 0) [controller setTopHeaders:headers];
                    // Side
                    headers = [NSMutableArray array];
                    nc = [[dict objectForKey:@"yCategories"] objectEnumerator];
                    while ((no = [nc nextObject])) {
                        [headers addObject:[[table headers] objectAtIndex:[no intValue]]];
                    }
                    if ([headers count] > 0) [controller setSideHeaders:headers];
                    // Page
                    headers = [NSMutableArray array];
                    nc = [[dict objectForKey:@"zCategories"] objectEnumerator];
                    while ((no = [nc nextObject])) {
                        [headers addObject:[[table headers] objectAtIndex:[no intValue]]];
                    }
                    if ([headers count] > 0) [controller setPageHeaders:headers];
                    
                    // set name
                    strg = [co objectForKey:@"name"];
                    if (strg) {
                        [controller setName:strg];
                    }
                    [controller syncWithDocument];
                    
                    // adjust view size
                    dict = [co objectForKey:@"windowFrame"];
                    [[controller window] setContentSize:NSMakeSize(
                        [[dict objectForKey:@"w"] intValue],
                        [[dict objectForKey:@"h"] intValue]
                    )];
                    [controller showWindow:nil];
                } else 
                if ([[co objectForKey:@"class"] isEqualToString:@"chartDepiction"]) {
                    NSMutableArray     *headers;

                    FSTableController  *controller = nil;
                    //[[FSChartController alloc] initWithWindowNibName:@"FSChart"];
                    [self addWindowController:controller];
                    [controller release];

                    // Read category distribution
                    [controller setTable:table];
                    dict = [co objectForKey:@"worksheetView"];
                    // Top
                    headers = [NSMutableArray array];
                    nc = [[dict objectForKey:@"xCategories"] objectEnumerator];
                    while ((no = [nc nextObject])) {
                        [headers addObject:[[table headers] objectAtIndex:[no intValue]]];
                    }
                    if ([headers count] > 0) [controller setTopHeaders:headers];
                    // Side
                    headers = [NSMutableArray array];
                    nc = [[dict objectForKey:@"yCategories"] objectEnumerator];
                    while ((no = [nc nextObject])) {
                        [headers addObject:[[table headers] objectAtIndex:[no intValue]]];
                    }
                    if ([headers count] > 0) [controller setSideHeaders:headers];
                    // Page
                    headers = [NSMutableArray array];
                    nc = [[dict objectForKey:@"zCategories"] objectEnumerator];
                    while ((no = [nc nextObject])) {
                        [headers addObject:[[table headers] objectAtIndex:[no intValue]]];
                    }
                    if ([headers count] > 0) [controller setPageHeaders:headers];
                    
                    // set name
                    strg = [co objectForKey:@"name"];
                    if (strg) {
                        [controller setName:strg];
                    }
                    [controller syncWithDocument];
                    
                    // adjust view size
                    dict = [co objectForKey:@"windowFrame"];
                    [[controller window] setContentSize:NSMakeSize(
                        [[dict objectForKey:@"w"] intValue],
                        [[dict objectForKey:@"h"] intValue]
                    )];
                    [controller showWindow:nil];
                } else {
                    [FSLog logDebug:@"Skipping unknown view class %@.", [co objectForKey:@"class"]];
                }
            }
        } else {
            [FSLog logDebug:@"Unknown table %@", [to objectForKey:@"name"]];
        }
    }

    return YES;
}

@end
