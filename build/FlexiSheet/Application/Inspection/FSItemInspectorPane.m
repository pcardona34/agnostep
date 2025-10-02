//
//  FSItemInspectorPane.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 15-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSItemInspectorPane.m,v 1.1 2008/10/28 13:10:29 hns Exp $

#import "FSItemInspectorPane.h"

@implementation FSItemInspectorPane

+ (void)initialize
{
    [FSInspectorPane registerInspectorPane:self];
}


- (NSString*)paneNibName
{
    return @"ItemInspector";
}


- (NSString*)inspectorName
{
    return @"Item";
}


- (NSString*)paneIdentifier
{
    return @"Item";
}


- (void)updateWithSelection:(id<FSInspectable>)selection
{
    if ([selection conformsToProtocol:@protocol(FSItem)]) {
        item = (id<FSItem>)selection;

        [labelField setStringValue:[item label]];
        if ([item table]) {
            [tableText setStringValue:[[item table] name]];
        } else {
            [tableText setStringValue:@""];
        }
        if ([item group]) {
            [groupText setStringValue:[[item group] label]];
            [groupButton setEnabled:YES];
        } else {
            [groupText setStringValue:@""];
            [groupButton setEnabled:NO];
        }
    } else {
        item = nil;

        [labelField setStringValue:@"No selection"];
        [tableText setStringValue:@""];
        [tableButton setEnabled:NO];
        [groupText setStringValue:@""];
        [groupButton setEnabled:NO];
    }
}


- (void)setItemLabel:sender
{
    [item setLabel:[sender stringValue]];
}


- (IBAction)inspectGroup:sender
{
    if ([item group]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FSSelectionDidChangeNotification
                                                           object:[item group]];
    }
}


- (IBAction)inspectTable:sender
{
        [[NSNotificationCenter defaultCenter] postNotificationName:FSSelectionDidChangeNotification
                                                           object:[item table]];
}

@end
