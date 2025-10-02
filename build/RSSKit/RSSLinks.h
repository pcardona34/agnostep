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

#import <Foundation/NSURL.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>


/**
 * A link that is used in a RSSArticle. You can find these in
 * the array returned by the -links method in RSSArticle.
 *
 * This inherits from NSURL and has special extra attributes.
 */
@interface RSSLink : NSURL
{
  NSString* _type;
}

/**
 * Factory method that returns a RSSLink with the given
 * attributes.
 *
 * Relation type is one of:
 * <ul>
 *  <li>"alternate": This link leads to an alternative location where
 *                   this article's contents can be found.</li>
 *  <li>"enclosure": A related resource which is probably large in size.
 *                   This may link to a movie, a mp3 file, etc.</li>
 *  <li>"related":   A related document</li>
 *  <li>"self":      The feed itself</li>
 *  <li>"via":       The source of the information provided in the entry.</li>
 * </ul>
 *
 * The <tt>nil</tt> relation type defaults to "related".
 *
 * These relation types are compatible with the ones of the ATOM
 * specification. For details, see
 * <a href="http://www.atomenabled.org/developers/syndication/#link">
 * the ATOM specification.</a>
 * 
 * @param aURLString the URL of the link as string
 * @param aRelation one of "alternate", "enclosure", "related", "self", "via", nil
 * @param aType the file type as string
 */
+(id) linkWithString: (NSString*) aURLString
	      andRel: (NSString*) aRelation
	     andType: (NSString*) aType;

/**
 * @see -initWithString:andRel:andType:
 */
-(id) initWithString: (NSString*) aURLString
	     andType: (NSString*) aType;

/**
 * Returns the type of this relation. This is one of
 * "alternate", "enclosure", "related", "self", "via".
 *
 * @return the relation type as string
 */
-(NSString*) relationType;


/**
 * Returns the file type of the file that this link points to.
 * 
 * @return the file type as a string
 */
-(NSString*) fileType;
@end

@interface RSSAlternativeLink : RSSLink
+(id) alternativeLinkWithString: (NSString*) aURLString;
+(id) alternativeLinkWithString: (NSString*) aURLString
			andType: (NSString*) aType;
@end

@interface RSSEnclosureLink : RSSLink
+(id) enclosureLinkWithString: (NSString*) aURLString;
+(id) enclosureLinkWithString: (NSString*) aURLString
		      andType: (NSString*) aType;
@end

@interface RSSRelatedLink : RSSLink
+(id) relatedLinkWithString: (NSString*) aURLString;
+(id) relatedLinkWithString: (NSString*) aURLString
		    andType: (NSString*) aType;
@end

@interface RSSViaLink : RSSLink
+(id) viaLinkWithString: (NSString*) aURLString;
+(id) viaLinkWithString: (NSString*) aURLString
		andType: (NSString*) aType;
@end
