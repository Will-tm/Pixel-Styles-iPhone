#import <UIKit/UIKit.h>

@interface UIImage (Resize)
- (UIImage*)imageScaledToSize:(CGSize)size;
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode imageToScale:(UIImage*)imageToScale bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *) makeThumbnailOfSize:(CGSize)size;

+ (UIImage *)getIconOfSize:(CGSize)size icon:(UIImage *)iconImage withOverlay:(UIImage *)overlayImage;

@end

