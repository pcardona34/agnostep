//
//  FSWorksheet.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 15-MAY-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSWorksheet.m,v 1.1 2008/10/14 15:03:49 hns Exp $

#import "FlexiSheet.h"
#import "FSWorksheet.h"

static NSString *FS_PAGE_NAME = @"PageHeaders";
static NSString *FS_SIDE_NAME = @"SideHeaders";
static NSString *FS_TOPH_NAME = @"TopHeaders";
static NSString *FS_RGHT_NAME = @"RightHeaders";

@implementation FSWorksheet

- (id)init
{
    self = [super init];
    if (self) {
        _winController = nil;
        _storedWinProps = nil;
        _pageHeaders  = [[NSMutableArray alloc] init];
        _rightHeaders = [[NSMutableArray alloc] init];
        _topHeaders   = [[NSMutableArray alloc] init];
        _sideHeaders  = [[NSMutableArray alloc] init];
        _name = @"View";
        //[FSLog logInfo:@"FSWorksheet %X allocated.", self];
    }
    return self;
}


- (BOOL)loadFromDictionary:(NSDictionary*)archive forTable:(FSTable*)table
{
    id value;

    [self setTable:table];

    value = [archive objectForKey:@"Name"];
    if ([value isKindOfClass:[NSString class]])
        [self setName:value];
    
    value = [archive objectForKey:@"Comment"];
    if ([value isKindOfClass:[NSData class]])
        [self setComment:value];
    
    [self setPageHeaders:[table headersWithNames:[archive objectForKey:FS_PAGE_NAME]]];
    [self setTopHeaders:[table headersWithNames:[archive objectForKey:FS_TOPH_NAME]]];
    [self setSideHeaders:[table headersWithNames:[archive objectForKey:FS_SIDE_NAME]]];
    [self setRightHeaders:[table headersWithNames:[archive objectForKey:FS_RGHT_NAME]]];

    value = [archive objectForKey:@"NSFrame"];
    if ([value isKindOfClass:[NSString class]])
        [self setWindowLocationString:value];
    //
    // Interpreting Layout dictionary is the sole
    // responsibility of FSWindowController subclasses.
    //
    value = [archive objectForKey:@"Layout"];
    if ([value isKindOfClass:[NSDictionary class]])
        [self storeWindowProperties:value];
    if (NO == [[archive objectForKey:@"Closed"] isEqualToString:@"YES"]) {
        [self displayWindow:YES];
    }
    
    return YES;
}

- (void)dealloc
{
    [_winController close];

    [_pageHeaders release];
    [_rightHeaders release];
    [_topHeaders release];
    [_sideHeaders release];

    [_comment release];
    [_name release];
    [_storedWinProps release];
    [_winController release];

    //[FSLog logInfo:@"FSWorksheet %X deallocated.", self];
    [super dealloc];
}

//
// Methods
//

- (NSWindowController*)windowController
{
    return _winController;
}


- (FSWindowController*)displayWindow:(BOOL)create
{
    if ((_winController == nil) && create) {
        // Create the window controller for this worksheet
        _winController = [[FSTableController alloc] initWithWindowNibName:@"FSTable"];
        [_winController setName:_name];
        [(FSDocument*)[_table document] addWindowController:_winController];
        [_winController setTable:_table];
        [_winController setWorksheet:self];
        [_winController setPageHeaders:_pageHeaders];
        [_winController setTopHeaders:_topHeaders];
        [_winController setSideHeaders:_sideHeaders];
        [_winController setRightHeaders:_rightHeaders];
        [_winController syncWithDocument];
        if (_windowFrame) [[_winController window] setFrameFromString:_windowFrame];
        if (_storedWinProps) [_winController applyLayoutDictionary:_storedWinProps];
    }
    [[_winController window] makeKeyAndOrderFront:nil];
    return _winController;
}

- (void)closeWindow
{
    if (_winController) {
        [self storeWindowInformation];
        [_winController release];
        _winController = nil;
    }
}

- (void)storeWindowInformation
{
    if (_winController) {
        // Get the freshest info
        [self setPageHeaders:[_winController pageHeadersForTableView:nil]];
        [self setTopHeaders:[_winController topHeadersForTableView:nil]];
        [self setSideHeaders:[_winController sideHeadersForTableView:nil]];
        [self setRightHeaders:[_winController rightHeadersForTableView:nil]];
        [self setWindowLocationString:[[_winController window] stringWithSavedFrame]];
        [self storeWindowProperties:[_winController layoutDictionary]];
    }
}

//
// Attributes
//

- (FSTable*)table { return _table; }
- (void)setTable:(FSTable*)table { _table = table; }
- (FSDocument*)document { return (FSDocument*)[_table document]; }

- (NSString*)name /*" Returns the name for this worksheet. "*/
{ return _name; }


- (void)setName:(NSString*)aName
    /*"Sets a name for this worksheet.
    Users can give each view on the data a different name. "*/
{
    if ([aName isEqualToString:_name]) return;
    [[[_table document] undoManager]
        registerUndoWithTarget:self selector:@selector(setName:) object:_name];
    [_name release];
    _name = [aName copy];
    [_winController setName:_name];
}


- (NSData*)comment
    /*" Returns the comment. "*/
{
    return _comment;
}


- (void)setComment:(NSData*)comment
{
    if ([_comment isEqualToData:comment]) return;
    [[[_table document] undoManager]
        registerUndoWithTarget:self selector:@selector(setComment:) object:_comment];
    [_comment release];
    _comment = [comment copy];
}

- (FSSelection*)selection
{
    return _selection;
}

- (void)setSelection:(FSSelection*)selection
{
    if (selection != _selection) {
        [_selection release];
        _selection = [selection retain];
    }
}

- (void)setWindowLocationString:(NSString*)string
{
    [_windowFrame release];
    _windowFrame = [string copy];
}

- (void)storeWindowProperties:(NSDictionary*)dict
{
    [_storedWinProps release];
    if (dict) {
        _storedWinProps = [[NSDictionary alloc] initWithDictionary:dict];
    }
}

- (void)setPageHeaders:(NSArray*)headers
{
    [_pageHeaders removeAllObjects];
    if (headers != nil)
        [_pageHeaders addObjectsFromArray:headers];
}

- (void)setRightHeaders:(NSArray*)headers
{
    [_rightHeaders removeAllObjects];
    if (headers != nil)
        [_rightHeaders addObjectsFromArray:headers];
}

- (void)setSideHeaders:(NSArray*)headers
{
    [_sideHeaders removeAllObjects];
    if (headers != nil)
        [_sideHeaders addObjectsFromArray:headers];
}

- (void)setTopHeaders:(NSArray*)headers
{
    [_topHeaders removeAllObjects];
    if (headers != nil)
        [_topHeaders addObjectsFromArray:headers];
}

@end


@implementation FSWorksheet (Archiving)

- (NSArray*)_headerNamesFor:(NSArray*)headerList
{
    NSMutableArray *result = [NSMutableArray array];
    int index;
    for (index = 0; index < [headerList count]; index++) {
        [result addObject:[[headerList objectAtIndex:index] label]];
    }
    return result;
}

- (NSDictionary*)dictionaryForArchiving
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [self storeWindowInformation];
    [dict setObject:NSStringFromClass([FSTableController class]) forKey:@"Class"];
    [dict setObject:[self name] forKey:@"Name"];
    [dict setObject:[[self table] name] forKey:@"Table"];
    if (_winController == nil) [dict setObject:@"YES" forKey:@"Closed"];
    if (_windowFrame) [dict setObject:_windowFrame forKey:@"NSFrame"];
    [dict setObject:[self _headerNamesFor:_pageHeaders]  forKey:FS_PAGE_NAME];
    [dict setObject:[self _headerNamesFor:_topHeaders]   forKey:FS_TOPH_NAME];
    [dict setObject:[self _headerNamesFor:_sideHeaders]  forKey:FS_SIDE_NAME];
    [dict setObject:[self _headerNamesFor:_rightHeaders] forKey:FS_RGHT_NAME];

    if (_storedWinProps) {
        [dict setObject:_storedWinProps forKey:@"Layout"];
    }
    if (_comment) {
        [dict setObject:_comment forKey:@"Comment"];
    }

    return dict;
}

@end
