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

#ifndef	INCLUDED_GWSDOCUMENT_H
#define	INCLUDED_GWSDOCUMENT_H

#import <Foundation/NSObject.h>

#if     defined(__cplusplus)
extern "C" {
#endif

@class  NSArray;
@class  NSData;
@class  NSString;
@class  NSMutableDictionary;
@class  NSRecursiveLock;
@class  NSURL;
@class  GWSBinding;
@class  GWSElement;
@class  GWSExtensibility;
@class  GWSMessage;
@class  GWSPortType;
@class  GWSService;
@class  GWSType;

/** A GWSDocument instance manages a collection of web services.
 * It is equivalent to a WSDL document, and is intended to provide
 * a mechanism for reading, writing, editing and creating
 * web services definitions.
 */
@interface GWSDocument : NSObject
{
@private
  NSRecursiveLock       *_lock;
  NSString              *_name;
  NSString              *_prefix;
  NSString              *_targetNamespace;
  GWSElement            *_documentation;
  GWSElement            *_elem; // Not retained
  NSMutableDictionary   *_bindings;
  NSMutableDictionary   *_messages;
  NSMutableDictionary   *_namespaces;
  NSMutableDictionary   *_portTypes;
  NSMutableDictionary   *_services;
  NSMutableDictionary   *_types;
  NSDictionary		*_ext;
  NSMutableArray	*_extensibility;
}

/** Return a previously registered extensibility object.
 */
+ (GWSExtensibility*) extensibilityForNamespace: (NSString*)namespaceURL;

/** Registers an extensibility object to be used to handle extensibility
 * elements with the specified namespace.<br />
 * New registrations replace older ones for the same namespace URL.<br />
 * Registering a nil object removes registrations for the namespace URL.<br />
 * NB. Changes to the registered extensibilities do not effect any
 * document instances created bnefore the change took place.
 */
+ (void) registerExtensibility: (GWSExtensibility*)extensibility
		  forNamespace: (NSString*)namespaceURL;

/** Returns the names of all WSDL bindings currently defined in this document.
 */
- (NSArray*) bindingNames;

/** Returns the named WSDL binding, creating a new instance if the
 * named binding does not exist and the shouldCreate flag is YES.
 */
- (GWSBinding*) bindingWithName: (NSString*)name
                         create: (BOOL)shouldCreate;

/** Returns the receiver serialised as an XML (WSDL) document.
 */
- (NSData*) data;

/** Returns the receiver's documentation.
 */
- (GWSElement*) documentation;

/** Returns the receiver's extensibility elements.
 */
- (NSArray*) extensibility;

/** Returns the registered exrtensibility object for the namespace.
 */
- (GWSExtensibility*) extensibilityForNamespace: (NSString*)namespaceURL;

/** Returns the current element when initializing the document from a
 * tree of elements, nil otherwise.  This is intended for use by
 * companion classes which are initializing themselves from this
 * document.
 */
- (GWSElement*) initializing;

/** Initialises the receiver by parsing the WSDL file.
 */
- (id) initWithContentsOfFile: (NSString*)file;

/** Initialises the receiver by parsing the WSDL file at the url.
 */
- (id) initWithContentsOfURL: (NSURL*)url;

/** Initialises the receiver by parsing the WSDL document specified.
 */
- (id) initWithData: (NSData*)xml;

/** Initialises the receiver by traversing the WSDL document in the
 * supplied tree.
 */
- (id) initWithTree: (GWSElement*)tree;

/** Returns the names of all WSDL messages currently defined in this document.
 */
- (NSArray*) messageNames;

/** Returns the named WSDL message, creating a new instance if the
 * named message does not exist and the shouldCreate flag is YES.
 */
- (GWSMessage*) messageWithName: (NSString*)name
                         create: (BOOL)shouldCreate;

/** Returns the receiver's name.
 */
- (NSString*) name;

/** Returns the namespace URI mapped to by the specified prefix,
 * or nil if there is no such prefix known.
 */
- (NSString*) namespaceForPrefix: (NSString*)prefix;

/** Returns the namespace prefix used for the WSDL namespace in this document,
 * or nil if there is no namespace prefix used.
 */
- (NSString*) namespacePrefix;

/** Returns the names of all WSDL port types currently defined in this document.
 */
- (NSArray*) portTypeNames;

/** Returns the named WSDL port type, creating a new instance if the
 * named port type does not exist and the shouldCreate flag is YES.
 */
- (GWSPortType*) portTypeWithName: (NSString*)name
                           create: (BOOL)shouldCreate;

/** Returns the prefix for the specified namespace (if defined).
 */
- (NSString*) prefixForNamespace: (NSString*)url;

/** Removes the named WSDL binding from the document.
 */
- (void) removeBindingNamed: (NSString*)name;

/** Removes the named WSDL message from the document.
 */
- (void) removeMessageNamed: (NSString*)name;

/** Removes the named WSDL port type from the document.
 */
- (void) removePortTypeNamed: (NSString*)name;

/** Removes the named WSDL service from the document.
 */
- (void) removeServiceNamed: (NSString*)name;

/** Removes the named WSDL type from the document.
 */
- (void) removeTypeNamed: (NSString*)name;

/** Given an element name which is in the WSDL namespace,
 * return the qualified version of the name appropriate
 * for use in this document.
 */
- (NSString*) qualify: (NSString*)name;

/** Returns the names of all WSDL services currently defined in this document.
 */
- (NSArray*) serviceNames;

/** Returns the named WSDL service, creating a new instance if the
 * named service does not exist and the shouldCreate flag is YES.
 */
- (GWSService*) serviceWithName: (NSString*)name
                         create: (BOOL)shouldCreate;

/** Set the documentation of this document.
 */
- (void) setDocumentation: (GWSElement*)documentation;

/** Set the extensibility elements for this document.
 */
- (void) setExtensibility: (NSArray*)extensibility;

/** Set the name of this document.
 */
- (void) setName: (NSString*)name;

/** Set the target namespace of this document.
 */
- (void) setTargetNamespace: (NSString*)uri;

/** Return the target namespace of this document.
 */
- (NSString*) targetNamespace;

/** Returns a tree of elements describing the WSDL documnet represented by
 * the receiver.
 */
- (GWSElement*) tree;

/** Returns the names of all WSDL types currently defined in this document.
 */
- (NSArray*) typeNames;

/** Returns the named WSDL type, creating a new instance if the
 * named type does not exist and the shouldCreate flag is YES.
 */
- (GWSType*) typeWithName: (NSString*)name
                   create: (BOOL)shouldCreate;

/** Writes the contents of the receiver to the specified file as a WSDL
 * document.
 */
- (BOOL) writeToFile: (NSString*)file atomically: (BOOL)atomically;

/** Writes the contents of the receiver to the specified URL as a WSDL
 * document.
 */
- (BOOL) writeToURL: (NSURL*)anURL atomically: (BOOL)atomically;
@end

#if	defined(__cplusplus)
}
#endif

#endif

