
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface SporView:NSView
{
	id	inspector;
	id	startPop;
	id	maxPop;
	id	startSpread;
	id	startCloud;
	id	kindRadio;
	id	eatRadio;
	id	sporWindow;

	int	kind,
			enemy,
			pop,
			sPop,
			spread,
		 	cloud;
	BOOL	initDone,
				inspectorPresent;

}

- oneStep;
- (id) initWithFrame:( NSRect )frameRect;
- (id) drawRect:(NSRect)rects;
/// - sizeToFit:(NSSize)size;

- (id)inspectorInstalled;
- (id)inspectorWillBeRemoved;
- inspector: sender;

- toggleKind:sender;
- toggleEnemy:sender;

- getStartParameter;
- showStartParameter;
- ( int )setRangeForValue:( int )aValue Low:( int )low High:( int )high;

@end
