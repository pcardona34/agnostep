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

#import "Database.h"
#import "NSBundle+Extensions.h"

#ifdef __APPLE__
#import "GNUstep.h"
#endif

static id<Database> sharedDatabase = nil;

NSString* const GrrDatabasePluginNameDefaults = @"DatabasePluginName";
NSString* const DatabaseChangeNotification = @"DatabaseChangeNotification";

@implementation Database

+(id<Database>) shared
{
    if (sharedDatabase == nil) {
        id<Database> database;

        // Find out the name of the database plugin to be loaded. The default is
        // "TreeDatabase", but it can be overridden using the DatabasePluginName
        // user default. For details, see the documentation on hacking a database
        // in the documentation directory.
        NSString* databasePluginName =
            [[NSUserDefaults standardUserDefaults] objectForKey: GrrDatabasePluginNameDefaults];
        
        if (databasePluginName == nil) {
            databasePluginName = @"TreeDatabase";
        }
        
        database = [NSBundle instanceForBundleWithName: databasePluginName type: @"grrdb"];
        
        NSAssert(database != nil, @"The database could not be loaded!");
        NSAssert1(
            [database conformsToProtocol: @protocol(Database)],
            @"Database %@ does not conform to the database protocol.",
            database
        );
        
        ASSIGN(sharedDatabase, database);
    }
    
    return sharedDatabase;
}

@end
