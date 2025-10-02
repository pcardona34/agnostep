//
//  FSFunctionHelp.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 17-OCT-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSFunctionHelp.m,v 1.2 2014/01/26 09:23:52 buzzdee Exp $

#import "FSFunctionHelp.h"
#import "FSFunction.h"
#import "FSOperator.h"
#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>

@implementation FSFunctionHelp

- (void)_getNames
{
    int row = [groups selectedRowInColumn:0];
    if (row == 0) {
        [fNames release];
        fNames = [[FSOperator allOperatorSymbols] retain];
    } else {
        NSString *groupName = [[FSFunction allGroupNames] objectAtIndex:row-1];
        [fNames release];
        fNames = [[FSFunction allFunctionNamesInGroup:groupName] retain];        
    }
}

- (void)showPanel:(id)sender
{
    if (helpView == nil) {
        [NSBundle loadNibNamed:@"Functions" owner:self];
        [groups reloadColumn:0];
        [groups selectRow:0 inColumn:0];
        [self _getNames];
    }
    [[helpView window] orderFront:sender];
}

- (void)selectGroup:(id)sender
{
    [self _getNames];
    [functions reloadColumn:0];
}

- (void)selectFunction:(id)sender
{
    int       row = [sender selectedRowInColumn:0];
    NSString *name = (row >= 0)?[fNames objectAtIndex:row]:@"<no selection>";
    Class     class = [FSFunction functionClassForName:name];

    if (class == nil)
    {
        class = [FSOperator operatorClassForSymbol:name];
    }
    
    if (class == nil)
    {
        [[helpView mainFrame] loadHTMLString:@"Nothing selected" baseURL:nil];
    }
    else
    {
        [[helpView mainFrame] loadHTMLString:[class htmlHelpData] baseURL:nil];
    }
}

- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
    if (sender == groups) {
        return [[FSFunction allGroupNames] count]+1;
    } else
    if (sender == functions) {
        return [fNames count];
    }
    return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    [cell setLeaf:YES];
    if (sender == groups) {
        if (row == 0) {
            [cell setStringValue:@"Operators"];
        } else {
            [cell setStringValue:[[FSFunction allGroupNames] objectAtIndex:row-1]];
        }
    } else
    if (sender == functions) {
        [cell setStringValue:[fNames objectAtIndex:row]];
    }
    [cell setLoaded:YES];
}

@end
