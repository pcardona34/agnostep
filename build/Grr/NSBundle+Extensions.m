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

#import "NSBundle+Extensions.h"

@implementation NSBundle (GrrExtensions)

/**
 * Returns the principal classes instance of the bundle with the given name
 * If there's no bundle with this name or an error occurs, nil is returned.
 */
+(id) instanceForBundleWithName: (NSString*) name
{
    return [self instanceForBundleWithName: name type: @"grrc"];
}

/**
 * Returns the principal classes instance of the bundle with the given name
 * and type (path extension). If there's no bundle with this name or an error
 * occurs, nil is returned.
 */
+(id) instanceForBundleWithName: (NSString*) name
                           type: (NSString*) type
{
    NSString* bundlePathName;
    NSBundle* bundle;
    id pClass;

#ifdef MACOSX
    bundlePathName =
        [[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:
            [name stringByAppendingPathExtension: type]];
#else
    bundlePathName =
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
            [name stringByAppendingPathExtension: type]];
#if 0
    bundlePathName = [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent];
    bundlePathName = [bundlePathName stringByDeletingPathExtension];
    
    // We verify if we must load the bundles in the GNUstep's Local, Network or System dir.
    // FIXME: We must also be careful in case poeple are using GNUstep with --enable-flattened
    if ([bundlePathName hasSuffix: @"/Applications/Grr"]) {
        bundlePathName = [NSString stringWithFormat: @"%@/Library/Grr/%@.%@",
                          [[bundlePathName stringByDeletingLastPathComponent]
                            stringByDeletingLastPathComponent],
                          name, type];
    } else {
        // This branch is taken when Grr is started from its source directory.
        bundlePathName = [NSString stringWithFormat: @"%@/Components/%@/%@.%@",
                          [bundlePathName stringByDeletingLastPathComponent],
                          name, name, type];
    }
#endif
#endif
    
    NSLog(@"Loading bundle at %@", bundlePathName);
    
    bundle = [NSBundle bundleWithPath: bundlePathName];
    pClass = [bundle principalClass];
    
    if ([pClass respondsToSelector: @selector(shared)]) {
        return [pClass performSelector:@selector(shared)];
    } else {
        return [pClass new];
    }
}

@end
