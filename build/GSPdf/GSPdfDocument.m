/*  -*-objc-*-
 *  GSPdfDocument.m: Implementation of the GSPdfDocument Class 
 *  of the GSPdf application
 *
 *  Copyright (c) 2002-2021 GNUstep Application Project
 *  
 *  Date: February 2002
 *  Authors: Enrico Sersale
 *           Riccardo Mottola
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GSPdfDocument.h"
#import "GSPdfDocWin.h"
#import "PSDocument.h"
#import "GSPdf.h"
#import "GSConsole.h"
#import "GNUstep.h"


@implementation GSPdfDocument

- (void)dealloc
{
  [self clearTempFiles];
  if (isPdf)
    {
      [fm removeFileAtPath: myPath handler: nil];
    }
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  if (task && [task isRunning])
    {
      [task terminate];
    } 
  RELEASE (task);
  RELEASE (myPath);
  RELEASE (psdoc);
  RELEASE (pagesMatrix);
  [gsComm release];

  [super dealloc];
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
  gspdf = [GSPdf gspdf];
  console = [gspdf console];
  nc = [NSNotificationCenter defaultCenter];
  fm = [NSFileManager defaultManager];		
  ASSIGN (myPath, fileName);
  gsComm = [[gspdf gsPath] retain];
  pageindex = 0;
  resolution = 72;
  pagew = 595;
  pageh = 842;

  if ([docType isEqualToString: @"com.adobe.pdf"] || [docType isEqualToString: @"PDF"])
    {
      NSDictionary *pageIdent = [gspdf uniquePageIdentifier];
      NSString *dscPath = [pageIdent objectForKey: @"dscpath"];
      NSMutableArray *args = [NSMutableArray arrayWithCapacity: 1];		

      [args addObject: @"-q"];
      [args addObject: @"-dNODISPLAY"];
      [args addObject: @"-dSAFER"];
      [args addObject: @"-dDELAYSAFER"];
      [args addObject: [NSString stringWithFormat: @"-sPDFname=%@", myPath]];
      [args addObject: [NSString stringWithFormat: @"-sDSCname=%@", dscPath]];
      [args addObject: @"pdf2dsc.ps"];
      [args addObject: @"-c"];
      [args addObject: @"quit"];

      ASSIGN (task, [NSTask new]);
      [task setLaunchPath: gsComm];
      [task setArguments: args];
      NS_DURING
        [task launch];
      NS_HANDLER
	{
	  if ([localException name] == NSInvalidArgumentException)
	    NSLog(@"Invalid Argument Exception");
	  return NO;
	}
      NS_ENDHANDLER
      [task waitUntilExit];

      if ([task terminationStatus] == 0)
	{
	  ASSIGN (myPath, dscPath);
	  psdoc = [[PSDocument alloc] initWithPsFileAtPath: myPath];
	  if (psdoc == nil)
	    {
	      NSLog(@"init with ps file failed");
	      return NO;
	    }
	}					 

    } else
    {
      psdoc = [[PSDocument alloc] initWithPsFileAtPath: myPath];
      if (psdoc == nil)
	{
	  return NO;
	}
    }
 
  return YES;
}

- (void)windowControllerDidLoadNib: (NSWindowController *)winController
{
  NSArray *docPages;
  NSImage *miniPage;
  id cell;
  int i, count;
    
  [super windowControllerDidLoadNib: winController];
  
  [self setBusy: NO];

  matrixScroll = [docwin matrixScroll];

  cell = AUTORELEASE ([NSButtonCell new]);
  [cell setButtonType: NSPushOnPushOffButton];
  [cell setImagePosition: NSImageOverlaps]; 

  pagesMatrix = [[NSMatrix alloc] initWithFrame: NSZeroRect
					   mode: NSRadioModeMatrix prototype: cell
				   numberOfRows: 0 numberOfColumns: 0];
  [pagesMatrix setIntercellSpacing: NSZeroSize];
  [pagesMatrix setCellSize: NSMakeSize(26, 24)];
  [pagesMatrix setAllowsEmptySelection: YES];
  [pagesMatrix setTarget: self];
  [pagesMatrix setAction: @selector(goToPage:)];
  [matrixScroll setDocumentView: pagesMatrix];	


  docPages = [psdoc pages];
  count = [docPages count];

  [pagesMatrix renewRows: 1 columns: count];		
  miniPage = [NSImage imageNamed: @"page.tiff"];

  for (i = 0; i < count; i++)
    {
      NSDictionary *pageIdent = [gspdf uniquePageIdentifier];
      NSString *psPath = [pageIdent objectForKey: @"pspath"];
      NSString *tiffPath = [pageIdent objectForKey: @"tiffpath"];
      NSString *dscPath = [pageIdent objectForKey: @"dscpath"];		
      PSDocumentPage *pspage = [docPages objectAtIndex: i];

      [pspage setPsPath: psPath];
      [pspage setTiffPath: tiffPath];
      [pspage setDscPath: dscPath];

      cell = [pagesMatrix cellAtRow: 0 column: i];
      if (i < 100)
	[cell setFont: [NSFont systemFontOfSize: 10]];
      else
	[cell setFont: [NSFont systemFontOfSize: 8]];
      [cell setImage: miniPage];	   
      [cell setTitle: [NSString stringWithFormat: @"%i", i+1]];	  
    }
  [pagesMatrix sizeToCells];

  [self makePage];
}

- (void)setBusy:(BOOL)value
{
  busy = value;
  [docwin setBusy: value];
}

- (NSString *)myPath
{
  return myPath;
}

- (BOOL)isPdf
{
  return isPdf;
}

- (void)nextPage
{
  pageindex++;
  if (pageindex == [[psdoc pages] count])
    {
      pageindex--;
      return;
    }
  [self makePage];	
}

- (void)previousPage
{
  pageindex--;
  if (pageindex < 0)
    {
      pageindex = 0;
      return;
    } 
  [self makePage];	
}

- (void)goToPage:(id)sender
{
  pageindex = [sender selectedColumn];
  [self makePage];
}

- (void)makePage
{
  PSDocumentPage *pspage;
  NSString *psPath, *tiffPath;
  NSFileHandle *fileHandle, *readHandle, *writeHandle;
  NSData *data;
  NSMutableArray *args;
  NSPipe *pipe[2];

  [self setBusy: YES];

  [pagesMatrix selectCellAtRow: 0 column: pageindex];
  [pagesMatrix scrollCellToVisibleAtRow: 0 column: pageindex];

  pspage = [[psdoc pages] objectAtIndex: pageindex];
  psPath = [pspage psPath];
  tiffPath = [pspage tiffPath];

  if ([fm fileExistsAtPath: psPath]) {
    [fm removeFileAtPath: psPath handler: nil];
  }

  if ([fm fileExistsAtPath: tiffPath])
    {
      NSImage *image = [[NSImage alloc] initWithContentsOfFile: tiffPath];
      NSSize scaledSize;

      scaledSize = NSMakeSize([image size].width * (resolution / 72), [image size].height * (resolution / 72));
      [image setSize: scaledSize];
      [docwin setImage: image];
      RELEASE (image);
      [self setBusy: NO];
      return;
    }

  [fm createFileAtPath: psPath contents: nil attributes: nil];

  readHandle = [NSFileHandle fileHandleForReadingAtPath: myPath];
  writeHandle = [NSFileHandle fileHandleForWritingAtPath: psPath];

  [readHandle seekToFileOffset: [psdoc beginprolog]];
  data = [readHandle readDataOfLength: [psdoc lenprolog]];
  [writeHandle writeData: data];

  [readHandle seekToFileOffset: [psdoc beginsetup]];
  data = [readHandle readDataOfLength: [psdoc lensetup]];
  [writeHandle writeData: data];

  [readHandle seekToFileOffset: [pspage begin] - 1];		// WHY -1 ??????
  data = [readHandle readDataOfLength: [pspage len]];
  [writeHandle writeData: data];

  [readHandle seekToFileOffset: [psdoc begintrailer]];
  data = [readHandle readDataOfLength: [psdoc lentrailer]];
  [writeHandle writeData: data];

  [readHandle closeFile];
  [writeHandle closeFile];

  args = [NSMutableArray arrayWithCapacity: 1];		
  [args addObject: @"-dQUIET"];
  [args addObject: @"-dSAFER"];
  [args addObject: @"-dDELAYSAFER"];
  [args addObject: @"-dSHORTERRORS"];
  [args addObject: @"-dDOINTERPOLATE"];
  if ([docwin antiAlias])
    {
      [args addObject: @"-dTextAlphaBits=4"];
      [args addObject: @"-dGraphicsAlphaBits=4"];
    }
  [args addObject: [NSString stringWithFormat: @"-dDEVICEXRESOLUTION=%i", (int)resolution]];	
  [args addObject: [NSString stringWithFormat: @"-dDEVICEYRESOLUTION=%i", (int)resolution]];	
  [args addObject: [NSString stringWithFormat: @"-dDEVICEWIDTHPOINTS=%i", pagew]];	
  [args addObject: [NSString stringWithFormat: @"-dDEVICEHEIGHTPOINTS=%i", pageh]];	
  [args addObject: @"-sDEVICE=tiff24nc"];
  [args addObject: [NSString stringWithFormat: @"-sOutputFile=%@", tiffPath]];	
  [args addObject: psPath];	

  ASSIGN (task, [NSTask new]);
  [task setLaunchPath: gsComm];
  [task setArguments: args];

  pipe[0] = [NSPipe pipe];
  [task setStandardOutput: pipe[0]];
  fileHandle = [pipe[0] fileHandleForReading];

  [nc addObserver: self 
      selector: @selector(taskOut:) 
      name: NSFileHandleReadCompletionNotification
      object: (id)fileHandle];

  [fileHandle readInBackgroundAndNotify];

  pipe[1] = [NSPipe pipe];
  [task setStandardError: pipe[1]];		
  fileHandle = [pipe[1] fileHandleForReading];

  [nc addObserver: self 
      selector: @selector(taskErr:) 
      name: NSFileHandleReadCompletionNotification
      object: (id)fileHandle];

  [fileHandle readInBackgroundAndNotify];

  [nc addObserver: self 
      selector: @selector(endOfTask:) 
      name: NSTaskDidTerminateNotification
      object: (id)task];

  [task launch]; 
}

- (void)setZoomValue:(int)value
{
  resolution = ((72.00 / 100) * value);		
  [self regeneratePage];	
}

- (void)regeneratePage
{		
  [self clearTempFiles];	
  [self makePage];
}

- (void)setPaperSize:(id)sender
{
  NSString *title = [sender title];
  NSDictionary *paperSizes = [gspdf paperSizes];
  NSDictionary *pSize = [paperSizes objectForKey: title];
  int w = [[pSize objectForKey: @"w"] intValue];
  int h = [[pSize objectForKey: @"h"] intValue];

  if ((w != pagew) && (h != pageh))
    {
      [self clearTempFiles];		
      pagew = w;
      pageh = h;
      [self makePage];
    }
}

- (void)clearTempFiles
{
  int i;

  for (i = 0; i < [[psdoc pages] count]; i++)
    {
      PSDocumentPage *pspage = [[psdoc pages] objectAtIndex: i];	
      [self clearTempFilesOfPage: pspage];
    }
}

- (void)clearTempFilesOfPage:(PSDocumentPage *)page
{
  [fm removeFileAtPath: [page psPath] handler: nil];
  [fm removeFileAtPath: [page tiffPath] handler: nil];
  [fm removeFileAtPath: [page dscPath] handler: nil];
}

- (void)taskOut:(NSNotification *)notif
{
  NSFileHandle *fileHandle = [notif object];
  NSDictionary *userInfo = [notif userInfo];
  NSData *data = [userInfo objectForKey: NSFileHandleNotificationDataItem];

  if ([data length])
    {
      NSString *buff = [[NSString alloc] initWithData: data 
					 encoding: NSUTF8StringEncoding];
      NSRange range = [buff rangeOfString: @">>showpage, press <return> to continue<<"];

      if (range.length != 0)
	{
	  PSDocumentPage *pspage = [[psdoc pages] objectAtIndex: pageindex];
	  NSString *tiffPath = [pspage tiffPath];
	  NSImage *image = [[NSImage alloc] initWithContentsOfFile: tiffPath];
	  NSSize scaledSize;

	  [image setBackgroundColor: [NSColor windowBackgroundColor]];

	  scaledSize = NSMakeSize([image size].width * (resolution / 72), [image size].height * (resolution / 72));
	  [image setSize: scaledSize];
	  [docwin setImage: image];
	  RELEASE (image);

	  if (task && [task isRunning])
	    {
	      [task terminate];
	    }

	  [self setBusy: NO];
	  RELEASE (buff);
	  return;
	}

      [gspdf showConsole: nil];
      [[console textView] insertText: buff];
      RELEASE (buff);
      [self setBusy: NO];
    }

  if (task && [task isRunning])
    {
      [fileHandle readInBackgroundAndNotify];
    }
} 

- (void)taskErr:(NSNotification *)notif
{
  NSFileHandle *fileHandle = [notif object];
  NSDictionary *userInfo = [notif userInfo];
  NSData *data = [userInfo objectForKey: NSFileHandleNotificationDataItem];

  if ([data length])
    {
      NSString *buff = [[NSString alloc] initWithData: data 
					 encoding: NSUTF8StringEncoding];
      [gspdf showConsole: nil];
      [[console textView] insertText: buff];
      RELEASE (buff);
      [self setBusy: NO];
    }

  if (task && [task isRunning])
    {
      [fileHandle readInBackgroundAndNotify];
    }
}

- (void)endOfTask:(NSNotification *)notif
{
  if ([notif object] == task)
    {
      [nc removeObserver: self];
      RELEASE (task);
    }
}


- (void)makeWindowControllers
{
  docwin = [[GSPdfDocWin alloc] initWithWindowNibName:@"GSPdfDocument"];
  NSAssert (docwin, @"created doc nib nil");
  [self addWindowController: docwin];
}

// Printing
- (void)printShowingPrintPanel:(BOOL)flag
{
    NSPrintOperation *op;

    op = [NSPrintOperation printOperationWithView:[docwin imageView]
                                        printInfo:[self printInfo]];
    [op setShowPanels:flag];
NSLog(@"here in printShowingPrintPanel: info: %@", [[self printInfo] dictionary]);
    [op runOperationModalForWindow:[[[self windowControllers] objectAtIndex: 0] window]
                          delegate:nil
                    didRunSelector:NULL
                       contextInfo:nil];
}

/**
 * after the page layout is changed, update the view
 */
- (void)setPrintInfo:(NSPrintInfo *)printInfo
{
  [super setPrintInfo: printInfo];
  [[docwin imageView] updatePrintInfo: printInfo];
}

/**
 * overridden so to allow changing the page layout
 */
- (BOOL)shouldChangePrintInfo:(NSPrintInfo *)newPrintInfo
{
    return YES;
}


@end

