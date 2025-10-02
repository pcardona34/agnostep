//
//  FSCellInspectorPane.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSCellInspectorPane.m,v 1.2 2014/01/26 09:23:52 buzzdee Exp $

#import "FlexiSheet.h"
#import "FSCellInspectorPane.h"
#import <FSInspection.h>
#import <FSTableView.h>
#import <FSCellStyle.h>


@implementation FSCellInspectorPane

+ (void)initialize
{
    [FSInspectorPane registerInspectorPane:self];
}


- (NSString*)paneNibName
{
    return @"Styles";
}


- (NSString*)inspectorName
{
    return @"Cell";
}


- (NSString*)paneIdentifier
{
    return @"Cell";
}


- (void)_reflectStyleInUI
{
    FSTableView *tv = [self activeTableView];
    FSSelection *selection = [tv selection];
    FSCellStyle *style = [tv styleForSelection:selection];
    NSFont      *font = [style font];
    NSColor     *bgColor = [style backgroundColor];
    NSColor     *negColor = [style negativeColor];

    [textPreview setFont:font];
    [textPreview setStringValue:[NSString stringWithFormat:@"%@ %1.0fpt",
        [font fontName], [font pointSize]]];

    if ([NSFontPanel sharedFontPanelExists]) {
        [[NSFontPanel sharedFontPanel] setPanelFont:font isMultiple:YES];
    }

    [foregroundColorWell setColor:[style foregroundColor]];
    [foregroundColorWell setEnabled:YES];

    if (bgColor) {
        [backgroundColorWell setColor:bgColor];
    } else {
        [backgroundColorWell setColor:[NSColor clearColor]];
    }
    [backgroundColorWell setEnabled:YES];

    if (negColor) {
        [negativeColorWell setColor:negColor];
        [negativeColorWell setEnabled:YES];
        [negativeColorSwitch setState:1];
    } else {
        [negativeColorWell setColor:[NSColor redColor]];
        [negativeColorWell setEnabled:NO];
        [negativeColorSwitch setState:0];
    }
    [negativeColorSwitch setEnabled:YES];
    
    [alignmentMatrix selectCellWithTag:[style alignment]];
    
    if ([selection isSingleSelection]) {
        [defaultButton setTitle:@"Set as Default"];
        [defaultButton setEnabled:YES];
    } else {
        [defaultButton setTitle:@"Multiple cells"];
        [defaultButton setEnabled:NO];
    }
}


- (void)_deactivateUI
{
    [defaultButton setTitle:@"Not inspectable"];
    [defaultButton setEnabled:NO];
    [foregroundColorWell setEnabled:NO];
    [backgroundColorWell setEnabled:NO];
    [negativeColorSwitch setEnabled:NO];
    [negativeColorWell setEnabled:NO];
    [alignmentMatrix deselectAllCells];
}


- (void)runFontSelectPanel:(id)sender
{
    NSFontPanel  *fontPanel = [NSFontPanel sharedFontPanel];
    NSFont       *font = nil;

    [fontPanel setEnabled:YES];
    [fontPanel setPanelFont:font isMultiple:(font == nil)];
    [fontPanel orderFront:sender];
}


- (void)changeFont:(id)sender
{
    FSSelection *selection = [[self activeWorksheet] selection];
    if ([selection conformsToProtocol:@protocol(FSInspectableStyle)]) {
        NSFontPanel *fontPanel = [NSFontPanel sharedFontPanel];
        NSFont      *font = [fontPanel panelConvertFont:[(id<FSInspectableStyle>)selection font]];

        //[(id<FSInspectableStyle>)selection setFont:font];
        [[self activeTableView] setNeedsDisplay:YES];
        [fontPanel setPanelFont:font isMultiple:(font != nil)];
    }
    [self updateWithSelection:selection];
}


- (void)updateWithSelection:(id<FSInspectable>)newSelection
{    
    if ([newSelection isKindOfClass:[FSSelection class]]) {        
        [self _reflectStyleInUI];
    } else {
        [self _deactivateUI];
    }
}


- (void)setForegroundColor:(id)sender
{
    //[style setForegroundColor:[foregroundColorWell color]];
    [[self activeTableView] setNeedsDisplay:YES];
}


- (void)setBackgroundColor:(id)sender
{
    //[style setBackgroundColor:[backgroundColorWell color]];
    [[self activeTableView] setNeedsDisplay:YES];
}


- (void)setNegativeColor:(id)sender
{
    if ([negativeColorSwitch state] == 1) {
        //[style setNegativeColor:[negativeColorWell color]];
        [negativeColorWell setEnabled:YES];
    } else {
        //[style setNegativeColor:nil];
        [negativeColorWell setEnabled:NO];
    }
    [[self activeTableView] setNeedsDisplay:YES];
}


- (void)setTextAlignment:(id)sender
{
    //[style setAlignment:[[alignmentMatrix selectedCell] tag]];
    [[self activeTableView] setNeedsDisplay:YES];
}


- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
    return 0;
}


- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    [cell setLeaf:YES];
    [cell setLoaded:YES];
    [cell setStringValue:@"Default format"];
}

@end
