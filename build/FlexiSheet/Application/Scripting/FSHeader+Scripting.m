//
//  FSHeader+Scripting.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 20-MAY-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSHeader+Scripting.m,v 1.1 2008/10/28 13:10:30 hns Exp $

#import "FlexiSheet.h"

@implementation FSHeader (Scripting)

- (NSScriptObjectSpecifier*)objectSpecifier
// An FSHeader sees itself as a category of it's table.
{
    NSArray      *allHeaders = [[self table] headers];
    unsigned int  index = [allHeaders indexOfObjectIdenticalTo:self];

    if (index != NSNotFound) {
        NSScriptObjectSpecifier *containerRef = [[self table] objectSpecifier];
        return [[[NSIndexSpecifier allocWithZone:[self zone]] initWithContainerClassDescription:[containerRef keyClassDescription]
                                                                             containerSpecifier:containerRef
                                                                                            key:@"categories"
                                                                                          index:index] autorelease];
    } else {
        return nil;
    }
}

@end

@implementation FSKeyGroup (Scripting)

- (NSScriptObjectSpecifier*)objectSpecifier
// An FSKeyGroup sees itself as an item of it's group.
{
    NSArray      *items = [[self group] items];
    unsigned int  index = [items indexOfObjectIdenticalTo:self];

    if (index != NSNotFound) {
        NSScriptObjectSpecifier *containerRef = [[self group] objectSpecifier];
        return [[[NSIndexSpecifier allocWithZone:[self zone]] initWithContainerClassDescription:[containerRef keyClassDescription]
                                                                             containerSpecifier:containerRef
                                                                                            key:@"groups"
                                                                                          index:index] autorelease];
    } else {
        return nil;
    }
}

@end
