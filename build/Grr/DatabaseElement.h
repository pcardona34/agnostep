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

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>


/**
 * Send a notification with this name and a database element as the
 * object to make that database element get the focus. (It will get
 * selected in the outline view.)
 */
extern NSString* const DatabaseElementFocusRequestNotification;

@protocol DatabaseElement <NSObject>

/**
 * Returns the super element of this database element. Note that
 * top level elements will return nil here.
 */
-(id) superElement;

/**
 * Sets the super element for an element
 */
-(void) setSuperElement: (id) superElement;

/**
 * Archives the element and all its subelements to a plist-conformant
 * NSDictionary object. The "isa" key of the dictionary must have the
 * class name of the archiving object as a value. Don't forget to
 * overwrite this class name in each subclass when archiving to the
 * plist dictionary!
 */
-(NSMutableDictionary*) plistDictionary;

/**
 * Unarchives the element from a plist-conformant NSDictionary object.
 */
-(id) initWithDictionary: (NSDictionary*) aDictionary;

/**
 * Sets the name for the database element. This name is then
 * returned by the -description method.
 */
-(void) setName: (NSString*) aString;

@end


/**
 * Unarchives a database element from a plist dictionary. The plist dictionary
 * must have a "isa" key which indicates the class of the object to be unarchived.
 * The class must also be known to the application.
 */
extern id<DatabaseElement> DatabaseElementFromPlistDictionary( NSDictionary* plistDictionary );


