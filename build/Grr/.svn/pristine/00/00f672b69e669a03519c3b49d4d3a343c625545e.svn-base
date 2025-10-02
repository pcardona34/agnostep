/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009  GNUstep Application Team
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

#import "DatabaseElement.h"

NSString* const DatabaseElementFocusRequestNotification = @"DatabaseElementFocusRequestNotification";

id<DatabaseElement> DatabaseElementFromPlistDictionary( NSDictionary* plistDictionary )
{
  id classObject;
  NSString* className;
  id<DatabaseElement> elem;

    NSCParameterAssert([plistDictionary isKindOfClass: [NSDictionary class]]);
    
    className = [plistDictionary objectForKey: @"isa"];
    
    NSCAssert1(
        [className isKindOfClass: [NSString class]],
        @"the dictionary's isa value \"%@\" is not a string.",
        className
    );
    
    classObject = NSClassFromString(className);
    
    NSCAssert1(
        classObject != nil,
        @"the dictionary's isa value \"%@\" cannot be resolved to a class",
        className
    );
    
    elem = [classObject alloc];
    elem = [elem initWithDictionary: plistDictionary];
    
    return elem;
}
