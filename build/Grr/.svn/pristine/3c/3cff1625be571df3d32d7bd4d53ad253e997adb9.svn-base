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

#import "PipeType.h"
#import <Foundation/NSString.h>

#ifdef __APPLE__
#import "GNUstep.h"
#endif

@implementation PipeType

- (id) initWithDescription: (NSString*) aDescription
{
    if ((self = [super init]) != nil) {
        ASSIGN(description, aDescription);
    }
    
    return self;
}

+ (id<PipeType>) articleType
{
    static id<PipeType> articleType = nil;
    
    if (articleType == nil) {
        articleType = [[self alloc] initWithDescription: @"article pipe type"];
    }
    
    return articleType;
}

+ (id<PipeType>) feedType
{
    static id<PipeType> feedType = nil;
    
    if (feedType == nil) {
        feedType = [[self alloc] initWithDescription: @"feed pipe type"];
    }
    
    return feedType;
}

+ (id<PipeType>) databaseElementType
{
    static id<PipeType> databaseElementType = nil;
    
    if (databaseElementType == nil) {
        databaseElementType = [[self alloc] initWithDescription: @"database element pipe type"];
    }
    
    return databaseElementType;
}

- (NSString*) description
{
    return description;
}
@end

