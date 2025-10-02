/*
 Project: Graphos
 GRTextEditorView.h

 Copyright (C) 2000-2012 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GRTextEditorView : NSView
{
  NSView *controlsView;
  NSScrollView *scrollView;
  NSTextField *fontField;
  NSButton *chooseFontButton;
    NSPopUpButton *fontsPopUp;
    NSTextField *sizeField;
    NSText *theText;
    NSButton *leftButt, *centerButt, *rightButt, *cancelButt, *okButt;
    int result;

    NSTextAlignment textAlignment;
    NSFont *font;
    int fontSize;
    float parSpace;
}

- (id)initWithFrame:(NSRect)frameRect
         withString:(NSString *)string
         attributes:(NSDictionary *)attributes;

- (void)setFirstResponder;

- (void)changeTextAlignment:(id)sender;

- (void) updateFontPreview:(NSTextField *)previewField :(NSFont *)font;

- (void)okCancelPressed:(id)sender;

- (NSString *)textString;

- (NSDictionary *)textAttributes;

- (int)result;

@end
