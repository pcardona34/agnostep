
#define IB_PARSE_HACK 0

#import <AppKit/NSApplication.h>
#import <AppKit/PSOperators.h>


#include <sys/resource.h>

#define NOWINDOW		(0)
#define NORMALWINDOW	(1)
#define BACKWINDOW		(2)

#define SAVERTIER (50)

// I'm not at all happy with BackSpace's time handling; it only works
// for 49 days after rebooting (according to my calculations... I boot
// a lot more often than that!) since it counds milliseconds in a
// 32 bit unsigned int.  This problem would be solved if I stuffed the
// time in a long long, but I think the compiler doesn't correctly do
// 64 bit comparisons.  Time should probably stay in the unix
// timeval struct.  Yuck! guess I should write functions for time
// addition and comparison...

// typedef long long BStimeval;  //doesn't work
typedef unsigned BStimeval;

enum BSEvents {BSDOSAVER, BSOPENFILE};

BStimeval currentTimeInMs();

float frandom();
float randBetween(float a, float b);

@interface Thinker:NSObject
{
    id	spaceView;
	
    id	spaceWindow;
    id	normalWindow;
    id	bigUnbufferedWindow;
    id	bigBufferedWindow;

	BOOL timerValid, keepLooping;
	BOOL doingSaver;
	DPSTimedEntry timer;
	
	int windowType;
	int realViewIndex;
	int virtualViewIndex;
	NXRect windowRect;
	
	NXZone *backZone;
	
	int screenCount;
	id windMatrix;

	id screenSaver;
	id screenLocker;
	BOOL screenSaverVal;
	id mySlider;

	id priorityLevel;
	int priority;
	int realDimInterval;
	
	int evs;	//event driver file descriptor
	int oldDimBrightness, normalBrightness;
	int dimTime;
	
	id myColorWell;
	id viewSelectionBrowser;
	id moduleList;
	id imageView;
	NXScreen *screens;
	id screenList;

	id image;
	int globalTier;
	
	id password;
	
	id invisibleInspectorBox;
	id commonImageInspector;
	id nullInspector;
	id spaceInspector;
	id currentInspector;
	NXRect inspectorFrame;
	id oldInspectorOwner;
	BOOL browserValid;

	
	char *fileToOpen;
	BOOL openAnother;
}

- appDidInit:sender;
- appDidHide:sender;
- appDidUnhide:sender;
- createTimer;
- removeTimer;
- doDistributorLoop;

- installSpaceViewIntoWindow:w;
- useNormalWindow;
- (int) backingTypeForView:aView;
- useBackWindow:(int)tier;
- createBigWindowIfNecessaryForView:aView;

- getWindowType;
- changeWindowType:sender;
- changeWindowTypeAndRemember:(BOOL)rem;

- getScreenSaverSetting;
- changeScreenSaverSetting:sender;
- setScreenSaver:(BOOL)val andRemember:(BOOL)rem;
- calcDimTime;
- maybeDoScreenSaver:sender;
- applicationDefined:(NXEvent *)theEvent;
- doScreenSaverAndResetTimer;
- showFakeScreenSaver:sender;
- doScreenSaver:sender;

- getPrioritySetting;
- changeSliderValue:sender;
- saveSliderValue;

- setImageFromFile: (const char *) filename;
- setImageFromName: (const char *) name;
- commonImageInit;
- getImageFile;
- setImageFileFrom: sender;

#if !IB_PARSE_HACK
@end


@interface Thinker(thinkMore)
#endif

- getBackgroundColor;
- setBackgroundColor:sender;

- getViewType;
- selectRealViewIndex:sender;
- setVirtualViewIndexAndIncrement:(BOOL)flag;
- selectScreenSaverViews;
- setWindowTitle;

- getScreenLockerSetting;
- changeScreenLockerSetting:sender;
- setScreenLocker:(BOOL)val andRemember:(BOOL)rem;

- backView;

#if !IB_PARSE_HACK
@end


@interface Thinker(ioctls)
#endif

- normalMode;
- screenSaverMode;

- blackOutAllScreens;
- unBlackOutAllScreens;

- getDimBrightness:(int *)b;
- _setDimBrightness :(int *)b;

- getNormalBrightness :(int *)b;

- getDimTime :(int *)t;
- getDimInterval :(int *)i;
- setDimInterval :(int *)i;

- getDimStatus :(int *)s;

#if !IB_PARSE_HACK
@end

@interface Thinker(inspector)
#endif

- commonImageInspector;
- nullInspector;
- spaceInspector;
- revertToDefaultImage:sender;
- (BOOL)browser:sender columnIsValid:(int)column;
- addCellWithString:(const char *)str at:(int)row toMatrix:matrix;
- (int)browser:sender fillMatrix:matrix inColumn:(int)column;

- loadViewsFrom: (const char *) dirname;
- doDelayedOpenFile;

- (const char *) appDirectory;
- (const char *) moduleDirectory:(const char *)name;

@end

