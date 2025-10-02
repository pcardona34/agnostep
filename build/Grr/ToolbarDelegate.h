/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009  GNUstep Application Team
                       Riccardo Mottola

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
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

/**
 * This must be implemented by any toolbar delegate.
 * Components may choose to implement this to provide toolbar items.
 */
@protocol ToolbarDelegate <NSObject>

- (NSToolbarItem*)toolbar: (NSToolbar*)toolbar
    itemForItemIdentifier: (NSString*)itemIdentifier
willBeInsertedIntoToolbar: (BOOL)flag;
// required method
- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*)toolbar;
// required method
- (NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar*)toolbar;

@end
