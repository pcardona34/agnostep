#import <AppKit/NSView.h>

#define NUMLINES 305
#define PI 3.1415926

@interface ItJustStoppedView:NSView
{
  // all sorts of extra bogus variables in here that I have never cleaned up.
  int pp,p,n,erase,erasep,erasepp, lper, count;
  float x1[NUMLINES],yc1[NUMLINES],t1[NUMLINES],t2[NUMLINES],t3[NUMLINES],
  p1,p2,p3,
  xs,ys, xf,yf,
  x1d,y1d,x2d,y2d,x3d,y3d,x4d,y4d,
  x5d,y5d,x6d,y6d,x7d,y7d,x8d,y8d,
  urx,ury,pmx,pmy, midx, midy, t,
  s1,s2,s3,s4, oldx, oldy;
  int up, i;

  int winNum;
}

- oneStep;
- newSize;
@end

