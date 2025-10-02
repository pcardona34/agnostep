//
//  FSTable+Scripting.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 20-MAY-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTable+Scripting.m,v 1.1 2008/10/28 13:10:30 hns Exp $

#import "FlexiSheet.h"

@implementation FSTable (Scripting)

- (NSScriptObjectSpecifier*)objectSpecifier;
{
    NSArray      *docsTables = [[self document] tables];
    unsigned int  index = [docsTables indexOfObjectIdenticalTo:self];

    if (index != NSNotFound) {
        NSScriptObjectSpecifier *containerRef = [(FSDocument*)[self document] objectSpecifier];
        return [[[NSIndexSpecifier allocWithZone:[self zone]] initWithContainerClassDescription:[containerRef keyClassDescription]
                                                                             containerSpecifier:containerRef
                                                                                            key:@"tables"
                                                                                          index:index] autorelease];
    } else {
        return nil;
    }
}


- (NSArray*)worksheets
{
    return [(FSDocument*)[self document] worksheetsForTable:self];
}


- (NSArray*)categories
{
    return [self headers];
}


- (void)handleSetValueCommand:(NSScriptCommand*)command
{
}


- (NSArray*)scriptingKeysets
{
    return _keysets;
}

@end

