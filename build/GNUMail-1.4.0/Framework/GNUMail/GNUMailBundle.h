/*
**  GNUMailBundle.h
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_GNUMailBundle
#define _GNUMail_H_GNUMailBundle

#import <AppKit/AppKit.h>

enum ViewingViewType 
{
  ViewingViewTypeToolbar,
  ViewingViewTypeHeaderCell
};

@class NSArray;
@class NSString;
@class NSTextView;

@class CWMessage;
@class CWMimeBodyPart;

@class PreferencesModule;

@protocol GNUMailBundle <NSObject>
//
//
//
- (id) initWithOwner: (id) theOwner;
- (void) dealloc;

+ (id) singleInstance;


//
// access / mutation methods
//
- (NSString *) name;
- (NSString *) description;
- (NSString *) version;

- (void) setOwner: (id) theOwner;           // You must not retain the theOwner.

//
// UI elements
//
- (BOOL) hasPreferencesPanel;               // YES/NO. If YES, preferencesModule must not return nil.
- (PreferencesModule *) preferencesModule;  // the panel in the pref panel and its controller



- (BOOL) hasComposeViewAccessory;                     // If the bundle provide a compose/viewing accessory 
- (id) composeViewAccessory;                          // view, it MUST return yes to hasComposeViewAccessory
- (void) composeViewAccessoryWillBeRemovedFromSuperview: (NSView *) theView;

                                                      // or hasViewingViewAccessory. the composeViewAccessory 
- (BOOL) hasViewingViewAccessory;                     // and the viewingViewAccessory MUST return a different
- (id) viewingViewAccessory;                          // instance on each call. setCurrentSuperview will
- (enum ViewingViewType) viewingViewAccessoryType;
- (void) viewingViewAccessoryWillBeRemovedFromSuperview: (id) theView;

                                                    // be called each time one of the compose/viewing 
- (void) setCurrentSuperview: (NSView *) theView;   // accessory view is 'the current one'. You must NOT
                                                    // retain the superview.

- (NSArray *) submenuForMenu: (NSMenu *) theMenu;   // Called so that the bundle can return a list of its own
                                                    // submenus for the predefined menus in GNUMail
- (NSArray *) menuItemsForMenu: (NSMenu *) theMenu; // Called so that the bundle can return a list of menu items
                                                    // for its own menus or the prefedefined
                                                    // menus in GNUMail

//
// The following methods are called if they are implemented. They are used
// by the bundle to be informed when Mail-related operations are 
// currently active.
//
- (CWMimeBodyPart *) bodyWillBeEncoded: (CWMimeBodyPart *) theBodyPart
                            forMessage: (CWMessage *) theMessage;

- (CWMimeBodyPart *) bodyWasEncoded: (CWMimeBodyPart *) theBodyPart
                         forMessage: (CWMessage *) theMessage;

- (CWMessage *) messageWasEncoded: (CWMessage *) theMessage;

- (CWMimeBodyPart *) bodyWillBeDecoded: (CWMimeBodyPart *) theBodyPart
                            forMessage: (CWMessage *) theMessage;

- (CWMimeBodyPart *) bodyWasDecoded: (CWMimeBodyPart *) theBodyPart
                         forMessage: (CWMessage *) theMessage;

- (void) messageWillBeDisplayed: (CWMessage *) theMessage
                         inView: (NSTextView *) theTextView;

- (void) messageWasDisplayed: (CWMessage *) theMessage
                      inView: (NSTextView *) theTextView;

@end

#endif // _GNUMail_H_GNUMailBundle
