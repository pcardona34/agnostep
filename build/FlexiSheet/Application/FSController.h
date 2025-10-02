//
//  FSController.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSController.h,v 1.1 2008/10/14 15:03:44 hns Exp $

#import <AppKit/AppKit.h>

@class SLOutlineView, FSFunctionHelp, FSInspector;

@interface FSController : NSDocumentController {    
    FSFunctionHelp          *_functionHelp;
    IBOutlet FSInspector    *inspector;
    IBOutlet NSPanel        *docBrowser;
    IBOutlet SLOutlineView  *docOutline;
}

- (void)showSplash:(id)sender;

- (void)showFunctionHelp:(id)sender;

- (void)showInspector:(id)sender;

- (void)removeTableFromTableBrowser:(id)sender;

- (void)expandForWindow:(NSWindow*)window;

@end

extern NSString *FSShowInspectorPreference;     /*" boolean "*/
extern NSString *FSSaveCompressedPreference;    /*" boolean "*/
extern NSString *FSDefaultFontFacePreference;   /*" String "*/
extern NSString *FSDefaultFontSizePreference;   /*" Number "*/
