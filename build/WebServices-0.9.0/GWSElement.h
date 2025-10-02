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

   $Date: 2007-09-24 14:19:12 +0100 (Mon, 24 Sep 2007) $ $Revision: 25500 $
   */ 

#ifndef	INCLUDED_GWSELEMENT_H
#define	INCLUDED_GWSELEMENT_H

#import <Foundation/NSObject.h>

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#define NSUInteger unsigned int
#endif

#if     defined(__cplusplus)
extern "C" {
#endif

@class  GWSCoder;
@class  NSDictionary;
@class  NSMutableArray;
@class  NSMutableDictionary;
@class  NSMutableString;
@class  NSString;

/** This little class encapsulates an XML element as part of a simple
 * tree of elements in a document.<br />
 * The [GWSCoder] class creates a tree of these elements
 * when it parses a document.<br />
 * This class aims to produce the most lightweight practical implementation
 * of a tree-structured representation of the subset of XML documents
 * required for web services, so that we have the ease of use advantages
 * of working with an entire document as a tree structure, while
 * minimising performance/efficiency overheads.<br />
 * You probably don't need to use this class directly yourself unless
 * you are writing a new GWSCoder subclass to handle some form of XML
 * serialisation of data (or if you want to bugfix/enhance the existing 
 * GWSCoder subclasses or GWSDocument decodiong/encooding of WSDL).
 */
@interface      GWSElement : NSObject <NSMutableCopying>
{
@private
  GWSElement            *_parent;       // not retained.
  GWSElement            *_next;		// not retained.
  GWSElement            *_prev;		// not retained.
  GWSElement		*_first;	// all retained.
  NSUInteger		_children;
  NSString              *_name;
  NSString              *_namespace;
  NSString		*_prefix;
  NSString              *_qualified;
  NSMutableDictionary   *_attributes;
  NSMutableDictionary   *_namespaces;
  NSMutableString       *_content;
  NSString              *_literal;
  NSString		*_start;
}

/** Adds an element to the list of elements which are direct
 * children of the receiver.
 */
- (void) addChild: (GWSElement*)child;

/** Creates a new child element of the receiver with the specified name,
 * namespace, qualified name, and text content (may be nil).<br />
 * The content is followed by a nil terminated list of strings in pairs
 * of attribute names and attribute values.<br />
 * Alternatively, the content can be followed by a single dictionary of
 * attributes, in which case the list of arguments does not need to be
 * nil terminated.<br />
 * The newly created child element is returned.
 */
- (GWSElement*) addChildNamed: (NSString*)name
		    namespace: (NSString*)namespace
		    qualified: (NSString*)qualified
		      content: (NSString*)content,
			   ... NS_REQUIRES_NIL_TERMINATION;
		    
/** Adds a string to the content of the receiver.  New content is appended
 * to any existing content.
 */
- (void) addContent: (NSString*)content;

/** Returns the value of the named attribute, or nil if no such attribute
 * has been specified in the receiver.
 */
- (NSString*) attributeForName: (NSString*)name;

/** Returns an autoreleased immutable copy of the attributes of the receiver,
 * or an empty dictionary if no attributes are set.
 */
- (NSDictionary*) attributes;

/** Returns the child of the receiver at the specified index in the list
 * of children. Raises an exception if the index does not lie in the list.
 */
- (GWSElement*) childAtIndex: (NSUInteger)index;

/** Returns an autoreleased array containing all the child elements of
 * the receiver.  Returns an empty array if there are no children.
 */
- (NSArray*) children;

/** Condenses the character content of the receiver by stripping leading
 * and trailing white space.  If the internal flag is YES, any sequence of
 * internal white space is also condensed to a single character by deleting
 * all but the first character.
 */
- (void) condense: (BOOL)internal;

/** Returns the content text of the receiver.  This may be an empty string
 * if no content has been added to the receiver (but will never be nil).
 */
- (NSString*) content;

/** returns the number of direct child elements.
 */
- (NSUInteger) countChildren;

/** Appends a string representation of the receiver's content
 * and/or child elements to the coder's mutable string.<br />
 * If the receiver is an empty element, this does nothing.<br />
 * If -setLiteralValue: has been called to set a string value for
 * this element, then this method does nothing.
 */
- (void) encodeContentWith: (GWSCoder*)coder;

/** Appends a string representation of the receiver's end tag
 * to the coder's mutable string.<br />
 * If -setLiteralValue: has been called to set a string value for
 * this element, then this method does nothing.
 */
- (void) encodeEndWith: (GWSCoder*)coder;

/** Appends a string representation of the receiver's start tag
 * (including attributes) to the coder's mutable string.<br />
 * If the receiver is an empty element and the collapse flag
 * is YES, this ends the start tag with ' /&gt;' markup.<br />
 * If -setLiteralValue: has been called to set a string value for
 * this element, then this method appends the entire literal value
 * to the coder's mutable string.<br />
 * The return value of this method is YES if either the element
 * has been collapsed into the start tage or a literal string has
 * been output to represent the whole element.  It returns NO if
 * the content and end tag of the element still need to be output.
 */
- (BOOL) encodeStartWith: (GWSCoder*)coder collapse: (BOOL)flag;

/** Appends a string representation of the receiver (and its child
 * elements) to the coder's mutable string.<br />
 * This method can be used to generate an XML document from a tree
 * of elements.  Typically it is called by a [GWSCoder] to output a
 * tree of elements that the coder has built up from the items it
 * is encoding.<br />
 * If -setLiteralValue: has been called to set a string value for
 * this element, then this method appends that literal value to
 * the document text in coder.  Otherwise, this method encodes a
 * representation of the receiver built from its name, namespace,
 * attributes, content and children.<br />
 * This method calls the other encoding methods to perform its work.
 */
- (void) encodeWith: (GWSCoder*)coder;

/** A convenience method to search the receiver for those elemements
 * match the supplied path (ignoring namespace prefixes).<br />
 * The path contains slash ('/') separated names, and if it begins with
 * a slash the search starts at the top of the tree rather than at the
 * receiver.<br />
 * A name in the path may be specified as an asterisk ('*') in which case it
 * matches any element at that level in the path.<br />
 * The order of the elements returned in the array is the same as the order
 * in which they occur in the tree.
 */
- (NSArray*) fetchElements: (NSString*)path;

/** A convenience method to search the receiver's children for an element
 * whose name (ignoring any namespace prefix) matches the method argument.<br />
 * The return value is the first matching direct child, or nil if
 * no such element is found.
 */
- (GWSElement*) findChild: (NSString*)name;

/** A convenience method to search the receiver for an element whose
 * name (ignoring any namespace prefix) matches the method argument.<br />
 * The return value could be the receiver itsself, any of it's direct
 * (or indirect) children, or nil if no such element is found.<br />
 * The search returns the first element found searching the parse
 * tree in 'natural' order.
 */
- (GWSElement*) findElement: (NSString*)name;

/** Returns the first child element or nil if there are no children.
 */
- (GWSElement*) firstChild;

/** Returns the position of this element within the list of siblings
 * which are direct children of its parent.<br />
 * Returns NSNotFound if the receiver has no parent.
 */
- (NSUInteger) index;

/* <init />
 * Initialises the receiver with the name, namespace URI, fully qualified
 * name, and attributes given.<br />
 * The receiver makes a mutable copy of the attributes dictionary, and may
 * subsequently modify that copy in response to the -setAttribute:forKey:
 * method.
 */
- (id) initWithName: (NSString*)name
          namespace: (NSString*)namespace
          qualified: (NSString*)qualified
         attributes: (NSDictionary*)attributes;

/** Inserts an element to the list of elements which are direct
 * children of the receiver.<br />
 * Raises an exception it the specified
 * index is greater than the number of children present.<br />
 * If the element is already a child of the receiver, this method
 * moves it to the new location.
 */
- (void) insertChild: (GWSElement*)child atIndex: (NSUInteger)index;

/** Returns YES if the receiver is a direct or indirect parent of other.
 */
- (BOOL) isAncestorOf: (GWSElement*)other;

/** Returns YES if the receiver is a direct or indirect child of other.
 */
- (BOOL) isDescendantOf: (GWSElement*)other;

/** Returns YES if the name of the receiver element is equal to aName
 */
- (BOOL) isNamed: (NSString*)aName;

/** Returns YES if the receiver and other share the same direct parent.
 */
- (BOOL) isSiblingOf: (GWSElement*)other;

/** Returns the last child element or nil if there are no children.
 */
- (GWSElement*) lastChild;

/** Perform a deep copy of the receiver.
 */
- (id) mutableCopyWithZone: (NSZone*)aZone;

/** Returns the name of the receiver (as set when it was initialised,
 * or by using the -setName: method).
 */
- (NSString*) name;

/** Returns the namespace URI of the receiver (as set when it was
 * initialised or changed using setPrefix:).
 */
- (NSString*) namespace;

/** Returns the namespace URL for the specified prefix by looking at
 * the namespace declarations in the receiver and its parents.  If the
 * prefix is empty, this returns the default namespace URL.<br />
 * returns nil if no matching namespace is found.
 */
- (NSString*) namespaceForPrefix: (NSString*)prefix;

/** Returns the namespaces mappings introduced by this element.<br />
 * If there are no namespaces introduced, this returns nil.
 */
- (NSDictionary*) namespaces;

/** Searches the tree for the next element with the specified name (ignoring
 * any namespace prefix).  Children of the receiver are searched first,
 * then siblings of the receiver's parent, then siblings of the parent's
 * parent and so on.<br />
 * If the supplied name is nil, any element matches, so this method may be
 * used to traverse the entire tree passing through all nodes.
 */
- (GWSElement*) nextElement: (NSString*)name;

/** Returns the parent of this element, or nil if the receiver has no parent.
 */
- (GWSElement*) parent;

/** Convenience method to return the names of the elements containing
 * the receiver (including the name of the receiver as the last item).
 */
- (NSMutableArray*) path;

/** Returns the prefix identifying the namespace of the receiver.<br />
 * The -qualified name of the receiver consists of the -prefix and
 * the -name separated by a single colon.<br />* 
 * Returns nil if the receiver has no prefix.
 */
- (NSString*) prefix;

/** Searches the receiver and its parents for the first usable prefix
 * mapping to the specified namespace.  Returns nil if there is none.
 */
- (NSString*) prefixForNamespace: (NSString*)uri;

/**
 * Returns the previous sibling of the receiver (if any).
 */
- (GWSElement*) previous;

/** Returns the fully qualified name of the receiver
 * (as set when it was initialised, or using the -setName: and -setPrefix:
 * methods).
 */
- (NSString*) qualified;

/** Removes the receiver (and its children) from its parent.<br />
 * This may cause the receiver to be deallocated.
 */
- (void) remove;

/** Sets the value for the specified key.<br />
 * If attribute is nil then any existing value for the key is removed.<br />
 * If the key is nil, then all existing attributes are removed.
 */
- (void) setAttribute: (NSString*)attribute forKey: (NSString*)key;

/** Sets the value of the content string of the receiver, replacing any
 * content already present.<br />
 * You may use an empty string or nil to remove content from the
 * receiver.
 */
- (void) setContent: (NSString*)content;

/** Sets the literal text to be used as the XML representing this element
 * and its content and children when encoding to an XML document.<br />
 * This overrides the default behavior which is to traverse the tree of
 * elements producing output to the XML document.<br />
 * Use with <em>extreme</em> care ... this method allows you to inject
 * illegal data into an XML document.
 */
- (void) setLiteralValue: (NSString*)xml;

/** Sets the name of the receiver to the specified value.
 */
- (void) setName: (NSString*)name;

/** Sets the namespace URI for the specified prefix.<br />
 * If the uri is nil, this removes any existing mapping for the prefix.<br />
 * If the prefix is empty or nil, this sets the default namespace.
 */
- (void) setNamespace: (NSString*)uri forPrefix: (NSString*)prefix;

/** Sets the namespace prefix of the receiver to the specified value,
 * which must be empty or a namespace prefix declared in the receiver
 * or one of the its parent elements.<br />
 * Changing the prefix also changes the namespace of the receiver ...
 * setting an empty/nil prefix causes the receiver to use the default
 * namespace.
 */
- (void) setPrefix: (NSString*)prefix;

/**
 * Returns the next sibling of the receiver.  In conjunction with the
 * -firstChild method, this can be used to step through all the children
 * of an element.
 */
- (GWSElement*) sibling;

@end

#if	defined(__cplusplus)
}
#endif

#endif

