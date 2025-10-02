/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2006 Guenther Noack
 *                2013 The GNUstep Application Project
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

#import "RSSLinks.h"
#import "GNUstep.h"

@implementation RSSLink
+(id) linkWithString: (NSString*) aURLString
	      andRel: (NSString*) aRelation
	     andType: (NSString*) aType
{
  id result = nil;
  
  if (aRelation == nil || // nil defaults to "related"
      [aRelation isEqualToString: @"related"]) {
    result = [RSSRelatedLink relatedLinkWithString: aURLString
			     andType: aType];
  } else if ([aRelation isEqualToString: @"alternate"]) {
    result = [RSSAlternativeLink alternativeLinkWithString: aURLString
				 andType: aType];
  } else if ([aRelation isEqualToString: @"enclosure"]) {
    result = [RSSEnclosureLink enclosureLinkWithString: aURLString
			       andType: aType];
  } else if ([aRelation isEqualToString: @"via"]) {
    result = [RSSViaLink viaLinkWithString: aURLString
			 andType: aType];
  } else if ([aRelation isEqualToString: @"self"]) {
    result = nil; // self relation not supported yet! FIXME
  }
  
  return result;
}


-(id) initWithString: (NSString*) aURLString
{
  return [self initWithString: aURLString
	       andType: nil];
}

-(id) initWithString: (NSString*) aURLString
	     andType: (NSString*) aType
{
  if ([self isMemberOfClass: [RSSLink class]]) {
    [self autorelease];
    [NSException
      raise: @"Abstract Class Instantiation"
      format: @"Abstract class %@ cannot be instantiated directly!",
      [self class]];
  }
  
  if ((self = [super initWithString: aURLString]) != nil) {
    ASSIGN(_type, aType);
  }
  
  return self;
}

-(NSString*) relationType
{
#ifdef GNUSTEP
  [self subclassResponsibility: _cmd];
#endif
  return nil;
}

-(NSString*) fileType
{
  return [[_type retain] autorelease];
}

@end

@implementation RSSAlternativeLink
+(id) alternativeLinkWithString: (NSString*) aURLString
{
  return [self alternativeLinkWithString: aURLString
	       andType: nil];
}

+(id) alternativeLinkWithString: (NSString*) aURLString
			andType: (NSString*) aType
{
  return AUTORELEASE([[self alloc] initWithString: aURLString
		       andType: aType]);
}

-(NSString*) relationType
{
  return @"alternate";
}
@end

@implementation RSSEnclosureLink
+(id) enclosureLinkWithString: (NSString*) aURLString
{
  return [self enclosureLinkWithString: aURLString
	       andType: nil];
}

+(id) enclosureLinkWithString: (NSString*) aURLString
		      andType: (NSString*) aType;
{
  return AUTORELEASE([[self alloc] initWithString: aURLString
		       andType: aType]);
}

-(NSString*) relationType
{
  return @"enclosure";
}
@end

@implementation RSSRelatedLink
+(id) relatedLinkWithString: (NSString*) aURLString
{
  return [self relatedLinkWithString: aURLString
	       andType: nil];
}

+(id) relatedLinkWithString: (NSString*) aURLString
		    andType: (NSString*) aType
{
  return AUTORELEASE([[self alloc] initWithString: aURLString
		       andType: aType]);
}

-(NSString*) relationType
{
  return @"related";
}
@end

@implementation RSSViaLink
+(id) viaLinkWithString: (NSString*) aURLString
{
  return [self viaLinkWithString: aURLString
	       andType: nil];
}

+(id) viaLinkWithString: (NSString*) aURLString
		andType: (NSString*) aType
{
  return AUTORELEASE([[self alloc] initWithString: aURLString
		       andType: aType]);
}

-(NSString*) relationType
{
  return @"via";
}
@end
