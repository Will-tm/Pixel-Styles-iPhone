//
//  UIImage+Additions.h
//  Pixel Styles
//
//  Created by William Markezana on 01/03/14.
//  Copyright (c) 2014 RGB Styles. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COLOR_PART_RED(color)    (((color) >> 16) & 0xff)
#define COLOR_PART_GREEN(color)  (((color) >>  8) & 0xff)
#define COLOR_PART_BLUE(color)   ( (color)        & 0xff)

@interface UIImage (Additions)
- (UIImage *)imageByRemovingColor:(uint)color;
- (UIImage *)imageByRemovingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor;
- (UIImage *)imageByReplacingColor:(uint)color withColor:(uint)newColor;
- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor;
- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor andAlpha:(float)alpha;
@end

@implementation UIImage (Additions)
- (UIImage *)imageByRemovingColor:(uint)color {
    return [self imageByRemovingColorsWithMinColor:color maxColor:color];
}

- (UIImage *)imageByRemovingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor {
    return [self imageByReplacingColorsWithMinColor:minColor maxColor:maxColor withColor:0 andAlpha:0];
}

- (UIImage *)imageByReplacingColor:(uint)color withColor:(uint)newColor {
    return [self imageByReplacingColorsWithMinColor:color maxColor:color withColor:newColor];
}

- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor {
    return [self imageByReplacingColorsWithMinColor:minColor maxColor:maxColor withColor:newColor andAlpha:1.0f];
}

- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor andAlpha:(float)alpha {
    CGImageRef imageRef = self.CGImage;
    float width = CGImageGetWidth(imageRef);
    float height = CGImageGetHeight(imageRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    uint minRed = COLOR_PART_RED(minColor);
    uint minGreen = COLOR_PART_GREEN(minColor);
    uint minBlue = COLOR_PART_BLUE(minColor);
    uint maxRed = COLOR_PART_RED(maxColor);
    uint maxGreen = COLOR_PART_GREEN(maxColor);
    uint maxBlue = COLOR_PART_BLUE(maxColor);
    float newRed = COLOR_PART_RED(newColor)/255.0f;
    float newGreen = COLOR_PART_GREEN(newColor)/255.0f;
    float newBlue = COLOR_PART_BLUE(newColor)/255.0f;
    
    CGContextRef context = nil;
    
    if (alpha) {
        context = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
        CGContextSetRGBFillColor(context, newRed, newGreen, newBlue, alpha);
        CGContextFillRect(context, bounds);
    }
    CGFloat maskingColors[6] = {minRed, maxRed, minGreen, maxGreen, minBlue, maxBlue};
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(imageRef, maskingColors);
    if (!maskedImageRef) return nil;
    if (alpha) CGContextDrawImage(context, bounds, maskedImageRef);
    CGImageRef newImageRef = (alpha)?CGBitmapContextCreateImage(context):maskedImageRef;
    if (context) CGContextRelease(context);
    if (newImageRef != maskedImageRef) CGImageRelease(maskedImageRef);
    
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

@end