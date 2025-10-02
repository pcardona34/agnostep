//
//  FSWorksheet+Scripting.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 20-MAY-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSWorksheet+Scripting.m,v 1.1 2008/10/28 13:10:30 hns Exp $

#import "FlexiSheet.h"

@implementation FSWorksheet (Scripting)

- (NSScriptObjectSpecifier*)objectSpecifier;
{
    NSArray      *allWorksheets = [[self document] worksheetsForTable:[self table]];
    unsigned int  index = [allWorksheets indexOfObjectIdenticalTo:self];

    if (index != NSNotFound) {
        NSScriptObjectSpecifier *containerRef = [[self table] objectSpecifier];
        return [[[NSIndexSpecifier allocWithZone:[self zone]] initWithContainerClassDescription:[containerRef keyClassDescription]
                                                                             containerSpecifier:containerRef
                                                                                            key:@"worksheets"
                                                                                          index:index] autorelease];
    } else {
        return nil;
    }
}

@end

