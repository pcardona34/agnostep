/** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	January 2008
   
   This file is part of the WebServices Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

   $Date: 2007-09-14 13:54:55 +0100 (Fri, 14 Sep 2007) $ $Revision: 25485 $
   */ 

#ifndef	INCLUDED_GWSMESSAGE_H
#define	INCLUDED_GWSMESSAGE_H

#import <Foundation/NSObject.h>

#if     defined(__cplusplus)
extern "C" {
#endif

@class  NSMutableDictionary;
@class  NSString;
@class  GWSDocument;
@class  GWSElement;

/** Encapsulates the WSDL message element ... a description of a named
 * message in terms of the data items (parts) transferred in the message.<br />
 * Each part of the message has a name and is described by an <em>element</em>
 * or <em>type</em> which specifies the kind of data being used.
 */
@interface	GWSMessage : NSObject
{
@private
  NSString              *_name;
  GWSDocument           *_document;
  GWSElement            *_documentation;
  NSMutableDictionary   *_elements;
  NSMutableDictionary   *_types;
}

/** Return the documentation tree for the receiver.
 */
- (GWSElement*) documentation;

/** Return the element of the specified part or nil if it does not exist.
 */
- (NSString*) elementOfPartNamed: (NSString*)name;

/** Return the name of the receiver.
 */
- (NSString*) name;

/** Return an array listing the names of all the parts defined for this
 * message.
 */
- (NSArray*) partNames;

/** Set the documentation for the receiver.
 */
- (void) setDocumentation: (GWSElement*)documentation;

/** Set the element of the specified part.
 */
- (void) setElement: (NSString*)type forPartNamed: (NSString*)name;

/** Set the type of the specified part.
 */
- (void) setType: (NSString*)type forPartNamed: (NSString*)name;

/** Return a tree representation of the receiver for output as part of
 * a WSDL document.
 */
- (GWSElement*) tree;

/** Return the type of the specified part or nil if it does not exist.
 */
- (NSString*) typeOfPartNamed: (NSString*)name;
@end

#if	defined(__cplusplus)
}
#endif

#endif

