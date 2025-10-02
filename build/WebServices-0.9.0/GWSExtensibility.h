/** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	November 2008
   
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

#ifndef	INCLUDED_GWSEXTENSIBILITY_H
#define	INCLUDED_GWSEXTENSIBILITY_H

#import <Foundation/NSObject.h>

#if     defined(__cplusplus)
extern "C" {
#endif

@class  NSString;
@class  GWSBinding;
@class  GWSDocument;
@class  GWSElement;
@class  GWSService;

/** <p>GWSExtensibility is an abstract class declaring the methods needed to
 * implement WSDL extensibility.<br />
 * The extensibility mechanism is the way that WSDL was designed to be
 * future-proof, it works by defining certain points within a WSDL document
 * at which extensibility elements may be inserted to give additional
 * information.
 * </p>
 * <p>The WebServices library reads in and stores extensibility elements in
 * the form of GWSElement objects and looks up the GWSExtensibility objects
 * to handle them using the namespaces of the elements read in.<br />
 * If there is no registered handler (see
 * [GWSDocument+registerExtensibility:forNamespace:]) then the
 * extensibility elements are ignored, but preserved for output
 * when a document is written.<br />
 * However, if a handler ihas been registered, the extensibility elements
 * are validated when the document is read in, and the handler is also asked
 * to perform service/coder setup when an attempt is made to perform an
 * operation using a service defined in the document.
 * </p>
 */
@interface	GWSExtensibility : NSObject
{
}

/** Method to validate an extensibility node for the specified document.
 * The section argument is the object on whose behalf the extensibility
 * instance is being parsed (eg  a GWSPortType).<br />
 * This must return nil if the extensibility node is valid,
 * and a descriptive error message if it is not.<br />
 * The optional service argument is, if present, a [GWSService] object
 * which is about to send a message ... in this case the method should
 * modify the parameters of the message adding in keys to specify how
 * the parameters should be encoded and where/how the message should
 * be sent.
 */
- (NSString*) validate: (GWSElement*)node
		   for: (GWSDocument*)document
		    in: (id)section
		 setup: (GWSService*)service;

@end

/**
 * An instance of this class is registered by default to handle the
 * <code>http://schemas.xmlsoap.org/wsdl/soap/</code> namespace.
 */
@interface	GWSSOAPExtensibility : GWSExtensibility
@end

#if	defined(__cplusplus)
}
#endif

#endif

