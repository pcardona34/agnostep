#import "ItJustStoppedViewPart.h"
#import <AppKit/NSImage.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSPanel.h>                // for NXRunAlertPanel()
#import <AppKit/AppKit.h>
#import <AppKit/PSOperators.h>
#import <math.h>

@implementation ItJustStoppedView

- oneStep
{
  float mx = 100, my = 100;
  float xi, yi;
  NSRect bounds = [self bounds];

  n=(n+1)%(NUMLINES-1);
    
  p=(p+1)%(NUMLINES-1);
    
  pp=(pp+1)%(NUMLINES-1);

  // PScurrentmouse(winNum, &mx, &my);
  xi=((mx-midx)/urx)*10.0;
  yi=((my-midy)/ury)*10.0;

  if((count++>500) && (((mx != oldx) && (my != oldy)) || (count>30000))){
    count=0;
    PSsetgray(0.0);
    NSRectFill(bounds);
  }
  oldx=mx; oldy=my;

  t1[n]=t1[p]+0.2*xi; if(t1[n]>(2*PI)) t1[n]-=(2*PI);
  t2[n]=t2[p]+0.2*yi; if(t2[n]>(2*PI)) t2[n]-=(2*PI);
  t3[n]=t3[p]+0.01;   if(t3[n]>(2*PI)) t3[n]-=(2*PI);

  x1[n]=(cos(t1[n])*s1) + (cos(t2[n])*s3) + midx;
  yc1[n]=(sin(t1[n])*s2) + (sin(t2[n])*s4) + midy;

  PSsetrgbcolor((cos(t1[n])+1.0)/2.0,
                (cos(t2[n])+1.0)/2.0,
                (cos(t3[n]*1.5)+1.0)/2.0);

  PSnewpath();
  PSmoveto(x1[pp], yc1[pp]);
  PSlineto(x1[p], yc1[p]);
  PSlineto(x1[n], yc1[n]);
  PSclosepath();
  PSfill();

  return self;
}

- initWithFrame:(NSRect)frameRect
{
  [super initWithFrame:frameRect];
  [self newSize];
  winNum=[[self window] windowNumber];
  return self;
}

- setFrame: (NSRect)frame
{
  [super setFrame: frame];
  [self newSize];
  return self;
}

- newSize
{
  int jkl;
  NSRect bounds = [self bounds];

  urx=bounds.size.width;
  ury=bounds.size.height;
  
  midx=urx/2;
  midy=ury/2;

  n = 0;
  t = 0;
  
  // phases of the three points;
  p1=0;
  p2=(4*PI)/3;
  p3=(2*PI)/3;
  
  // starting angle of each point;
  t1[0]=0;
  t2[0]=p2;
  t3[0]=p3;

  for(jkl=0;jkl<NUMLINES;jkl++){
    x1[jkl]=midx;
    yc1[jkl]=midy;
  }

  // s1 and s2 should define an oval that takes up middle 75% of the screen
  s1 = midx*0.5; s2 = midy*0.5;
  s3 = midx*0.5; s4 = midy*0.5;

  // line per is the percentage back that erase steps
  lper=NUMLINES-5;

  n=lper;
  p=(lper/3)*2;
  pp=(lper/3);
  return self;
}

@end
