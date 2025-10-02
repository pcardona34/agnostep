/*
 Project: Graphos
 GRTextEditorView.m

 Copyright (C) 2000-2017 GNUstep Application Project

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



#import "GRTextEditorView.h"

@implementation GRTextEditorView

- (id)initWithFrame:(NSRect)frameRect
         withString:(NSString *)string
         attributes:(NSDictionary *)attributes
{
  self = [super initWithFrame: frameRect];
  if(self)
    {
      NSString *firstStr;
      NSFont *f;
      NSParagraphStyle *pstyle;
    
      controlsView = [[NSView alloc] initWithFrame: NSMakeRect(0, 270, 500, 40)];
      [controlsView setAutoresizingMask: ~NSViewMaxYMargin & ~NSViewHeightSizable];

      fontField = [[NSTextField alloc] initWithFrame: NSMakeRect(10, 10, 190, 26)];
      [fontField setEditable:NO];
      [controlsView addSubview: fontField];

      chooseFontButton = [[NSButton alloc] initWithFrame: NSMakeRect(210, 10, 28, 20)];
      [chooseFontButton setTitle:@"..."];
      [chooseFontButton setTarget: self];
      [chooseFontButton setAction: @selector(chooseFont:)];
      [controlsView addSubview: chooseFontButton];
      
        leftButt = [[NSButton alloc] initWithFrame: NSMakeRect(255, 10, 20, 20)];
        [leftButt setButtonType: NSOnOffButton];
        [leftButt setImage: [NSImage imageNamed:@"txtAlignLeft.tiff"]];
        [leftButt setImagePosition: NSImageOnly];
        [leftButt setTarget: self];
        [leftButt setAction: @selector(changeTextAlignment:)];
        [controlsView addSubview: leftButt];

        centerButt = [[NSButton alloc] initWithFrame: NSMakeRect(285, 10, 20, 20)];
        [centerButt setButtonType: NSOnOffButton];
        [centerButt setImage: [NSImage imageNamed:@"txtAlignCenter.tiff"]];
        [centerButt setImagePosition: NSImageOnly];
        [centerButt setTarget: self];
        [centerButt setAction: @selector(changeTextAlignment:)];
        [controlsView addSubview: centerButt];

        rightButt = [[NSButton alloc] initWithFrame: NSMakeRect(315, 10, 20, 20)];
        [rightButt setButtonType: NSOnOffButton];
        [rightButt setImage: [NSImage imageNamed:@"txtAlignRight.tiff"]];
        [rightButt setImagePosition: NSImageOnly];
        [rightButt setTarget: self];
        [rightButt setAction: @selector(changeTextAlignment:)];
        [controlsView addSubview: rightButt];

        cancelButt = [[NSButton alloc] initWithFrame: NSMakeRect(350, 5, 80, 30)];
        [cancelButt setButtonType: NSMomentaryLight];
#if defined(__APPLE__)
        [cancelButt setBezelStyle:NSRoundedBezelStyle];
#endif
        [cancelButt setTitle: @"Cancel"];
        [cancelButt setTarget: self];
        [cancelButt setAction: @selector(okCancelPressed:)];
        [controlsView addSubview: cancelButt];

        okButt = [[NSButton alloc] initWithFrame: NSMakeRect(430, 5, 60, 30)];
        [okButt setButtonType: NSMomentaryLight];
#if defined(__APPLE__)
        [okButt setBezelStyle:NSRoundedBezelStyle];
#endif
        [okButt setTitle: @"Ok"];
        [okButt setTarget: self];
        [okButt setAction: @selector(okCancelPressed:)];
        [controlsView addSubview: okButt];

        if(attributes)
	  {
            firstStr = [NSString stringWithString: string];
            f = [attributes objectForKey: NSFontAttributeName];
            fontSize = (int)[f pointSize];
	    font = f;
            pstyle = [attributes objectForKey: NSParagraphStyleAttributeName];
            parSpace = [pstyle paragraphSpacing];
            textAlignment = [pstyle alignment];
            if(textAlignment == NSLeftTextAlignment)
                [leftButt setState: NSOnState];
            if(textAlignment == NSCenterTextAlignment)
                [centerButt setState: NSOnState];
            if(textAlignment == NSRightTextAlignment)
                [rightButt setState: NSOnState];

	  }
	else
	  {
            firstStr = @"New Text";
            textAlignment = NSLeftTextAlignment;
            [leftButt setState: NSOnState];
            fontSize = 12;
	    font = [NSFont systemFontOfSize:fontSize];
            pstyle = [NSMutableParagraphStyle defaultParagraphStyle];
            parSpace = [pstyle paragraphSpacing];
        }
        [self addSubview: controlsView];

        scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 500, 260)];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setAutoresizingMask: NSViewHeightSizable];

        theText = [[NSText alloc] initWithFrame: NSMakeRect(20, 0, 480, 250)];
        [theText setAlignment: textAlignment];
        [theText setString: firstStr];
	[self updateFontPreview:fontField :font];
        [scrollView setDocumentView: theText];
	[theText setFont: font];
	[theText setNeedsDisplay: YES];

        [self addSubview: scrollView];
    }
    return self;
}

- (void) dealloc
{
    [leftButt release];
    [centerButt release];
    [rightButt release];
    [cancelButt release];
    [okButt release];
    [chooseFontButton release];
    [fontField release];
    [controlsView release];
    [theText release];
    [scrollView release];
    [super dealloc];
}

/* we accept to be the first responder
   we want to be the first responder to handle changeFont from the FontPanel
*/
- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void)setFirstResponder
{
  [[self window] makeFirstResponder:self];
}


- (void)changeTextAlignment:(id)sender
{
    NSButton *b = (NSButton *)sender;
    if(b == leftButt) {
        textAlignment = NSLeftTextAlignment;
        [leftButt setState: NSOnState];
        [centerButt setState: NSOffState];
        [rightButt setState: NSOffState];
    } else if(b == centerButt) {
        textAlignment = NSCenterTextAlignment;
        [leftButt setState: NSOffState];
        [centerButt setState: NSOnState];
        [rightButt setState: NSOffState];
    } else if(b == rightButt) {
        textAlignment = NSRightTextAlignment;
        [leftButt setState: NSOffState];
        [centerButt setState: NSOffState];
        [rightButt setState: NSOnState];
    }

    [theText setAlignment: textAlignment];
    [theText setNeedsDisplay: YES];
}

- (IBAction) chooseFont:(id)sender
{
  NSFontManager *fontMgr;

  fontMgr = [NSFontManager sharedFontManager];

  [fontMgr setSelectedFont: font  isMultiple:NO];
  [fontMgr setAction:@selector(changeFontAction:)];
  [fontMgr setDelegate:self];
  [fontMgr orderFrontFontPanel: self];
}

- (void) changeFontAction:(id)sender
{
  NSFont *newFont;

  newFont = [sender convertFont: [fontField font]];

  if (newFont != nil)
    {
      [self updateFontPreview:fontField :newFont];
      font = newFont;
      [font pointSize];
      [theText setFont: font];
      [theText setNeedsDisplay: YES];
    }
}

- (void) updateFontPreview:(NSTextField *)previewField :(NSFont *)aFont
{
  NSString *fontName;

  fontName = [aFont displayName];
  if (fontName)
    {
      [fontField setFont:[NSFont fontWithName: fontName size:12.0]];
      [previewField setStringValue: fontName];
      font = aFont;
    }
  else
    {
      [fontField setFont:[NSFont systemFontOfSize: -1]];
      [fontField setStringValue: @"(unset)"];
    }

}


- (void)okCancelPressed:(id)sender
{
    if(sender == okButt)
        result = NSAlertDefaultReturn;
    else
        result = NSAlertAlternateReturn;
    [[self window] orderOut: self];
    [[NSApplication sharedApplication] stopModal];
}

- (NSString *)textString
{
    return [theText string];
}

- (NSDictionary *)textAttributes
{
  NSDictionary *dict;
  NSMutableParagraphStyle *style;

  style = [[NSMutableParagraphStyle alloc] init];
  [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
  [style setAlignment: textAlignment];
  [style setParagraphSpacing: parSpace];
  dict = [NSDictionary dictionaryWithObjectsAndKeys:
			 [theText font], NSFontAttributeName,
		       style, NSParagraphStyleAttributeName, nil];
  [style release];
  return dict;
}

- (int)result
{
    return result;
}

@end

