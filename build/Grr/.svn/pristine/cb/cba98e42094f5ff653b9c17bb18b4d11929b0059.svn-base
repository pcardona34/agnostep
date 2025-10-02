/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2012 GNUstep Application Team
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

#import "SubscriptionPanel.h"

#import "Database.h"

#ifdef __APPLE__
#import "GNUstep.h"
#endif

@implementation SubscriptionPanel

// -----------------------------------------------------
//    initialisation
// -----------------------------------------------------

+(id) shared
{
  static SubscriptionPanel* controller = nil;
    
  if (controller == nil)
    {
      ASSIGN(controller, [SubscriptionPanel new]);
    }
    
  return controller;
}

-(id) init
{
  if ((self = [super init]) != nil)
  {
    BOOL nibLoaded;
    
    nibLoaded = [NSBundle loadNibNamed:@"SubscriptionPanel" owner:self];
    if (nibLoaded == NO)
    {
      NSLog(@"SubscriptionPanel: Failed to load nib.");
      return nil;
    }
  }
  
  return self;
}

-(void) dealloc
{
    DESTROY(panel);
    DESTROY(referenceElement);
    
    [super dealloc];
}


// ------------------------------------------------------------
//    SubscriptionPanel protocol (see FeedOperations component)
// ------------------------------------------------------------

-(void) show
{
    [panel makeKeyAndOrderFront: self];
}

-(void) setReferenceElement: (id<DatabaseElement>) anElement
{
    ASSIGN(referenceElement, anElement);
}


// ------------------------------------------------------------
//    helper methods
// ------------------------------------------------------------

-(BOOL) subscribeToURL: (NSURL*) url
{
    BOOL result = NO;
    NSParameterAssert([url isKindOfClass: [NSURL class]]);
    
    if (referenceElement != nil) {
        if ([referenceElement conformsToProtocol: @protocol(Category)]) {
            result = [[Database shared] subscribeToURL: url
                                            inCategory: (id<Category>)referenceElement];
        } else {
            NSUInteger index = 0;
            id<Category> category;

            NSAssert1(
                [referenceElement conformsToProtocol: @protocol(DatabaseElement)],
                @"The reference element %@ is not a DatabaseElement.", referenceElement
            );
            
            // The category to put the subscription into is the super category of the
            // reference element, the index is one below the reference element.
            category = [referenceElement superElement];
            if (category != nil) {
                index = [[category elements] indexOfObject: referenceElement] + 1;
            } else {
                // The ref elements category was nil, so it's a top level element in the database.
                index = [[[Database shared] topLevelElements] indexOfObject: referenceElement];
                
                NSAssert(index != NSNotFound, @"The reference element points to a bad super element!");
                index ++;
            }
            
            result = [[Database shared] subscribeToURL: url
                                            inCategory: category
                                              position: index];
        }
    } else {
        result = [[Database shared] subscribeToURL: url];
    }
    
    return result;
}

// ------------------------------------------------------------
//    GUI actions
// ------------------------------------------------------------

-(IBAction) subscribe: (id)sender
{
    NSURL* URL = [NSURL URLWithString: [urlField stringValue]];
    NSLog(@"URL: %@", [urlField stringValue]);
    
    if (URL == nil) {
        NSRunAlertPanel(
            NSLocalizedString(@"Subscription failed", @"title of an alert dialog"),
            NSLocalizedString(
                @"The string you provided is not in URL format.",
                @"failure reason in alert dialog"
            ),
            _(@"Ok"), nil, nil
        );
    } else {
        // URL is valid.
        
        if ([self subscribeToURL: URL]) {
            // success
            [panel close];
        } else {
            // could not subscribe
            NSRunAlertPanel(
                NSLocalizedString(@"Subscription failed", @"alert message title"),
                NSLocalizedString(
                    @"Your subscription failed. Possible reasons include:\n"
                    @"\t- There's not a RSS or Atom document stored at this URL\n"
                    @"\t- Incorrect Web Proxy settings\n",
                    @"failure reason in alert dialog"
                ),
                _(@"Ok"), nil, nil
            );
        }
    }
}

@end
