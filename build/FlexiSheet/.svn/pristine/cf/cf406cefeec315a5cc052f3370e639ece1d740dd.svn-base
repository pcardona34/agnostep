//
//  FSInspection.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSInspection.h,v 1.2 2008/12/15 14:48:00 rmottola Exp $

#import <Foundation/Foundation.h>
#import "FSDocument.h"
#import "FSWindowController.h"
#import "FSTable.h"
#import "FSHeader.h"
#import "FSKey.h"
#import "FSKeySet.h"
#import "FSValue.h"
#import "FSSelection.h"


@protocol FSInspectable <NSObject>
/*" The FSInspectable protocol is the bare minimum a model
object has to implement to be inspectable.
There is just one method: paneIdentifier, which returns the
ID for the FSInspectorPane that should handle inspection.
"*/

- (NSString*)paneIdentifier;

@end


@protocol FSInspectableStyle <NSObject>

- (NSColor*)lineColor;
- (NSColor*)foregroundColor;
- (NSColor*)backgroundColor;

- (NSFont*)font;
- (NSTextAlignment)alignment;

@end


@interface FSDocument (FSInspectable) <FSInspectable>
@end


@interface FSWindowController (FSInspectable) <FSInspectable>
@end


@interface FSTable (FSInspectable) <FSInspectable>
@end


@interface FSKeyGroup (FSInspectable) <FSInspectable>
@end


@interface FSKey (FSInspectable) <FSInspectable>
@end


@interface FSValue (FSInspectable) <FSInspectable>
@end


@interface FSSelection (InspectingAttributes) <FSInspectable>
@end


extern NSString* FSSelectionDidChangeNotification;
extern NSString* FSSelectionInfo;
extern NSString* FSWorksheetInfo;
extern NSString* FSTableviewInfo;
extern NSString* FSInspectorNeedsUpdateNotification;

