//
//  FSTableTabs.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableTabs.m,v 1.1 2008/10/14 15:03:48 hns Exp $

#import "FlexiSheet.h"

#define FREESPACE  42
#define SPACING    2
#define TABSIZE    12

@implementation FSTableTabs

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _orientation = FSOnTop;
        _items = nil;
        _widths = malloc(sizeof(int));
        _widths[0] = 80;
        _visibleRange = NSMakeRange(0,1);
        
        _backButton = [[NSButtonCell alloc] initImageCell:[NSImage imageNamed:@"BlackLeftArrow.tiff"]];
        [_backButton setBezelStyle:NSShadowlessSquareBezelStyle];
        [_backButton setBordered:NO];
        [_backButton setTarget:self];
        [_backButton setAction:@selector(previousItem:)];
        _backRect = NSMakeRect(2,2,16,16);
        _backPath = [[NSBezierPath alloc] init];
        [_backPath appendBezierPathWithOvalInRect:_backRect];
        [_backPath moveToPoint:NSMakePoint(6,10)];
        [_backPath relativeLineToPoint:NSMakePoint(6,4)];
        [_backPath relativeLineToPoint:NSMakePoint(0,-8)];
        [_backPath closePath];
        [_backButton setImagePosition:NSImageOnly];
        
        _foreButton = [[NSButtonCell alloc] initImageCell:[NSImage imageNamed:@"BlackRightArrow.tiff"]];
        [_foreButton setBezelStyle:NSShadowlessSquareBezelStyle];
        [_foreButton setBordered:NO];
        [_foreButton setTarget:self];
        [_foreButton setAction:@selector(nextItem:)];
        _foreRect = NSMakeRect(21,2,16,16);
        _forePath = [[NSBezierPath alloc] init];
        [_forePath appendBezierPathWithOvalInRect:_foreRect];
        [_forePath moveToPoint:NSMakePoint(33,10)];
        [_forePath relativeLineToPoint:NSMakePoint(-6,-4)];
        [_forePath relativeLineToPoint:NSMakePoint(0,8)];
        [_forePath closePath];
        [_foreButton setImagePosition:NSImageOnly];
    }
    if (frame.size.height > frame.size.width) {
        [self setBoundsRotation:-90];
        [self translateOriginToPoint:NSMakePoint(-frame.size.height,0)];
    }
    return self;
}


- (void)dealloc
{
    [_items release];
    [super dealloc];
}


- (BOOL)hasSelection
{
    return (_selectedItem != -1);
}


- (void)setFrameSize:(NSSize)newSize
{
    int dx = [self frame].size.height - newSize.height;
    [super setFrameSize:newSize];
    [self translateOriginToPoint:NSMakePoint(dx,0)];
}


- (void)notifySelectionChange
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    id selection = nil;

    if ([self hasSelection]) {
        FSKeySet   *keyset = [_items objectAtIndex:_selectedItem];
        NSArray    *keys = [[keyset objectEnumerator] allObjects];
        if ([keys count] == 1) {
            selection = [keys lastObject];
        } else {
            selection = keyset;
        }
    }

    [nc postNotificationName:FSSelectionDidChangeNotification
                      object:selection];
}


- (void)drawRect:(NSRect)rect
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSFont              *font = [NSFont systemFontOfSize:12];
    NSRect               cell = [self bounds];
    NSString            *item;
    int                  index;
    int                  xEnd = cell.size.width;
    int                  yPos;
    int                  width;
    int                  bestStart = _visibleRange.location;
    BOOL                 hasFocus = ([[self window] firstResponder] == self);
    NSBezierPath        *tab;

    if ([_backButton isEnabled]) {
        [[NSColor colorWithDeviceWhite:.2 alpha:.8] set];
    } else {
        [[NSColor colorWithDeviceWhite:.5 alpha:.8] set];
    }
    [_backPath fill];
    if ([_foreButton isEnabled]) {
        [[NSColor colorWithDeviceWhite:.2 alpha:.8] set];
    } else {
        [[NSColor colorWithDeviceWhite:.5 alpha:.8] set];
    }
    [_forePath fill];
        
    
    // Make sure we draw the selected item.
    if (_selectedItem < bestStart) bestStart = _selectedItem;
    
    width = xEnd - FREESPACE; // This is the width we have
    index = _selectedItem; // Subtract the tabs leading our selection
    while (index >= bestStart) width -= _widths[index--] + SPACING;
    // Now, if we don't have the space to draw the selection, move up
    while (width < SPACING) width += SPACING + _widths[bestStart++];
    _visibleRange.location = bestStart;
    
    // Draw tabs
    [attributes setObject:font forKey:NSFontAttributeName];
    cell.origin.x = FREESPACE;
    for (index = _visibleRange.location; index < [_items count]; index++) {
        item = [[_items objectAtIndex:index] description];
        cell.size.width = MAX(80, [item sizeWithAttributes:attributes].width+8);
        _widths[index] = cell.size.width;
        tab = [NSBezierPath bezierPath];
        if (index == _selectedItem) {
            if (hasFocus) {
                [[NSColor selectedControlColor] set];
            } else {
                [[NSColor secondarySelectedControlColor] set];
            }
        } else {
            [[NSColor controlBackgroundColor] set];
        }
        if ((_orientation == FSOnTop) || (_orientation == FSRightSide)) {
            [tab moveToPoint:cell.origin];
            [tab relativeLineToPoint:NSMakePoint(0,cell.size.height-TABSIZE)];
            [tab relativeCurveToPoint:NSMakePoint(TABSIZE, TABSIZE)
                        controlPoint1:NSMakePoint(0, TABSIZE)
                        controlPoint2:NSMakePoint(0, TABSIZE)];
            [tab relativeLineToPoint:NSMakePoint(cell.size.width-2*TABSIZE,0)];
            [tab relativeCurveToPoint:NSMakePoint(TABSIZE,-TABSIZE)
                        controlPoint1:NSMakePoint(TABSIZE,0)
                        controlPoint2:NSMakePoint(TABSIZE,0)];
            [tab relativeLineToPoint:NSMakePoint(0,TABSIZE-cell.size.height)];
            [tab closePath];
            [tab fill];
        }
        if ((_orientation == FSAtBottom) || (_orientation == FSLeftSide)) {
            [tab moveToPoint:cell.origin];
            [tab relativeMoveToPoint:NSMakePoint(0,cell.size.height)];
            [tab relativeLineToPoint:NSMakePoint(0,TABSIZE-cell.size.height)];
            [tab relativeCurveToPoint:NSMakePoint(TABSIZE, -TABSIZE)
                        controlPoint1:NSMakePoint(0, -TABSIZE)
                        controlPoint2:NSMakePoint(0, -TABSIZE)];
            [tab relativeLineToPoint:NSMakePoint(cell.size.width-2*TABSIZE,0)];
            [tab relativeCurveToPoint:NSMakePoint(TABSIZE,TABSIZE)
                        controlPoint1:NSMakePoint(TABSIZE,0)
                        controlPoint2:NSMakePoint(TABSIZE,0)];
            [tab relativeLineToPoint:NSMakePoint(0,cell.size.height-TABSIZE)];
            [tab closePath];
            [tab fill];
        }
        [item drawInRect:NSInsetRect(cell,4,3) withAttributes:attributes];
        cell.origin.x += cell.size.width+SPACING;
        if (cell.origin.x > xEnd) {
            //_visibleRange.length = index - _visibleRange.location + 1;
            break;
        }
    }
    [[NSColor colorWithDeviceWhite:0 alpha:.3] set];
    switch (_orientation) {
        case FSOnTop:
        case FSRightSide:
            yPos = 0;
            break;
        case FSAtBottom:
        case FSLeftSide:
            yPos = cell.size.height;
            break;
    }
    [NSBezierPath strokeLineFromPoint:NSMakePoint(FREESPACE,yPos)
                              toPoint:NSMakePoint(cell.origin.x-SPACING,yPos)];
}


- (FSTabOrientation)orientation
{
    return _orientation;
}


- (void)setOrientation:(FSTabOrientation)newOrientation
{
    _orientation = newOrientation;
}


- (NSArray*)keySets
{
    return _items;
}


- (void)setKeySets:(NSArray*)keySets
{
    int count = [keySets count];
    
    free(_widths);
    [keySets retain];
    [_items release];
    _items = keySets;
    _widths = malloc(sizeof(int)*count);
    if (_selectedItem >= count) {
        _selectedItem = count - 1;
    }
    [_backButton setEnabled:(_selectedItem > 0)];
    [_foreButton setEnabled:(_selectedItem < count-1)];
    _visibleRange = NSMakeRange(0,count);
    while (count--) _widths[count] = 80;
    [[self superview] setNeedsDisplay:YES];
}


- (void)previousItem:(id)sender
{
    if (_selectedItem > 0) {
        _selectedItem--;
    }
    [(FSTableView*)[self superview] reflectPageTabChange];
    [_backButton setEnabled:(_selectedItem > 0)];
    [_foreButton setEnabled:(_selectedItem < [_items count]-1)];
    [[self superview] setNeedsDisplay:YES];
    [self notifySelectionChange];
}


- (void)nextItem:(id)sender
{
    if (_selectedItem < [_items count]-1) {
        _selectedItem++;
    }
    [(FSTableView*)[self superview] reflectPageTabChange];
    [_backButton setEnabled:(_selectedItem > 0)];
    [_foreButton setEnabled:(_selectedItem < [_items count]-1)];
    [[self superview] setNeedsDisplay:YES];
    [self notifySelectionChange];
}


- (FSKeySet*)selectedKeySet
{
    if (_selectedItem >= [_items count]) return nil;
    return [_items objectAtIndex:_selectedItem];
}


- (int)_indexForPoint:(NSPoint)point
{
    int pos = FREESPACE;
    int index = _visibleRange.location;
    while (index < [_items count]) {
        if (point.x < pos) return -1;
        pos += _widths[index];
        if (point.x < pos) return index;
        index++;
        pos += SPACING;
    }
    return -1;
}


- (NSString*)_uniqueHeaderName:(NSString*)name inTable:(FSTable*)table
{
    while ([table headerWithName:name]) {
        name = [name followingString];
    }
    return name;
}


- (BOOL)_endEditing
{
    if (_isEditing) {
        [[self window] endEditingFor:self];
        _isEditing = NO;
        [[self window] makeFirstResponder:self];
        [self setNeedsDisplay:YES];
    } else {
        [[self window] endEditingFor:nil];
    }
    return YES;
}


- (void)textDidEndEditing:(NSNotification *)notification
// Called by the field editor
{
    NSText    *editor = [notification object];
    NSString  *value = [[editor string] copy];

    if (([[_editHeader label] isEqualToString:value] == NO) && ([value length])) {
        value = [self _uniqueHeaderName:value inTable:[_editHeader table]];
        [_editHeader setLabel:value];
    }

    [self _endEditing];
}


- (void)keyDown:(NSEvent*)event
{
    switch ([[event characters] characterAtIndex:0]) {
        case NSUpArrowFunctionKey:
            if ((_orientation == FSLeftSide) || (_orientation == FSRightSide))
                [self previousItem:nil];
            break;
        case NSDownArrowFunctionKey:
            if ((_orientation == FSLeftSide) || (_orientation == FSRightSide))
                [self nextItem:nil];
            break;
        case NSLeftArrowFunctionKey:
            if ((_orientation == FSOnTop) || (_orientation == FSAtBottom))
                [self previousItem:nil];
            break;
        case NSRightArrowFunctionKey:
            if ((_orientation == FSOnTop) || (_orientation == FSAtBottom))
                [self nextItem:nil];
            break;
        default:
            [super keyDown:event]; 
    }
}

//
//
//

- (void)textDidChange:(NSNotification*)notification
{
    [self setNeedsDisplay:YES];
}


- (BOOL)_beginEditingAtIndex:(int)index
{
    NSRect        editorFrame;
    NSSize        maxSize;
    NSTextView   *editor;
    FSKeySet     *ks;
    int           idx = index;

    [self _endEditing];
    if (![[self window] makeFirstResponder:self]) {
        [FSLog logError:@"Could not become first responder.  Handle me!"];
        return NO;
    }

    ks = [self selectedKeySet];
    if ([ks count] != 1) {
        // cannot edit
        return NO;
    }
    _editHeader = [[ks objectEnumerator] nextObject];
    
    editor = (NSTextView*)[[self window] fieldEditor:YES forObject:self];

    editorFrame = NSMakeRect(FREESPACE,2,_widths[index]-2,17);
    while (idx-- > _visibleRange.location) {
        editorFrame.origin.x += _widths[idx] + SPACING;
    }

    [editor setString:[_editHeader label]];
    [editor selectAll:nil];
    [editor setDelegate:self];
    [editor setFont:[NSFont systemFontOfSize:12]];
    [editor setFrame:editorFrame];
    [editor setBackgroundColor:[NSColor whiteColor]];
    [editor setAlignment:NSLeftTextAlignment];
    [editor setDrawsBackground:YES];

    maxSize = NSMakeSize(1.0e6,editorFrame.size.height);
    [[editor textContainer] setWidthTracksTextView:NO];
    [[editor textContainer] setContainerSize:maxSize];
    [editor setHorizontallyResizable:YES];
    [editor setMaxSize:maxSize];
    [editor setMinSize:editorFrame.size];
    [[editor textContainer] setHeightTracksTextView:NO];
    [editor setVerticallyResizable:NO];
    [self addSubview:editor];
    [[self window] makeFirstResponder:editor];
    _isEditing = YES;

    return YES;
}


- (void)startEditing:(id)sender
{
    if (_selectedItem != -1) {
        if ([self _beginEditingAtIndex:_selectedItem] == NO) {
            NSBeep();
        }
    }
}


- (void)mouseDown:(NSEvent*)event
{
    NSPoint  location = [self convertPoint:[event locationInWindow] fromView:nil];

    if (NSPointInRect(location, _backRect)) {
        [_backButton trackMouse:event inRect:_backRect ofView:self untilMouseUp:YES];
    } else if (NSPointInRect(location, _foreRect)) {
        [_foreButton trackMouse:event inRect:_foreRect ofView:self untilMouseUp:YES];
    } else {
        int      index = [self _indexForPoint:location];

        if (index < 0) return;
        [[self window] makeFirstResponder:self];
        _selectedItem = index;
        [(FSTableView*)[self superview] reflectPageTabChange];
        [_backButton setEnabled:(_selectedItem > 0)];
        [_foreButton setEnabled:(_selectedItem < [_items count]-1)];
        [[self superview] setNeedsDisplay:YES];
        [self notifySelectionChange];

        if ([event clickCount] == 2) {
            [self startEditing:nil];
        }
    }
}

@end
