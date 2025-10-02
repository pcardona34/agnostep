 /*
 *  GSPdfDocument.h: Interface and declarations for the GSPdfDocument 
 *  Class of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002-2010
 *  Riccardo Mottola
 *  Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: February 2002
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

@class GSPdfDocWin;
@class PSDocument;
@class PSDocumentPage;
@class GSPdf;
@class GSConsole;

@interface GSPdfDocument : NSDocument
{
  NSScrollView *matrixScroll;
  NSMatrix *pagesMatrix;

  GSConsole *console;

  NSString *myPath;
  PSDocument *psdoc;
  int pageindex;
  float resolution;
  int pagew, pageh;
  NSSize papersize;
  BOOL isPdf;
  GSPdfDocWin *docwin; /* window controller */  
  NSString *gsComm;
  NSTask *task;
  BOOL busy;	
  NSFileManager *fm;
  NSNotificationCenter *nc;	
  GSPdf *gspdf;
  
}

- (NSString *)myPath;

- (BOOL)isPdf;

- (void)nextPage;
- (void)previousPage;
- (void)regeneratePage;

- (void)goToPage:(id)sender;

- (void)makePage;
- (void)setZoomValue:(int)value;

- (void)setPaperSize:(id)sender;

- (void)clearTempFiles;

- (void)clearTempFilesOfPage:(PSDocumentPage *)page;

- (void)setBusy:(BOOL)value;

- (void)taskOut:(NSNotification *)notif;

- (void)taskErr:(NSNotification *)notif;

- (void)endOfTask:(NSNotification *)notif;

@end


