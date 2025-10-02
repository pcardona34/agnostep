//
//  FSNoSelectionInspectorPane.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 15-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSNoSelectionInspectorPane.m,v 1.1 2008/10/28 13:10:29 hns Exp $

#import "FSNoSelectionInspectorPane.h"


@implementation FSNoSelectionInspectorPane

+ (void)initialize
{
    [FSInspectorPane registerInspectorPane:self];
}


- (NSString*)paneNibName
{
    return @"NoSelectionInspector";
}


- (NSString*)paneIdentifier
{
    return @"NoSelection";
}

@end
