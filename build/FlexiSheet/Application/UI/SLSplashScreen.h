//
//  SLSplashScreen.h
//
//  Created by Stefan Leuker on Fri Sep 07 2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface SLSplashScreen : NSView {
    NSImage *image;
}

- (id)initWithName:(NSString*)imageName;

@end
