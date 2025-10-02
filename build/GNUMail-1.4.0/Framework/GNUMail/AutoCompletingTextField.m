/*
**  AutoCompletingTextField.m
**
**  Copyright (c) 2003 Ken Ferry
**  Copyright (C) 2014-2023 GNUstep Team
**
**  Author: Ken Ferry <kenferry@mac.com>
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#import "AutoCompletingTextField.h"
#import "Constants.h"

static NSWindow *_sharedDropDown = nil;
static NSScrollView *_sharedDropDownScrollView = nil;
static NSTableView *_sharedDropDownTableView = nil;

@interface AutoCompletingTextField (Private)
- (void)_setupAutoCompletingTextField;
- (NSRange)_defaultCurrentComponentRange;
- (NSRange)_commaDelimitedCurrentComponentRange;
@end


@implementation AutoCompletingTextField

+ (void)initialize
{
  NSTableColumn *aTableColumn;

  aTableColumn = AUTORELEASE([[NSTableColumn alloc] init]);
  [aTableColumn setResizable: YES];
  [aTableColumn setDataCell: AUTORELEASE([[NSTextFieldCell alloc] init])];

  _sharedDropDownTableView = AUTORELEASE([[NSTableView alloc] init]);
  [_sharedDropDownTableView addTableColumn: aTableColumn];
  [_sharedDropDownTableView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  [_sharedDropDownTableView setHeaderView: nil];
  [_sharedDropDownTableView setCornerView: nil];
  [_sharedDropDownTableView setDrawsGrid: NO];
  [_sharedDropDownTableView sizeLastColumnToFit];

  _sharedDropDownScrollView = AUTORELEASE([[NSScrollView alloc] init]);
  [_sharedDropDownScrollView setDocumentView: _sharedDropDownTableView];
  [_sharedDropDownScrollView setHasVerticalScroller: YES];
  [_sharedDropDownScrollView setBorderType: NSBezelBorder];
  [_sharedDropDownScrollView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

  _sharedDropDown = [[NSWindow alloc] initWithContentRect: NSMakeRect(1000000,1000000,0,0)
				      styleMask: NSBorderlessWindowMask
				      backing: NSBackingStoreBuffered
				      defer: YES]; 

  [_sharedDropDown setContentView: _sharedDropDownScrollView];
  [_sharedDropDown setHasShadow: YES];
  [_sharedDropDown setAlphaValue: .88];
  [_sharedDropDown useOptimizedDrawing: YES];
}

- (id)initWithFrame:(NSRect)frameRect
{
  if ((self = [super initWithFrame:frameRect]))
    {
      [self _setupAutoCompletingTextField];
    }
  return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
  if ((self = [super initWithCoder:decoder]))
    {
      [self _setupAutoCompletingTextField];
    }
  return self;
}

- (void)_setupAutoCompletingTextField
{
  [self setCompletionDelay: .2];
  [self setMaximumDropDownRows: 10];
  _justDeleted = NO;
  _shouldShowDropDown = YES;
}

- (void)dealloc
{
  [_cachedCompletions release];
  [self setDataSource:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self]; // at least NSWindowWillMoveNotification
  [super dealloc];
}

- (void)textDidBeginEditing:(NSNotification *)aNotification
{
  [super textDidBeginEditing:aNotification];
  [_sharedDropDownTableView setDelegate:self];
  [_sharedDropDownTableView setDataSource:self];
  [self setDropDownIsDown:NO];
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
  [super textDidEndEditing:aNotification];
  [_sharedDropDownTableView setDelegate:nil];
  [_sharedDropDownTableView setDataSource:nil];
  [_sharedDropDownTableView reloadData];
  [self setDropDownIsDown:NO];
}

- (void)textDidChange:(NSNotification *)aNotification
{
  [super textDidChange:aNotification];

  if (_justDeleted)
    {
      _justDeleted = NO;
      _shouldShowDropDown = NO;
    }
  else
    {
      _shouldShowDropDown = YES;
    }

  [NSObject cancelPreviousPerformRequestsWithTarget:self
	    selector :@selector(complete:)
	    object :nil];
  [self performSelector:@selector(complete:)
	withObject :nil
	afterDelay :_completionDelay];
}

- (void)complete:(id)sender
{
  id fieldEditor;
  NSRange selectedRange;
  BOOL shouldShowDropDown, shouldComplete;
  NSUInteger numTableRows;

  fieldEditor = [[self window] fieldEditor:YES forObject:self];

  _componentRange = [self currentComponentRange];
  selectedRange = [fieldEditor selectedRange];

  shouldShowDropDown = (_shouldShowDropDown &&
			NSMaxRange(selectedRange) == NSMaxRange(_componentRange) &&
			NSEqualRanges(NSUnionRange(_componentRange, selectedRange), _componentRange));
  shouldComplete = (shouldShowDropDown && selectedRange.length == 0);
  _shouldShowDropDown = YES;

  if (shouldComplete)
    {
      NSString *prefix, *newComponent;

      AUTORELEASE(_cachedCompletions);
      _prefixRange = _componentRange;

      prefix = [[self stringValue] substringWithRange:_prefixRange];
      newComponent = [_dataSource completionForPrefix:prefix];

      if (newComponent)
        {
	  id insertedText;

	  _componentRange.length = [newComponent length];
	  selectedRange.length = _componentRange.length - _prefixRange.length;
	  insertedText = [newComponent substringWithRange:NSMakeRange(_prefixRange.length, selectedRange.length)];

	  [fieldEditor insertText:insertedText];
	  [fieldEditor setSelectedRange:selectedRange];

	  _cachedCompletions = [[_dataSource allCompletionsForPrefix:prefix] retain];
        }
      else
        {
	  _cachedCompletions = nil;
        }
    }

  numTableRows = [_cachedCompletions count];
  shouldShowDropDown = shouldShowDropDown && (numTableRows > 1);

  if (shouldShowDropDown && shouldComplete)
    {
      NSString *component;
      int selectedRow;

      component = [[self stringValue] substringWithRange:_componentRange];
      selectedRow = [_cachedCompletions indexOfObject:component];
      [_sharedDropDownTableView reloadData];
      if (selectedRow == -1 || selectedRow >= [_sharedDropDownTableView numberOfRows])
        {
	  [_sharedDropDownTableView deselectAll: nil];
        }
      else
        {
	  [_sharedDropDownTableView selectRow: selectedRow
				    byExtendingSelection: NO];
        }
    }

  [self setDropDownIsDown: shouldShowDropDown];
}

- (BOOL)dropDownIsDown
{
  return _dropDownIsDown;
}

- (void)setDropDownIsDown:(BOOL)flag
{
  if (flag)
    {
      NSUInteger numTableRows, numVisibleTableRows;
      NSInteger selectedRow;
      float visibleTableHeight;
      NSSize dropDownSize;
      NSPoint dropDownTopLeft;

      numTableRows = [_cachedCompletions count];
      selectedRow = [_sharedDropDownTableView selectedRow];

      numVisibleTableRows = numTableRows < _maximumDropDownRows ? numTableRows : _maximumDropDownRows;

      // this is not quite what you'd expect it to be, but seems to be correct on Mac OS X
      visibleTableHeight = numVisibleTableRows * ([_sharedDropDownTableView rowHeight] +
						  [_sharedDropDownTableView intercellSpacing].height);

#ifndef MACOSX
      // We set the table column min/max width.
      [[[_sharedDropDownTableView tableColumns] objectAtIndex: 0] setMinWidth: [self frame].size.width];
      [[[_sharedDropDownTableView tableColumns] objectAtIndex: 0] setMaxWidth: [self frame].size.width];
#endif

      dropDownSize = [NSScrollView frameSizeForContentSize:NSMakeSize(0, visibleTableHeight)
				   hasHorizontalScroller:NO
				   hasVerticalScroller:NO
				   borderType:NSBezelBorder];
      dropDownSize.width = [self frame].size.width;
      dropDownTopLeft = [self convertPoint:NSMakePoint(0,[self frame].size.height) toView:nil];
      dropDownTopLeft = [[self window] convertBaseToScreen:dropDownTopLeft];

      [[[_sharedDropDownTableView tableColumns] objectAtIndex: 0] setWidth: dropDownSize.width];

      [_sharedDropDown setFrame:NSMakeRect(dropDownTopLeft.x,
					   
					   dropDownTopLeft.y - dropDownSize.height,
					   dropDownSize.width,
					   dropDownSize.height)
		       display: YES];


      [_sharedDropDownScrollView setHasVerticalScroller:(numVisibleTableRows != numTableRows)];
      if (selectedRow != -1)
        {
	  [_sharedDropDownTableView scrollRowToVisible:selectedRow];
        }
      [_sharedDropDown orderWindow:NSWindowAbove relativeTo:[[self window] windowNumber]];
    }
  else // get rid of the drop down
    {
      [_sharedDropDown orderOut:nil];
    }
  _dropDownIsDown = flag;
}

- (NSRange)currentComponentRange
{
  if (_commaDelimited)
    {
      return [self _commaDelimitedCurrentComponentRange];
    }
  else
    {
      return [self _defaultCurrentComponentRange];
    }
}

- (NSRange)_defaultCurrentComponentRange
{
  return NSMakeRange(0,[[self stringValue] length]);
}

- (NSRange)_commaDelimitedCurrentComponentRange
{
  NSRange currentComponentRange;
  NSUInteger componentEndInd, componentStartInd, insertionPoint;
  NSString *insertionPtOnward, *toInsertionPt;

  NSCharacterSet *commaCharSet    = [NSCharacterSet characterSetWithCharactersInString:@","];
  NSCharacterSet *nonWhiteCharSet = [[NSCharacterSet whitespaceCharacterSet] invertedSet];

  insertionPoint = [[[self window] fieldEditor:YES forObject:self] selectedRange].location;

  // separate into halves of the string broken at insertionPoint
  insertionPtOnward = [[self stringValue] substringFromIndex:insertionPoint];
  toInsertionPt     = [[self stringValue] substringToIndex:insertionPoint];

  // first we find the end of the component
  // first approximation: the next comma after the insertion point
  componentEndInd = [insertionPtOnward rangeOfCharacterFromSet:commaCharSet].location;

  // if we didn't find a comma then the end of the string is the (approximate) end of the component
  if (componentEndInd == NSNotFound)
    componentEndInd = [insertionPtOnward length];

  // we cut off any trailing white space to get the real end of the component
  componentEndInd = [insertionPtOnward rangeOfCharacterFromSet:nonWhiteCharSet
				       options:NSBackwardsSearch
				       range:NSMakeRange(0,componentEndInd)].location;
  if (componentEndInd == NSNotFound)
    componentEndInd = 0;
  else
    componentEndInd++;

  // now we have to find the beginning of the component
  // first approximation: comma before the insertion point
  componentStartInd = [toInsertionPt rangeOfCharacterFromSet:commaCharSet
				     options:NSBackwardsSearch].location;

  // if we didn't find a comma, the beginning of the string is the desired index
  // if we did find a comma, we want the component to start with the next char
  if (componentStartInd == NSNotFound)
    componentStartInd = 0;
  else
    componentStartInd++;

  // cut off whitespace in the beginning of the component
  componentStartInd = [toInsertionPt rangeOfCharacterFromSet:nonWhiteCharSet
				     options:0
				     range:NSMakeRange(componentStartInd,
						       [toInsertionPt length] - componentStartInd)].location;

  // if we didn't find anything, the component begins at the insertion point.
  if (componentStartInd == NSNotFound)
    componentStartInd = [toInsertionPt length];

  // set the current component range
  currentComponentRange.location = componentStartInd;
  currentComponentRange.length   = [toInsertionPt length] - componentStartInd + componentEndInd;

  return currentComponentRange;
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
  _textViewDoCommandBySelectorResponse = NO;
  if ([self respondsToSelector:aSelector])
    {
      [self performSelector:aSelector withObject:nil];
    }

  return _textViewDoCommandBySelectorResponse;
}

- (void)moveDown:(id)sender
{
  int selectedRow;

  selectedRow = [_sharedDropDownTableView selectedRow] + 1;

  if (0 <= selectedRow && selectedRow < [_sharedDropDownTableView numberOfRows] )
    {
      [_sharedDropDownTableView selectRow:selectedRow
				byExtendingSelection:NO];
      [_sharedDropDownTableView scrollRowToVisible:selectedRow];
      _textViewDoCommandBySelectorResponse = YES;
    }
  
  // LM
#ifndef MACOSX
  [[self window] makeFirstResponder: self];
#endif
}

- (void)moveUp:(id)sender
{
  NSInteger selectedRow;

  selectedRow = [_sharedDropDownTableView selectedRow] - 1;
  if (0 <= selectedRow && selectedRow < [_sharedDropDownTableView numberOfRows] )
    {
      [_sharedDropDownTableView selectRow:selectedRow
				byExtendingSelection:NO];
      [_sharedDropDownTableView scrollRowToVisible:selectedRow];
      _textViewDoCommandBySelectorResponse = YES;
    }

#ifndef MACOSX
  [[self window] makeFirstResponder: self];
#endif
}

- (void)deleteBackward:(id)sender
{
  NSRange selectedRange;

  selectedRange = [[[self window] fieldEditor:YES forObject:self] selectedRange];
  if (selectedRange.location != 0 || selectedRange.length != 0)
    {
      _justDeleted = YES;
    }
}


//
//
//
- (void) tableViewSelectionDidChange: (NSNotification *) theNotification
{
  NSMutableString *newString;
  NSString *newComponent;
  NSRange selectedRange;
  NSInteger selectedRow;
  
  selectedRow = [_sharedDropDownTableView selectedRow];
  
  if (selectedRow < 0 || selectedRow >= (NSInteger)[_cachedCompletions count])
    {
      return;
    }

  newComponent = [_cachedCompletions objectAtIndex: selectedRow];
  newString = [NSMutableString stringWithString: [self stringValue]];
  [newString replaceCharactersInRange: _componentRange withString:newComponent];
  _componentRange.length = [newComponent length];
  selectedRange = NSMakeRange(_componentRange.location + _prefixRange.length,
			      _componentRange.length - _prefixRange.length);
  
  [self setStringValue: newString];
  [[[self window] fieldEditor:YES forObject:self] setSelectedRange:selectedRange];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
  if (rowIndex >= 0 && rowIndex < (NSInteger)[_cachedCompletions count])
    {
      return [_cachedCompletions objectAtIndex: rowIndex];
    }

  return nil;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
  return NO;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
  return [_cachedCompletions count];
}

- (void) viewWillMoveToWindow: (NSWindow *) newWindow
{
  [super viewWillMoveToWindow: newWindow];
  [[NSNotificationCenter defaultCenter] removeObserver: self
					name: NSWindowWillMoveNotification
					object: [self window]];
  [[NSNotificationCenter defaultCenter] removeObserver: self
					name: NSWindowWillCloseNotification
					object: [self window]];

  // FIXME - This doesn't work under GNUstep - the notification is never posted.
  [[NSNotificationCenter defaultCenter] addObserver: self
					selector: @selector(windowWillMove:)
					name: NSWindowWillMoveNotification
					object: newWindow];
  [[NSNotificationCenter defaultCenter] addObserver: self
					selector: @selector(windowWillClose:)
					name: NSWindowWillCloseNotification
					object: newWindow];
}

- (void) windowWillClose: (NSNotification *) theNotification
{
  // We do the same thing as in -windowWillMove
  [self windowWillMove: theNotification];
}

- (void)windowWillMove: (NSNotification *) theNotification
{
  [NSObject cancelPreviousPerformRequestsWithTarget: self
	    selector: @selector(complete:)
	    object: nil];
  [self setDropDownIsDown: NO];
}

- (id)dataSource
{
  return _dataSource;
}

- (void)setDataSource:(id)dataSource
{
  _dataSource = dataSource;
}

- (BOOL)commaDelimited
{
  return _commaDelimited;
}

- (void)setCommaDelimited:(BOOL)commaDelimited
{
  _commaDelimited = commaDelimited;
}

- (float)completionDelay
{
  return _completionDelay;
}

- (void)setCompletionDelay:(float)completionDelay
{
  _completionDelay = completionDelay;
}

- (NSUInteger)maximumDropDownRows
{
  return _maximumDropDownRows;
}

- (void)setMaximumDropDownRows:(NSUInteger)maxRows
{
  _maximumDropDownRows = maxRows;
}

@end
