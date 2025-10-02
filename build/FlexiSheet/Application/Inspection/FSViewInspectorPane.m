//
//  FSViewInspectorPane.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 16-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSViewInspectorPane.m,v 1.2 2014/01/26 09:23:52 buzzdee Exp $

#import "FSViewInspectorPane.h"


@implementation FSViewInspectorPane

+ (void)initialize
{
    [FSInspectorPane registerInspectorPane:self];
}


- (NSString*)paneNibName
{
    return @"ViewInspector";
}


- (NSString*)inspectorName
{
    return @"Worksheet";
}


- (NSString*)paneIdentifier
{
    return @"Worksheet";
}


- (void)updateWithSelection:(id<FSInspectable>)selection
{
    FSWorksheet *view = [self activeWorksheet];
    
    if (view != nil){
        NSString *doc = [(FSDocument*)[view document] displayName];

        [nameField setStringValue:[view name]];
        [nameField setEditable:YES];
        if (doc) {
            [documentField setStringValue:doc];
        } else {
            [documentField setStringValue:@""];
        }
        [comments setString:@""];
        [comments replaceCharactersInRange:NSMakeRange(0,0)
				   withRTF:[[view comment] dataUsingEncoding:NSUTF8StringEncoding]];
        [comments setEditable:YES];
    } else {
        [nameField setStringValue:@"Invalid object"];
        [nameField setEditable:NO];
        [documentField setStringValue:@"Not available"];
        [comments setString:@""];
        [comments setEditable:NO];
    }
}


- (void)setViewName:sender
{
    [[self activeWorksheet] setName:[sender stringValue]];
}


- (IBAction)inspectDocument:sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FSSelectionDidChangeNotification
                                                        object:[[self activeWorksheet] document]];
}


- (IBAction)inspectTable:sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FSSelectionDidChangeNotification
                                                        object:[[self activeWorksheet] table]];
}

@end


@implementation FSViewInspectorPane (TextDelegate)

- (void)textDidChange:(NSNotification *)notification
{
    NSRange everything = NSMakeRange(0, [[comments string] length]);
    [[self activeWorksheet] setComment:[comments RTFFromRange:everything]];
}

@end
