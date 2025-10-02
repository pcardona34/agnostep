/**
    ScriptingSupport
    Code for loading scripting
    
    Copy and include this file into your application project.
    
    NOTE: Please, do not modify this file. It is part of the StepTalk and
    depends on its interface.   
  
    Copyright (c) 2002 Stefan Urbanek
  
    Written by: Stefan Urbanek <stefanurbanek@yahoo.fr>
    Date: 2002 Apr 13
 
    This file is part of the StepTalk project.
 
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
  
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

   */


#import "STScriptingSupport.h"

#import <AppKit/NSPanel.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSString.h>

@interface NSApplication (STPrivateMethods)
- (BOOL)setUpApplicationScripting;
- (NSBundle *)_applicationScriptingBundle;
@end

@implementation NSApplication (STApplicationScripting)

- (NSBundle *)_applicationScriptingBundle
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator  *enumerator;
    NSString      *path;
    NSArray       *paths;
    BOOL           isDir;

    paths = NSStandardLibraryPaths();

    enumerator = [paths objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
    
        path = [path stringByAppendingPathComponent:@"Bundles"];
        path = [path stringByAppendingPathComponent:@"ApplicationScripting"];
        path = [path stringByAppendingPathExtension:@"bundle"];

        if( [manager fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            return [NSBundle bundleWithPath:path];
        }
    }
    
    return nil;
}

- (BOOL)initializeApplicationScripting
{
    NSBundle      *bundle;

    if(![self isScriptingSupported])
    {
        NSRunAlertPanel(@"Scripting is not available",
                        @"Application scripting bundle is not installed. ",
                        @"Cancel", nil, nil);
        return NO;
    }

    NSLog(@"Loading application scripting support");

    bundle = [self _applicationScriptingBundle];

    if(bundle)
    {
        /* Load the bundle! */

        [[bundle principalClass] class];
        if([self respondsToSelector:@selector(setUpApplicationScripting)])
        {
            return [self setUpApplicationScripting];
        }
        else
        {
            NSRunAlertPanel(@"Broken scripting support",
                            @"Scripting support cannot be loaded, because "
                            @"the application scripting bundle is broken.",
                            @"Cancel", nil, nil);
            return NO;
        }
    }
    else
    {
        NSRunAlertPanel(@"Cannot initialize scripting",
                        @"Unable to load application scripting bundle.",
                        @"Cancel", nil, nil);
        return NO;
    }
}

- (BOOL)isScriptingSupported
{
    return ([self _applicationScriptingBundle] != nil);
}

- (void)_loadAppTalkAndRetryAction:(SEL)sel with:(id)anObject
{
    static BOOL isIn = NO;
    
    if(isIn)
    {
        NSLog(@"Error occurred while loading application scripting support");

        isIn = NO;
        return;
    }
    
    isIn = YES;

    if([self initializeApplicationScripting])
    {
        [self performSelector:sel withObject:anObject];
    }

    isIn = NO;
}

- (id)_loadAppTalkAndRetryAction:(SEL)sel
{
    static BOOL isIn = NO;
    id          retval = nil;
    
    if(isIn)
    {
        NSLog(@"Error occurred while loading application scripting support");

        isIn = NO;
        return nil;
    }
    
    isIn = YES;

    if([self initializeApplicationScripting])
    {
        retval = [self performSelector:sel];
    }

    isIn = NO;
    
    return retval;
}

- (void)orderFrontScriptsPanel:(id)sender
{
    [self _loadAppTalkAndRetryAction:_cmd with:sender];
}

- (void)orderFrontTranscriptWindow:(id)sender
{
    [self _loadAppTalkAndRetryAction:_cmd with:sender];
}

- (NSMenu *)scriptingMenu
{
    return [self _loadAppTalkAndRetryAction:_cmd];
}
@end
