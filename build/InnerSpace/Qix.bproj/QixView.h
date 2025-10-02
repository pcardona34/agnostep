
#import	<AppKit/NSView.h>
#import	<AppKit/NSGraphics.h>

/*
 *	This class implements what I've heard called, Qix lines.
 *
 *	Please send any suggestions for improving or correcting this
 *	screen saver to larry@netcom.com.  Have fun!
 *
 */
 
/**********************************************************************/

typedef	struct	moveable_point	// All values neccessary to keep track
		{						// of a moving points position and direction.

				int	x;				// x coordinate of the point.
				int	y;				// y coordinate of the point.
				
				int	x_dir;			// Points "x" direction, LEFT or RIGHT.
				int	y_dir;			// Points "y" direction, UP or DOWN.
				
				float	x_inc;		// Amount to move point in x's direction.
				float	y_inc;		// Amount to move point in y's direction.
				
				float	orig_inc;	// Used to reset x_inc and y_inc.
		}
		MVPOINT;


typedef	struct	qix_line		// Two moveable points make a moving line.
		{
			MVPOINT	pointA;
			MVPOINT	pointB;
		}
		QIX;

/*********************************************************************/

@interface QixView : NSView
{
	QIX		head;			// Head Qix values. Drawn in white.
	QIX		tail;			// Tail Qix values. Drawn in black.
	
	int		tailLen;		// Current length of tail.
}

/*********************************************************************/

//--------------------------------------------------------------//
//																//
- setQixPoint : ( MVPOINT * ) qix;								//
//																//
//	Sets a movable points next position.						//
//																//
//--------------------------------------------------------------//

//--------------------------------------------------------------//
//																//
- resetQix : ( QIX * ) qix : ( BOOL ) resetControls;			//
//																//
//	Resets a qix points fields to default values.				//
//																//
//--------------------------------------------------------------//

//--------------------------------------------------------------//
//																//
- initWithFrame  : ( NSRect ) frameRect;					//
//																//
//	Calls resetQix to reset the head and tail qix. 				//
//																//
//--------------------------------------------------------------//

- (NSString *) windowTitle;

//--------------------------------------------------------------//
//																//
- drawRect : ( NSRect ) r ;
//																//
//	Clears its view to a black background and calls resetQix,	//
//	to reset the head and tail qix to their default values.		//
//																//
//--------------------------------------------------------------//

//--------------------------------------------------------------//
//																//
- drawQix : ( QIX ) qix;										//
//																//
//	Draws a line between the two points in a qix structure.		//
//																//
//--------------------------------------------------------------//

//--------------------------------------------------------------//
//																//
- oneStep;														//
//																//
//	This is it the master method.  This method is the control	//
//	center for animating the qix lines.							//
//																//
//--------------------------------------------------------------//

@end
