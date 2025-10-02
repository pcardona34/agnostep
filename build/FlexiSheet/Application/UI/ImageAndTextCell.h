//
//  ImageAndTextCell.h
//
//  Copyright (c) 2001 Apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#if !defined(NSUInteger)
#define NSUInteger unsigned
#endif
#if !defined(NSInteger)
#define NSInteger int
#endif
#if !defined(CGFloat)
#define CGFloat float
#endif
#endif


@interface ImageAndTextCell : NSTextFieldCell {
@private
    NSImage	*image;
}

- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

@end

