//
//  FSValue+Scripting.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 21-MAY-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSValue+Scripting.m,v 1.1 2008/10/28 13:10:30 hns Exp $

#import "FlexiSheet.h"

@implementation FSValue (Scripting)

- (FSKeyGroup*)group
{
#warning must implement group method
	return nil;
}

- (NSScriptObjectSpecifier*)objectSpecifier;
    // Returns itself always as the key of the group it's in.
{
    NSArray      *items = [[self group] items];
    unsigned int  index = [items indexOfObjectIdenticalTo:self];

    if (index != NSNotFound) {
        NSScriptObjectSpecifier *containerRef = [[self group] objectSpecifier];
        return [[[NSIndexSpecifier allocWithZone:[self zone]] initWithContainerClassDescription:[containerRef keyClassDescription]
                                                                             containerSpecifier:containerRef
                                                                                            key:@"items"
                                                                                          index:index] autorelease];
    } else {
        return nil;
    }
}

@end
