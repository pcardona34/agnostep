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

#ifndef	INCLUDED_GWSPORT_H
#define	INCLUDED_GWSPORT_H

#import <Foundation/NSObject.h>

#if     defined(__cplusplus)
extern "C" {
#endif

@class  NSMutableArray;
@class  NSString;
@class  GWSBinding;
@class  GWSDocument;
@class  GWSElement;

/** Encapsulates a WSDL port within a service.<br />
 * The port provides access to the particular binding used to perform an
 * operation.
 */
@interface	GWSPort : NSObject
{
@private
  NSString              *_name;
  NSString		*_binding;
  GWSDocument           *_document;
  NSMutableArray	*_extensibility;
}

/** Return the binding of this port.
 */
- (GWSBinding*) binding;

/** Return the extensibility for this port.
 */
- (NSArray*) extensibility;

/** Return the name of this port type.
 */
- (NSString*) name;

/** Set the extensibility elements for this document.
 */
- (void) setExtensibility: (NSArray*)extensibility;

/** Return a tree representation of the receiver for output as part of
 * a WSDL document.
 */
- (GWSElement*) tree;
@end

#if	defined(__cplusplus)
}
#endif

#endif

