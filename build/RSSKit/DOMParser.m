/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2006 Guenther Noack
 *                2012 Free Software Foundation
 *
 *  Authors: Guenther Noack
 *           Riccardo Mottola
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

#import "DOMParser.h"
#import "GNUstep.h"

//#define DEBUG 1

@implementation XMLText

-(NSString*) contentAndNextContents
{
  return [NSString stringWithFormat: @"%@%@",
		   ( (_content==nil) ? @"" : _content ),
		   ( (_next==nil) ? @"" : [_next contentAndNextContents])];
}

-(NSString*) content
{
  return ( (_content==nil) ? @"" : _content );
}

-(void) _setNext: (id<XMLTextOrNode>) node
{
  ASSIGN(_next, node);
}

-(XMLNode*) nextElement
{
  // !!! If you change this, change it in XMLNode, too!
  // XXX: Write a macro
  
  // we only return *XML elements* here, *not* contents!
  if ([_next isKindOfClass: [XMLText class]]) {
    return [_next nextElement];
  } else {				    
    return AUTORELEASE(RETAIN(_next));
  }  
}

/**
 * @deprecated
 * Please don't call init on XMLText objects. It won't work.
 * Instead, use initWithString:
 */
-(id)init
{
  [self release];
  return nil;
}

-(id)initWithString: (NSString*) str
{
  self = [super init];
  
  if (self != nil) {
    ASSIGN(_content, str);
  }
  
  return self;
}

-(void)dealloc
{
  DESTROY(_next);
  DESTROY(_content);
  [super dealloc];
}

@end


@implementation XMLNode

-(XMLNode*) firstChildElement
{
  if (_child == nil)
    return nil;
  
  if ([[_child class] isSubclassOfClass: [XMLNode class]]) {
    return AUTORELEASE(RETAIN(_child));
  } else {
    return [_child nextElement];
  }
}

-(XMLNode*) nextElement
{
  // !!! If you change this, change it in XMLText, too!
  // XXX: Write a macro
  
  // we only return *XML elements* here, *not* contents!
  if ([_next isKindOfClass: [XMLText class]]) {
    return [_next nextElement];
  } else {				    
    return AUTORELEASE(RETAIN(_next));
  }
}

-(NSString*) name
{
  return AUTORELEASE(RETAIN(_name));
}

-(NSString*) contentAndNextContents
{
  NSString* result;
  
  // XXX: attributes are still not shown here! Do we need it?
  
  if (_child == nil) {
    result = [NSString stringWithFormat:
			 @"<%@/>%@", _name,
		       (_next==nil?@"":[_next contentAndNextContents])];
  } else {
    result = [NSString stringWithFormat:
			 @"<%@>%@</%@>%@",
		       _name, [_child contentAndNextContents], _name,
		       (_next==nil?@"":[_next contentAndNextContents])];
  }
  
  return result;
}

-(NSString*) content
{
  NSString* result;
  
  // XXX: attributes are still not shown here! Do we need it?
  
  if (_child == nil) {
    result = @"";
  } else {
    result = [_child contentAndNextContents];
  }
  
  return result;
}

-(NSDictionary*) attributes
{
  return AUTORELEASE(RETAIN(_attributes));
}

-(NSString*) namespace
{
  return AUTORELEASE(RETAIN(_namespace));
}

-(id) initWithName: (NSString*) name
	 namespace: (NSString*) namespace
	attributes: (NSDictionary*) attributes
	    parent: (XMLNode*) parent;
{
  self = [super init];
  
  if (self != nil) {
    ASSIGN(_name, name);
    ASSIGN(_namespace, namespace);
    ASSIGN(_parent, parent);
    ASSIGN(_attributes, attributes);
  }
  
  return self;
}

-(void) dealloc
{
  DESTROY(_child);
  DESTROY(_next);
  DESTROY(_namespace);
  DESTROY(_name);
  DESTROY(_current);
  DESTROY(_parent);
  DESTROY(_attributes);
  [super dealloc];
}

- (void) _setNext: (id<XMLTextOrNode>) node
{
  #ifdef DEBUG
  NSLog(@"_setNext: %@ --> %@", self, node);
  #endif

  ASSIGN(_next, node);
}


- (void) appendTextOrNode: (id<XMLTextOrNode>) aThing
	       fromParser: (NSXMLParser*) aParser
{
  #ifdef DEBUG
  NSLog(@"appendTextOrNode: %@ at: %@", aThing, [self name]);
  #endif
  
  if (_child == nil) {
    ASSIGN(_child, aThing);
  }
  
  if (_current == nil) {
    ASSIGN(_current, aThing);
  } else {
    [_current _setNext: aThing];
    
    ASSIGN(_current, aThing);
  }
  
  if ([[aThing class] isSubclassOfClass: [XMLNode class]]) {
    [aParser setDelegate: (XMLNode *)aThing];
  }
}

@end

@implementation XMLNode (NSXMLParserDelegateEventAdditions)
- (void) parser: (NSXMLParser*)aParser
  didEndElement: (NSString*)anElementName
   namespaceURI: (NSString*)aNamespaceURI
  qualifiedName: (NSString*)aQualifierName
{
  #ifdef DEBUG
  NSLog(@"closing XML node %@", anElementName);
  #endif
  
  if (![anElementName isEqualToString: _name]) {
    NSLog(@"badly nested XML elements!");
  }
  
  if (_parent != nil) {
    [aParser setDelegate: _parent];
    DESTROY(_parent);
  }
}

- (void) parser: (NSXMLParser*)aParser
didStartElement: (NSString*)anElementName
   namespaceURI: (NSString*)aNamespaceURI
  qualifiedName: (NSString*)aQualifierName
     attributes: (NSDictionary*)anAttributeDict
{
  XMLNode *item = [[XMLNode alloc]
	   initWithName: anElementName
	   namespace: aNamespaceURI
	   attributes: anAttributeDict
	   parent: self ];
  
  #ifdef DEBUG
  NSLog(@"starting XML node %@ (NS=%@)", anElementName, aNamespaceURI);
  #endif
  
  [self appendTextOrNode: item
	fromParser: aParser];
  
  DESTROY(item);
}

- (void)    parser: (NSXMLParser*)aParser
 parseErrorOccured: (NSError*)parseError
{
  NSLog(@"XML-DOM Parser: %@ at line %ld, col %ld",
	[parseError localizedDescription],
	(long int)[aParser lineNumber], (long int)[aParser columnNumber]);
}

- (void) parser: (NSXMLParser*)aParser
foundCharacters: (NSString*)aString
{
  XMLText *text = [[XMLText alloc] initWithString: aString];
  
  [self appendTextOrNode: text
	fromParser: aParser];
  
  DESTROY(text);
}

- (void) parser: (NSXMLParser*)aParser
     foundCDATA: (NSData*)CDATABlock
{
    // FIXME: Find out how to retieve the XML file's encoding from here!
    //   At the moment, I'm just using UTF8 here, as it's the most commonly
    //   used encoding in RSS feeds (and XML in general).
    NSString* blockContents = [[NSString alloc] initWithData: CDATABlock
                                                    encoding: NSUTF8StringEncoding];
    [blockContents autorelease];
    
    // delegate to the foundCharacters method.
    [self parser: aParser foundCharacters: blockContents];
}

@end
