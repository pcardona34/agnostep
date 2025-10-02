//
//  SLFloatingMark.h
//
//  Created by Stefan Leuker on Sun Sep 09 2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface SLFloatingMark : NSView {
    NSImage    *image;
    NSString   *text;
}

- (id)initWithImage:(NSString*)imageName;
- (id)initWithLabel:(NSString*)label;

- (void)close:(id)sender;
- (void)fadeOut:(id)sender;

- (void)positionAt:(NSPoint)screenPoint;
- (void)setLabel:(NSString*)label;

@end
