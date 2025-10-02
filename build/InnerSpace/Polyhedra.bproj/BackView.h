#include <AppKit/NSView.h>

@interface BackView:NSView
{
	id image;
	NSRect imageRect;
	NSPoint maxCoord;
	unsigned BVthen;
}

- (BOOL) timePassed: (int) delay; // (BStimeval) delay;
- initWithFrame:(NSRect)frameRect;
- drawRect:(NSRect)rects;
- setImageConstraints;
- setImage: newImage;
- (BOOL) useBufferedWindow;

@end
