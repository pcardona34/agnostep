/*
**  ExtendedTextView.m
**
**  Copyright (c) 2002-2006 Ludovic Marcotte, Ujwal S. Sathyam
**  Copyright (C) 2019-2020 Riccardo Mottola
**
**  Author: Ujwal S. Sathyam <ujwal@setlurgroup.com>
**          Ludovic Marcotte <ludovic@Sophos.ca>
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

#include "ExtendedTextView.h"

#include "ExtendedFileWrapper.h"
#include "ExtendedTextAttachmentCell.h"
#include "GNUMail.h"
#include "Constants.h"
#include "MimeTypeManager.h"
#include "MimeType.h"
#include "Utilities.h"

#include <Pantomime/NSData+Extensions.h>

static int imageCounter = 0;

//
// Private methods
//
@interface ExtendedTextView (Private)
- (NSDragOperation) _checkForSupportedDragTypes:(id <NSDraggingInfo>) sender;
@end

//
//
//
@implementation ExtendedTextView

- (id) init
{
  self = [super init];
  if (self != nil)
    {
      if (cursor == nil)
        {
          cursor = [[NSCursor alloc] initWithImage: [NSImage imageNamed: @"hand"]
                                     hotSpot: NSZeroPoint];
        }
    }
  return self;
}


- (id) initWithFrame: (NSRect) theFrame
{
  self = [super initWithFrame: theFrame];
  if (self != nil)
    {
      if (cursor == nil)
        {
          cursor = [[NSCursor alloc] initWithImage: [NSImage imageNamed: @"hand"]
	  			     hotSpot: NSZeroPoint];
        }
    }
  
  return (self);
}


- (id) initWithFrame: (NSRect) theRect  textContainer: (NSTextContainer *) theTextContainer
{
  self = [super initWithFrame: theRect  textContainer: theTextContainer];
  if (self != nil)
    {
      if (cursor == nil)
        {
          cursor = [[NSCursor alloc] initWithImage: [NSImage imageNamed: @"hand"]
				     hotSpot: NSZeroPoint];
       
        }
    }
  return (self);
}


//
//
//
- (void) dealloc
{
  RELEASE(cursor);
  [super dealloc];
}


//
// NSTextView
//
- (void) paste: (id) sender
{
  if ([[[NSPasteboard generalPasteboard] types] containsObject:  NSTIFFPboardType])
    {
      [self insertImageData: [[NSPasteboard generalPasteboard] dataForType: NSTIFFPboardType]
                   filename: [NSString stringWithFormat: @"pasteGraphic%d.tiff", ++imageCounter]];
    }
  else
    {
      [self readSelectionFromPasteboard: [NSPasteboard generalPasteboard]];
    }
}

- (void) pasteAsQuoted: (id) sender
{
  NSData *aData;

  aData = [[[NSPasteboard generalPasteboard] stringForType: NSStringPboardType] dataUsingEncoding: NSUTF8StringEncoding];
  
  if (aData)
    {
      [self insertText: AUTORELEASE([[NSString alloc] initWithData: [[aData unwrapWithLimit: 78] quoteWithLevel: 1  wrappingLimit: 80]
						      encoding: NSUTF8StringEncoding])];
    }
}


//
// Drag and Drop methods for our text view
//

//
// Ensure that we declare the dragging types we will accept
// (such as NSFilenamesPBoardType)
//
- (NSArray *) acceptableDragTypes 
{
  NSMutableArray *dragTypes;

  dragTypes = [NSMutableArray arrayWithArray: [super acceptableDragTypes]];

  if (![dragTypes containsObject: NSFilenamesPboardType])
    {
      [dragTypes addObject: NSFilenamesPboardType];
    }
  
  return dragTypes;
}


//
// Called when our drop area is entered
//
- (NSDragOperation) draggingEntered: (id<NSDraggingInfo>) sender
{
  return [self _checkForSupportedDragTypes: sender];
}


//
// Called when the dragged object is moved within our drop area
//
- (NSDragOperation) draggingUpdated: (id<NSDraggingInfo>) sender
{
  return [self _checkForSupportedDragTypes: sender];
}


//
// Called when the dragged item is about to be released in our drop area.
//
- (BOOL) prepareForDragOperation: (id<NSDraggingInfo>) sender
{
  if ([self _checkForSupportedDragTypes: sender] != NSDragOperationNone)
    {
      return YES;
    }

  return NO;
}


//
// Called when the dragged item is released in our drop area.
//
- (BOOL) performDragOperation: (id<NSDraggingInfo>) sender
{
  NSPasteboard *pb = [sender draggingPasteboard];
  NSArray *propertyList;
  NSUInteger i;
  NSDragOperation dragOperation;
      
  dragOperation = [self _checkForSupportedDragTypes: sender];
      
  switch (dragOperation)
    {
      case NSDragOperationCopy:
      propertyList = [pb propertyListForType: NSFilenamesPboardType];

      for (i = 0; i < [propertyList count]; i++)
        {
          [self insertFile: (NSString*)[propertyList objectAtIndex: i]];
        }

      return YES;
   }
  
  return NO;
}


//
//
//
- (void) concludeDragOperation: (id<NSDraggingInfo>) sender
{
  // Do nothing.
}


//
// Inserts an individual file.
//
- (void) insertFile: (NSString *) theFilename
{
  NSAttributedString *aAttributedString;
  NSTextAttachment *aTextAttachment;
  ExtendedTextAttachmentCell *cell;
  ExtendedFileWrapper *aFileWrapper;
  MimeType *aMimeType;
  
  aFileWrapper = [[ExtendedFileWrapper alloc] initWithPath: theFilename];
  AUTORELEASE(aFileWrapper);
  
  // We save the path of the last file
  [GNUMail setCurrentWorkingPath: [theFilename stringByDeletingLastPathComponent]];
  
  // We set the icon of the attachment if the mime-type is found
  aMimeType = [[MimeTypeManager singleInstance] bestMimeTypeForFileExtension: [[theFilename lastPathComponent]
										pathExtension]];
  
  // If we found a MIME-type for this attachment...
  if ((aMimeType && [aMimeType icon]) ||
      (aMimeType && [[aMimeType primaryType] caseInsensitiveCompare: @"image"] == NSOrderedSame))
    {
      // If we got an image, we resize our attachment to fix the text view, if we need to.
      if ([[aMimeType primaryType] caseInsensitiveCompare: @"image"] == NSOrderedSame)
	{
          [self insertImageData: [NSData dataWithContentsOfFile: theFilename]
                       filename: [theFilename lastPathComponent]];
          return;
	}
      else
	{
	  [aFileWrapper setIcon: [aMimeType icon]];
	}
    }

  // We now create our attachment from our filewrapper
  aTextAttachment = [[NSTextAttachment alloc] initWithFileWrapper: aFileWrapper];
  
  cell = [[ExtendedTextAttachmentCell alloc] initWithFilename: [[aFileWrapper filename] lastPathComponent]
					     size: [[aFileWrapper regularFileContents] length]];
  
  [aTextAttachment setAttachmentCell: cell];
  
  // Cocoa bug
#ifdef MACOSX
  [cell setAttachment: aTextAttachment];
#endif
  [cell setImage: [aFileWrapper icon]];
  RELEASE(cell);
  
  aAttributedString = [NSAttributedString attributedStringWithAttachment: aTextAttachment];
  RELEASE(aTextAttachment);
  
  if (aAttributedString)
    {
      [self insertText: (id)aAttributedString];
    }
}


//
//
//
- (void) insertImageData: (NSData *) theData
                filename: (NSString *) theFilename
{
  ExtendedFileWrapper *aFileWrapper;
  NSTextAttachment *aTextAttachment;
  ExtendedTextAttachmentCell *cell;
  NSImage *theImage;
  
  NSRect rectOfTextView;
  NSSize imageSize;

  theImage = AUTORELEASE([[NSImage alloc] initWithData: theData]);
  rectOfTextView = [self frame];
  imageSize = [theImage size];
  
  if (imageSize.width > rectOfTextView.size.width)
    {
      double delta =  1.0 / ( imageSize.width / rectOfTextView.size.width );
      double dy = 15*delta;
      
      [theImage setScalesWhenResized: YES];
      [theImage setSize: NSMakeSize(((imageSize.width-15) * delta), (imageSize.height-dy) * delta)];
    }

  aFileWrapper = AUTORELEASE([[ExtendedFileWrapper alloc] initRegularFileWithContents: theData]);
  [aFileWrapper setFilename: theFilename];
  [aFileWrapper setIcon: theImage];

  aTextAttachment = [[NSTextAttachment alloc] initWithFileWrapper: aFileWrapper];
  
  cell = [[ExtendedTextAttachmentCell alloc] initWithFilename: theFilename					                                         size: [[aFileWrapper regularFileContents] length]];
  
  [aTextAttachment setAttachmentCell: cell];
  
  // Cocoa bug
#ifdef MACOSX
  [cell setAttachment: aTextAttachment];
#endif
  [cell setImage: [aFileWrapper icon]];
  RELEASE(cell);
  
  [self insertText: [NSAttributedString attributedStringWithAttachment: aTextAttachment]];
  RELEASE(aTextAttachment);
}


//
//  
//
- (void) updateCursorForLinks
{
  NSTextStorage *aTextStorage;
  
  NSRange visibleGlyphRange, visibleCharRange, attrsRange;
  NSPoint aPoint;
  NSRect aRect;
  
  // We get the attributed text
  aTextStorage = [self textStorage];
  
  // We found out what part is visible
  aPoint = [self textContainerOrigin];
  aRect = NSOffsetRect ([self visibleRect], -aPoint.x, -aPoint.y);
  
  // We found out what characters are visible
  visibleGlyphRange = [[self layoutManager] glyphRangeForBoundingRect: aRect
					    inTextContainer: [self textContainer]];

  visibleCharRange = [[self layoutManager] characterRangeForGlyphRange: visibleGlyphRange
					   actualGlyphRange: NULL];
  
  attrsRange = NSMakeRange(visibleCharRange.location, 0);
  
  // Loop whitin the visible range of characters
  while (NSMaxRange(attrsRange) < NSMaxRange(visibleCharRange))
    {
      if ( [aTextStorage attribute: NSLinkAttributeName
			 atIndex: NSMaxRange(attrsRange)
			 effectiveRange: &attrsRange] )
	{
	  NSUInteger rectCount, rectIndex;
	  NSRect *rects;
	 
	  // Find the rectangle(s) associated to the link
	  // NB: there may be multiple rects if the link uses many lines
	  rects = [[self layoutManager] rectArrayForCharacterRange: attrsRange
#ifdef MACOSX
					withinSelectedCharacterRange: NSMakeRange(NSNotFound, 0)
#else
					withinSelectedCharacterRange: attrsRange
#endif
					inTextContainer: [self textContainer]
					rectCount: &rectCount];
	  
	  // For the visible part of each rectangle, make the cursor visible
	  for (rectIndex = 0; rectIndex < rectCount; rectIndex++)
	    {
	      aRect = NSIntersectionRect(rects[rectIndex], [self visibleRect]);
	      [self addCursorRect: aRect
		    cursor: cursor];
	    }
	}
    }
}


//
//
//
- (void) resetCursorRects
{
  [super resetCursorRects];
  [self updateCursorForLinks];
} 

@end


//
// private methods
//
@implementation ExtendedTextView (Private)

- (NSDragOperation) _checkForSupportedDragTypes: (id<NSDraggingInfo>) sender
{
  NSString *sourceType;
  BOOL iResult;
  
  iResult = NSDragOperationNone;

  // We support the FileName drag type for attching files
  sourceType = [[sender draggingPasteboard] availableTypeFromArray: [NSArray arrayWithObjects: 
									       NSFilenamesPboardType, 
									     NSStringPboardType, 
									     nil]];
  
  if (sourceType)
    {
      iResult = NSDragOperationCopy;
    }
  
  return iResult;
}

@end
