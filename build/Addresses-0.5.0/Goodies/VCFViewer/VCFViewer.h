// VCFViewer.h (this is -*- ObjC -*-)
// 
// Author: Björn Giesler <giesler@ira.uka.de>
// 
// VCF Content Viewer for GWorkspace
// 

#import <Foundation/Foundation.h>
#import <Inspector/ContentViewersProtocol.h>
#import <Addresses/Addresses.h>
#import <AddressView/ADPersonView.h>

@protocol ContentInspectorProtocol
- (void)contentsReadyAt:(NSString *)path;
@end

@interface VCFViewer: NSView <ContentViewersProtocol>
{
  BOOL valid;
  id panel;
  NSArray *people;
  int currentPerson;

  NSScrollView *sv;
  NSClipView *cv;
  ADPersonView *pv;
  NSButton *nb, *pb;
  NSTextField *lbl;
  NSButton *ifb, *dfb;
  NSTextField *errLabel;

  NSString *bundlePath;
  NSString *vcfPath;
  NSWorkspace *ws;
  id<ContentInspectorProtocol> inspector;
}

- (void) nextPerson: (id) sender;
- (void) previousPerson: (id) sender;

- (void) increaseFontSize: (id) sender;
- (void) decreaseFontSize: (id) sender;
@end

