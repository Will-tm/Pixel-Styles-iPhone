//
//  spectrumView.h
//  layer2d
//
//  Created by William Markezana on 22/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WMTouchDictionary.h"
#import "UIDevice+Resolutions.h"

#define BACK_IMAGE_VIEW_TAG        (101)

typedef enum
{
	touchUp = 0,
	touchDown,
	touchMove
}touch_type;

@interface SpectrumView : UIView
{
    id delegate;
    NSMutableArray *sortedTouches; 
    UIImage *spectrumImage;
    CGImageRef image;
    NSUInteger width;
    NSUInteger height;
    CGColorSpaceRef colorSpace;
    unsigned char *rawData;
    NSUInteger bytesPerPixel;
    NSUInteger bytesPerRow;
    NSUInteger bitsPerComponent;
    CGContextRef context;
    UIImageView *backImageView;
    WMTouchDictionary *_touchDictionary;
    NSDate *lastTouchMoved;
}

@property (nonatomic, readwrite) BOOL acceptTouch;
@property (nonatomic, readwrite) NSInteger maxTouchCount;

- (UIColor*)colorAtX:(NSInteger)x y:(NSInteger)y;
- (void)touchProcessing:(BOOL)shouldTransmitData;
- (void)setDelegate:(id)aDelegate;
- (void)willUpdateLayout;
- (void)didUpdateLayout;

@end

@interface NSObject (SpectrumViewDelegate)

- (void)spectrumViewGotColorStringReady:(NSString*)colorString;

@end
