/*
 *  GSPdf.m: Principal Class  
 *  of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002-2018 GNUstep Application Project
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
 *  
 *  Authors: Riccardo Mottola
 *           Enrico Sersale
 * 
 *  Creation: Date: August 2001
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
#import "GSPdf.h"
#import "PSDocument.h"
#import "GSPdfDocument.h"
#import "GSPdfDocWin.h"
#import "GSConsole.h"
#import "Functions.h"

#ifndef GNUSTEP
#import "GNUstep.h"
#endif

#define MAXPAGES 9999
#define GHOSTSCRIPT_PATH_KEY @"GhostScriptPath"

static GSPdf *gspdf = nil;

@implementation GSPdf

+ (void)initialize
{
  static BOOL initialized = NO;
	
  if (initialized == YES)
    {
      return;
    }
	
  initialized = YES;
}

+ (GSPdf *)gspdf
{
  if (gspdf == nil)
    {
      gspdf = [[GSPdf alloc] init];
    }	
  return gspdf;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication
{
    return NO;
}

- (void)dealloc
{
  RELEASE (workPath);
  RELEASE (paperSizes);
  RELEASE (gsConsole);
  RELEASE (processId);

  [gsPath release];

  [super dealloc];
}

- (id)init
{
  self = [super init];

  if (self)
    {		
      processId = RETAIN([NSNumber numberWithInt: [[NSProcessInfo processInfo] processIdentifier]]);
      pageIdentifier = 0;
      documents = [[NSMutableArray alloc] initWithCapacity: 1];
      ASSIGN (workPath, NSHomeDirectory());
      gsConsole = [GSConsole new];
      nc = [NSNotificationCenter defaultCenter];
      gspdf = self;
    }

  return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  NSUserDefaults *defaults;
  NSString *gsPathStr;
  NSString *path = [[NSBundle mainBundle] pathForResource: @"papersizes" ofType: @"plist"];
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

  if (dict && [dict objectForKey: @"papersizes"])
    {
      NSArray *names;
      NSMenu *menu;
      int i;
		
      ASSIGN (paperSizes, [dict objectForKey: @"papersizes"]);
      names = [paperSizes allKeys];		
      menu = [[[NSApp mainMenu] itemWithTitle: NSLocalizedString(@"Document", @"")] submenu];
      menu = [[menu itemWithTitle: NSLocalizedString(@"Page Size", @"")] submenu];
		
      for (i = 0; i < [names count]; i++)
	{
	  addItemToMenu(menu, [names objectAtIndex: i], @"", @"setPaperSize:", @"");
	}

    }
  else
    {
      paperSizes = [NSDictionary new];
    }

  defaults = [NSUserDefaults standardUserDefaults];
  gsPathStr = [defaults stringForKey:GHOSTSCRIPT_PATH_KEY];
  if (gsPathStr == nil)
    {
#if defined __NetBSD__
    gsPathStr = @"/usr/pkg/bin/gs";
#else
    gsPathStr = @"/usr/bin/gs";
#endif
    }
  [gsPath release];
  gsPath = [[NSString stringWithString:gsPathStr] retain];
}

- (BOOL)application:(NSApplication *)app openFile:(NSString *)filename
{
  NSDocumentController *dc;
  GSPdfDocument *doc;

  dc = [NSDocumentController sharedDocumentController];
  doc = [dc openDocumentWithContentsOfFile:filename display:YES];

  if (doc)
    {
      ASSIGN (workPath, [filename stringByDeletingLastPathComponent]);
      return YES;
    }	
  return NO;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app 
{
  unsigned i;

  for (i = 0; i < [documents count]; i++)
    {
      GSPdfDocument *doc = [documents objectAtIndex: i];
				
      [doc clearTempFiles]; 
		
      if ([doc isPdf])
      { // TODO shouldn't the document handle this by itselsf?
	[[NSFileManager defaultManager] removeFileAtPath: [doc myPath] 
					handler: nil];		
      }
    }	

  return NSTerminateNow;
}

- (void)documentHasClosed:(GSPdfDocument *)doc
{
  [doc clearTempFiles];
  [documents removeObject: doc];
}

- (NSDictionary *)uniquePageIdentifier
{
  NSString *tempName = [NSString stringWithFormat: @"gspdf_%@_%i", [processId stringValue], pageIdentifier];	
  NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent: tempName];
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: 1];

  [dict setObject: [tempPath stringByAppendingPathExtension: @"ps"] forKey: @"pspath"];
  [dict setObject: [tempPath stringByAppendingPathExtension: @"tiff"] forKey: @"tiffpath"];
  [dict setObject: [tempPath stringByAppendingPathExtension: @"dsc"] forKey: @"dscpath"];

  pageIdentifier++;
  if (pageIdentifier >= MAXPAGES)
    {
      pageIdentifier = 0;
    }
	
  return dict;
}

- (NSDictionary *)paperSizes
{
  return paperSizes;
}

- (GSConsole *)console
{
  return gsConsole;
}

- (IBAction)showConsole:(id)sender
{
  [[gsConsole window] orderFrontRegardless];
}

- (IBAction)showPrefPanel:(id)sender
{
  [gsPathField setStringValue:gsPath];
  [prefPanel makeKeyAndOrderFront:self];
}

- (IBAction)prefSave:(id)sender
{
  NSUserDefaults *defaults;
  NSString *gsPathStr;

  defaults = [NSUserDefaults standardUserDefaults];
  gsPathStr = [gsPathField stringValue];
  if (gsPathStr != nil)
    {
      [defaults setObject:gsPathStr forKey:GHOSTSCRIPT_PATH_KEY];
      [gsPath release];
      gsPath = [[NSString stringWithString:gsPathStr] retain];
    }

  [prefPanel performClose:nil];
}

- (IBAction)prefCancel:(id)sender
{
  [prefPanel performClose:nil];
}

- (IBAction)chooseGsPath:(id)sender
{
  NSOpenPanel *openPanel;
  int result;

  openPanel = [NSOpenPanel openPanel];
  [openPanel setTitle: @"Select executable"];	
  [openPanel setAllowsMultipleSelection: NO];
  [openPanel setCanChooseFiles: YES];
  [openPanel setCanChooseDirectories: NO];

  result = [openPanel runModalForDirectory: workPath file: nil 
		      types: nil];

  if(result != NSOKButton)
    {
      return;
    }
  [gsPathField setStringValue:[openPanel filename]];
}

- (IBAction)previousPage:(id)sender
{
  [[[NSDocumentController sharedDocumentController] currentDocument] previousPage];
}

- (IBAction)nextPage:(id)sender
{
  [[[NSDocumentController sharedDocumentController] currentDocument] nextPage];
}

- (void)runInfoPanel:(id)sender
{
  [NSApp orderFrontStandardInfoPanel:self];
}

- (BOOL)windowShouldClose:(id)sender
{
  return YES;
}

- (NSString *)gsPath
{
  return [NSString stringWithString:gsPath];
}


@end
