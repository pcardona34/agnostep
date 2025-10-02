//  $Id: FSKeyGroup.m,v 1.3 2014/01/26 09:23:53 buzzdee Exp $
//
//  FSKeyGroup.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 26-SEP-2001.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//  2008-2010 GNUstep Application Project
//            Riccardo Mottola
//  
//  Redistribution and use in source and binary forms,  with or without
//  modification,  are permitted provided that the following conditions
//  are met:
//  
//  *  Redistributions of source code must retain the above copyright
//     notice,  this list of conditions and the following disclaimer.
//  
//  *  Redistributions  in  binary  form  must  reproduce  the  above
//     copyright notice,  this  list of conditions  and the following
//     disclaimer  in  the  documentation  and / or  other  materials
//     provided with the distribution.
//  
//  *  Neither the name  "FlexiSheet"  nor the names of its copyright
//     holders  or  contributors  may  be used  to endorse or promote
//     products  derived  from  this software  without specific prior
//     written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT
//  LIMITED TO,  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND  FITNESS
//  FOR  A PARTICULAR PURPOSE  ARE  DISCLAIMED.  IN NO EVENT  SHALL THE
//  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO,  PROCUREMENT  OF  SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN
//  ANY WAY  OUT  OF  THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//  

#include <assert.h>

#import "FSCore.h"
#import "FoundationExtentions.h"
#import "FSParserFunctions.h"
#import "FSHashMap.h"
#import <AppKit/NSPasteboard.h>


@implementation FSKeyGroup
/*" An FSKeyGroup instance is a list of FSKey objects,
    grouped together with a label. Groups can contain
    other groups.
        
    FSKeyGroup is the super class of FSHeader,
    FlexiSheet's implementation of a category.
    
    A group belongs to a parent group, except for
    headers which belong to a table."*/

+ (FSKeyGroup*)groupWithLabel:(NSString*)label
/*" Creates an empty group with the name label. "*/
{
    FSKeyGroup *instance = [[FSKeyGroup alloc] init];
    [instance setLabel:label];
    return [instance autorelease];
}


+ (FSKeyGroup*)groupWithKeys:(NSArray*)keys
{
    FSKeyGroup *instance = [[FSKeyGroup alloc] init];
    [instance setItems:(NSArray*)keys];
    return [instance autorelease];
}


- (id)init
/*" Designated initializer.  The name is set to Group. "*/
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _itemLookup = [[FSHashMap alloc] init];
        _label = @"Group";
        _fullPath = nil;
        _cachedKeys = nil;
        _cachedGroups = nil;
        TEST_DBG [FSLog logDebug:@"%@ %X allocated.", [self className], self];
    }
    return self;
}


- (void)dealloc
/*" Releases all retained resources and frees the object memory. "*/
{
    [_cachedUM removeAllActionsWithTarget:self];
    [_label release];
    [_items makeObjectsPerformSelector:@selector(removeFromHeader)];
    [_itemLookup release];
    [_items release];
    [_fullPath release];
    [_cachedKeys release];
    [_cachedGroups release];
    // _parent is not retained!
    TEST_DBG [FSLog logDebug:@"%@ %X deallocated.", [self className], self];
    [super dealloc];
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ '%@':\n%@",
        [self className], _label, [_items description]];
}


- (void)_recacheKeys
{
    [_cachedGroups release];
    _cachedGroups = nil;
    [_cachedKeys release];
    _cachedKeys = nil;
    [_group _recacheKeys];
}


- (void)_removeItems
// Called internally
{
    [_items removeAllObjects];
    [_itemLookup removeAllObjects];
}


- (id<FSDocument>)document
/*" Returns the FSDocument this key group belongs to. "*/
{
    return (id<FSDocument>)[_group document];
}

- (FSTable*)table
/*" Returns the FSTable this key group belongs to. "*/
{
    return [_group table];
}


- (FSHeader*)header
{
    if (_group) return [_group header];
    return (FSHeader *) self;
}


- (NSString*)fullPath
    /*" Returns the full path from the header to this group. Path elements
        are wrapped in single quotes. "*/
{
    FSKeyGroup *group = _group;
    NSString   *result = (_group != nil)?_label:@"";

    while ([group group]) {
        result = [NSString stringWithFormat:@"%@.%@",
            [group label], result];
        group = [group group];
    }

    return result;
}


- (FSKeyGroup*)group
/*" Returns the FSKeyGroup this group belongs to. "*/
{
    return _group;
}


- (void)setGroup:(FSKeyGroup*)group
{
    if (group && _group) {
        NSAssert([group header] == [self header],
            @"Setting group's group to an invalid object.");
    }
    _group = group;
}


- (void)removeFromHeader
{
    [self setGroup:nil];
}


- (NSString*)_uniqueLabel:(NSString*)name
{
    while ([self itemWithLabel:name]) {
        name = [name followingString];
    }
    return name;
}


- (NSString*)label
/*" Returns the name of this key group. "*/
{
    return _label;
}


- (void)setLabel:(NSString*)label
/*" Sets the name of this key group.  This method does not check for name conflicts within the document! "*/
{
    NSNotificationCenter *nc = [[self table] notificationCenter];
    SEL                   selector;
    NSMethodSignature    *signature;
    NSInvocation         *invocation;
    NSString             *oldPath;

    if ([label isEqualToString:_label]) return;
    assert(label != nil);
    
    [[[self table] undoManager] 
        registerUndoWithTarget:self selector:@selector(setLabel:) object:_label];
    [nc postNotificationName:FSTableWillChangeNotification object:[self table]];
    [nc postNotificationName:FSItemWillChangeNotification object:[self table]
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
            self, [self className], label, FSNewNameUserInfo, nil]];
    oldPath = [self fullPath];
    [_label release];
    _label = [label copy];
    [nc postNotificationName:FSItemDidChangeNotification object:[self table]
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
            self, [self className], oldPath, FSOldPathUserInfo, nil]];
    [nc postNotificationName:FSTableDidChangeNotification object:[self table]];

    selector = @selector(setLabel:forItemWithPath:);
    signature = [FSHeader instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setArgument:&label atIndex:2];
    [invocation setArgument:&oldPath atIndex:3];
    [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
        userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];
}


- (void)setItems:(NSArray*)items
{
    int index = [items count];
    id  anItem;

    [_items removeAllObjects];
    [_itemLookup removeAllObjects];
    [_items addObjectsFromArray:items];
    [_items makeObjectsPerformSelector:@selector(setGroup:) withObject:self];

    while (index-- > 0) {
        anItem = [_items objectAtIndex:index];
        [_itemLookup setObject:anItem forKey:[[anItem label] UTF8String]];
    }
}

- (NSArray*)items
/*" Returns an immutable array containing all items in this group. "*/
{
    return _items;
}


NSArray* FSExpandItemsToKeys(NSArray *items)
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:items];
    int             index = 0;
    id<FSItem>      item;
    
    while (index < [keys count]) {
        item = [keys objectAtIndex:index];
        if ([item isKindOfClass:[FSKeyGroup class]]) {
            NSArray *subKeys = [(FSKeyGroup*)item keys];
            [keys replaceObjectsInRange:NSMakeRange(index,1)
                withObjectsFromArray:subKeys];
            index += [subKeys count];
        } else
            index++;
    }
    return keys;
}


- (NSArray*)keys
/*" Returns a list of all keys in the group.
    Nested groups are flatted. "*/
{
    if (_cachedKeys) return _cachedKeys;
    
    _cachedKeys = FSExpandItemsToKeys(_items);
    [_cachedKeys retain];
    
    return _cachedKeys;
}


NSArray* FSExpandItemsToGroups(NSArray *items)
{
    NSMutableArray *groups = [NSMutableArray arrayWithArray:items];
    int             index = 0;
    id<FSItem>      item;
    
    while (index < [groups count]) {
        item = [groups objectAtIndex:index];
        if ([item isKindOfClass:[FSKeyGroup class]]) {
            [groups addObjectsFromArray:[(FSKeyGroup*)item items]];
            index++;
        } else {
            [groups removeObjectAtIndex:index];
        }
    }
    return groups;
}


- (NSArray*)subgroups
{
    if (_cachedGroups) return _cachedGroups;
    
    _cachedGroups = FSExpandItemsToGroups(_items);
    [_cachedGroups retain];
    
    return _cachedGroups;
}


- (NSArray*)groups
{
    NSMutableArray *groups = [NSMutableArray array];
    FSKeyGroup     *group = _group;
    
    if (group == nil) return nil;
    
    while ([group group]) {
        [groups addObject:group];
        group = [group group];
    }
    
    return groups;
}


- (FSKey*)appendKeyWithLabel:(NSString*)label
/*" Returns the key for the given label, creating and appending it if it doesn't exist. "*/
{
    return [self insertKeyWithLabel:label atIndex:[_items count]];
}


- (void)moveItemFromIndex:(unsigned)idx1 toIndex:(unsigned)idx2
/*" Moves the key at index idx1 to index idx2. 
    Both idx1 and idx2 must be in the range
    of valid indices for this group. "*/
{
    SEL                   selector;
    NSMethodSignature    *signature;
    NSInvocation         *invocation;
    FSKey                *tempKey;
    FSTable              *table = [self table];
    NSString             *path = [self fullPath];
    NSNotificationCenter *nc = [table notificationCenter];
    
    assert(idx1 < [_items count]);
    assert(idx2 <= [_items count]); // To index can be one beyond last

    [nc postNotificationName:FSTableWillChangeNotification object:table];
    [[[table undoManager] prepareWithInvocationTarget:self]
        moveItemFromIndex:idx2-(idx2>idx1?1:0) toIndex:idx1+(idx2<idx1?1:0)];

    selector = @selector(moveItemFromIndex:toIndex:atPath:);
    signature = [FSHeader instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setArgument:&idx1 atIndex:2];
    [invocation setArgument:&idx2 atIndex:3];
    [invocation setArgument:&path atIndex:4];
    [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
        userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];
        
    tempKey = [_items objectAtIndex:idx1];    
    [_items insertObject:tempKey atIndex:idx2];
    if (idx1 > idx2) idx1++;
    [_items removeObjectAtIndex:idx1];
    [self _recacheKeys];
    [nc postNotificationName:FSTableDidChangeNotification object:table];
}


- (FSKey*)insertKeyWithLabel:(NSString*)label atIndex:(int)index
/*" Returns the key for the given label, creating and inserting it at index if it doesn't exist. "*/
{
    NSNotificationCenter *nc = [[self table] notificationCenter];
    FSKey                *newKey = [self keyWithLabel:label];

    if (newKey == nil) {
        SEL                   selector;
        NSMethodSignature    *signature;
        NSInvocation         *invocation;
        NSString             *fullPath = [self fullPath];
        
        [nc postNotificationName:FSTableWillChangeNotification object:[self table]];
        newKey = [[FSKey alloc] initWithGroup:self];
        [newKey setLabel:label];
        if ([_items count] > index) {
            [_items insertObject:newKey atIndex:index];
        } else {
            [_items addObject:newKey];
        }
        [newKey release];
        [self _recacheKeys];
        [[[self table] undoManager] registerUndoWithTarget:self
            selector:@selector(removeItemWithLabel:) object:label];
        [nc postNotificationName:FSTableDidChangeNotification object:[self table]];

        selector = @selector(insertKeyWithLabel:intoGroupWithPath:atIndex:);
        signature = [FSHeader instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setArgument:&label atIndex:2];
        [invocation setArgument:&fullPath atIndex:3];
        [invocation setArgument:&index atIndex:4];
        [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
            userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];
    }

    return newKey;
}


- (int)removeItemWithLabel:(NSString*)label
/*" Returns the index at which label was, or -1 if it wasn't in the header. "*/
{
    int idx = [_items count];
    
    while (idx-- > 0) {
        if ([[[_items objectAtIndex:idx] label] isEqualToString:label]) {
            [self deleteItemsInRange:NSMakeRange(idx,1)];
            [self _recacheKeys];
            return idx;
        }
    }
    
    return -1;
}


- (NSDictionary*)_kidsDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSEnumerator        *cursor;
    id<FSItem>           item;
    
    cursor = [[self keys] objectEnumerator];
    while ((item = [cursor nextObject])) {
        [result setObject:item forKey:[item fullPath]];
    }
    
    cursor = [[self subgroups] objectEnumerator];
    while ((item = [cursor nextObject])) {
        [result setObject:item forKey:[item fullPath]];
    }
    
    return result;
}


- (void)_notifyChangeForKidsInDictionary:(NSDictionary*)kids
{
    NSEnumerator         *cursor = [kids keyEnumerator];
    NSString             *key;
    NSObject<FSItem>     *item;
    FSTable              *table = [self table];
    NSNotificationCenter *nc = [table notificationCenter];
    
    while ((key = [cursor nextObject])) {
        item = [kids objectForKey:key];
        [nc postNotificationName:FSItemDidChangeNotification object:table
            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                item, [item className], key, FSOldPathUserInfo, nil]];
    }
}


- (FSKeyGroup*)groupItemsInRange:(NSRange)range withLabel:(NSString*)label
/*" Replaces the items in range with a group containing these items. "*/
{
    FSTable              *table = [self table];
    NSNotificationCenter *nc = [table notificationCenter];
    SEL                   selector;
    NSMethodSignature    *signature;
    NSInvocation         *invocation;
    FSKeyGroup           *newGroup;
    NSDictionary         *kids = [self _kidsDictionary];
    NSArray              *items;
    id<FSItem>            anItem;
    int                   index;
    
    if (range.length == 0) return nil;
    
    [nc postNotificationName:FSTableWillChangeNotification object:table];
    newGroup = [FSKeyGroup groupWithLabel:label];
    [newGroup setGroup:self];
    // We will remove these from the group.
    items = [_items subarrayWithRange:range];
    [newGroup setItems:items];
    index = [items count];
    while (index-- > 0) {
        anItem = [items objectAtIndex:index];
        [_itemLookup removeObjectForKey:[[anItem label] UTF8String]];
    }
    [_items replaceObjectsInRange:range
        withObjectsFromArray:[NSArray arrayWithObject:newGroup]];
    [[[table undoManager] prepareWithInvocationTarget:self]
        ungroupAtIndex:range.location];
    [_itemLookup setObject:newGroup forKey:[label UTF8String]];
    [self _recacheKeys];

    selector = @selector(groupItemsInRange:withLabel:);
    signature = [FSHeader instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setArgument:&range atIndex:2];
    [invocation setArgument:&label atIndex:3];
    [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
                    userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];

    [self _notifyChangeForKidsInDictionary:kids];
    [nc postNotificationName:FSTableDidChangeNotification object:table];
    return newGroup;
}


- (void)ungroupAtIndex:(unsigned)index
{
    FSTable              *table = [self table];
    NSNotificationCenter *nc = [table notificationCenter];
    FSKeyGroup           *group = [_items objectAtIndex:index];
    
    if ([group isKindOfClass:[FSKeyGroup class]]) {
        SEL                selector;
        NSMethodSignature *signature;
        NSInvocation      *invocation;
        NSArray           *items = [group items];
        NSDictionary      *kids = [group _kidsDictionary];
        int i;
        
        [nc postNotificationName:FSTableWillChangeNotification object:table];
        [items retain];
        [[[table undoManager] prepareWithInvocationTarget:self]
            groupItemsInRange:NSMakeRange(index,[items count])
            withLabel:[group label]];
        for (i = 0; i < [items count]; i++) {
            id itm = [items objectAtIndex:i];
            [itm setLabel:[self _uniqueLabel:[itm label]]];
            [_itemLookup setObject:itm forKey:[[itm label] UTF8String]];
        }
        [group retain]; // So we don't lose it
        [_items replaceObjectsInRange:NSMakeRange(index,1) withObjectsFromArray:items];
        [items makeObjectsPerformSelector:@selector(setGroup:) withObject:self];
        [items release];
        [group _removeItems];
        [group setGroup:nil];
        [group release];
        [self _recacheKeys];

        selector = @selector(ungroupAtIndex:);
        signature = [FSHeader instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setArgument:&index atIndex:2];
        [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
                        userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];

        [self _notifyChangeForKidsInDictionary:kids];
        [nc postNotificationName:FSTableDidChangeNotification object:table];
    }
}


- (void)ungroupItemsInGroup:(FSKeyGroup*)group
{
    NSUInteger index = [_items indexOfObject:group];
    if (index != NSNotFound) [self ungroupAtIndex:index];
}


- (id)itemWithLabel:(NSString*)label
/*" Returns the item for the given label, or nil if it doesn't exist. "*/
{
    if ([label isSingleQuotedString]) {
        label = [label stringByTrimmingQuotes]; 
    }

    return [_itemLookup objectForKey:[label UTF8String]];
}


- (BOOL)item:(id<FSItem>)item willBeLabeled:(NSString*)newLabel
{
    FSHashKey key = [newLabel UTF8String];
    if ([_itemLookup objectForKey:key] != nil)
        return NO;
    [_itemLookup removeObjectForKey:[[item label] UTF8String]];
    [_itemLookup setObject:item forKey:key];
    return YES;
}


- (FSKey*)keyWithLabel:(NSString*)label
/*" Returns the key for the given label, or nil if it doesn't exist. "*/
{
    id item;

    if ([label isSingleQuotedString]) {
        label = [label stringByTrimmingQuotes];
    }

    item = [_itemLookup objectForKey:[label UTF8String]];
    if ([item isKindOfClass:[FSKey class]]) {
        return item;
    } else {
        NSArray   *keys = [self keys];
        int        index = [keys count];
        NSString  *temp;
        
        while (index-- > 0) {
            item = [keys objectAtIndex:index];
            temp = [item label];
            if ([temp isEqualToString:label]) 
                return item;
        }
        return nil;
    }    
}


- (id<FSItem>)itemWithPath:(NSString*)path
/*" empty path returns the group itself. "*/
{
    if ([path length] > 0) {
        NSArray *components = FSSplitStringByDots(path);

        if ([components count] == 1) {
            if ([path isSingleQuotedString])
                path = [path stringByTrimmingQuotes];
            return [_itemLookup objectForKey:[path UTF8String]];
        } else {
            int idx = 0;
            id  item = self;
            while (idx < [components count]) {
                item = [item itemWithLabel:[components objectAtIndex:idx]];
                idx++;
            }
            return item;
        }
    }
    return self;
}


- (FSKey*)keyWithPath:(NSString*)path
{
    id item = [self itemWithPath:path];
    if ([item isKindOfClass:[FSKey class]])
        return item;
    return nil;
}


- (FSKeyGroup*)groupWithLabel:(NSString*)label
/*" Returns the key for the given label, or nil if it doesn't exist. "*/
{
    id item = [self itemWithLabel:label];
    if ([item isKindOfClass:[FSKeyGroup class]]) return item;
    return nil;
}


- (BOOL)containsKey:(FSKey*)key
{
    return [_items containsObject:key];
}


- (void)fillFromArray:(NSArray*)items
{
    NSDictionary *dict;
    NSArray      *subarray;
    NSEnumerator *cursor;
    int           index;
    Class         strgClass = [NSString class];

    cursor = [items objectEnumerator];
    while ((dict = [cursor nextObject])) {
        if ([dict isKindOfClass:strgClass]) {
            [self appendKeyWithLabel:[(NSString*)dict stringByTrimmingQuotes]];
        } else {
            index = [_items count];
            subarray = [dict objectForKey:@"Labels"];
            [self fillFromArray:subarray];
            [self groupItemsInRange:NSMakeRange(index, [subarray count]) 
                withLabel:[dict objectForKey:@"Name"]];
        }
    }
}


- (NSDictionary*)pboardDataFromRange:(NSRange)range
{
    NSArray        *data;
    FSKeyRange     *keyRange;
    NSDictionary   *result;

    NSMutableArray *items = [[NSMutableArray alloc] init];
    int             idx = 0;
    id              item;
    
    keyRange = [FSKeyRange keyRangeWithRange:range inGroup:self];
    data = [[self table] valuesInSelection:
        [FSSelection selectionWithRanges:[NSArray arrayWithObject:keyRange]]];
    
    while (idx < range.length) {
        item = [_items objectAtIndex:range.location+idx];
        [items addObject:[item dictionaryForArchiving]];
        idx++;
    }
    
    result = [NSDictionary dictionaryWithObjectsAndKeys:
        data, @"FSDataArray", items, @"FSItemArray", nil];
    [items release];

    return result;
}


- (int)pasteData:(NSDictionary*)pbData atIndex:(int)index
{
    NSNotificationCenter *nc = [[self table] notificationCenter];
    NSUndoManager        *um = [[self table] undoManager];
    NSArray              *items = [pbData objectForKey:@"FSItemArray"];
    NSDictionary         *dict;
    Class                 class;
    id                    item;
    int                   idx = 0;
    int                   count = 0;
    SEL                   selector;
    NSMethodSignature    *signature;
    NSInvocation         *invocation;
    NSString             *lastLabel = nil;
    NSString             *newLabel = @"undefined";
    
    [[self table] setShouldPostNotifications:NO];
    [[self table] disableRecalculation];
    while (idx < [items count]) {
        dict = [items objectAtIndex:idx++];
        class = NSClassFromString([dict objectForKey:@"Class"]);

        if (class == [FSKey class]) {
            item = [[class alloc] initWithGroup:self];
            newLabel = [[dict objectForKey:@"Label"] stringByTrimmingQuotes];
        } else if (class == [FSKeyGroup class]) {
            item = [[class alloc] init];
            [item fillFromArray:[dict objectForKey:@"Labels"]];
            [item setGroup:self];
            newLabel = [[dict objectForKey:@"Name"] stringByTrimmingQuotes];
        } else {
            [FSLog logError:@"Unknown class %@", [class description]];
            item = nil;
        }
        
        if (item) {
            // smart find new label if already taken
            if ([self itemWithLabel:newLabel]) {
                if (lastLabel == nil) {
                    newLabel = [self _uniqueLabel:newLabel];
                } else {
                    newLabel = [self _uniqueLabel:lastLabel];
                }
                lastLabel = newLabel;
            }
            [item setLabel:newLabel];

            [_items insertObject:item atIndex:index+count];
            [_itemLookup setObject:item forKey:[[item label] UTF8String]];
            [item release];
            count++;
        }
    }
    [self _recacheKeys];
    [um disableUndoRegistration];
    [[self table] setValues:[pbData objectForKey:@"FSDataArray"]
        inSelection:[FSSelection selectionWithRanges:[NSArray arrayWithObject:
            [FSKeyRange keyRangeWithRange:NSMakeRange(index,count) inGroup:self]]]];
    [um enableUndoRegistration];
    [[um prepareWithInvocationTarget:self]
        deleteItemsInRange:NSMakeRange(index,count)];
    [[self table] enableRecalculation];
    [[self table] setShouldPostNotifications:YES];
    
    [um disableUndoRegistration];
    selector = @selector(pasteData:atIndex:);
    signature = [[self class] instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    dict = [NSDictionary dictionaryWithObject:items forKey:@"FSItemArray"];
    [invocation setArgument:&dict atIndex:2];
    [invocation setArgument:&index atIndex:3];
    [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
        userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];
    [um enableUndoRegistration];
    return count;
}


- (void)deleteItemsInRange:(NSRange)range
{
    NSNotificationCenter *nc = [[self table] notificationCenter];
    id                    data = [self pboardDataFromRange:range];
    id                    um = [[self table] undoManager];
    BOOL                  post = [um isUndoRegistrationEnabled];
    SEL                   selector;
    NSMethodSignature    *signature;
    NSInvocation         *invocation;
    NSArray              *items;
    id<FSItem>            anItem;
    int                   index;

    if (post) {
        [nc postNotificationName:FSTableWillChangeNotification object:[self table]];
        [[um prepareWithInvocationTarget:self] pasteData:data atIndex:range.location];
    }
    items = [_items subarrayWithRange:range];
    [items makeObjectsPerformSelector:@selector(setGroup:) withObject:nil];
    index = [items count];
    while (index-- > 0) {
        anItem = [items objectAtIndex:index];
        [_itemLookup removeObjectForKey:[[anItem label] UTF8String]];
    }
    [_items removeObjectsInRange:range];
    if ([_items count] == 0) {
        FSKey *newKey = [[FSKey alloc] initWithGroup:self];
        [newKey setLabel:[_label stringByAppendingString:@"1"]];
        [_items addObject:newKey];
        [newKey release];
        [[um prepareWithInvocationTarget:_items] removeObjectAtIndex:0];
    }
    [self _recacheKeys];
    if (post) {
        [nc postNotificationName:FSTableDidChangeNotification object:[self table]];
    }
    [[self table] _revalidateAllExistingValues];

    selector = @selector(deleteItemsInRange:);
    signature = [FSHeader instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setArgument:&range atIndex:2];
    [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
        userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];
}

//
// Sorting
//

- (NSComparisonResult)smartCompare:(id<FSItem>)otherObject
{
    return [[self label] compare:[otherObject label] options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)smartCompareReverse:(id<FSItem>)otherObject
{
    return -[self smartCompare:otherObject];
}

- (void)sortItemsByName
{
    [self sortItemsByName:YES];
}


- (void)_copyOrderByNameFromArray:(NSArray*)items
    /*" Used for linked categories, probably slow as heck. "*/
{
    NSNotificationCenter *nc = [[self table] notificationCenter];
    int       count = [items count];
    int       index = 0;
    FSHashKey key;

    [nc postNotificationName:FSTableWillChangeNotification object:[self table]];
    [_items removeAllObjects];

    while (index < count) {
        key = [[[items objectAtIndex:index] label] UTF8String];
        [_items addObject:[_itemLookup objectForKey:key]];
        index++;
    }
    [self _recacheKeys];
    
    [nc postNotificationName:FSTableDidChangeNotification object:[self table]];
}


- (void)restoreOrderFromArray:(NSArray*)items
{
    NSNotificationCenter *nc = [[self table] notificationCenter];
    id                    um = [[self table] undoManager];

    [nc postNotificationName:FSTableWillChangeNotification object:[self table]];
    [[um prepareWithInvocationTarget:self] restoreOrderFromArray:[NSArray arrayWithArray:_items]];
    [_items removeAllObjects];
    [_items addObjectsFromArray:items];
    [self _recacheKeys];
    if (nc) {
        SEL                   selector;
        NSMethodSignature    *signature;
        NSInvocation         *invocation;

        selector = @selector(_copyOrderByNameFromArray:);
        signature = [FSHeader instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setArgument:&items atIndex:2];

        [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
                        userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];
    }
    [nc postNotificationName:FSTableDidChangeNotification object:[self table]];
}


- (void)sortItemsByName:(BOOL)ascending
{
    NSNotificationCenter *nc = [[self table] notificationCenter];
    id                    um = [[self table] undoManager];

    [nc postNotificationName:FSTableWillChangeNotification object:[self table]];
    [[um prepareWithInvocationTarget:self] restoreOrderFromArray:[NSArray arrayWithArray:_items]];
    if (ascending) {
        [_items sortUsingSelector:@selector(smartCompare:)];
    } else {
        [_items sortUsingSelector:@selector(smartCompareReverse:)];
    }
    [self _recacheKeys];
    if (nc) {
        SEL                   selector;
        NSMethodSignature    *signature;
        NSInvocation         *invocation;
        NSArray              *order = [NSArray arrayWithArray:_items];

        selector = @selector(_copyOrderByNameFromArray:);
        signature = [FSHeader instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setArgument:&order atIndex:2];

        [nc postNotificationName:FSHeaderDidChangeNotification object:[self header]
                        userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"Invoke"]];
    }
    [nc postNotificationName:FSTableDidChangeNotification object:[self table]];
}

- (void)sortItemsWithOtherKeys:(FSKeySet*)otherKeys
{
    [self sortItemsWithOtherKeys:otherKeys ascending:YES];
}

- (void)sortItemsWithOtherKeys:(FSKeySet*)otherKeys ascending:(BOOL)order
{
}

@end
