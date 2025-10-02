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

#import "ArticleTextViewPlugin.h"
#import "Article.h"

#import "NSString+TolerantHTML.h"
#import "ExtendedWindow.h"

#ifdef __APPLE__
#import "GNUstep.h"
#endif

@implementation ArticleTextViewPlugin

-(void)awakeFromNib
{
    NSNotificationCenter* notifCenter;

    [_view retain];
    ASSIGN(textView, [scrollView documentView]);
    
    [textView setDelegate: self];
    
    notifCenter = [NSNotificationCenter defaultCenter];
    
    [notifCenter addObserver: self
                    selector: @selector(scrollUp:)
                        name: ScrollArticleUpNotification
                      object: nil];
    
    [notifCenter addObserver: self
                    selector: @selector(scrollDown:)
                        name: ScrollArticleDownNotification
                      object: nil];
}

-(void)componentDidUpdateSet: (NSNotification*) aNotification
{
    NSSet* articles = [[aNotification object] objectsForPipeType: [PipeType articleType]];
    
    if ([articles count] == 1) {
        id<Article> article = [[articles allObjects] objectAtIndex: 0];
        [headlineView setStringValue: [article headline]];
        
        NS_DURING
          [[textView textStorage] setAttributedString: [[article content] parseHTML]];
        NS_HANDLER
          NSLog(
              @"ERROR: HTML PARSING:\n name: %@\n desc: %@",
              [localException name],
              [localException description]
          );
          [[textView textStorage] setAttributedString:
              AUTORELEASE([[NSAttributedString alloc] initWithString: [article content]])];
        NS_ENDHANDLER
        [article setRead: YES];
        
        // Scroll to top
        //[textView scrollRangeToVisible: NSMakeRange(0,0)];
        [[scrollView contentView] scrollToPoint: NSMakePoint(0.0,0.0)];
    } else if ([articles count] == 0) {
        [headlineView setStringValue: NSLocalizedString(
            @"No articles selected.",
            @"Shown in the article view headline"
        )];
        [textView setString: @""];
    } else {
        // too many articles
        [headlineView setStringValue: [NSString stringWithFormat: NSLocalizedString(
                @"%d articles selected",
                @"Shown in the article view headline"
            ), [articles count]]];
        [textView setString: NSLocalizedString(
            @"\nPlease select only one article.",
            @"Shown in the article view text area"
        )];
    }
}

-(void) scrollDown: (id)sender
{
    [self scrollWithDownFlag: YES];
}

-(void) scrollUp: (id)sender
{
    [self scrollWithDownFlag: NO];
}

/**
 * Scrolls the visible part of the article view down or up.
 */
-(void) scrollWithDownFlag: (BOOL) isDown
{
    NSRect aRect = [scrollView documentVisibleRect];
    
    double delta = aRect.size.height - [scrollView verticalPageScroll];
    
    if (isDown == NO) {
        delta = -delta;
    }
    
    aRect.origin.y += delta;
    
    [textView scrollRectToVisible: aRect];
}

/**
 * Is executed when the user clicks a link.
 */
-(BOOL) textView: (NSTextView*) textView
   clickedOnLink: (id) link
         atIndex: (NSUInteger) charIndex
{
    BOOL result = NO;
    NSLog(@"textView:clickedOnLink: %@ atIndex: %lu", link, (unsigned long)charIndex);
    
    if ([link isKindOfClass: [NSURL class]]) {
        result = [[NSWorkspace sharedWorkspace] openURL: (NSURL*)link];
    }
    
    return result;
}
@end
