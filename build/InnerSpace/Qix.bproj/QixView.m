
#import	<stdlib.h>
#import	<math.h>
#import	<AppKit/NSApplication.h>
#import	<AppKit/NSSlider.h>
#import	<AppKit/NSButton.h>
#import	<AppKit/NSImage.h>
#import	<AppKit/PSOperators.h>
#import	"QixView.h"

/**********************************************************************/

#define	LEFT		( 100 )
#define	RIGHT		( 101 )
#define	UP			( 102 )
#define	DOWN		( 103 )

#define	INITLEN		( 55 )				//	Initial qix tail length.

#define	A_BASE_INC	( 5 )				//	Default distance to move the
										//	"A" point of a qix structure.
#define	B_BASE_INC	( 8 )				//	Default distance to move the
										//	"B" point of a qix structure.

/**********************************************************************/


@implementation QixView

/**********************************************************************/

- newWindow
{
	[ self resetQix : &head : NO ];
	[ self resetQix : &tail : YES ];
	
	return self;
}
 
/**********************************************************************/

- (NSString *) windowTitle
{
	return ( NSString * ) "Qix Lines";
}

/**********************************************************************/

- initWithFrame : ( NSRect ) frameRect
{
	[ super initWithFrame : frameRect ];
	
	[ self resetQix : &head : NO ];
	[ self resetQix : &tail : YES ];
	
	return self;
}

- (BOOL) isOpaque
{
  return YES;
}

/**********************************************************************/

- setFrame: (NSRect) size 
{
  [ super setFrame: size];
  
  [ self resetQix : &head : NO ];
  [ self resetQix : &tail : YES ];
  
  return self;
}

/**********************************************************************/

- resetQix : ( QIX * ) qix : ( BOOL ) resetControls
{
  NSRect bounds = [self bounds];

  if( resetControls == YES )
    tailLen = INITLEN;
	
	qix->pointA.x = bounds.size.width / 3.0;
	qix->pointA.y = bounds.size.height / 3.0;
	qix->pointA.x_dir = RIGHT;
	qix->pointA.y_dir = DOWN;
	qix->pointA.x_inc = A_BASE_INC;
	qix->pointA.y_inc = A_BASE_INC;
	qix->pointA.orig_inc = A_BASE_INC;
	
	qix->pointB.x = bounds.size.width / 2.0;
	qix->pointB.y = bounds.size.height / 2.0;
	qix->pointB.x_dir = LEFT;
	qix->pointB.y_dir = UP;
	qix->pointB.x_inc = B_BASE_INC;
	qix->pointB.y_inc = B_BASE_INC;
	qix->pointB.orig_inc = B_BASE_INC;
	
	return self;
}

/**********************************************************************/
	
- setQixPoint : ( MVPOINT * ) point
{
  NSRect bounds = [self bounds];
	if( point->x >= bounds.size.width )
	{
		point->x_dir = LEFT;
		point->x_inc = point->orig_inc;
	}
	else if( point->x <= 0 )
		point->x_dir = RIGHT;
	
	if( point->x_dir == RIGHT )
	{
		point->x += point->x_inc;
		point->x_inc -= .009;
	}
	else
	{
		point->x -= point->x_inc;
		point->x_inc += .03;
	}

	if( point->y >= bounds.size.height )
	{
		point->y_dir = DOWN;
		point->y_inc = point->orig_inc;
	}
	else if( point->y <= 0 )
		point->y_dir = UP;
		
	if( point->y_dir == UP )
	{
		point->y += point->y_inc;
		point->y_inc -= .009;
	}
	else
	{
		point->y -= point->y_inc;
		point->y_inc += .06;
	}
		
	return self;
}

/**********************************************************************/

- drawQix : ( QIX ) qix
{
	PSsetlinewidth( 0.5 );

	PSmoveto( qix.pointA.x, qix.pointA.y );
	PSlineto( qix.pointB.x, qix.pointB.y );
	PSstroke( );

	NSLog(@"%d, %d - %d, %d", qix.pointA.x, qix.pointA.y, qix.pointB.x, qix.pointB.y );

	
	return self;
}

/**********************************************************************/

- oneStep
{
	if( tailLen )
		--tailLen;
	else
	{
		PSsetgray( 1.0 );
		[ self drawQix : tail ];
		[ self setQixPoint :  &tail.pointA ];
		[ self setQixPoint :  &tail.pointB ];
	}
	
	PSsetgray( 1.0 );
	[ self drawQix : head ];
	[ self setQixPoint : &head.pointA ];
	[ self setQixPoint : &head.pointB ];
	
	return self;
}

/**********************************************************************/

- drawRect : ( NSRect ) r 
{	 
	PSsetgray( 0.0 );
	
	NSRectFill( r );
	
	return self;
	
}

/**********************************************************************/

@end
