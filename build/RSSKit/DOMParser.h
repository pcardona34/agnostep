/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2006 Guenther Noack
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation, in version 2.1
 *  of the License
 * 
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA
 */

#import <Foundation/Foundation.h>

#if defined(__APPLE__)
#ifndef MAC_OS_X_VERSION_10_5
#define MAC_OS_X_VERSION_10_5 1050
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5
@protocol NSXMLParserDelegate
@end
#endif
#endif


@class XMLNode;

@protocol XMLTextOrNode <NSObject>
-(NSString*) contentAndNextContents;
-(NSString*) content;
-(void) _setNext: (id<XMLTextOrNode>) node;
-(XMLNode*) nextElement;
@end

@interface XMLText : NSObject <XMLTextOrNode>
{
  NSString* _content;
  id<XMLTextOrNode> _next;
}

-(NSString*) contentAndNextContents;
-(NSString*) content;
-(void) _setNext: (id<XMLTextOrNode>) node;
-(XMLNode*) nextElement;

-(id)init;
-(id)initWithString: (NSString*) str;

-(void)dealloc;
@end


@interface XMLNode : NSObject <XMLTextOrNode, NSXMLParserDelegate>
{
  NSString* _name;
  NSString* _namespace;
  
  XMLNode* _child;
  id<XMLTextOrNode> _next;
  
  id<XMLTextOrNode> _current;
  XMLNode* _parent;
  
  NSDictionary* _attributes;
}

-(XMLNode*) firstChildElement;

-(XMLNode*) nextElement;

-(NSString*) name;

-(NSString*) contentAndNextContents;
-(NSString*) content;

-(NSDictionary*) attributes;

-(NSString*) namespace;

-(id) initWithName: (NSString*) name
	 namespace: (NSString*) namespace
	attributes: (NSDictionary*) attributes
	    parent: (XMLNode*) parent;

-(void) dealloc;

- (void) _setNext: (id <XMLTextOrNode>) node;

- (void) appendTextOrNode: (id<XMLTextOrNode>) aThing
	       fromParser: (NSXMLParser*) aParser;

@end

@interface XMLNode (NSXMLParserDelegateEventAdditions)
- (void) parser: (NSXMLParser*)aParser
  didEndElement: (NSString*)anElementName
   namespaceURI: (NSString*)aNamespaceURI
  qualifiedName: (NSString*)aQualifierName;

- (void) parser: (NSXMLParser*)aParser
didStartElement: (NSString*)anElementName
   namespaceURI: (NSString*)aNamespaceURI
  qualifiedName: (NSString*)aQualifierName
     attributes: (NSDictionary*)anAttributeDict;

- (void)    parser: (NSXMLParser*)aParser
 parseErrorOccured: (NSError*)parseError;

- (void) parser: (NSXMLParser*)aParser
foundCharacters: (NSString*)aString;

- (void) parser: (NSXMLParser*)aParser
     foundCDATA: (NSData*)CDATABlock;
@end
