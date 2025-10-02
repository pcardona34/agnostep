//
//  FSCellInspectorPane.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSCellInspectorPane.h,v 1.1 2008/10/28 13:10:18 hns Exp $

#import <FSInspectorPane.h>

@interface FSCellInspectorPane : FSInspectorPane
{
    // Generic features
    IBOutlet NSButton           *defaultButton;
    
    // Format tab
    IBOutlet NSMatrix           *typeMatrix;
    IBOutlet NSButton           *negativeColorSwitch;
    IBOutlet NSColorWell        *negativeColorWell;
    IBOutlet NSBrowser          *formats;
    IBOutlet NSButton           *addFormatButton;
    IBOutlet NSButton           *removeFormatButton;
    
    // Attributes tab
    IBOutlet NSColorWell        *foregroundColorWell;
    IBOutlet NSColorWell        *backgroundColorWell;
    IBOutlet NSTextField        *textPreview;
    IBOutlet NSButton           *selectFont;

    // Style tab
    IBOutlet NSPopUpButton      *lineStylePopup;
    IBOutlet NSColorWell        *lineColorWell;
    IBOutlet NSMatrix           *alignmentMatrix;
}

- (void)runFontSelectPanel:(id)sender;

- (void)setForegroundColor:(id)sender;
- (void)setBackgroundColor:(id)sender;
- (void)setNegativeColor:(id)sender;
- (void)setTextAlignment:(id)sender;

@end
