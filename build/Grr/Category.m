/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2011  GNUstep Application Team
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

#import <Foundation/Foundation.h>

#import "Category.h"

#ifdef __APPLE__
#import "GNUstep.h"
#endif

@implementation GrrCategory

// ---------------------------------------------------------
//    initialisation
// ---------------------------------------------------------

// conforming to DatabaseElement protocol
-(id) initWithDictionary: (NSDictionary*) dict
{
    NSString* aName;
    NSArray* subElemDicts;
    NSMutableArray* subElements;
    int i;

    NSParameterAssert([dict isKindOfClass: [NSDictionary class]]);
    
    aName = [dict objectForKey: @"name"];
    NSAssert1([aName isKindOfClass: [NSString class]], @"%@ is not a string", aName);
    
    subElemDicts = [dict objectForKey: @"elements"];
    subElements = [NSMutableArray new];
    
    for (i=0; i<[subElemDicts count]; i++) {
        id<DatabaseElement> elem = DatabaseElementFromPlistDictionary([subElemDicts objectAtIndex: i]);
        NSAssert1(
            [elem conformsToProtocol: @protocol(DatabaseElement)],
            @"%@ is not a database element", elem
        );
        [subElements addObject: elem];
        [elem setSuperElement: self];
    }
    
    return [self initWithName: aName elements: subElements];
}

-(id) initWithName: (NSString*) aName
{
    return [self initWithName: aName elements: [NSArray new]];
}

/**
 * Designated initialiser.
 */
-(id) initWithName: (NSString*) aName
          elements: (NSArray*) anElementsArray
{
    if ((self = [super init]) != nil) {
        ASSIGN(name, aName);
        ASSIGN(elements, [NSMutableArray arrayWithArray: anElementsArray]);
    }
    
    return self;
}

// ---------------------------------------------------------
//    NSObject protocol
// ---------------------------------------------------------

-(NSString*) description
{
    return name;
}

// ---------------------------------------------------------
//    database element protocol
// ---------------------------------------------------------

-(id) superElement
{
    return parent;
}


-(void) setSuperElement: (id)superElement
{
    ASSIGN(parent, superElement);
}

-(NSMutableDictionary*) plistDictionary
{
    NSMutableDictionary* dict = [NSMutableDictionary new];
    NSMutableArray* arr = [NSMutableArray new];
    
    int i;
    for (i=0; i<[elements count]; i++) {
        id<DatabaseElement> elem = [elements objectAtIndex: i];
        
        [arr addObject: [elem plistDictionary]];
    }
    
    [dict setObject: arr forKey: @"elements"];
    [dict setObject: name forKey: @"name"];
    [dict setObject: [[self class] description] forKey: @"isa"];
    [arr release];

    return dict;
}

/**
 * Sets the name for the category. This name is then returned by
 * the -description method.
 */
-(void) setName: (NSString*) aString
{
    ASSIGN(name, aString);
}


// ---------------------------------------------------------
//    category protocol
// ---------------------------------------------------------

-(NSArray*) elements
{
    return elements;
}

/**
 * Inserts the given element in this category.
 * Returns YES if - and only if - the operation is a success.
 * Otherwise, NO is returned. The operation will fail when the
 * element is already contained in this category.
 *
 * The position argument is an integer between 0 and the number
 * of already existing database elements. A position of 0 inserts
 * the new element before the first and a position equaling the
 * number of elements inserts the new element after the last element.
 */
-(BOOL) insertElement: (id<DatabaseElement>)element
           atPosition: (int)index
{
    if (index < 0 || index > [elements count]) {
        return NO;
    } else {
        [elements insertObject: element atIndex: index];
        [element setSuperElement: self];
        return YES;
    }
}

/**
 * This convenience method inserts a database element in a category
 * without caring about the position. See the documentation for
 * -insertElement:atPosition: for details.
 */
-(BOOL) insertElement: (id<DatabaseElement>)element
{
    [elements addObject: element];
    [element setSuperElement: self];
    return YES;
}

/**
 * Removes the given database element from the category. If the object
 * has been removed, YES is returned. Not recursive.
 */
-(BOOL) removeElement: (id<DatabaseElement>)element
{
    if ([elements containsObject: element]) {
        [elements removeObject: element];
        // nil means 'top level element' here. Not very nice actually.
        [element setSuperElement: nil];
        return YES;
    } else {
        return NO;
    }
}

/**
 * Recursively removes the given database element from the category.
 * On success, YES is returned.
 */
-(BOOL) recursivelyRemoveElement: (id<DatabaseElement>)element
{
    BOOL result = [self removeElement: element];
    
    int i;
    for (i=0; i<[elements count]; i++) {
        id<DatabaseElement> elem = [elements objectAtIndex: i];
        
        if ([elem conformsToProtocol: @protocol(Category)]) {
            result = result || [(id<Category>)elem recursivelyRemoveElement: element];
        }
    }
    
    return result;
}

@end

