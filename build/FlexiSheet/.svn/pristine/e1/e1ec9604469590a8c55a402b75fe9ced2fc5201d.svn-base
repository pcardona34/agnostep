//
//  FSInspectorPane.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 15-DEC-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSInspectorPane.m,v 1.1 2008/10/28 13:10:29 hns Exp $

#import "FlexiSheet.h"
#import "FSInspectorPane.h"

static NSMutableDictionary *__FSInspectorPaneSubclasses;

@implementation FSInspectorPane
/*" An FSInspectorPane is the abstract superclass for all
    UI element controllers that handle Inspector logic.
    An inspector pane represents one tab or page in the
    inspector window.  "*/

+ (void)dummy
{
    // All subclasses call this method once while initializing.
    // It is a real no-brainer.
}

+ (void)initialize
{
    if (__FSInspectorPaneSubclasses == nil) {
        __FSInspectorPaneSubclasses = [[NSMutableDictionary alloc] init];
    }
    [[self subclasses] makeObjectsPerformSelector:@selector(dummy)];
}


+ (void)registerInspectorPane:(Class)aPaneClass
{
    FSInspectorPane *aPane = [[aPaneClass alloc] init];
    NSString *identifier = [aPane paneIdentifier];
    if ([__FSInspectorPaneSubclasses objectForKey:identifier] == nil) {
        [__FSInspectorPaneSubclasses setObject:aPane forKey:identifier];
    } else {
        [FSLog logError:@"Inspector pane for identifier '%@' is already registered.", identifier];
    }
    [aPane release];
}


+ (NSArray*)allPaneIdentifiers
{
    return [__FSInspectorPaneSubclasses allKeys];
}


+ (FSInspectorPane*)inspectorPaneForIdentifier:(NSString*)identifier
{
    return [__FSInspectorPaneSubclasses objectForKey:identifier];
}


- (NSString*)paneNibName
{
    [NSException raise:@"FSInspectorPaneSubclassingException"
                format:@"-[FSInspectorPane paneNibName] must be overwritten!"];
    return nil;
}


- (NSString*)inspectorName
{
    return @"Nothing";
}


- (NSString*)paneIdentifier
{
    [NSException raise:@"FSInspectorPaneSubclassingException"
        format:@"-[FSInspectorPane paneIdentifier] must be overwritten!"];
    return nil;
}


- (NSView*)paneView
{
    if (paneView == nil) {
        [NSBundle loadNibNamed:[self paneNibName] owner:self];
        // Implement -awakeFromNib to initialize if needed.
    }
    return paneView;
}


- (FSWorksheet*)activeWorksheet
{
    return _activeWorksheet;
}


- (void)setActiveWorksheet:(FSWorksheet*)ws
{
    if (ws != _activeWorksheet) {
        [_activeWorksheet release];
        _activeWorksheet = [ws retain];
    }
}


- (FSTableView*)activeTableView
{
    return _activeTableView;
}


- (void)setActiveTableView:(FSTableView*)tv
{
    if (tv != _activeTableView) {
        [_activeTableView release];
        _activeTableView = [tv retain];
    }
}


- (void)updateWithSelection:(id<FSInspectable>)selection
/*" Subclasses implement this method to update the UI
    with whatever settings they can derive from the
    selection.

    See FSInspectabe."*/
{
}

@end
