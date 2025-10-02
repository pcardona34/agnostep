/*
 Project: Graphos
 GRDocView.m

 Copyright (C) 2000-2019 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */

#import "GRDocView.h"
#import "Graphos.h"
#import "GRDrawableObject.h"
#import "GRFunctions.h"
#import "GRBezierPath.h"
#import "GRBox.h"
#import "GRBoxEditor.h"
#import "GRText.h"
#import "GRTextEditor.h"
#import "GRCircle.h"
#import "GRCircleEditor.h"
#import "GRPropsEditor.h"
#import "GRImage.h"

#define UNDO_ACTION_OBJPROPS @"Change Object Properties"
#define UNDO_ACTION_CP_SYMMETRIC @"Change Point to Symmetric"
#define UNDO_ACTION_CP_CUSP @"Change Point to Cusp"
#define UNDO_ACTION_CP_EXTRACT @"Change Point by Extracting"
#define UNDO_ACTION_CP_OVERLAP @"Change Point by Overlapping"
#define UNDO_ACTION_CP_DELETE @"Delete Point"
#define UNDO_ACTION_SUBDIVIDE @"Subdivide Path"

#define ZOOM_FACTORS 13
#define STD_ZOOM_INDEX 5
float zFactors[ZOOM_FACTORS] = {0.25, 0.33, 0.5, 0.66, 0.75, 1, 1.25, 1.5, 2, 2.5, 3, 4, 6};


@implementation GRDocView


- (id)initWithFrame:(NSRect)aRect
{
  pageRect = NSMakeRect(0, 0, 695, 942);
  a4Rect = NSMakeRect(50, 50, 595, 842);
  zmdRect = NSMakeRect(50, 50, 595, 842);
  
  self = [super initWithFrame: pageRect];
  if(self)
    {
      NSImage *img;
        
      img = [NSImage imageNamed: @"blackarrow.tiff"];
      cur = [[NSCursor alloc] initWithImage: img hotSpot: NSMakePoint(0, 0)];
      [cur setOnMouseEntered: YES];
      [cur setOnMouseExited: YES];
      [self addTrackingRect: [self frame]
	    owner: cur userData: NULL
	    assumeInside: YES];

      objects = [[NSMutableArray alloc] initWithCapacity: 1];
      delObjects = [[NSMutableArray alloc] initWithCapacity: 1];
      objectHistory = [[NSMutableArray alloc] initWithCapacity: 1];
      historyPointer = 0;
      shiftclick = NO;
      altclick = NO;
      ctrlclick = NO;
      zIndex = STD_ZOOM_INDEX;
      zFactor = zFactors[zIndex];
    }
  return self;
}

- (void)dealloc
{
    [cur release];
    [objects release];
    [delObjects release];
    [objectHistory release];
    [super dealloc];
}

- (NSDictionary *) objectDictionary
{
  NSMutableDictionary *objsdict;
  NSMutableArray *objectOrder;
  NSString *str = nil;
  id obj;
  NSUInteger counter;
  NSUInteger p = 0;
  NSUInteger c = 0;
  NSUInteger t = 0;
  NSUInteger b = 0;
  NSUInteger i = 0;
  
  objsdict = [NSMutableDictionary dictionaryWithCapacity: 1];
  objectOrder = [NSMutableArray arrayWithCapacity: [objects count]];
  for(counter = 0; counter < [objects count]; counter++)
    {
      obj = [objects objectAtIndex: counter];
      NSLog(@"class: %@", [obj className]);
      if([obj isKindOfClass: [GRBezierPath class]])
        {
	  str = [NSString stringWithFormat: @"path%lu", (unsigned long)p];
	  p++;
        }
      else if([obj isKindOfClass: [GRImage class]])
        {
	  str = [NSString stringWithFormat: @"image%lu", (unsigned long)i];
	  i++;
        }
      else if([obj isKindOfClass: [GRBox class]])
        {
	  str = [NSString stringWithFormat: @"box%lu", (unsigned long)b];
	  b++;
        }
      else if([obj isKindOfClass: [GRCircle class]])
        {
	  str = [NSString stringWithFormat: @"circle%lu", (unsigned long)c];
	  c++;
        }
      else if([obj isKindOfClass: [GRText class]])
        {
	  str = [NSString stringWithFormat: @"text%lu", (unsigned long)t];
	  t++;
        }
      else
	{
	  [NSException raise:@"Unhandled object type" format:@"%@", [obj class]];
	}
      if (str)
        {
          [objectOrder addObject: str];
          [objsdict setObject: [obj objectDescription] forKey: str];
        }
    }
  [objsdict setObject:[NSNumber numberWithFloat:FILE_FORMAT_VERSION] forKey:@"Version"];
  [objsdict setObject:objectOrder forKey:@"Order"];
  return [NSDictionary dictionaryWithDictionary: objsdict];
}


- (BOOL)createObjectsFromDictionary:(NSDictionary *)dict
{
    NSArray *keys;
    NSString *key;
    NSDictionary *objdict;
    GRBezierPath *bzPath;
    GRText *gGRText;
    GRBox *box;
    GRCircle *circle;
    GRImage *image;
    NSUInteger i;
    float version;
    NSNumber *versionNumber;

    if(!dict)
      return NO;

    [objects removeAllObjects];
    version = 0.0;
    versionNumber = [dict objectForKey:@"Version"];
    if (versionNumber)
      version = [versionNumber floatValue];
    NSLog(@"loading file of version: %f", version);

    if (version < 0.3)
      {
	/* loading for files without ordering */

	NSLog(@"Loading old file version, < 0.3");
	keys = [dict allKeys];
	for(i = 0; i < [keys count]; i++)
	  {
	    key = [keys objectAtIndex: i];
	    objdict = [dict objectForKey: key];
	    if(!objdict)
	      return NO;

	    if([key rangeOfString: @"path"].length)
	      {
		bzPath = [[GRBezierPath alloc] initFromData: objdict
						     inView: self zoomFactor: zFactor];
		[objects addObject: bzPath];
		[bzPath release];
		edind = [objects count] -1;
	      }
	    else if([key rangeOfString: @"text"].length)
	      {
		gGRText = [[GRText alloc] initFromData: objdict
						inView: self zoomFactor: zFactor];
		[objects addObject: gGRText];
		[gGRText release];
	      }
	    else if([key rangeOfString: @"box"].length)
	      {
		box = [[GRBox alloc] initFromData: objdict
					   inView: self zoomFactor: zFactor];
		[objects addObject: box];
		[box release];
	      }
	    else if([key rangeOfString: @"circle"].length)
	      {
		circle = [[GRCircle alloc] initFromData: objdict
						 inView: self zoomFactor: zFactor];
                [circle setCircle:YES];
		[objects addObject: circle];
		[circle release];
	      }
	    else if ([key isEqualToString:@"Version"])
	      {
		/* skip, already parsed */
	      }
	    else
	      {
		[NSException raise:@"Unsupported object in file." format:@"Key: %@", key]; 
	      }
	  }
      } 
    else
      {
	/* loading of files with encoded ordering */
	NSArray *order;

	NSLog(@"Loading version 0.3 or later, ordered objects");
	order = [dict objectForKey:@"Order"];
	for(i = 0; i < [order count]; i++)
	  {
	    key = [order objectAtIndex: i];
	    objdict = [dict objectForKey: key];
	    if(!objdict)
	      return NO;

	    if([key rangeOfString: @"path"].length)
	      {
		bzPath = [[GRBezierPath alloc] initFromData: objdict
						     inView: self zoomFactor: zFactor];
		[objects addObject: bzPath];
		[bzPath release];
		edind = [objects count] -1;
	      }
	    else if([key rangeOfString: @"text"].length)
	      {
		gGRText = [[GRText alloc] initFromData: objdict
						inView: self zoomFactor: zFactor];
		[objects addObject: gGRText];
		[gGRText release];
	      }
	    else if([key rangeOfString: @"box"].length)
	      {
		box = [[GRBox alloc] initFromData: objdict
					   inView: self zoomFactor: zFactor];
		[objects addObject: box];
		[box release];
	      }
	    else if([key rangeOfString: @"image"].length)
	      {
		image = [[GRImage alloc] initFromData: objdict
					   inView: self zoomFactor: zFactor];
		[objects addObject: image];
		[image release];
	      }
	    else if([key rangeOfString: @"circle"].length)
	      {
		circle = [[GRCircle alloc] initFromData: objdict
						 inView: self zoomFactor: zFactor];
                /* 0.5 and prior only had circles, not ovals */
                if (version < 0.6)
                  [circle setCircle:YES];
		[objects addObject: circle];
		[circle release];
	      }
	    else
	      {
		[NSException raise:@"Unsupported object in file." format:@"Key: %@", key]; 
	      }
	  }
      }
    [self setNeedsDisplay:YES];
    return YES;
}

- (void)addPath
{
  GRBezierPath *path;
  GRPropsEditor *objInspector;

  objInspector = [(Graphos *)[[NSApplication sharedApplication] delegate] objectInspector];

  path = [[GRBezierPath alloc] initInView: self
			       zoomFactor: zFactor
			   withProperties: [objInspector properties]];

  [objects addObject: path];
  [path release];
  edind = [objects count] -1;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

- (void)addTextAtPoint:(NSPoint)p
{
  GRText *gdtxt;
  NSInteger i;
  NSUndoManager *uMgr;
  GRPropsEditor *objInspector;

  objInspector = [(Graphos *)[[NSApplication sharedApplication] delegate] objectInspector];
    
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Add Text"];
    
  [self saveCurrentObjects];
    
  for(i = 0; i < [objects count]; i++)
    [[[objects objectAtIndex: i] editor] unselect];

  gdtxt = [[GRText alloc] initInView: self
			     atPoint: p
			  zoomFactor: zFactor
		      withProperties: [objInspector properties]
			  openEditor: YES];
  if (gdtxt)
    [objects addObject: gdtxt];
  [[gdtxt editor] select];
  [gdtxt release];
  [self setNeedsDisplay: YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

- (void)addBox
{
  GRBox *box;
  GRPropsEditor *objInspector;

  objInspector = [(Graphos *)[[NSApplication sharedApplication] delegate] objectInspector];

  box = [[GRBox alloc] initInView: self
		       zoomFactor: zFactor
		   withProperties: [objInspector properties]];

  [objects addObject: box];
  [[box editor] select];
  [box release];
  [self setNeedsDisplay: YES];
  edind = [objects count] -1;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

- (void)addCircle
{
  GRCircle *circle;
  GRPropsEditor *objInspector;

  objInspector = [(Graphos *)[[NSApplication sharedApplication] delegate] objectInspector];

  circle = [[GRCircle alloc] initInView: self
			     zoomFactor: zFactor
			 withProperties: [objInspector properties]];

  [objects addObject: circle];
  [[circle editor] select];
  [circle release];
  [self setNeedsDisplay: YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
  edind = [objects count] -1;
}

- (NSArray *)duplicateObjects:(NSArray *)objs andMoveTo:(NSPoint)p
{
  id obj, duplObj;
  NSMutableArray *duplObjs;
  NSUInteger i;

  duplObjs = [NSMutableArray arrayWithCapacity: 1];

  for(i = 0; i < [objs count]; i++)
    {
      obj = [objs objectAtIndex: i];
      duplObj = [obj copy];
      [[obj editor] unselect];
      [[duplObj editor] selectAsGroup];
      [duplObj moveAddingCoordsOfPoint: p];
      [objects addObject: duplObj];
      [duplObjs addObject: duplObj];
      [duplObj release];
    }
  edind = [objects count] -1;
  [self setNeedsDisplay: YES];
  
  return duplObjs;
}

- (void)updatePrintInfo: (NSPrintInfo *)pi;
{
  CGFloat lm, rm, tm, bm;

  if (pi == nil)
    {
      NSLog(@"invalid printer information");
      return;
    }
  lm = [pi leftMargin];
  rm = [pi rightMargin];
  tm = [pi topMargin];
  bm = [pi bottomMargin];
  if ([pi paperSize].width < 0 || [pi paperSize].height < 0)
    {
      NSLog(@"invalid paper size information. %f %f", [pi paperSize].width, [pi paperSize].height);
      return;
    }
  if (lm < 0 || rm < 0 || bm < 0 || rm < 0)
    {
      NSLog(@"invalid margin information. %f %f %f %f", lm, rm, tm, bm);
      lm = rm = bm = tm = 30;
    }
  pageRect = NSMakeRect(0,0,[pi paperSize].width, [pi paperSize].height);

  a4Rect = NSMakeRect(lm, bm,
		      pageRect.size.width-(lm+rm),
		      pageRect.size.height-(tm+bm));
    
  zmdRect = a4Rect;
  zIndex = STD_ZOOM_INDEX;
  zFactor = zFactors[zIndex];
                                                          
  [self setFrame: pageRect];
  [self setNeedsDisplay:YES];
}

- (void)deleteSelectedObjects
{
    id obj;
    NSMutableArray *deleted;
    NSUInteger i, count;

    deleted = [NSMutableArray arrayWithCapacity: 1];

    count = [objects count];
    for(i = 0; i < count; i++)
    {
        obj = [objects objectAtIndex: i];
        if([[obj editor] isGroupSelected])
        {
            [deleted addObject: obj];
            [objects removeObject: obj];
            count--;
            i--;
        }
    }
    if([deleted count])
    {
        [delObjects addObject: deleted];
    }
    [self setNeedsDisplay: YES];
}

- (void)startDrawingAtPoint:(NSPoint)p
{
  NSEvent *nextEvent;
  GRBezierPath *bzpath;
  id obj;
  BOOL isNewEditor = YES;
  NSUInteger i;
  NSUndoManager *uMgr;
  
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Create Path"];
  
  [self saveCurrentObjectsDeep];
  
  for(i = 0; i < [objects count]; i++)
    {
      obj = [objects objectAtIndex: i];
      if([obj isKindOfClass: [GRBezierPath class]])
        if(![[obj editor] isDone])
          {
            isNewEditor = NO;
            edind = i;
          }
    }

  if(isNewEditor)
    for(i = 0; i < [objects count]; i++)
      {
        GRObjectEditor *objEdi;
        
        objEdi = [[objects objectAtIndex: i] editor];
        if (![objEdi isSelected])
          [objEdi unselect];
      }
  
    nextEvent = [[self window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    [self verifyModifiersOfEvent: nextEvent];

    if([nextEvent type] != NSLeftMouseDragged)
      {
        if(isNewEditor)
          {
            [self addPath];
            bzpath = [objects objectAtIndex: edind];
            [[bzpath editor] selectForEditing];
            [bzpath addControlAtPoint: p];
            [self setNeedsDisplay: YES];
            return;
          }
        else
          {
            bzpath = [objects objectAtIndex: edind];
            [[bzpath editor] selectForEditing];
            if(shiftclick)
                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);
            [bzpath addLineToPoint: p];
            [self setNeedsDisplay: YES];
            return;
          }
      }
    else
      {
        if(isNewEditor)
          {
            [self addPath];
            bzpath = [objects objectAtIndex: edind];
            [[bzpath editor] selectForEditing];
            [bzpath addControlAtPoint: p];
          }
        else
          {
            bzpath = [objects objectAtIndex: edind];
            [[bzpath editor] selectForEditing];
            if(shiftclick)
                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);
            [bzpath addControlAtPoint: p];
          }
        [self setNeedsDisplay: YES];
        
        do
          {
            p = [nextEvent locationInWindow];
            p = [self convertPoint: p fromView: nil];
	    p = GRpointDeZoom(p, zFactor);

            if(shiftclick)
              p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);

            [bzpath addCurveWithBezierHandlePosition: p];

            [self setNeedsDisplay: YES];

            nextEvent = [[self window] nextEventMatchingMask:
                NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            [self verifyModifiersOfEvent: nextEvent];
          }
        while([nextEvent type] != NSLeftMouseUp);
        
        [bzpath confirmNewCurve];
        [self setNeedsDisplay: YES];
      }
}

- (void)startBoxAtPoint:(NSPoint)p
{
  NSEvent *nextEvent;
  GRBox *box;
  NSUInteger i;
  NSUndoManager *uMgr;
    
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Create Box"];
    
  [self saveCurrentObjectsDeep];

  for(i = 0; i < [objects count]; i++)
    {
      GRObjectEditor *objEdi;
            
      objEdi = [[objects objectAtIndex: i] editor];
      if (![objEdi isSelected])
        [objEdi unselect];
    }

  nextEvent = [[self window] nextEventMatchingMask:
                               NSLeftMouseUpMask | NSLeftMouseDraggedMask];
  [self verifyModifiersOfEvent: nextEvent];

  if([nextEvent type] != NSLeftMouseDragged)
    {
      NSLog(@"is not left mouse dragged");
 
      [self addBox];
      box = [objects objectAtIndex: edind];
      [[box editor] selectForEditing];
      [box setStartAtPoint: p];
      [self setNeedsDisplay: YES];
      return;
    }
  else
    {
      NSLog(@"is left mouse dragged");
 
      [self addBox];
      box = [objects objectAtIndex: edind];
      [[box editor] selectForEditing];
      [box setStartAtPoint: p];
      [box setEndAtPoint: p];
      [self setNeedsDisplay: YES];

      [self moveControlPointOfEditor: (GRBezierPathEditor *)[box editor] toPoint: p];
 
      [[box editor] unselect];
      [[box editor] selectAsGroup];
    }
}

/* this has a lot in common with startBoxAtPoint */
- (void)startCircleAtPoint:(NSPoint)p
{
  NSEvent *nextEvent;
  GRCircle *circle;
  NSUInteger i;
  NSUndoManager *uMgr;
    
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Create Circle"];
    
  [self saveCurrentObjectsDeep];


  for(i = 0; i < [objects count]; i++)
    {
      GRObjectEditor *objEdi;

      objEdi = [[objects objectAtIndex: i] editor];
      if (![objEdi isSelected])
        [objEdi unselect];
    }

  nextEvent = [[self window] nextEventMatchingMask:
                               NSLeftMouseUpMask | NSLeftMouseDraggedMask];
  [self verifyModifiersOfEvent: nextEvent];

  if([nextEvent type] != NSLeftMouseDragged)
    {
      NSLog(@"is not left mouse dragged");

      [self addBox];
      circle = [objects objectAtIndex: edind];
      [[circle editor] selectForEditing];
      [circle setStartAtPoint: p];
      [self setNeedsDisplay: YES];
      return;
    }
  else
    {
      NSLog(@"is left mouse dragged");

      [self addCircle];
      circle = [objects objectAtIndex: edind];
      [[circle editor] selectForEditing];
      [circle setStartAtPoint: p];
      [circle setEndAtPoint: p];
      [self setNeedsDisplay: YES];


      [self moveControlPointOfEditor: (GRBezierPathEditor *)[circle editor] toPoint: p];

      [[circle editor] unselect];
      [[circle editor] selectAsGroup];

    }
}


- (void)selectObjectAtPoint:(NSPoint)p
{
  id obj;
  NSMutableArray *objs;
  NSUInteger i;
  GRDrawableObject *hitObj;

  objs = [NSMutableArray arrayWithCapacity: 1];

  hitObj = nil;
  for(i = 0; i < [objects count]; i++)
    {
      obj = [objects objectAtIndex: i];

      if ([obj objectHitForSelection: p])
        hitObj = obj;
      else if ([[obj editor] isSelected])
        [objs addObject: obj];
    }

  /* with shift we add or remove the hit object from the list*/
  if (shiftclick && hitObj)
    {
      if ([[hitObj editor] isSelected])
        {
          [[hitObj editor] unselect];
        }
      else
        {
          [[hitObj editor] select];
          [objs addObject:hitObj];
        }
    }
  else
    {
      /* if not shift, if the object is already selected
         we essentially don't change the selection.
         else, we select it and deselect the rest */
      if ([[hitObj editor] isSelected])
        {
          [objs addObject:hitObj];
        }
      else
        {
          NSEnumerator *e;
          GRDrawableObject *o;
          
          e = [objs objectEnumerator];
          while ((o = [e nextObject]))
            {
              [[o editor] unselect];
            }
          [objs removeAllObjects];
          if (hitObj)
            {
              [[hitObj editor] select];
              [objs addObject: hitObj];
            }
        }
    }
  [self setNeedsDisplay: YES];
  
  if([objs count])
    [self moveSelectedObjects: objs startingPoint: p];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

- (void)editPathAtPoint:(NSPoint)p
{
  id obj;
  NSUInteger i;
  NSUndoManager *uMgr;
  
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Edit Path"];
  
  [self saveCurrentObjectsDeep];

  /* we look for a path that is selected and process editing
     we no longer auto-select the object for editing though, nor automatically unselect the editing of the object */
  for(i = 0; i < [objects count]; i++)
    {
      obj = [objects objectAtIndex: i];
      if([obj isKindOfClass: [GRBezierPath class]] && [[obj editor] isSelected])
        {
          if([obj onControlPoint: p])
            {
              [[obj editor] selectForEditing];
              [self moveControlPointOfEditor: (GRBezierPathEditor *)[obj editor] toPoint: p];
              return;
            }
          else
            {
              if([self moveBezierHandleOfEditor: (GRBezierPathEditor *)[obj editor] toPoint: p])
                return;
            }
        }
      else if ([[obj editor] isSelected] && ([obj isKindOfClass: [GRBox class]] || [obj isKindOfClass: [GRCircle class]]))
        {
          if([obj onControlPoint: p])
            {
              [[obj editor] selectForEditing];
              [self moveControlPointOfEditor: (GRBezierPathEditor *)[obj editor] toPoint: p];
              return;
            }
        }
      else if([obj isKindOfClass: [GRText class]] && [[obj editor] isSelected])
        {
          /* we have no actions for GRText */
        }
    }
  [self setNeedsDisplay: YES];
}

- (void)editTextAtPoint:(NSPoint)p
{
  id obj;
  NSUInteger i;
  NSUndoManager *uMgr;
    
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Edit Text"];
    
  [self saveCurrentObjectsDeep];

  for(i = 0; i < [objects count]; i++)
    [[[objects objectAtIndex: i] editor] unselect];

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRText class]])
        {
            if([obj objectHitForSelection: p])
            {
                [[obj editor] select];
                [self setNeedsDisplay: YES];
                [obj edit];
            }
        }
    }
    [self setNeedsDisplay: YES];
}

/** for keyboard equivalent */
- (void)editSelectedText
{
    id obj;
    NSUInteger i;

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRText class]])
        {
            if([obj isSelect])
                [obj edit];
        }
    }
}

- (void)moveSelectedObjects:(NSArray *)objs startingPoint:(NSPoint)startp
{
  NSEvent *nextEvent;
  NSArray *moveobjs = nil;
  id obj;
  NSPoint p, op, diffp;
  BOOL dupl = NO;
  NSUInteger i;
  NSUndoManager *uMgr;
    
    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
    [uMgr setActionName:@"Move Object"];

    [self saveCurrentObjectsDeep];

    nextEvent = [[self window] nextEventMatchingMask:
				 NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    if([nextEvent type] == NSLeftMouseDragged)
      {
        [self verifyModifiersOfEvent: nextEvent];
        op.x = startp.x;
        op.y = startp.y;
	
        do
	  {
	    p = [nextEvent locationInWindow];
	    p = [self convertPoint: p fromView: nil];
	    p = GRpointDeZoom(p, zFactor);
	    
	    if(shiftclick)
	      p = pointApplyingCostrainerToPoint(p, startp);
	    
	    if(altclick && !dupl)
	      {
		moveobjs = [self duplicateObjects: objs andMoveTo: NSMakePoint(0, 0)];
		dupl = YES;
	      }
	    else if(!moveobjs)
	      {
		moveobjs = [NSArray arrayWithArray: objs];
	      }
	    
	    diffp.x = p.x - op.x;
	    diffp.y = p.y - op.y;
	    for(i = 0; i < [moveobjs count]; i++)
	      {
		obj = [moveobjs objectAtIndex: i];
		[obj moveAddingCoordsOfPoint: diffp];
	      }
	    op.x = p.x;
	    op.y = p.y;
	    [self setNeedsDisplay: YES];
	    nextEvent = [[self window] nextEventMatchingMask:
					 NSLeftMouseUpMask | NSLeftMouseDraggedMask];
	    [self verifyModifiersOfEvent: nextEvent];
	  }
	while([nextEvent type] != NSLeftMouseUp);
	
        if(dupl)
	  {
            diffp.x = p.x - startp.x;
            diffp.y = p.y - startp.y;
	  }
	else
	  {
            diffp.x = startp.x - p.x;
            diffp.y = startp.y - p.y;
	  }
      }
}


/* propagates control point editing down to each editor */
- (BOOL)moveControlPointOfEditor:(GRPathEditor *)editor toPoint:(NSPoint)pos
{
  NSPoint p;

  p = [editor moveControlAtPoint: pos];
  if(p.x == pos.x && p.y == pos.y)
    return NO;
  
  [self setNeedsDisplay: YES];
  return YES;
}

- (BOOL)moveBezierHandleOfEditor:(GRBezierPathEditor *)editor toPoint:(NSPoint)pos
{
  NSPoint p;

  p = [editor moveBezierHandleAtPoint: pos];
  if(p.x == pos.x && p.y == pos.y)
    return NO;
  
  [self setNeedsDisplay: YES];
  return YES;
}

- (void)changePointsOfCurrentPathToSymmetric:(id)sender
{
  NSUndoManager *uMgr;
  NSUInteger i;
  NSArray *points;
  GRBezierPath *path;

  path = nil;
  for(i = 0; i < [objects count]; i++)
    {
      GRDrawableObject *obj;
      obj = [objects objectAtIndex: i];
      
      if([[obj editor] isSelected] && [obj isKindOfClass:[GRBezierPath class]])
        {
          path = (GRBezierPath *)obj;
        }
    }
  
  if (!path)
    return;

  points = [(GRBezierPathEditor *)[path editor] selectedControlPoints];
  if (!points || [points count] == 0)
    return;

  uMgr = [self undoManager];
  /* save the method on the undo stack, but stack actions */
  if ([[uMgr undoActionName] isEqualToString: UNDO_ACTION_CP_SYMMETRIC] == NO)
    {
      [self saveCurrentObjectsDeep];
      [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
      [uMgr setActionName: UNDO_ACTION_CP_SYMMETRIC];
    }

  for (i = 0; i < [points count]; i++)
    {
      [(GRBezierControlPoint *)[points objectAtIndex: i] setSymmetricalHandles:YES];
    }
  [path remakePath];
  [self setNeedsDisplay: YES];
}

- (void)changePointsOfCurrentPathToCusp:(id)sender
{
  NSUndoManager *uMgr;
  NSUInteger i;
  NSArray *points;
  GRBezierPath *path;

  path = nil;
  for(i = 0; i < [objects count]; i++)
    {
      GRDrawableObject *obj;
      obj = [objects objectAtIndex: i];
      
      if([[obj editor] isSelected] && [obj isKindOfClass:[GRBezierPath class]])
        {
          path = (GRBezierPath *)obj;
        }
    }
  
  if (!path)
    return;

  points = [(GRBezierPathEditor *)[path editor] selectedControlPoints];
  if (!points || [points count] == 0)
    return;

  uMgr = [self undoManager];
  /* save the method on the undo stack, but stack actions */
  if ([[uMgr undoActionName] isEqualToString: UNDO_ACTION_CP_CUSP] == NO)
    {
      [self saveCurrentObjectsDeep];
      [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
      [uMgr setActionName: UNDO_ACTION_CP_CUSP];
    }

  for (i = 0; i < [points count]; i++)
    {
      [(GRBezierControlPoint *)[points objectAtIndex: i] setSymmetricalHandles:NO];
    }
  [path remakePath];
  [self setNeedsDisplay:YES];
}

- (void)changePointsOfCurrentPathByOverlap:(id)sender
{
  NSUndoManager *uMgr;
  NSUInteger i;
  NSArray *points;
  GRBezierPath *path;

  path = nil;
  for(i = 0; i < [objects count]; i++)
    {
      GRDrawableObject *obj;
      obj = [objects objectAtIndex: i];
      
      if([[obj editor] isSelected] && [obj isKindOfClass:[GRBezierPath class]])
        {
          path = (GRBezierPath *)obj;
        }
    }
  
  if (!path)
    return;

  points = [(GRBezierPathEditor *)[path editor] selectedControlPoints];
  if (!points || [points count] == 0)
    return;

  uMgr = [self undoManager];
  /* save the method on the undo stack, but stack actions */
  if ([[uMgr undoActionName] isEqualToString: UNDO_ACTION_CP_OVERLAP] == NO)
    {
      [self saveCurrentObjectsDeep];
      [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
      [uMgr setActionName: UNDO_ACTION_CP_OVERLAP];
    }

  for (i = 0; i < [points count]; i++)
    {
      [(GRBezierControlPoint *)[points objectAtIndex: i] overlapHandles];
    }
  [path remakePath];
  [self setNeedsDisplay: YES];
}

- (void)changePointsOfCurrentPathByExtract:(id)sender
{
  NSUndoManager *uMgr;
  NSUInteger i;
  NSArray *points;
  GRBezierPath *path;

  path = nil;
  for(i = 0; i < [objects count]; i++)
    {
      GRDrawableObject *obj;
      obj = [objects objectAtIndex: i];
      
      if([[obj editor] isSelected] && [obj isKindOfClass:[GRBezierPath class]])
        {
          path = (GRBezierPath *)obj;
        }
    }
  
  if (!path)
    return;

  points = [(GRBezierPathEditor *)[path editor] selectedControlPoints];
  if (!points || [points count] == 0)
    return;

  uMgr = [self undoManager];
  /* save the method on the undo stack, but stack actions */
  if ([[uMgr undoActionName] isEqualToString: UNDO_ACTION_CP_EXTRACT] == NO)
    {
      [self saveCurrentObjectsDeep];
      [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
      [uMgr setActionName: UNDO_ACTION_CP_EXTRACT];
    }

  for (i = 0; i < [points count]; i++)
    {
      [(GRBezierControlPoint *)[points objectAtIndex: i] extractHandles];
    }
  [path remakePath];
  [self setNeedsDisplay: YES];
}

- (IBAction)deletePointsOfCurrentPath:(id)sender
{
  NSUndoManager *uMgr;
  NSUInteger i;
  NSArray *points;
  GRBezierPath *path;
    
  path = nil;
  for(i = 0; i < [objects count]; i++)
    {
      GRDrawableObject *obj;
      obj = [objects objectAtIndex: i];
        
      if([[obj editor] isSelected] && [obj isKindOfClass:[GRBezierPath class]])
	{
	  path = (GRBezierPath *)obj;
	}
    }
    
  if (!path)
    return;
    
  points = [(GRBezierPathEditor *)[path editor] selectedControlPoints];
  if (!points || [points count] == 0)
    return;
    
  uMgr = [self undoManager];
  /* save the method on the undo stack, but stack actions */
  if ([[uMgr undoActionName] isEqualToString: UNDO_ACTION_CP_DELETE] == NO)
    {
      [self saveCurrentObjectsDeep];
      [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
      [uMgr setActionName: UNDO_ACTION_CP_DELETE];
    }
    
  for (i = 0; i < [points count]; i++)
    {
      [path deletePoint: [points objectAtIndex: i]];
    }
  [path remakePath];
  [self setNeedsDisplay: YES];
}


- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split
{
  NSUndoManager *uMgr;
  id obj;
  NSUInteger i;
  GRBezierPath *path;

  path = nil;
  for(i = 0; i < [objects count]; i++)
    {
      obj = [objects objectAtIndex: i];
      if([obj isKindOfClass: [GRBezierPath class]] && [[obj editor] isSelected])
        {
          if([obj onPathBorder: p])
            {
              path = obj;
	      break;
            }
        }
    }
  
  if (!path)
    return;
    
  uMgr = [self undoManager];
  /* save the method on the undo stack, but stack actions */
  if ([[uMgr undoActionName] isEqualToString: UNDO_ACTION_SUBDIVIDE] == NO)
    {
      [self saveCurrentObjectsDeep];
      [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
      [uMgr setActionName: UNDO_ACTION_SUBDIVIDE];
    }
    
  [path subdividePathAtPoint: p splitIt: split];

  [self setNeedsDisplay:YES];
}

- (NSDictionary *)selectionProperties
{
  NSMutableDictionary *propDict;
  NSUInteger i;
  NSUInteger selectedObjects;
  NSUInteger circleObjNum;
  NSUInteger boxObjNum;
  NSUInteger bezObjNum;
  NSUInteger pathObjNum;
  NSUInteger textObjNum;
  NSNumber *num;
  
  if(![objects count])
    return nil;

  selectedObjects = 0;
  circleObjNum = 0;
  boxObjNum = 0;
  bezObjNum = 0;
  pathObjNum = 0;
  textObjNum = 0;
  propDict = [NSMutableDictionary dictionaryWithCapacity: 1];
  for(i = 0; i < [objects count]; i++)
    {
      id obj;
      obj = [objects objectAtIndex: i];
      
      if([[obj editor] isSelected])
        {
          selectedObjects++;
        
          num = [NSNumber numberWithBool: [obj isStroked]];
          [propDict setObject: num forKey: @"stroked"];
          [propDict setObject: [obj strokeColor] forKey: @"strokecolor"];
          num = [NSNumber numberWithBool: [obj isFilled]];
          [propDict setObject: num forKey: @"filled"];
          [propDict setObject: [obj fillColor] forKey: @"fillcolor"];

          if([obj isKindOfClass: [GRPathObject class]])
            {
              pathObjNum++;
              num = [NSNumber numberWithFloat: [obj flatness]];
              [propDict setObject: num forKey: @"flatness"];
              num = [NSNumber numberWithInt: [obj lineJoin]];
              [propDict setObject: num forKey: @"linejoin"];
              num = [NSNumber numberWithInt: [obj lineCap]];
              [propDict setObject: num forKey: @"linecap"];
              num = [NSNumber numberWithFloat: [obj miterLimit]];
              [propDict setObject: num forKey: @"miterlimit"];
              num = [NSNumber numberWithFloat: [obj lineWidth]];
              [propDict setObject: num forKey: @"linewidth"];
              if([obj isKindOfClass: [GRCircle class]])
                {
                  circleObjNum++;
                  num = [NSNumber numberWithBool: [obj circle]];
                  [propDict setObject: num forKey: @"circle"];
                }
              else if([obj isKindOfClass: [GRBox class]])
                {
                  boxObjNum++;
                }
              else if([obj isKindOfClass: [GRBezierPath class]])
                {
                  bezObjNum++;
                }
            }
          else if([obj isKindOfClass: [GRText class]])
            {
              textObjNum++;
              [propDict setObject: @"text" forKey: @"type"];
            }
        }
    }
  
  if(selectedObjects == 0)
    return nil;
  
  if (textObjNum + pathObjNum != selectedObjects)
    {
      NSLog(@"Internal error: Help we lost some objects.");
    }
  
  /* we check if the selection is homogeneous or not
     and in case remove the keys that are not common among all objects */
  if (textObjNum > 0 && pathObjNum > 0)
    {
      [propDict removeObjectForKey: @"flatness"];
      [propDict removeObjectForKey: @"linejoin"];
      [propDict removeObjectForKey: @"linecap"];
      [propDict removeObjectForKey: @"miterlimit"];
      [propDict removeObjectForKey: @"linewidth"];
    }
  
  return propDict;
}

- (void)setSelectionProperties: (NSDictionary *)properties;
{
  NSUndoManager *uMgr;
  id obj;
  NSUInteger i;
  
  uMgr = [self undoManager];
  /* save the method on the undo stack, but stack actions */
  if ([[uMgr undoActionName] isEqualToString: UNDO_ACTION_OBJPROPS] == NO)
    {
      [self saveCurrentObjectsDeep];
      [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
      [uMgr setActionName: UNDO_ACTION_OBJPROPS];
    }
  
  for(i = 0; i < [objects count]; i++)
    {
      NSNumber *num;

      obj = [objects objectAtIndex: i];
      if([[obj editor] isSelected])
        {
          NSColor *newColor;
      
          if([obj isKindOfClass: [GRBezierPath class]] || [obj isKindOfClass: [GRBox class]] || [obj isKindOfClass: [GRCircle class]])
            {
              num = [properties objectForKey: @"flatness"];
              if (num)
                [obj setFlat: [num floatValue]];

              num = [properties objectForKey: @"linejoin"];
              if (num)
                [obj setLineJoin: [num intValue]];

              num = [properties objectForKey: @"linecap"];
              if (num)
                [obj setLineCap: [num intValue]];

              num = [properties objectForKey: @"miterlimit"];
              if (num)
                [obj setMiterLimit: [num floatValue]];

              num = [properties objectForKey: @"linewidth"];
              if (num)
                [obj setLineWidth: [num floatValue]];
            }
          num = [properties objectForKey: @"stroked"];
          if (num)
            [obj setStroked: [num boolValue]];

          newColor = (NSColor *)[properties objectForKey: @"strokecolor"];
          if (newColor)
            [obj setStrokeColor: newColor];

          num = [properties objectForKey: @"filled"];
          if (num)
            [obj setFilled: [num boolValue]];

          newColor = (NSColor *)[properties objectForKey: @"fillcolor"];
          if (newColor)
            [obj setFillColor: newColor];
        }
    }
  [self setNeedsDisplay: YES];
}

- (void)moveSelectedObjectsForward:(id)sender
{
  NSUInteger i;
  NSUndoManager *uMgr;
  NSMutableArray *toMoveObjs;
  id topUnselectedObj = nil;
  
  toMoveObjs = [NSMutableArray new];
  for (i = 0; i < [objects count]; i++)
    {
      id obj = [objects objectAtIndex: i];
      if ([[obj editor] isGroupSelected])
        [toMoveObjs addObject: obj];
      else
        topUnselectedObj = obj;
    }
  
  if (topUnselectedObj == nil || [toMoveObjs count] == 0)
    {
      [toMoveObjs release];
      return;
    }
  
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Move forward"];
  
  [self saveCurrentObjectsDeep];

  // we slide the selected objects up one starting from the bottom
  for (i = [toMoveObjs count]; i > 0; i--)
    {
      id obj;
      NSUInteger originalIndex, newIndex, topIndex;
    
      obj = [toMoveObjs objectAtIndex: i-1];
      originalIndex = [objects indexOfObject:obj];
      topIndex = [objects indexOfObject:topUnselectedObj];
      newIndex = originalIndex;
      // if we reach the top and have a multple selection we squeeze it
      if (newIndex < topIndex)
         newIndex++;
      else
        newIndex = topIndex+1;
   
      if (newIndex != originalIndex)
        {
          [obj retain];
          [objects removeObject:obj];
          [objects insertObject:obj atIndex:newIndex];
          [obj release];
        }
    }
  
  [toMoveObjs release];
  [self setNeedsDisplay: YES];
}


- (void)moveSelectedObjectsToFront:(id)sender
{
  NSUInteger i;
  NSUndoManager *uMgr;
  NSMutableArray *toMoveObjs;
  
  toMoveObjs = [NSMutableArray new];
  for (i = 0; i < [objects count]; i++)
    if ([[[objects objectAtIndex: i] editor] isGroupSelected])
      [toMoveObjs addObject: [objects objectAtIndex: i]];

  if ([toMoveObjs count] == 0)
    {
      [toMoveObjs release];
      return;
    }

  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Move to front"];
    
  [self saveCurrentObjectsDeep];
  
  // we bring the selected object to top starting from the bottom
  for (i = 0; i < [toMoveObjs count]; i++)
    {
      id obj = [toMoveObjs objectAtIndex: i];
      [objects removeObject:obj];
      [objects addObject: obj];
    }
  
  [toMoveObjs release];
  [self setNeedsDisplay: YES];
}

- (void)moveSelectedObjectsBackward:(id)sender
{
  NSUInteger i;
  NSUndoManager *uMgr;
  NSMutableArray *toMoveObjs;
  id bottomUnselectedObj = nil;
  
  toMoveObjs = [NSMutableArray new];
  for (i = [objects count]; i >  0; i--)
    {
      id obj = [objects objectAtIndex: i-1];
      if ([[obj editor] isGroupSelected])
          [toMoveObjs addObject: obj];
      else
          bottomUnselectedObj = obj;
    }
  
  if (bottomUnselectedObj == nil || [toMoveObjs count] == 0)
    {
      [toMoveObjs release];
      return;
    }

  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Move backward"];
  
  [self saveCurrentObjectsDeep];
  
  for (i = [toMoveObjs count]; i > 0; i--)
    {
      id obj;
      NSUInteger originalIndex, newIndex, bottomIndex;
    
      obj = [toMoveObjs objectAtIndex: i-1];
      originalIndex = [objects indexOfObject:obj];
      bottomIndex = [objects indexOfObject:bottomUnselectedObj];
      newIndex = originalIndex;
      // if we reach the bottom and have a multple selection we squeeze it
      if (newIndex > 0)
        {
          if (newIndex > bottomIndex)
            newIndex--;
          else
            newIndex = bottomIndex-1;
        }

      if (newIndex != originalIndex)
        {
          [obj retain];
          [objects removeObject:obj];
          [objects insertObject:obj atIndex:newIndex];
          [obj release];
        }
    }

  [toMoveObjs release];
  [self setNeedsDisplay: YES];
}

- (void)moveSelectedObjectsToBack:(id)sender
{
  NSUInteger i;
  NSUndoManager *uMgr;
  NSMutableArray *toMoveObjs;

  toMoveObjs = [NSMutableArray new];
  for (i = 0; i < [objects count]; i++)
    if ([[[objects objectAtIndex: i] editor] isGroupSelected])
      [toMoveObjs addObject: [objects objectAtIndex: i]];
  
  if ([toMoveObjs count] == 0)
    {
      [toMoveObjs release];
      return;
    }
  
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Move to back"];
  
  [self saveCurrentObjectsDeep];
  
  // we bring the selected object to top starting from top
  for (i = [toMoveObjs count]; i > 0;  i--)
    {
      id obj = [toMoveObjs objectAtIndex: i-1];
      [objects removeObject: obj];
      [objects insertObject: obj atIndex: 0];
    }

  [toMoveObjs release];
  [self setNeedsDisplay: YES];
}

- (void)unselectOtherObjects:(GRDrawableObject *)anObject
{
  id obj;
  NSUInteger i;

  if(shiftclick)
    return;
  
  for(i = 0; i < [objects count]; i++)
    {
      obj = [objects objectAtIndex: i];
      if(obj != anObject)
        [[obj editor] unselect];
    }
  
  [self setNeedsDisplay: YES];
}

- (void)zoomOnPoint:(NSPoint)p zoomOut:(BOOL)isout
{
  NSUInteger i;

  i = zIndex;
  if(isout)
    {
      if (i == 0)
	return;
      i--; 
    }
  else
    {
      if (i == ZOOM_FACTORS-1)
	return;
      i++;
    }

  [self zoomOnPoint:p withFactor:i];
}


- (void)zoomOnPoint:(NSPoint)p withFactor:(int)index
{
  CGFloat orx, ory, szx, szy;
  NSRect vr;
  NSPoint pp;
  NSUInteger i;

  zIndex = index;
  zFactor = zFactors[zIndex];

  orx = a4Rect.origin.x * zFactor;
  ory = a4Rect.origin.y * zFactor;
  szx = a4Rect.size.width * zFactor;
  szy = a4Rect.size.height * zFactor;
  zmdRect = NSMakeRect(orx, ory, szx, szy);
  szx = pageRect.size.width * zFactor;
  szy = pageRect.size.height * zFactor;

  pp.x = p.x * ([self frame].origin.x + pageRect.size.width) / [self frame].size.width;
  pp.y = p.y * ([self frame].origin.y + pageRect.size.height) / [self frame].size.height;
  vr = NSMakeRect(pp.x * zFactor - 200, pp.y * zFactor - 200, 400, 400);
  [self setFrame: NSMakeRect(0, 0, szx, szy)];
  [self scrollRectToVisible: vr];

  for(i = 0; i < [objects count]; i++)
    [[objects objectAtIndex: i] setZoomFactor: zFactor];

  [[self window] display];
}

- (IBAction)zoom50:(id)sender
{
  NSUInteger i;
  NSPoint p;
  NSRect visibleRect;

  zFactor = 0.5;

  i = ZOOM_FACTORS - 1;
  while (i > 0 && zFactor < zFactors[i])
    i--;

  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (IBAction)zoom100:(id)sender
{
  NSUInteger  i;
  NSPoint p;
  NSRect visibleRect;

  zFactor = 1;

  i = ZOOM_FACTORS - 1;
  while (i > 0 && zFactor < zFactors[i])
    i--;

  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (IBAction)zoom200:(id)sender
{
  NSUInteger i;
  NSPoint p;
  NSRect visibleRect;

  zFactor = 2;

  i = ZOOM_FACTORS - 1;
  while (i > 0 && zFactor < zFactors[i])
    i--;

  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (IBAction)zoomFitPage:(id)sender
{
  NSUInteger i;
  NSPoint p;
  NSRect visibleRect;
  NSRect docVRect;
  CGFloat fWidth;
  CGFloat fHeight;

  fWidth = [self frame].size.width / zFactor;
  fHeight = [self frame].size.height / zFactor;
  docVRect = [(NSClipView*)[self superview] documentVisibleRect];
  i = ZOOM_FACTORS - 1;
  while (i > 0 && ((docVRect.size.width < fWidth * zFactors[i]) || (docVRect.size.height < fHeight * zFactors[i])))
    i--;

  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (IBAction)zoomFitWidth:(id)sender
{
  NSUInteger i;
  NSPoint p;
  NSRect visibleRect;
  NSRect docVRect;
  CGFloat fWidth;

  fWidth = [self frame].size.width / zFactor;
  docVRect = [(NSClipView*)[self superview] documentVisibleRect];
  i = ZOOM_FACTORS - 1;
  while (i > 0 && docVRect.size.width < fWidth * zFactors[i])
    i--;
 
  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (void)movePageFromHandPoint:(NSPoint)handpos
{
  NSEvent *nextEvent;
  NSPoint p, diffp;
  NSRect r;
  
  nextEvent = [[self window] nextEventMatchingMask:
                               NSLeftMouseUpMask | NSLeftMouseDraggedMask];
  if([nextEvent type] == NSLeftMouseDragged)
    {
      do
        {
          p = [nextEvent locationInWindow];
          p = [self convertPoint: p fromView: nil];
          p = GRpointDeZoom(p, zFactor);
          
          diffp.x = p.x - handpos.x;
          diffp.y = p.y - handpos.y;
          r = [self visibleRect];
          r = NSMakeRect(r.origin.x - diffp.x, r.origin.y - diffp.y,
                         r.size.width, r.size.height);
          [self scrollRectToVisible: r];
          nextEvent = [[self window] nextEventMatchingMask:
                                       NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        }
      while([nextEvent type] != NSLeftMouseUp);
      [[self window] display];
    }
}

- (void)delete:(id)sender
{
  NSUndoManager *uMgr;

  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Delete"];
  
  [self saveCurrentObjectsDeep];
  
  [self deleteSelectedObjects];
}

- (void)cut:(id)sender
{
  NSUndoManager *uMgr;

  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Cut"];
  
  [self saveCurrentObjectsDeep];
  [self copy: sender];
  [self deleteSelectedObjects];
}

- (void)copy:(id)sender
{
  NSMutableArray *types;
  NSPasteboard *pboard;
  GRDrawableObject *dObj;
  NSMutableArray *objsdesc;
  NSUInteger i;

  dObj = nil;
  objsdesc = [NSMutableArray arrayWithCapacity: 1];
  for(i = 0; i < [objects count]; i++)
    {
      dObj = [objects objectAtIndex: i];
      if([[dObj editor] isGroupSelected])
	[objsdesc addObject: [dObj objectDescription]];
    }
  
  if([objsdesc count])
    {
      types = [NSMutableArray arrayWithObjects: @"GRObjectPboardType", nil];
      pboard = [NSPasteboard generalPasteboard];
      [pboard declareTypes: types owner: self];
      [pboard setString:[objsdesc description] forType: @"GRObjectPboardType"];

      /* if we have just a single image selected, also add a standard TIFF image */
      if ([objsdesc count] == 1 && [dObj isKindOfClass:[GRImage class]])
        {
          GRImage *grImg;

          [types addObject:NSTIFFPboardType];
          grImg = (GRImage *)dObj;
          [pboard setData:[[grImg image] TIFFRepresentation] forType:NSTIFFPboardType];
        }
    }
}

- (void)paste:(id)sender
{
  NSPasteboard *pboard;
  NSArray *grTypes;
  NSString *imgType;
  NSArray *descriptions;
  NSDictionary *objdesc;
  id obj;
  NSString *str;
  NSUInteger i;
  NSUndoManager *uMgr;
  
  // FIXME we should push the undo stack only if copy is certain to succeed
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] backObjectHistory];
  [uMgr setActionName:@"Paste"];
  
  [self saveCurrentObjectsDeep];

  pboard = [NSPasteboard generalPasteboard];
  grTypes = [NSArray arrayWithObject: @"GRObjectPboardType"];
  imgType = [pboard availableTypeFromArray:[NSArray arrayWithObjects:NSTIFFPboardType, nil]];
  NSLog(@"%@", [pboard types]);
  if([[pboard availableTypeFromArray: grTypes] isEqualToString: @"GRObjectPboardType"])
    {
      descriptions = [[pboard stringForType: @"GRObjectPboardType"] propertyList];

      for(i = 0; i < [descriptions count]; i++)
        {
          objdesc = [descriptions objectAtIndex: i];
          str = [objdesc objectForKey: @"type"];

          obj = nil;
          if([str isEqualToString: @"path"])
            obj = [GRBezierPath alloc];
          else if([str isEqualToString: @"text"])
            obj = [GRText alloc];
          else if([str isEqualToString: @"box"])
            obj = [GRBox alloc];
          else if([str isEqualToString: @"circle"])
            obj = [GRCircle alloc];
          else if([str isEqualToString: @"image"])
            obj = [GRImage alloc];
          else
            NSLog(@"Unknown object to paste");
          if (obj != nil)
            {
              obj = [obj initFromData: objdesc
                               inView: self zoomFactor: zFactor];
              [objects addObject: obj];
              [[obj editor] selectAsGroup];
              [obj release];
              [self setNeedsDisplay: YES];
            }
        }
    }
  else if ([imgType isEqualToString:NSTIFFPboardType])
    {
      NSImage *tmpNSImage;
      GRImage *tmpGRImage;
      NSMutableDictionary *properties;
      NSString *str;
      NSPoint pos;
      NSSize size;
    
      tmpNSImage = [[NSImage alloc] initWithData:[pboard dataForType:NSTIFFPboardType]];
    
      size = [tmpNSImage size];
      pos = NSMakePoint(50, pageRect.size.height-50);
      properties = [[NSMutableDictionary alloc] init];
      [properties autorelease];
      str = [NSString stringWithFormat: @"%.3f", pos.x];
      [properties setObject: str forKey: @"posx"];
      str = [NSString stringWithFormat: @"%.3f", pos.y];
      [properties setObject: str forKey: @"posy"];
    
      str = [NSString stringWithFormat: @"%.3f", size.width];
      [properties setObject: str forKey: @"width"];
      str = [NSString stringWithFormat: @"%.3f", -size.height];
      [properties setObject: str forKey: @"height"];
    
      tmpGRImage = [[GRImage alloc] initInView: self zoomFactor:zFactor withProperties:properties];
      [tmpGRImage setImage:tmpNSImage];
      [objects addObject:tmpGRImage];
      [tmpGRImage release];
      [tmpNSImage release];
      [self setNeedsDisplay: YES];
    }
}

/* ----- Undo Methods ----- */

- (NSMutableArray *)deepCopyObjects: (NSMutableArray *)objArray
{
  NSMutableArray *copyArray;
  NSEnumerator *e;
  NSObject *o;

    
  copyArray = [NSMutableArray arrayWithCapacity:[objArray count]];

  e = [objArray objectEnumerator];
  while ((o = [e nextObject]))
    {
      [copyArray addObject:[[o copy] autorelease]];
    }

  return copyArray;
}

- (void)saveCurrentObjects
{
  NSUndoManager *uMgr = [self undoManager];
  
  /* remove the tail if we are not at the top */
  while ([objectHistory count] > historyPointer)
    {
      NSLog(@"Save not requested at top, removing last");
      [objectHistory removeLastObject];
    }

  if ([uMgr levelsOfUndo] > 0)
    if ([objectHistory count] == [uMgr levelsOfUndo])
      [objectHistory removeObjectAtIndex:0];
  [objectHistory addObject:[NSMutableArray arrayWithArray:objects]];
  historyPointer++;
}

- (void)saveCurrentObjectsDeep
{
  NSUndoManager *uMgr = [self undoManager];

  /* remove the tail if we are not at the top */
  while ([objectHistory count] > historyPointer)
    {
      NSLog(@"SaveDeep not requested at top, removing last");
      [objectHistory removeLastObject];
    }

  if ([uMgr levelsOfUndo] > 0)
    if ([objectHistory count] == [uMgr levelsOfUndo])
      [objectHistory removeObjectAtIndex:0];
  [objectHistory addObject:[self deepCopyObjects: objects]];
  historyPointer++;
}


- (void)backObjectHistory
{
  /* backup the current status if we are at the top */
  if (historyPointer == [objectHistory count])
    {
      NSMutableArray *tempObjects;
      
      NSLog(@"undo requested at top, saving current state");
      tempObjects = [NSMutableArray arrayWithArray:objects];
      [objectHistory addObject:tempObjects];
    }
    
  /* re-register for redo */
  [[[self undoManager] prepareWithInvocationTarget: self] forwardObjectHistory];

  /* get the last status */
  historyPointer--;
  objects = [[objectHistory objectAtIndex:historyPointer] retain];

  [self setNeedsDisplay: YES];

  NSLog(@"back pointer %u out of %u", historyPointer, [objectHistory count]);
}

- (void)forwardObjectHistory
{
  NSLog(@"forward pointer %u out of %u", historyPointer, [objectHistory count]);
  
  /* re-register for redo */
  [[[self undoManager] prepareWithInvocationTarget: self] backObjectHistory];

  /* get the last status */
  historyPointer++;
  objects = [[objectHistory objectAtIndex:historyPointer] retain];


  /* set the last status to the backup */
  [self setNeedsDisplay: YES];
}

/* ----- Mouse Methods ----- */

- (void)verifyModifiersOfEvent:(NSEvent *)theEvent
{
    if([theEvent type] == NSLeftMouseDown
       || [theEvent type] == NSLeftMouseDragged)
    {
        if([theEvent modifierFlags] & NSShiftKeyMask)
            shiftclick = YES;
        else
            shiftclick = NO;
        if([theEvent modifierFlags] & NSAlternateKeyMask)
            altclick = YES;
        else
            altclick = NO;
        if([theEvent modifierFlags] & NSControlKeyMask)
            ctrlclick = YES;
        else
            ctrlclick = NO;
    }

    else if([theEvent type] == NSLeftMouseUp)
    {
        if(!([theEvent modifierFlags] & NSShiftKeyMask))
            shiftclick = NO;
        if(!([theEvent modifierFlags] & NSAlternateKeyMask))
            altclick = NO;
        if(!([theEvent modifierFlags] & NSControlKeyMask))
            ctrlclick = NO;
    }
}

- (BOOL)shiftclick
{
    return shiftclick;
}

- (BOOL)altclick
{
    return altclick;
}

- (BOOL)ctrlclick
{
    return ctrlclick;
}

- (void)mouseDown:(NSEvent *)theEvent
{
  NSPoint p;
  NSUInteger count = [theEvent clickCount];

  [self verifyModifiersOfEvent: theEvent];

  p = [theEvent locationInWindow];
  p = [self convertPoint: p fromView: nil];
  p = GRpointDeZoom(p, zFactor);

  if(count == 1)
    {
      switch([(Graphos *) [NSApp delegate] currentToolType])
        {
            case blackarrowtool:
                [self selectObjectAtPoint: p];
                break;
            case whitearrowtool:
                [self editPathAtPoint: p];
                break;
            case beziertool:
                [self startDrawingAtPoint: p];
                break;
            case texttool:
                [self addTextAtPoint: p];
                break;
            case circletool:
                [self startCircleAtPoint: p];
                break;
            case rectangletool:
                [self startBoxAtPoint: p];
                break;
            case painttool:

                break;
            case penciltool:

                break;
            case rotatetool:

                break;
            case reducetool:

                break;
            case reflecttool:

                break;
            case scissorstool:
                if(altclick)
                    [self subdividePathAtPoint: p splitIt: NO];
                else
                    [self subdividePathAtPoint: p splitIt: YES];
                break;
            case handtool:
                [self movePageFromHandPoint: p];
                break;
            case magnifytool:
                if(altclick)
                    [self zoomOnPoint: p zoomOut: YES];
                else
                    [self zoomOnPoint: p zoomOut: NO];
                break;
            default:
                break;
        }
    }
  else
    {
      if([(Graphos *) [NSApp delegate] currentToolType] == blackarrowtool)
	[self editTextAtPoint: p];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self verifyModifiersOfEvent: theEvent];
}


/** respond to key equivalents which are not bound to menu items */
-(BOOL)performKeyEquivalent: (NSEvent*)theEvent
{
  NSString *keyStr;
  unichar keyCh;
  NSRect vRect, hiddRect;
  NSPoint vPoint;
  CGFloat hiddRx, hiddRy, hiddRw, hiddRh;  
  
#ifdef __APPLE__
  /* Apple is definitively broken here and on all versions tested it returns for the arrow key
     also a KeyUp event, which it should not, as the Event is specified to be keyDown */
  if ([theEvent type] == NSKeyUp)
    return [super performKeyEquivalent:theEvent];
#endif

  keyCh = 0x0;
  keyStr = [theEvent characters];
  if ([keyStr length] > 0)
    keyCh = [keyStr characterAtIndex:0];

  if (keyCh == NSDeleteFunctionKey || keyCh == NSDeleteCharacter)
    {
      [self delete:self];
      return YES;
    }
  else if(keyCh == NSPageUpFunctionKey)
    {
      vRect = [self visibleRect];
      vPoint = vRect.origin;
      hiddRx = vPoint.x;
      hiddRy = vPoint.y + vRect.size.height;
      hiddRw = vRect.size.width;
      hiddRh = vRect.size.height;
      hiddRect = NSMakeRect(hiddRx, hiddRy, hiddRw, hiddRh);
      [self scrollRectToVisible: hiddRect];
      return YES;
    }
  else if(keyCh == NSPageDownFunctionKey)
    {
      vRect = [self visibleRect];
      vPoint = vRect.origin;
      hiddRx = vPoint.x;
      hiddRy = vPoint.y - vRect.size.height;
      hiddRw = vRect.size.width;
      hiddRh = vRect.size.height;
      hiddRect = NSMakeRect(hiddRx, hiddRy, hiddRw, hiddRh);
      [self scrollRectToVisible: hiddRect];
      return YES;
    }    
  else if (keyCh == NSLeftArrowFunctionKey)
    {
      NSLog(@"arrow left");
      return YES;
    }
  else if (keyCh == NSUpArrowFunctionKey)
    {
      NSLog(@"arrow up");
      return YES;
    }
  else if (keyCh == NSRightArrowFunctionKey)
    {
      NSLog(@"right left");
      return YES;
    }
  else if (keyCh == NSDownArrowFunctionKey)
    {
      NSLog(@"down left");
      return YES;
    }
  else
    NSLog(@"keyCh %x", keyCh);
  return [super performKeyEquivalent:theEvent];
}

- (BOOL)validateMenuItem:(NSMenuItem *)mi
{
  NSUInteger i;
  NSUInteger selectedPaths;
  NSUInteger selectedObjs;
  SEL action;
  
  selectedPaths = 0;
  selectedObjs = 0;

  if ([[[mi menu] title] isEqualToString:@"Zoom"])
    return YES;
  
  for(i = 0; i < [objects count]; i++)
    {
      GRDrawableObject *obj;
      obj = [objects objectAtIndex: i];
    
      if([[obj editor] isSelected])
        {
          selectedObjs++;
          if ([obj isKindOfClass:[GRBezierPath class]])
            selectedPaths++;
        }
    }

  action = [mi action];
  if (sel_isEqual(action, @selector(paste:)))
    return YES;
      
  if (sel_isEqual(action, @selector(copy:)) || sel_isEqual(action, @selector(cut:)) || sel_isEqual(action, @selector(delete:)))
    {
      if (selectedObjs)
        return YES;
      else
        return NO;
    }

  if (sel_isEqual(action, @selector(changePointsOfCurrentPathToSymmetric:)))
    {
      if ([[NSApp delegate] currentToolType] == whitearrowtool && (selectedPaths == 1))
        {
          return YES;
        }
      else
        return NO;
    }
  
  if (sel_isEqual(action, @selector(changePointsOfCurrentPathToCusp:)))
    {
      if ([[NSApp delegate] currentToolType] == whitearrowtool && (selectedPaths == 1))
        {
          return YES;
        }
      else
        return NO;
    }
  
  if (sel_isEqual(action, @selector(changePointsOfCurrentPathByOverlap:)))
    {
      if ([[NSApp delegate] currentToolType] == whitearrowtool && (selectedPaths == 1))
        {
          return YES;
        }
      else
        return NO;
    }
  
  if (sel_isEqual(action, @selector(changePointsOfCurrentPathByExtract:)))
    {
      if ([[NSApp delegate] currentToolType] == whitearrowtool && (selectedPaths == 1))
        {
          return YES;
        }
      else
        return NO;
    }

  if (sel_isEqual(action, @selector(deletePointsOfCurrentPath:)))
    {
      if ([[NSApp delegate] currentToolType] == whitearrowtool && (selectedPaths == 1))
        {
          return YES;
        }
      else
        return NO;
    }
  if (sel_isEqual(action, @selector(moveSelectedObjectsForward:)) || sel_isEqual(action, @selector(moveSelectedObjectsBackward:)))
    {
      if (selectedObjs)
        return YES;
      else
        return NO;
    }
  if (sel_isEqual(action, @selector(moveSelectedObjectsToFront:)) || sel_isEqual(action, @selector(moveSelectedObjectsToBack:)))
    {
      if (selectedObjs)
        return YES;
      else
        return NO;
    }  
  return NO;
}

/* override the menu for special context menus

   While editing a path, display the handle options
 */
- (NSMenu *) menuForEvent: (NSEvent*)theEvent
{
  if ([(Graphos *) [NSApp delegate] currentToolType] == whitearrowtool)
    {
      NSUInteger i;
      NSUInteger selectedPaths;
      
      selectedPaths = 0;
      for(i = 0; i < [objects count]; i++)
        {
          GRDrawableObject *obj;
          obj = [objects objectAtIndex: i];
          
          if([[obj editor] isSelected] && [obj isKindOfClass:[GRBezierPath class]])
            {
              selectedPaths++;
            }
        }

      if (selectedPaths == 1)
        {
          NSMenu *menu;
          NSMenuItem *menuItem;
          
          
          menu = [[NSMenu alloc] initWithTitle: NSLocalizedString(@"Handles", @"")];

	  menuItem = [[NSMenuItem alloc] init];
          [menuItem setTitle: NSLocalizedString(@"Delete", @"")];
          [menuItem setTarget: self];      
          [menuItem setAction: @selector(deletePointsOfCurrentPath:)];     
          [menu addItem: menuItem];
          [menuItem release];
	  
          menuItem = [[NSMenuItem alloc] init];
          [menuItem setTitle: NSLocalizedString(@"Symmetric", @"")];
          [menuItem setTarget: self];      
          [menuItem setAction: @selector(changePointsOfCurrentPathToSymmetric:)];     
          [menu addItem: menuItem];
          [menuItem release];
          
          menuItem = [[NSMenuItem alloc] init];
          [menuItem setTitle: NSLocalizedString(@"Cusp", @"")];
          [menu addItem: menuItem];
          [menuItem setTarget: self];      
          [menuItem setAction: @selector(changePointsOfCurrentPathToCusp:)];     
          [menuItem release];

          menuItem = [[NSMenuItem alloc] init];
          [menuItem setTitle: NSLocalizedString(@"Overlap to Segment", @"")];
          [menu addItem: menuItem];
          [menuItem setTarget: self];      
          [menuItem setAction: @selector(changePointsOfCurrentPathByOverlap:)];     
          [menuItem release];

          menuItem = [[NSMenuItem alloc] init];
          [menuItem setTitle: NSLocalizedString(@"Extract to Round", @"")];
          [menu addItem: menuItem];
          [menuItem setTarget: self];      
          [menuItem setAction: @selector(changePointsOfCurrentPathByExtract:)];     
          [menuItem release];
          
          [menu autorelease];
          return menu;
        }
    }

  return [super menuForEvent: theEvent]; 
}


- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)drawRect:(NSRect)rect
{
  NSUInteger   i;
  NSRect       frameRect;
  NSBezierPath *bzp;

  frameRect = [self frame];
    
  [[NSColor whiteColor] set];
  NSRectFill(rect);

  if ([[NSGraphicsContext currentContext] isDrawingToScreen])
    {
      [[NSColor lightGrayColor] set];

      bzp = [NSBezierPath bezierPath];
      [bzp moveToPoint:NSMakePoint(0, zmdRect.origin.y)];
      [bzp lineToPoint:NSMakePoint(frameRect.size.width, zmdRect.origin.y)];
      [bzp lineToPoint:NSMakePoint(rect.size.width, zmdRect.origin.y)];
      [bzp moveToPoint:NSMakePoint(0, zmdRect.origin.y + zmdRect.size.height)];
      [bzp lineToPoint:NSMakePoint(frameRect.size.width, zmdRect.origin.y + zmdRect.size.height)];
      [bzp moveToPoint:NSMakePoint(zmdRect.origin.x, 0)];
      [bzp lineToPoint:NSMakePoint(zmdRect.origin.x, frameRect.size.height)];
      [bzp moveToPoint:NSMakePoint(zmdRect.origin.x + zmdRect.size.width, 0)];
      [bzp lineToPoint:NSMakePoint(zmdRect.origin.x + zmdRect.size.width, frameRect.size.height)];
      [bzp stroke];
    }

    for(i = 0; i < [objects count]; i++)
        [(GRDrawableObject *)[objects objectAtIndex: i] draw];

}

/* --- overridden for printing --- */
/**
 * override for a custom pagination scheme
 */
- (BOOL) knowsPageRange: (NSRangePointer) range
{
  /* we simply set one page */
  range->location = 1;
  range->length = 1;
    
  return YES;
}

/**
 * override for a custom pagination scheme
 */
- (NSRect ) rectForPage: (NSInteger) pageNumber
{
    NSRect pageRec;
    NSSize pageSize;
    NSPrintInfo *pi;
    
    pi = [[[NSDocumentController sharedDocumentController] currentDocument] printInfo];
    
    pageSize = [pi paperSize];    
    pageRec = NSMakeRect(0, 0, pageSize.width, pageSize.height);
    NSLog(@"page rect: %f, %f, %f, %f", pageRec.origin.x, pageRec.origin.y, pageRec.size.width, pageRec.size.height);
    return pageRec;
}

@end


