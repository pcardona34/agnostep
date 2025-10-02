/* 
   Copyright (C) 2013 German A. Arias <german@xelalug.org>

   This file is part of Gemas application

   Gemas is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "EditorWindow.h"

@implementation EditorWindow

- (id) initWithContentRect: (NSRect)contentRect styleMask: (unsigned int)aStyle backing: (NSBackingStoreType)bufferingType defer: (BOOL)flag
{
  NSInteger width = 680, height = 510;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      
  //Set the Window size
  if ([defaults integerForKey: @"EditorWidth"] != 0)
    {
      width = [defaults integerForKey: @"EditorWidth"];
    }
  
  if ([defaults integerForKey: @"EditorHeight"] != 0)
    {
      height = [defaults integerForKey: @"EditorHeight"];
    }
  
  if ( (height != 510) || (width != 680) )
    {
      contentRect.size.width = width;
      contentRect.size.height = height;
    }
  
  self = [super initWithContentRect: contentRect styleMask: aStyle backing: bufferingType defer: flag];

  return self;
}

@end
