#import <AppKit/NSView.h>

#define NSTARS (200)
#define STARSPERIT (100)

typedef struct STAR {
	float theta;	// angle
	float distance;
	float delta;	// change in distance
	float ddelta;	// change in delta, a constant multiplier
	int changemode;
	float changepoint[6];
	
	NSRect draw;
	NSRect erase;
	
	} STAR;

@interface Space2View:NSView
{
	STAR stars[NSTARS];
	int nstars;
	int radius;			// min radius of this view

	NSRect b[NSTARS];
	NSRect w[NSTARS];
}

- convertToXY:(STAR *)p;
- oneStep;
- drawRect:(NSRect)rects;
- setFrame: (NSRect)rect;
- addStar;
- replaceStarAt:(int)index;
- setRadius;
@end

