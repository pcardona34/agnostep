//
//  FSFormulaTable.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 11-FEB-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSFormulaTable.m,v 1.2 2014/01/26 09:23:53 buzzdee Exp $

#import "FlexiSheet.h"

@implementation FSFormulaTable

- (BOOL)needsDisplay;
{
    NSResponder *resp = nil;
    
    if ([[self window] isKeyWindow]) {
        resp = [[self window] firstResponder];
        if (resp == lastResp)
            return [super needsDisplay];
    } else if (lastResp == nil) {
        return [super needsDisplay];
    }
    shouldDrawFocusRing = ([resp isKindOfClass:[NSView class]] && [(NSView *)resp isDescendantOf:self]);
    lastResp = resp;
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    return YES;
}


- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if (shouldDrawFocusRing) {
        NSSetFocusRingStyle(NSFocusRingOnly);
        NSRectFill([self bounds]);
    }
}


- (BOOL)isEditing
{
    //NSLog(@"FSFormulaTable %@ editing", _isEditing?@"is":@"is not");
    return _isEditing;
}


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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FSSelectionDidChangeNotification
                                                  object:nil];
    _isEditing = NO;
    //NSLog(@"No longer editing.");
    [[[self window] windowController] setupTableToolbar];
}


- (void)editColumn:(NSInteger)columnIndex
	       row:(NSInteger)rowIndex
	 withEvent:(NSEvent *)theEvent
	    select:(BOOL)flag
{
    [super editColumn:columnIndex row:rowIndex withEvent:theEvent select:flag];
    _isEditing = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tableSelectionDidChange:)
                                                 name:FSSelectionDidChangeNotification
                                               object:nil];
    //NSLog(@"Begins editing.");
    [[[self window] windowController] setupFormulaToolbar];
}


- (void)tableSelectionDidChange:(NSNotification*)notification
{
    id   editor = [[self window] firstResponder];
    id   newSelection = [notification object];

    if ([editor isKindOfClass:[NSText class]] && [newSelection isKindOfClass:[FSSelection class]]) {
        NSString  *strg = [(FSSelection*)newSelection creatorString];
        NSRange    sel = [editor selectedRange];

        [editor replaceCharactersInRange:sel withString:strg];
        [editor setSelectedRange:NSMakeRange(sel.location, [strg length])];
    }
}


- (void)insertString:(NSString*)string
{
    id   editor = [[self window] firstResponder];

    if ([editor isKindOfClass:[NSText class]]) {
        NSRange    sel = [editor selectedRange];

        sel.location = sel.location+sel.length;
        sel.length = 0;
        //[editor setSelectedRange:sel];
        [editor replaceCharactersInRange:sel withString:string];
        sel.location += [string length];
        [editor setSelectedRange:sel];
    }
}


- (void)insertEqualSign:sender
{
    [self insertString:@" = "];
}


- (void)insertIfBlock:sender
{
    id   editor = [[self window] firstResponder];

    if ([editor isKindOfClass:[NSText class]]) {
        NSRange    sel = [editor selectedRange];
        NSRange    ins = sel;

        ins.length = 0;
        [editor replaceCharactersInRange:ins withString:@"if("];
        sel.location += 3;
        ins.location += 3+sel.length;
        [editor replaceCharactersInRange:ins withString:@", true, false)"];
        [editor setSelectedRange:sel];
    }
}


- (void)mouseDown:(NSEvent*)event
{
    if (([event clickCount] == 2) && ([self numberOfRows] == 0)) {
        if ([NSApp sendAction:@selector(insertItem:) to:nil from:nil])
            return;
    }
    [super mouseDown:event];
}

@end
