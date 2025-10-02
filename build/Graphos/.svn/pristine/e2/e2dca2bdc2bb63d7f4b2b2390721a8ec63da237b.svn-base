/*
 Project: Graphos
 GRDocView.h

 Copyright (C) 2000-2019 GNUstep Application Project

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

#import "GRBezierPathEditor.h"

#ifndef ASSIGN
#define ASSIGN(object,value)     ({\
    id __value = (id)(value); \
        id __object = (id)(object); \
            if (__value != __object) \
            { \
                if (__value != nil) \
                { \
                    [__value retain]; \
                } \
                object = __value; \
                    if (__object != nil) \
                    { \
                        [__object release]; \
                    } \
            } \
})
#endif

@interface GRDocView : NSView
{
    NSMutableArray *objects, *delObjects;
    NSMutableArray *objectHistory;
    NSUInteger historyPointer;
    int edind;
    BOOL shiftclick, altclick, ctrlclick;

    NSRect pageRect, a4Rect, zmdRect;
    int zIndex;
    CGFloat zFactor;
    BOOL isDrawingForPrinting;
    NSCursor *cur;
}

- (id)initWithFrame:(NSRect)aRect;
- (NSDictionary *) objectDictionary;
- (BOOL)createObjectsFromDictionary:(NSDictionary *)dict;

/**
 * add a GRBezierPath
 */
- (void)addPath;

/**
 * add a GRBox
 */
- (void)addBox;

/**
 * add a GRCircle
 */
- (void)addCircle;

/**
 * add a GRText at the specified point
 */
- (void)addTextAtPoint:(NSPoint)p;

/**
 * make a copy of the objects invoking the object's duplicate method
 */
- (NSArray *)duplicateObjects:(NSArray *)objs andMoveTo:(NSPoint)p;

/**
 * update the view orientation and size according to the new print info object
 */
- (void)updatePrintInfo: (NSPrintInfo *)pi;

- (void)deleteSelectedObjects;
- (void)startDrawingAtPoint:(NSPoint)p;
- (void)selectObjectAtPoint:(NSPoint)p;
- (void)editPathAtPoint:(NSPoint)p;
- (void)editTextAtPoint:(NSPoint)p;

- (void)editSelectedText;

- (void)moveSelectedObjects:(NSArray *)objs startingPoint:(NSPoint)startp;

- (BOOL)moveControlPointOfEditor:(GRPathEditor *)editor toPoint:(NSPoint)pos;
- (BOOL)moveBezierHandleOfEditor:(GRBezierPathEditor *)editor toPoint:(NSPoint)pos;
- (IBAction)changePointsOfCurrentPathToSymmetric:(id)sender;
- (IBAction)changePointsOfCurrentPathToCusp:(id)sender;
- (IBAction)changePointsOfCurrentPathByOverlap:(id)sender;
- (IBAction)changePointsOfCurrentPathByExtract:(id)sender;
- (IBAction)deletePointsOfCurrentPath:(id)sender;
- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split;

- (NSDictionary *)selectionProperties;
- (void)setSelectionProperties: (NSDictionary *)properties;

- (IBAction)moveSelectedObjectsForward:(id)sender;
- (IBAction)moveSelectedObjectsToFront:(id)sender;
- (IBAction)moveSelectedObjectsBackward:(id)sender;
- (IBAction)moveSelectedObjectsToBack:(id)sender;
- (void)unselectOtherObjects:(GRDrawableObject *)anObject;
- (void)zoomOnPoint:(NSPoint)p zoomOut:(BOOL)isout;
- (void)zoomOnPoint:(NSPoint)p withFactor:(int)index;
- (void)movePageFromHandPoint:(NSPoint)handpos;
- (IBAction)zoom50:(id)sender;
- (IBAction)zoom100:(id)sender;
- (IBAction)zoom200:(id)sender;
- (IBAction)zoomFitPage:(id)sender;
- (IBAction)zoomFitWidth:(id)sender;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

- (void)saveCurrentObjects;
- (void)saveCurrentObjectsDeep;
- (void)backObjectHistory;
- (void)forwardObjectHistory;

- (void)verifyModifiersOfEvent:(NSEvent *)theEvent;

- (BOOL)shiftclick;
- (BOOL)altclick;
- (BOOL)ctrlclick;

@end
