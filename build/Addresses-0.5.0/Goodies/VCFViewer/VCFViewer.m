// VCFViewer.m (this is -*- ObjC -*-)
// 
// Author: Björn Giesler <giesler@ira.uka.de>
// 
// VCF Content Viewer for GWorkspace
// 

#import "VCFViewer.h"

@implementation VCFViewer

- (void)dealloc
{
  RELEASE (sv);
  RELEASE (errLabel);
  RELEASE (bundlePath);
  [super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect inspector:(id)insp
{
  self = [super initWithFrame:frameRect];
  if (self)
    {
      sv = [[NSScrollView alloc] initWithFrame: NSMakeRect(0, 30, 257, 215)];
      [sv setHasVerticalScroller: YES];
      [sv setHasHorizontalScroller: YES];
      [sv setBorderType: NSBezelBorder];
      [self addSubview: sv];

      errLabel = [[NSTextField alloc] initWithFrame: NSMakeRect(0, 30, 257, 215)];	
      [errLabel setFont: [NSFont systemFontOfSize: 18]];
      [errLabel setAlignment: NSCenterTextAlignment];
      [errLabel setBackgroundColor: [NSColor windowBackgroundColor]];
      [errLabel setTextColor: [NSColor darkGrayColor]];	
      [errLabel setBezeled: NO];
      [errLabel setEditable: NO];
      [errLabel setSelectable: NO];
      [errLabel setStringValue: NSLocalizedString(@"Invalid Contents", @"")];

      cv = [[NSClipView alloc] initWithFrame: [sv frame]];
      [cv setAutoresizesSubviews: YES];
      [sv setContentView: cv];
      [cv release];

      pv = [[ADPersonView alloc] initWithFrame: NSZeroRect];
      [pv setFillsSuperview: YES];
      [pv setFontSize: 6.0];
      [pv setAcceptsDrop: NO];
      [pv setDelegate: self];
      [cv setDocumentView: pv];
      [pv release];

      pb = [[NSButton alloc] initWithFrame: NSMakeRect(80, 0, 20, 20)];
      [pb setImage: [NSImage imageNamed: @"common_ArrowLeft"]];
      [pb setImagePosition: NSImageOnly];
      [pb setTarget: self];
      [pb setAction: @selector(previousPerson:)];
      [self addSubview: pb];
      [pb release];

      lbl = [[NSTextField alloc] initWithFrame: NSMakeRect(100, 0, 57, 20)];
      [lbl setEditable: NO];
      [lbl setSelectable: NO];
      [lbl setBezeled: NO];
      [lbl setDrawsBackground: NO];
      [lbl setAlignment: NSCenterTextAlignment];
      [self addSubview: lbl];
      [lbl release];

      nb = [[NSButton alloc] initWithFrame: NSMakeRect(157, 0, 20, 20)];
      [nb setImage: [NSImage imageNamed: @"common_ArrowRight"]];
      [nb setImagePosition: NSImageOnly];
      [nb setTarget: self];
      [nb setAction: @selector(nextPerson:)];
      [self addSubview: nb];
      [nb release];

      dfb = [[NSButton alloc] initWithFrame: NSMakeRect(215, 0, 20, 20)];
      [dfb setTitle: @"-"];
      [dfb setTarget: self];
      [dfb setAction: @selector(decreaseFontSize:)];
      [dfb setContinuous: YES];
      [self addSubview: dfb];
      [dfb release];

      ifb = [[NSButton alloc] initWithFrame: NSMakeRect(237, 0, 20, 20)];
      [ifb setTitle: @"+"];
      [ifb setTarget: self];
      [ifb setAction: @selector(increaseFontSize:)];
      [ifb setContinuous: YES];
      [self addSubview: ifb];
      [ifb release];

      people = nil;
      bundlePath = nil;
      vcfPath = nil;
      ws = [NSWorkspace sharedWorkspace];  
      inspector = insp;
      valid = YES;

    }
  return self;
}

- (void) setBundlePath: (NSString*) path
{
  [bundlePath release];
  bundlePath = [path copy];
}

- (NSString*) bundlePath
{
  return bundlePath;
}

// TODO: right now this is runing on the same thread or process
// It conversion should detach in a separate process like image resizers
- (void)displayPath:(NSString *)path
{
  id<ADInputConverting> conv;
  ADRecord *r;
  NSMutableArray *ppl;

  BOOL decoded;

  ASSIGNCOPY(vcfPath, path);

  decoded = NO;
  if ([self canDisplayPath: vcfPath] == YES)
    {
      conv = [[ADConverterManager sharedManager]
	       inputConverterWithFile: path];
      DESTROY(people);

      if (conv == nil)
	{
	  NSLog(@"failed to open file");
	}
  
      ppl = [NSMutableArray array];
      while((r = [conv nextRecord]))
	if([r isKindOfClass: [ADPerson class]])
	  [ppl addObject: r];
      people = [[NSArray alloc] initWithArray: ppl];
      currentPerson = 0;
      if([people count])
	{
	  decoded = YES;

	  if (!valid)
            {
              valid = YES;
              [errLabel removeFromSuperview];
              [self addSubview: sv];
            }
	  [pv setPerson: [people objectAtIndex: currentPerson]];
	  [ifb setEnabled: YES];
	  [dfb setEnabled: YES];
	  [lbl setStringValue: [NSString stringWithFormat: @"%d/%d",
					 currentPerson+1, (int)[people count]]];
	}
      else
	{
	  NSLog(@"read, but no people found");
	  [pv setPerson: nil];
	  [ifb setEnabled: NO];
	  [dfb setEnabled: NO];
	  [lbl setStringValue: @""];
	}

      if([people count] > 1)
	{
	  [nb setEnabled: YES];
	  [pb setEnabled: YES];
	}
      else
	{
	  [nb setEnabled: NO];
	  [pb setEnabled: NO];
	}
    }

  if (decoded)
    {
      [sv setNeedsDisplay: YES];
    }
  else
    {
      if (valid)
        {
          valid = NO;
          [sv removeFromSuperview];
          [self addSubview: errLabel];
        }
    }

  [inspector contentsReadyAt: path];

  return;
}

- (void)displayLastPath:(BOOL)forced
{
  if (vcfPath) {
    if (forced)
      [self displayPath: vcfPath];
    else
      [inspector contentsReadyAt: vcfPath];
  }
}

- (BOOL)canDisplayDataOfType:(NSString *)type
{
    return NO;
}

- (void)displayData: (NSData*) data
	     ofType: (NSString*) type
{
}

- (void) stopTasks
{
}

- (void) deactivate
{
  [self removeFromSuperview];
  DESTROY(people);
}

- (NSString *)path
{
    return vcfPath;
}

- (BOOL)canDisplayPath:(NSString *)path
{
  NSDictionary *attributes;
  NSString *defApp, *fileType, *extension;
  NSArray *types;

  attributes = [[NSFileManager defaultManager] fileAttributesAtPath: path
					       traverseLink: YES];
  if ([attributes objectForKey: NSFileType] == NSFileTypeDirectory) {
    return NO;
  }		
			
  [ws getInfoForFile: path application: &defApp type: &fileType];
	
  if(([fileType isEqual: NSPlainFileType] == NO)
     && ([fileType isEqual: NSShellCommandFileType] == NO)) {
    return NO;
  }

  extension = [path pathExtension];
  types = [NSArray arrayWithObjects: @"vcf", @"vcard", nil];

  if ([types containsObject: [extension lowercaseString]])
    {
      // maybe we can run some more heuristics without parsing the whole file?
      return YES;
    }

  return NO;
}

- (NSString *)description
{
    return NSLocalizedString(@"This Inspector Displays content of vcard files", @"");
}

- (NSString *)winname
{
  return NSLocalizedString(@"VCF Inspector", @"");
}

- (void) nextPerson: (id) sender
{
  if (!people)
    return;

  currentPerson++;
  if(currentPerson > [people count]-1)
    currentPerson = 0;

  if([people count])
    [pv setPerson: [people objectAtIndex: currentPerson]];
  else
    [pv setPerson: nil];
  [lbl setStringValue: [NSString stringWithFormat: @"%d/%d",
				 currentPerson+1, (int)[people count]]];
}

- (void) previousPerson: (id) sender
{
  if (!people)
    return;

  currentPerson--;
  if(currentPerson < 0)
    currentPerson = [people count]-1;
  
  if([people count])
    [pv setPerson: [people objectAtIndex: currentPerson]];
  else
    [pv setPerson: nil];
  
  [lbl setStringValue: [NSString stringWithFormat: @"%d/%d",
				 currentPerson+1, (int)[people count]]];
}

- (void) increaseFontSize: (id) sender
{
  [pv setFontSize: [pv fontSize]+2];
  if([pv fontSize] > 2)
    [dfb setEnabled: YES];
}

- (void) decreaseFontSize: (id) sender
{
  if([pv fontSize] <= 2) return;
  [pv setFontSize: [pv fontSize]-2];
  if([pv fontSize] <= 2)
    [dfb setEnabled: NO];
}

//
// Delegate stuff
//
- (BOOL) personView: (ADPersonView*) aView
     willDragPerson: (ADPerson*) person
{
  return YES;
}

- (BOOL) personView: (ADPersonView*) aView
   willDragProperty: (NSString*) property
{
  return NO;
}

@end
