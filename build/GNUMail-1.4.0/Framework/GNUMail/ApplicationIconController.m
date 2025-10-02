/*
**  ApplicationIconController.m
**
**  Copyright (c) 2004-2007 Ludovic Marcotte
**  Copyright (c) 2017      Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "ApplicationIconController.h"

#import <Pantomime/CWFolder.h>
#import <Pantomime/CWStore.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWLocalStore.h>
#import <Pantomime/NSString+Extensions.h>

#import "Constants.h"
#import "MailboxManagerCache.h"
#import "MailboxManagerController.h"

static ApplicationIconController *singleInstance;
static NSMapTable *_cache;

#ifndef GNUSTEP
static NSUInteger previous_unread_count = NSNotFound;
#endif

@interface UglyHack : NSObject
-(NSSize)iconSize;
-(NSImage *)iconTileImage;
@end

//
//
//
void draw_value(int value, NSSize imageSize)
{
  NSMutableDictionary *attrs;
  NSString *aString;
  
  NSPoint text_location;
  NSRect disc_rect;
  NSSize disc_size;
  int image_width, pad;
  
  attrs = [[NSMutableDictionary alloc] init];
#ifdef MACOSX
  [attrs setObject: [NSFont fontWithName: @"Helvetica"  size: imageSize.width/4]  forKey: NSFontAttributeName];
#else
  [attrs setObject: [NSFont boldSystemFontOfSize: 0]  forKey: NSFontAttributeName];
#endif
  [attrs setObject: [NSColor blackColor]  forKey: NSForegroundColorAttributeName];
  
  aString = [NSString stringWithFormat: @"%d", value];
  disc_size = [aString sizeWithAttributes: attrs];
  
#ifdef MACOSX
  image_width = imageSize.width;
  pad = image_width / 8;
#else
  image_width = 64;
  pad = 8;
#endif
  disc_size.height += pad;
  disc_size.width += pad;
  disc_size.width = (disc_size.width < disc_size.height ? disc_size.height : disc_size.width);
  disc_size.height = (disc_size.height < disc_size.width ? disc_size.width : disc_size.height);

  disc_rect = NSMakeRect(image_width-disc_size.width-5,
			 image_width-disc_size.height-5,
			 disc_size.width,
			 disc_size.height);
  
  text_location = NSMakePoint(image_width-(disc_size.width - ((disc_size.width - [aString sizeWithAttributes: attrs].width) * 0.5))-5,
			      image_width-(disc_size.height - ((disc_size.height - [aString sizeWithAttributes: attrs].height) * 0.5))-4);
  
  [[NSColor colorWithDeviceRed: 1.0
	    green: 0.90
	    blue: 0.24
	    alpha: 1.0] set];
  [[NSBezierPath bezierPathWithOvalInRect: disc_rect] fill];
  [aString drawAtPoint: text_location  withAttributes: attrs];
  
  RELEASE(attrs);
}

//
// Set of all INBOX mailboxes (INBOXFOLDERNAME:s)
//
NSArray* inbox_folder_names()
{
  NSDictionary *allAccounts, *theAccount;
  NSEnumerator *theEnumerator;
  NSMutableArray *names;

  names = [NSMutableArray arrayWithCapacity: 10];
  allAccounts = [[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"];
  theEnumerator = [allAccounts keyEnumerator];
  
  while ((theAccount = [theEnumerator nextObject]))
    {
      [names addObject: [[[allAccounts objectForKey: theAccount] objectForKey: @"MAILBOXES"]
			  objectForKey: @"INBOXFOLDERNAME"]];
    }

  return names;
}


//
//
//
NSString* stringValueOfURLNameFromFolderName(NSString *folderName, id aStore)
{
  NSString *aString;
  
  if ([aStore isKindOfClass: [CWIMAPStore class]])
    {
      aString = [NSString stringWithFormat: @"imap://%@@%@/%@", 
			  [((CWIMAPStore *)aStore) username],
			  [((CWIMAPStore *)aStore) name],
			  folderName];
    }
  else
    {
      aString = [NSString stringWithFormat: @"local://%@/%@", 
			  [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"],
			  folderName];
    }
  
  return aString;
}

//
//
//
NSUInteger number_of_unread_messages()
{
  NSArray *allFolders, *allKeys;
  MailboxManagerCache *cache;
  NSString *aFolderName;
  id<NSObject> aStore;
  NSArray *inboxNames;
  BOOL inboxOnly;

  NSUInteger c, i, j, v, result;
  
  cache = [[MailboxManagerController singleInstance] cache];
  allKeys = NSAllMapTableKeys(_cache);
  result = 0;
  
  inboxOnly = [[NSUserDefaults standardUserDefaults] boolForKey: @"ShowUnreadForInboxOnly"];
  inboxNames = nil;

  if (inboxOnly)
    {
      inboxNames = inbox_folder_names();
    }
  
  for (i = 0; i < [allKeys count]; i++)
    {
      aStore = [allKeys objectAtIndex: i];
      allFolders = NSMapGet(_cache, aStore);
      c = [allFolders count];
      
      for (j = 0; j < c; j++)
	{
	  aFolderName = [allFolders objectAtIndex: j];

	  if (inboxOnly && ![inboxNames containsObject: stringValueOfURLNameFromFolderName(aFolderName, aStore)])
	    continue;
	  
	  [cache allValuesForStoreName: ([aStore isKindOfClass: [CWIMAPStore class]] ? (id)[(CWIMAPStore *)aStore name] : (id)@"GNUMAIL_LOCAL_STORE")
		 folderName: [aFolderName stringByReplacingOccurrencesOfCharacter: [(id<CWStore>)aStore folderSeparator]  withCharacter: '/']
		 username: ([aStore isKindOfClass: [CWIMAPStore class]] ? [(CWIMAPStore *)aStore username] : NSUserName())
		 nbOfMessages: NULL
		 nbOfUnreadMessages: &v];
	  result += v;
	}
    }
  
  return result;
}

//
//
//
#ifndef MACOSX
@interface ApplicationIconView : NSView
{
  @private
    NSImage *_icon;
    NSImage *_tile;
    NSPoint _borderPoint;
}
@end

@implementation ApplicationIconView

- (id) init
{
  id currentServer = nil;
  NSSize serverIconSize;

  self = [super init];
  if (self)
    {
      currentServer = [[[NSThread currentThread] threadDictionary] objectForKey:@"NSCurrentServerThreadKey"];
      _icon = [NSImage imageNamed: @"GNUMail"];
      [_icon setScalesWhenResized: YES];
      if (currentServer && [currentServer respondsToSelector: @selector(iconSize)])
	{
	  serverIconSize = [currentServer iconSize];
	  [_icon setSize: NSMakeSize(serverIconSize.width - (serverIconSize.width / 4),
				     serverIconSize.height - (serverIconSize.height / 4))];
	  _borderPoint = NSMakePoint(serverIconSize.width/8,serverIconSize.height/8);
	}
      else
	{
	  serverIconSize = NSMakeSize(64,64);
	  [_icon setSize: NSMakeSize(56,56)];
	  _borderPoint = NSMakePoint(0, 4);
	}
      RETAIN(_icon);

      _tile = nil;

      if (currentServer && [currentServer respondsToSelector:@selector(iconTileImage)])
	{
	  _tile = [[currentServer iconTileImage] copy];
	  [_tile setScalesWhenResized:YES];
	  [_tile setSize:serverIconSize];
	}
      else
	{
	  _tile = [NSImage imageNamed: @"common_Tile"];
	  RETAIN(_tile);
	}
      [self setFrame: NSMakeRect(0,0,serverIconSize.width,serverIconSize.height)];
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_icon);
  TEST_RELEASE(_tile);
  [super dealloc];
}

- (BOOL) acceptsFirstMouse: (NSEvent *) theEvent
{
  return YES;
}

- (void) drawRect: (NSRect) theRect
{
  NSUInteger v;

  [_tile compositeToPoint: NSMakePoint(0,0)  operation: NSCompositeSourceAtop];

  [_icon compositeToPoint: _borderPoint operation: NSCompositeSourceOver];
  v = number_of_unread_messages();

  if (v > 0)
    {
      draw_value(v, theRect.size);
    }

  if ([NSApp isHidden])
    {
      NSRectEdge mySides[] = {NSMinXEdge, NSMinYEdge, NSMaxXEdge, NSMaxYEdge};
      const CGFloat myGrays[] = {NSBlack, NSWhite, NSWhite, NSBlack};
      NSDrawTiledRects(NSMakeRect(4, 4, 3, 2), theRect, mySides, myGrays, 4);
    }
}

- (void) mouseDown: (NSEvent *) theEvent
{
  [[self superview]  mouseDown: theEvent];
}

@end
#endif



//
//
//
@implementation ApplicationIconController

- (id) init
{
  self = [super init];
  
  if (self)
    {
      _cache = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 16);

#ifndef MACOSX
      [[[NSApp iconWindow] contentView] addSubview: AUTORELEASE([[ApplicationIconView alloc] init])];
#endif

      [[NSNotificationCenter defaultCenter]
	addObserver: self
	   selector: @selector(folderListCompleted:)
	       name: PantomimeFolderListCompleted
	     object: nil];

      [[NSNotificationCenter defaultCenter]
	addObserver: self
	   selector: @selector(connectionTerminated:)
	       name: PantomimeConnectionTerminated
	     object: nil];
 
      [[NSNotificationCenter defaultCenter]
	addObserver: self
	   selector: @selector(folderListCompleted:)
	       name: PantomimeFolderListSubscribedCompleted
	     object: nil];  
    }

  return self;
}


//
//
//
- (void) dealloc
{
  NSArray *keys;
  NSUInteger u;

  keys = NSAllMapTableKeys(_cache);
  for (u = 0; u < [keys count]; u++)
    [[keys objectAtIndex:u] release];
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  NSFreeMapTable(_cache);
  _cache = nil;
  [super dealloc];
}

//
//
//
- (void) update
{
#ifndef MACOSX
  [[[NSApp iconWindow] contentView] setNeedsDisplay: YES];
#elif defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
  NSImage *currImage = [NSApp applicationIconImage];
  NSImage *image;
  NSUInteger v;
  
  image = [NSImage imageNamed: @"GNUMail"];
  [image setScalesWhenResized:YES];
  [image setSize: [currImage size]];
  [image lockFocus];
  
  v = number_of_unread_messages();

  if (previous_unread_count != NSNotFound && previous_unread_count < v)
    {
      [NSApp requestUserAttention: NSInformationalRequest];
    }

  previous_unread_count = v;

  if (v > 0)
    {
      draw_value(v, [image size]);
    }
  
  [image unlockFocus];
  [NSApp setApplicationIconImage: image];
#else
  NSUInteger v;

  v = number_of_unread_messages();
    
  if (previous_unread_count != NSNotFound && previous_unread_count < v)
    {
      [NSApp requestUserAttention: NSInformationalRequest];
    }
    
    previous_unread_count = v;
    
    if (v > 0)
      {
	NSDockTile *dt;
	  
	dt = [NSApp dockTile];
	[dt setBadgeLabel:[NSString stringWithFormat:@"%d", (unsigned long)v]];
      }
#endif
}

//
//
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[ApplicationIconController alloc] init];
    }

  return singleInstance;
}


//
//
//
- (void) connectionTerminated: (NSNotification *) theNotification
{
  id o;

  o = [theNotification object];
  if (NSMapMember(_cache, o, NULL, NULL))
    {
      [o release];
      NSMapRemove(_cache, o);
    }
  [self update];
}

//
//
//
- (void) folderListCompleted: (NSNotification *) theNotification
{
  id o;

  o = [theNotification object];
  //
  // We skip those notifications for the STATUS'ing task AND
  // we verify if it's our LocalStore (since it's not added to the allStores ivar in MailboxManagerController)
  //
  if ([[[[MailboxManagerController singleInstance] allStores] allValues] containsObject: o] ||
      [o isKindOfClass: [CWLocalStore class]])
    {
      if (!NSMapMember(_cache, o, NULL, NULL))
        [o retain];
      NSMapInsert(_cache, o, [[[theNotification userInfo] objectForKey: @"NSEnumerator"] allObjects]);
      [self update];
    }
}
@end
