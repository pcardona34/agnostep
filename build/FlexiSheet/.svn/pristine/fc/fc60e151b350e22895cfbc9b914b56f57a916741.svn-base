//
//  FSSortPanelController.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 27-APR-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSSortPanelController.m,v 1.1 2008/10/14 15:03:47 hns Exp $

#import "FlexiSheet.h"
#import "FSSortPanelController.h"

@implementation FSSortPanelController

+ (FSSortPanelController*)sortPanelController
{
    return [[[self alloc] init] autorelease];
}


- (void)dealloc
{
    [_table release];
    [super dealloc];
}


- (void)_setup
{
    [categoryPopup removeAllItems];
    [valueCatPopup removeAllItems];
    [sortFirstPopup removeAllItems];
    [sortSecondPopup removeAllItems];
    [sortThirdPopup removeAllItems];
    if (_table) {
        NSArray  *headers = [_table headers];
        NSString *item;
        int       index;
        
        for (index = 0; index < [headers count]; index++) {
            item = [[headers objectAtIndex:index] label];
            [categoryPopup addItemWithTitle:item];
        }
        [categoryPopup setEnabled:YES];
        [self selectCategory:nil];
        [self selectSortByValue:nil];
        [sortButton setEnabled:YES];
    } else {
        [categoryPopup addItemWithTitle:@"No categories"];
        [categoryPopup setEnabled:NO];
        [sortButton setEnabled:NO];        
    }
}


- (void)setupWithTable:(FSTable*)table
{
    [_table release];
    _table = [table retain];
}


- (void)selectCategory:(id)sender
{
    NSString   *sortHeader = [categoryPopup titleOfSelectedItem];
    NSArray    *headers = [_table headers];
    NSString   *oldSelection = [valueCatPopup titleOfSelectedItem];
    int         index;
    NSString   *item;

    [valueCatPopup removeAllItems];
    for (index = 0; index < [headers count]; index++) {
        item = [[headers objectAtIndex:index] label];
        if ([sortHeader isEqualToString:item] == NO) {
            [valueCatPopup addItemWithTitle:item];
        }
    }
    [valueCatPopup selectItemWithTitle:oldSelection];
    [valueCatPopup synchronizeTitleAndSelectedItem];

    if ([sortByValue state]) {
        if ([[valueCatPopup titleOfSelectedItem] isEqualToString:oldSelection] == NO) {
            [self selectValueCategory:nil];
        }
    }
}


- (void)selectValueCategory:(id)sender
{
    FSHeader *header = [_table headerWithName:[valueCatPopup titleOfSelectedItem]];
    NSArray  *keys = [header keys];
    NSString *item;
    int       index;

    [sortFirstPopup removeAllItems];
    [sortFirstPopup addItemWithTitle:@"< choose >"];
    [sortSecondPopup removeAllItems];
    [sortSecondPopup addItemWithTitle:@"< choose >"];
    [sortThirdPopup removeAllItems];
    [sortThirdPopup addItemWithTitle:@"< choose >"];

    for (index = 0; index < [keys count]; index++) {
        item = [[keys objectAtIndex:index] label];
        [sortFirstPopup addItemWithTitle:item];
        [sortSecondPopup addItemWithTitle:item];
        [sortThirdPopup addItemWithTitle:item];
    }
}


- (void)selectSortByValue:(id)sender
{    
    if ([sortByValue state] == 0) {
        // Sort by name
        [valueCatPopup setEnabled:NO];
        [sortFirstPopup setEnabled:YES];
        [sortFirstPopup removeAllItems];
        [sortFirstPopup addItemWithTitle:@"by name"];
        [sortSecondPopup setEnabled:NO];
        [sortSecondPopup removeAllItems];
        [sortThirdPopup setEnabled:NO];
        [sortThirdPopup removeAllItems];
        [reverseFirstPopup setEnabled:YES];
        [reverseSecondPopup setEnabled:NO];
        [reverseThirdPopup setEnabled:NO];
    } else {
        // Sort by value
        [self selectValueCategory:nil];
        [valueCatPopup setEnabled:YES];
        [sortFirstPopup setEnabled:YES];
        [sortSecondPopup setEnabled:YES];
        [sortThirdPopup setEnabled:YES];
        [reverseFirstPopup setEnabled:YES];
        [reverseSecondPopup setEnabled:YES];
        [reverseThirdPopup setEnabled:YES];
    }
}


- (void)selectFirstCriteria:(id)sender
{
}


- (void)selectSecondCriteria:(id)sender
{
}


- (void)selectThirdCriteria:(id)sender
{
}


- (void)runSortSheetForWindowController:(FSWindowController*)wc
{
    if (sortPanel == nil) {
        [NSBundle loadNibNamed:@"SortingItems" owner:self];
    }

    [self setupWithTable:[wc table]];
    [self _setup];
    
    [NSApp beginSheet:sortPanel modalForWindow:[wc window] modalDelegate:self
       didEndSelector:@selector(sortSheetDidEnd:returnCode:contextInfo:) contextInfo:wc];
}


- (void)sortSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(FSWindowController*)wc
{
    if (returnCode == NSAlertDefaultReturn) {
        FSHeader *header = [_table headerWithName:[categoryPopup titleOfSelectedItem]];
        
        if ([sortByValue state] == 0) {
            // Sort by name
            [header sortItemsByName:[[reverseFirstPopup selectedItem] tag]];
        } else {
            // Sort by value
            // not implemented
        }
    }
}


- (void)endSheetFromControl:(id)sender
{
    [NSApp endSheet:[sender window] returnCode:[sender tag]];
    [[sender window] orderOut:sender];
}


@end
