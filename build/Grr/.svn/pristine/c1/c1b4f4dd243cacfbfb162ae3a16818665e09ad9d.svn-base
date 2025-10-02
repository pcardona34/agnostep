/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2010  GNUstep Application Team
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

#import <RSSKit/RSSArticleProtocol.h>

#import "ArticleOperations.h"
#import "Article.h"

#ifdef __APPLE__
#import "GNUstep.h"
#endif

#define BROWSE_IDENTIFIER @"Article.Ops.Browse"

@implementation ArticleOperationsComponent


-(id)init
{
    if ((self = [super init]) != nil)
    {
        NSArray* identifiers;
        NSMenu* menu;
        
        menu = [[[NSApp mainMenu] itemWithTag:2] submenu];

        // Article browsing toolbar item
        browseItem = [[NSToolbarItem alloc] initWithItemIdentifier: BROWSE_IDENTIFIER];
        [browseItem setLabel: _(@"View in WWW")];
        [browseItem setImage: [NSImage imageNamed: @"ArticleLink"]];
        [browseItem setAction: @selector(browseSelectedArticles)];
        [browseItem setTarget: self];
        
        // Article browsing menu item
        browseMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"View in WWW")
                                                    action: @selector(browseSelectedArticles)
                                             keyEquivalent: @"b"];
        [browseMenuItem setTarget: self];
        
        // Add the menu
        [menu addItem: browseMenuItem];

        
        // Provided identifiers
        identifiers = [NSArray arrayWithObjects:
            BROWSE_IDENTIFIER,
            nil
        ];
        ASSIGN(allowedIdentifiers, identifiers);
        ASSIGN(defaultIdentifiers, allowedIdentifiers);
        
        // Init selected articles with empty set
        ASSIGN(selectedArticles, [NSSet new]);        
    }
    
    return self;
}

// input accepting component protocol

-(void)componentDidUpdateSet: (NSNotification*) aNotification
{
    BOOL isEnabled;
    id<OutputProvidingComponent> component = [aNotification object];
    
    ASSIGN(selectedArticles, [component objectsForPipeType: [PipeType articleType]]);
    
    isEnabled = ([selectedArticles count] > 0) ? YES : NO;
    [browseItem setEnabled: isEnabled];
    
    #ifdef GRRRDEBUG
    [debugItem setEnabled: isEnabled];
    #endif
}



// toolbar delegate protocol

- (NSToolbarItem*)toolbar: (NSToolbar*)toolbar
    itemForItemIdentifier: (NSString*)itemIdentifier
willBeInsertedIntoToolbar: (BOOL)flag
{
    if ([itemIdentifier isEqualToString: BROWSE_IDENTIFIER]) {
        return browseItem;
    }
    #ifdef GRRRDEBUG
    else if ([itemIdentifier isEqualToString: @"Grr Debug Article"]) {
        return debugItem;
    }
    #endif
    
    return nil; // this identifier was not found here
}

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*)toolbar
{
    return allowedIdentifiers;
}

- (NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar*)toolbar
{
    return defaultIdentifiers;
}


// own methods

-(void)browseSelectedArticles
{
    NSEnumerator* enumerator = [selectedArticles objectEnumerator];
    id<RSSArticle> article;
    
    while ((article = [enumerator nextObject]) != nil) {
        [[NSWorkspace sharedWorkspace] openURL: [article url]];
    }
}

#ifdef GRRRDEBUG
-(void)debugSelectedArticles
{
    NSEnumerator* enumerator = [selectedArticles objectEnumerator];
    id<Article> article;
    
    while ((article = [enumerator nextObject]) != nil)
    {
        NSLog(@"Article %@ is \n%@", [article headline], [article plistDictionary]);
        NSLog(@"Storage reseult: %d", [article store]);
    }
}
#endif

@end
