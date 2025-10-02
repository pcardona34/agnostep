//
//  FSHeaderDock.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 04-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//                2012 Free Software Foundation
//
//  $Id: FSHeaderDock.m,v 1.4 2012/01/26 14:14:39 rmottola Exp $

#import "FlexiSheet.h"

// Text distance from left/right border
#define LABEL_D 12

// Label height
#define LABEL_H 24

// Default label width
#define LABEL_W 80

static NSString *dragName;
static NSColor  *_color;

NSString *FSHeadersChangedInDockNotification = @"FSHeadersChangedInDock";

@interface FSHeaderDock (Private)

- (int)_indexAtPoint:(NSPoint)point;
- (NSImage*)_buttonImageWithTitle:(NSString*)title;

@end

static NSString *FSHeaderPboardType = @"FSHeaderPboardType";

@implementation FSHeaderDock

+ (void)initialize
{
    _color = [[NSColor secondarySelectedControlColor] retain];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _headers = [[NSMutableArray alloc] init];
        _dragIndex = -1;
        _sizeCache = malloc(sizeof(int));
        _sizeCache[0] = LABEL_W;
        _selection = -1;
        [self registerForDraggedTypes:
            [NSArray arrayWithObjects:FSHeaderPboardType, NSColorPboardType, nil]];
    }
    if (frame.size.height > frame.size.width) {
        [self setBoundsRotation:-90];
        [self translateOriginToPoint:NSMakePoint(-frame.size.height,0)];
    }
    return self;
}

- (void)setFrameSize:(NSSize)newSize
{
    int dx = [self frame].size.height - newSize.height;
    [super setFrameSize:newSize];
    [self translateOriginToPoint:NSMakePoint(dx,0)];
}

- (void)dealloc
{
    [_headers release];
    free(_sizeCache);
    _headers = nil;
    [super dealloc];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate { return _delegate; }


- (void)setHeaders:(NSArray*)headers
{
    free(_sizeCache);
    [_headers removeAllObjects];
    [_headers addObjectsFromArray:headers];
    _sizeCache = malloc(sizeof(int)*[_headers count]);
}
- (NSArray*)headers { return _headers; }


- (void)resetCursorRects
{
    NSImage      *cImg = [NSImage imageNamed:@"OpenGrabHandCursor.tiff"];
    NSCursor     *cursor = [[NSCursor alloc] initWithImage:cImg hotSpot:NSMakePoint(8,8)];
    NSRect        bounds = [self bounds];
    
    bounds.size.width = LABEL_W*[_headers count];
    [self addCursorRect:bounds cursor:cursor];
    [cursor release];
}

- (void)_drawButtonInRect:(NSRect)rect withColor:(NSColor*)color
{
    NSImage  *l = [[NSImage alloc] initWithSize:NSMakeSize(32,32)];
    NSImage  *m = [[NSImage alloc] initWithSize:NSMakeSize(32,32)];
    NSImage  *r = [[NSImage alloc] initWithSize:NSMakeSize(32,32)];
    NSRect    imgrect;
    NSString *path;
    NSData   *data;
    NSColor  *shadowColor = [color shadowWithLevel:.8];
    NSColor  *highlightColor = [color highlightWithLevel:.8];
    NSBitmapImageRep *rep;

    // colorizeByMappingGray
    {
        path = [[NSBundle mainBundle] pathForResource:@"ldock-6" ofType:@"tiff"];
        data = [NSData dataWithContentsOfFile:path];
        rep = [[NSBitmapImageRep alloc] initWithData:data];
        [rep colorizeByMappingGray:.6
            toColor:color blackMapping:shadowColor whiteMapping:highlightColor];
        [l addRepresentation:rep];
        [rep release];
    }
    {
        path = [[NSBundle mainBundle] pathForResource:@"mdock-6" ofType:@"tiff"];
        data = [NSData dataWithContentsOfFile:path];
        rep = [[NSBitmapImageRep alloc] initWithData:data];
        [rep colorizeByMappingGray:.6
            toColor:color blackMapping:shadowColor whiteMapping:highlightColor];
        [m addRepresentation:rep];
        [rep release];
    }
    {
        path = [[NSBundle mainBundle] pathForResource:@"rdock-6" ofType:@"tiff"];
        data = [NSData dataWithContentsOfFile:path];
        rep = [[NSBitmapImageRep alloc] initWithData:data];
        [rep colorizeByMappingGray:.6
            toColor:color blackMapping:shadowColor whiteMapping:highlightColor];
        [r addRepresentation:rep];
        [rep release];
    }

    imgrect = rect;
    imgrect.size.width=30;
    [l drawInRect:imgrect fromRect:NSMakeRect(0,0,29,31) 
        operation:NSCompositeSourceOver fraction:1];
        
    imgrect = rect;
    imgrect.origin.x += 30;
    imgrect.size.width -= 60;
    [m drawInRect:imgrect fromRect:NSMakeRect(1,0,28,31) 
        operation:NSCompositeSourceOver fraction:1];

    imgrect = rect;
    imgrect.origin.x += imgrect.size.width-30;
    imgrect.size.width = 30;
    [r drawInRect:imgrect fromRect:NSMakeRect(2,0,29,31) 
        operation:NSCompositeSourceOver fraction:1];
        
    [r release];
    [m release];
    [l release];
}


- (void)_drawEmptyBayInRect:(NSRect)rect
{
    NSImage *l = [NSImage imageNamed:@"lempty-6"];
    NSImage *m = [NSImage imageNamed:@"mempty-6"];
    NSImage *r = [NSImage imageNamed:@"rempty-6"];
    NSRect   imgrect;

    imgrect = rect;
    imgrect.size.width=30;
    [l drawInRect:imgrect fromRect:NSMakeRect(0,0,29,31) 
        operation:NSCompositeSourceOver fraction:1];
        
    imgrect = rect;
    imgrect.origin.x += 30;
    imgrect.size.width -= 60;
    [m drawInRect:imgrect fromRect:NSMakeRect(0,0,28,31) 
        operation:NSCompositeSourceOver fraction:1];

    imgrect = rect;
    imgrect.origin.x += imgrect.size.width-30;
    imgrect.size.width = 30;
    [r drawInRect:imgrect fromRect:NSMakeRect(2,0,29,31) 
        operation:NSCompositeSourceOver fraction:1];
}

- (NSImage*)_emptyButtonImage
{
    if (_emptyImage) return _emptyImage;

    _emptyImage = [[NSImage alloc] initWithSize:NSMakeSize(LABEL_W, LABEL_H)];
    [_emptyImage lockFocus];
    [self _drawEmptyBayInRect:NSMakeRect(0,0,LABEL_W,LABEL_H)];
    [_emptyImage unlockFocus];
    
    return _emptyImage;
}

- (NSImage*)_buttonImageWithTitle:(NSString*)title withColor:(NSColor*)color
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSFont              *font = [NSFont systemFontOfSize:12];
    float                base = 2-[font descender];
    NSSize               size;
    NSString            *label = title;
    NSImage             *image;
    int                  width;

    [attributes setObject:font forKey:NSFontAttributeName];
    size = [label sizeWithAttributes:attributes];
#if 0
    No shrinking
    while (size.width > LABEL_W-2*LABEL_D) {
        int lLen = [label length];
        label = [label substringToIndex:lLen-4];
        label = [label stringByAppendingString:@"..."];
        size = [label sizeWithAttributes:attributes];
    }
    width = LABEL_W;
#else
    width = MAX(LABEL_W, size.width+2*LABEL_D);
#endif
    image = [[NSImage alloc] initWithSize:NSMakeSize(width, LABEL_H)];
    [image lockFocus];
    [self _drawButtonInRect:NSMakeRect(0,0,width,LABEL_H) withColor:color];
    [label drawAtPoint:NSMakePoint(LABEL_D, base) withAttributes:attributes];
    [image unlockFocus];
    
    return [image autorelease];
}


- (NSImage*)_buttonImageWithTitle:(NSString*)title
{
    return [self _buttonImageWithTitle:title withColor:_color];
}


- (void)drawRect:(NSRect)rect
{
    float         offset = 0;
    int           index;
    NSImage      *image = nil;
    NSImage      *dropimage = nil;
    NSImage      *empty = [self _emptyButtonImage];
    
    NSDrawWindowBackground(rect);
    
    if (_isDropping) {
        dropimage = [self _buttonImageWithTitle:dragName];
    }
    
    if (([_headers count] == 0) ||
        (([_headers count] == 1) && _isDragging && !_isDropping)) {
            [empty drawAtPoint:NSMakePoint(0,0) 
                fromRect:NSMakeRect(0,0,LABEL_W,LABEL_H)
                operation:NSCompositeSourceOver fraction:1];
    } else for (index = 0; index < [_headers count]; index++) {
        if (_isDropping && (_dropIndex == index) && (!_isDragging || (_dragIndex > _dropIndex))) {
            offset += [dropimage size].width;
        }
        if (!_isDragging || (_dragIndex != index)) {
            if ((index==_selection) && ([[self window] firstResponder] == self)) {
                image = [self _buttonImageWithTitle:[[_headers objectAtIndex:index] label]
                    withColor:[NSColor selectedControlColor]];
            } else {
                image = [self _buttonImageWithTitle:[[_headers objectAtIndex:index] label]];
            }
            
            [image drawAtPoint:NSMakePoint(offset,0) 
                fromRect:NSMakeRect(0,0,[image size].width,LABEL_H)
                operation:NSCompositeSourceOver fraction:1];
            
            offset += [image size].width;
            _sizeCache[index] = [image size].width;
        }
        if (_isDropping && (_dropIndex == index) && _isDragging && (_dragIndex <= _dropIndex) && dropimage != nil) {
            offset += [dropimage size].width;
        }
    }

    image = nil; // better save
    if (_isDropping) {
        NSRect rect = [self bounds];
        index = 0;
        offset = 0;
        while (index < _dropIndex) {
            if (!_isDragging || (index != _dragIndex)) 
                offset += _sizeCache[index];
            index++;
        }
        if (_isDragging && (_dragIndex < _dropIndex)) {
            offset += _sizeCache[index];
        }
        rect.origin.x = offset;
        rect.size.width = [dropimage size].width;
        [dropimage drawAtPoint:rect.origin 
            fromRect:NSMakeRect(0,0,[dropimage size].width,LABEL_H)
            operation:NSCompositeSourceOver fraction:.5];
    }
}


- (FSHeader*)draggedHeader
{
    return [_headers objectAtIndex:_dragIndex];
}


- (FSHeader*)removeDraggedHeader
{
    if (_isDragging && !_isDropping) {
        FSHeader *header = [_headers objectAtIndex:_dragIndex];
        [_headers removeObjectAtIndex:_dragIndex];
        return header;
    }
    if (_isDragging && _isDropping) {
        FSHeader *header = [_headers objectAtIndex:_dragIndex];
        [_headers removeObjectAtIndex:_dragIndex];
        [_headers insertObject:header atIndex:MIN(_dropIndex, [_headers count])];
    }
    return nil;
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


- (void)textDidChange:(NSNotification*)notification
{
    [self setNeedsDisplay:YES];
}


- (void)_beginEditingAtIndex:(int)index
{
    NSRect        editorFrame;
    NSSize        maxSize;
    NSTextView   *editor;
    int           idx = index, pos = 0;

    [self _endEditing];
    if (![[self window] makeFirstResponder:self]) {
        [FSLog logError:@"Could not become first responder.  Handle me!"];
        return;
    }
    editor = (NSTextView*)[[self window] fieldEditor:YES forObject:self];

    _editHeader = [_headers objectAtIndex:index];
    while (idx-- > 0) { pos += _sizeCache[idx]; }
    editorFrame = NSMakeRect(pos+LABEL_D-5,4,_sizeCache[index]-LABEL_D, LABEL_H-7);
    
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
}


- (BOOL)becomeFirstResponder
{
    [[self superview] setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}


- (BOOL)resignFirstResponder
{
    [[self superview] setNeedsDisplay:YES];
    return [super resignFirstResponder];
}


- (void)deselectAll:(id)sender
{
    _selection = -1;
    [self setNeedsDisplay:YES];
}


- (void)mouseDown:(NSEvent*)event
{
    NSPoint  location = [self convertPoint:[event locationInWindow] fromView:nil];
    if ([event clickCount] == 2) {
        int      index = [self _indexAtPoint:location];

        if (index >= [_headers count]) return;
        [self _beginEditingAtIndex:index];
    } else {
        NSEvent *nextEv = event;
        NSPoint  click;
        
        [self _endEditing];
        do {
            click = [self convertPoint:[nextEv locationInWindow] fromView:nil];
            if ((abs(click.x-location.x) > 4) || (abs(click.y-location.y) > 4)) {
                [self mouseDragged:event];
                return;
            }
            nextEv = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        } while ([nextEv type] != NSLeftMouseUp);
        _selection = [self _indexAtPoint:location];
        if (_selection >= [_headers count]) {
            _selection = -1;
        } else {
            [[self window] makeFirstResponder:self];
            [self setNeedsDisplay:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:FSSelectionDidChangeNotification
                                                                object:[_headers objectAtIndex:_selection]];
        }
    }
}


- (NSString*)_uniqueHeaderName:(NSString*)name inTable:(FSTable*)table
{
    while ([table headerWithName:name]) {
        name = [name followingString];
    }
    return name;
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


- (void)startEditing:(id)sender
{
    if (_selection != -1) {
        [self _beginEditingAtIndex:_selection];
    }
}


- (void)deleteSelection:(id)sender
{
    if (_selection != -1) {
        FSHeader *sel = [_headers objectAtIndex:_selection];
        FSTable  *table = [sel table];
        if ([[table headers] count] > 1) {
            [table removeHeader:sel];
        }
    }
}


- (BOOL)hasSelection
{
    return (_selection != -1);
}


- (void)insertItem:(id)sender
/*" Adds a category to the table controlled by this instance. "*/
{
  FSTable  *table = nil;
  FSHeader *newHeader;
  if ([_delegate isKindOfClass:[FSWindowController class]])
    table = [(FSWindowController *)_delegate table];
  newHeader = [FSHeader headerNamed:[table nextAvailableHeaderName]];
    [newHeader appendKeyWithLabel:[NSString stringWithFormat:@"%@1", [newHeader label]]];
    [_headers insertObject:newHeader atIndex:++_selection];
    [[NSNotificationCenter defaultCenter] postNotificationName:
        FSHeadersChangedInDockNotification object:self];
    [table addHeader:newHeader];
}


- (BOOL)validateUserInterfaceItem:(id)anItem
{
    if (([anItem action] == @selector(cut:))
    || ([anItem action] == @selector(copy:))) {
        return NO;
    }
    if ([anItem action] == @selector(paste:)) {
        return NO;
    }
    if ([anItem action] == @selector(insertItem:)) {
        [anItem setTitle:FS_LOCALIZE(@"Insert Category")];
        return YES;
    }
    return NO;
}

@end


@implementation FSHeaderDock (Dragging)

- (int)_indexAtPoint:(NSPoint)point
{
    int max = 0;
    int index = 0;
    
    while (index < [_headers count]) {
        max += _sizeCache[index];
        if (point.x < max)
            return index;
        index++;
    }

    return [_headers count];
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint       location = [self convertPoint:[event locationInWindow] fromView:nil];
    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    NSImage      *dragImage;
    FSHeader     *dragHeader;
    int           index, idx;
    NSPoint       dragPoint = NSMakePoint(0,0);
    NSSize        offset = NSMakeSize(0,0);  // !!! offset is ignored by dragImage: !!!
    
    [self _endEditing];
    index = [self _indexAtPoint:location];
    if (index >= [_headers count]) return;

    idx = index;
    while (idx-- > 0)dragPoint.x += _sizeCache[idx];

    if ([self isRotatedFromBase]) {
        dragPoint.x = location.x+LABEL_H/2;
        dragPoint.y = -location.y;
    }

    dragHeader = [_headers objectAtIndex:index];
    [pboard declareTypes:[NSArray arrayWithObject:FSHeaderPboardType] owner:self];
    [pboard setString:[dragHeader label] forType:FSHeaderPboardType];

    dragImage = [self _buttonImageWithTitle:[dragHeader label]];
    dragName = [dragHeader label];

    _dragIndex = index;
    _isDragging = YES;
    [self setNeedsDisplay:YES];
    
    [self dragImage:dragImage at:dragPoint offset:offset
        event:event pasteboard:pboard source:self slideBack:YES];

    _isDragging = NO;
    _dragIndex = -1;
    dragName = nil;
    [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
    if (flag) {
        return NSDragOperationLink | NSDragOperationGeneric;
    }
    return NSDragOperationNone;
}

- (FSTable*)table
{
  FSTable *t = nil;

  if ([_delegate isKindOfClass:[FSWindowController class]])
    t = [(FSWindowController *)_delegate table];
  return t;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSPoint          location = [self convertPoint:[sender draggingLocation] fromView:nil];
    NSDragOperation  operation = NSDragOperationNone;

    if ([NSColor colorFromPasteboard:[sender draggingPasteboard]]) {
        return NSDragOperationCopy;
    }

    if ([[sender draggingSource] window] != [self window]) {
        // Linking headers is only allowed in the same document, to different table!
        if ([_delegate table] == [[sender draggingSource] table]) return NSDragOperationNone;
        operation = NSDragOperationLink;
        _isLinking = YES;
    } else {
        operation = NSDragOperationGeneric;
        _isLinking = NO;
    }
    _dropIndex = [self _indexAtPoint:location];
    if (_dropIndex >= [_headers count]) {
        _dropIndex = [_headers count];
        if (_isDragging) _dropIndex--;
    }
    _isDropping = YES;
    [self setNeedsDisplay:YES];
    return operation;
}
    
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    [self _endEditing];
    return [self draggingUpdated:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    _isDropping = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    NSColor  *color = [NSColor colorFromPasteboard:[sender draggingPasteboard]];
    FSHeader *header;
        
    if (color) {
        [_color release];
        _color = [color retain];
        [self setNeedsDisplay:YES];
        return;
    }
    
    if (_isLinking)
      {
	FSTable *table = nil;
        FSGlobalHeader *gh;
	if ([_delegate isKindOfClass:[FSWindowController class]])
	  table = [(FSWindowController *)_delegate table];
        header = [[sender draggingSource] draggedHeader];
        
        gh = [header globalHeader];
        if (gh == nil) {
            gh = [[FSGlobalHeader alloc] init];
            [gh addHeader:header];
            [[table document] addToGlobalCategories:gh];
            [gh release];
        }
        header = [header cloneForTable:table];
        // the new header was added to some 
        [gh addHeader:header];
    } else {
        header = [[sender draggingSource] removeDraggedHeader];
    }

    if (header != nil) {
        [_headers removeObject:header];
        [_headers insertObject:header atIndex:_dropIndex];
        [self discardCursorRects];
    }
    
    _isDropping = NO;
    if (header) {
        [[NSNotificationCenter defaultCenter] postNotificationName:
            FSHeadersChangedInDockNotification object:self
            userInfo:[NSDictionary dictionaryWithObject:header forKey:@"MovedHeader"]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:
            FSHeadersChangedInDockNotification object:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:
        FSTableDidChangeNotification object:[[_headers lastObject] table]];
    [self setNeedsDisplay:YES];
}

@end
