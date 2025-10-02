//
//  FSTableView+Scrolling.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//                2010-2012 FRee Software Foundation
//
//  $Id: FSTableView+Scrolling.m,v 1.2 2012/01/25 09:35:32 rmottola Exp $

#import "FlexiSheet.h"

@interface _FSScrollView : NSScrollView
// almost empty subclass, just needed to overwrite -reflectScrolledClipView:
@end


@implementation _FSScrollView

- (void)reflectScrolledClipView:(NSClipView *)cView
{
    [super reflectScrolledClipView:cView];
    [[self superview] performSelector:@selector(reflectScrolledDataTable)];
}

@end


@implementation FSTableView (Scrolling)

- (void)reflectScrolledDataTable
{
    NSRect vRect;

    vRect = [(NSClipView*)[[_dataSV documentView] superview] documentVisibleRect];
    [_topClip scrollToPoint:NSMakePoint(vRect.origin.x, 0)];
    [_sideClip scrollToPoint:NSMakePoint(0, vRect.origin.y)];
}


- (void)scrollItemSelectionToVisible
{
    NSArray      *headers;
    NSRect        rect;
    int           index = 0;
    int           pos = 0;     // Position of selection
    int           len = 0;     // Pixel length of selection
    FSKeyRange   *range;
    NSRange       ir;

    if ((range = [self selectedColumnItems]))
      {
        headers = [dataSource topHeadersForTableView:self];
        index = [headers indexOfObject:[range header]];
        ir = [range keyIndexRange];
        if (index < _nHTop-1) {
            pos = 0;
            len = 1;
            while (++index < _nHTop) {
                len *= [[self _hloTop:index] horizontalSize].width;
            }
            pos = ir.location * len;
            len *= ir.length;
        } else {
            FSHeaderLayout *hlo = [self _hloTop:-1];
            index = 0;
            while (index < ir.location) {
                pos += [hlo widthAtIndex:index];
                index++;
            }
            while (ir.length--) {
                len += [hlo widthAtIndex:index+ir.length];
            }
        }
        rect = [(NSClipView*)[[_dataSV documentView] superview] documentVisibleRect];
        rect.origin.x = pos;
        rect.size.width = len;
        [_dataMatrix scrollRectToVisible:rect];
        [self reflectScrolledDataTable];
      }
    else if ((range = [self selectedRowItems]))
      {
        headers = [dataSource sideHeadersForTableView:self];
        index = [headers indexOfObject:[range header]];
        ir = [range keyIndexRange];
        if (index < _nHSide-1) {
            pos = 0;
            len = 1;
            while (++index < _nHSide) {
                len *= [[self _hloSide:index] verticalSize].height;
            }
            pos = ir.location * len;
            len *= ir.length;
        } else {
            FSHeaderLayout *hlo = [self _hloSide:-1];
            index = 0;
            while (index < ir.location) {
                pos += [hlo heightAtIndex:index];
                index++;
            }
            while (ir.length--) {
                len += [hlo heightAtIndex:index+ir.length];
            }
        }
        rect = [(NSClipView*)[[_dataSV documentView] superview] documentVisibleRect];
        rect.origin.y = pos;
        rect.size.height = len;
        [_dataMatrix scrollRectToVisible:rect];
        [self reflectScrolledDataTable];
    } else {
        rect = [self rectForSelectionInDataMatrix];
        [_dataMatrix scrollRectToVisible:rect];
        [self reflectScrolledDataTable];
        [_dataMatrix setNeedsDisplayInRect:rect];
    }
    [self setNeedsDisplayInRect:rect];
}

@end
