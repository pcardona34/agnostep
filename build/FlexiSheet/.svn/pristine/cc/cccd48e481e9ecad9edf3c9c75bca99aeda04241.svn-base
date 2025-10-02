//
//  SLOutlineView.m
//
//  Created by Stefan Leuker on 17-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: SLOutlineView.m,v 1.1 2008/10/28 13:10:32 hns Exp $

#import "SLOutlineView.h"
#import <AppKit/AppKit.h>

@implementation SLOutlineView

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

//warning   SLOutlineView needs fix for expanded group leek!

- (void)textDidEndEditing:(NSNotification *)notification;
{
    // This is ugly, but just about the only way to do it. NSTableView is determined to select and edit something else, even the text field that it just finished editing, unless we mislead it about what key was pressed to end editing.
    NSMutableDictionary *newUserInfo;
    NSNotification *newNotification;

    newUserInfo = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
    [newUserInfo setObject:[NSNumber numberWithInt:0] forKey:@"NSTextMovement"];
    newNotification = [NSNotification notificationWithName:[notification name]
                                                    object:[notification object]
                                                  userInfo:newUserInfo];
    [super textDidEndEditing:newNotification];

    // For some reason we lose firstResponder status when when we do the above.
    [[self window] makeFirstResponder:self];
}

- (id)parentItemForItem:(id)child;
{
    int row = [self rowForItem:child];
    return [self parentItemForRow:row indentLevel:[self levelForRow:row] child:NULL];
}

- (id)parentItemForRow:(int)row child:(unsigned int *)childIndexPointer;
{
    int originalLevel;

    originalLevel = [self levelForRow:row];
    return [self parentItemForRow:row indentLevel:originalLevel child:childIndexPointer];
}

- (id)parentItemForRow:(int)row indentLevel:(int)childLevel child:(unsigned int *)childIndexPointer;
{
    unsigned int childIndex;

    childIndex = 0;

    while (row-- >= 0) {
        int currentLevel;

        currentLevel = [self levelForRow:row];
        if (currentLevel < childLevel) {
            if (childIndexPointer)
                *childIndexPointer = childIndex;
            return [self itemAtRow:row];
        } else if (currentLevel == childLevel)
            childIndex++;
    }
    if (childIndexPointer)
        *childIndexPointer = childIndex;
    return nil;
}

@end
