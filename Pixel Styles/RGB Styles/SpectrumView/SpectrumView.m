//
//  spectrumView.m
//  layer2d
//
//  Created by William Markezana on 22/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "spectrumView.h"

@implementation SpectrumView

@synthesize acceptTouch;

- (void)willUpdateLayout
{    
    for(CALayer *layer in  [self.layer.sublayers copy])
    {
        if([layer.name isEqualToString:@"Background"])
            [layer removeFromSuperlayer];
    }
}

- (void)didUpdateLayout
{    
    spectrumImage = nil;    
    [self setNeedsDisplay];
}

- (void)setAcceptTouch:(BOOL)acceptTouch_
{
    self.userInteractionEnabled = acceptTouch_;
}

- (void)awakeFromNib
{            
    acceptTouch = YES;
    self.userInteractionEnabled = YES;
 
    spectrumImage = [UIImage imageNamed:@"Spectrum"];
    
    image = spectrumImage.CGImage;
    width = CGImageGetWidth(image);
    height = CGImageGetHeight(image);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    rawData = malloc(height * width * 4);
    bytesPerPixel = 4;
    bytesPerRow = bytesPerPixel * width;
    bitsPerComponent = 8;
    context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);    

    backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spectrum.png"] ];

    if ([UIDevice currentResolution] == UIDevice_iPhoneTallerHiRes)
        backImageView.frame = CGRectMake(0.0, 0.0, width/2.0, height/2.0);
    else if ([UIDevice currentResolution] == UIDevice_iPhoneHiRes)
        backImageView.frame = CGRectMake(0.0, 0.0, width/2.0, height/2.0);
    else
        backImageView.frame = CGRectMake(0.0, 0.0, width, height);

    backImageView.tag = BACK_IMAGE_VIEW_TAG;
    
    self.opaque = NO;
    [self addSubview: backImageView];
    
    _touchDictionary = [[WMTouchDictionary alloc] init];
}

- (UIView *)fingerViewAtPoint:(CGPoint)point withColor:(UIColor*)color
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(point.x-30.0f, point.y-30.0f, 60.0f, 60.0f)];
    view.opaque = NO;
    view.userInteractionEnabled = NO;
    view.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:0.95].CGColor;
    view.layer.cornerRadius = 30.0f;
    view.layer.borderWidth = 2.0f;
    view.layer.backgroundColor = color.CGColor;
    view.layer.shadowOpacity = 0.7; 
    view.layer.shadowRadius = 2.0;
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    return view;
}

- (UIColor*)colorAtX:(NSInteger)x y:(NSInteger)y
{    
    x--;y--;
    if((x>=0)&&(y>=0)&&(x<width)&&(y<height))
    {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0))  
        {
            x *= 2;
            y *= 2;
        }
        
        @try
        {
            if((x>=0)&&(y>=0)&&(x<width)&&(y<height))
            {
                uint64_t byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
                UIColor *currentColor = [[UIColor alloc] initWithRed:rawData[byteIndex]/255.0 green:rawData[byteIndex + 1]/255.0 blue:  rawData[byteIndex + 2]/255.0 alpha:rawData[byteIndex + 3]/255.0];
                return(currentColor);
            }
            else
            {
                return nil;
            }
        }
        @catch (NSException* ex)
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}
 
#pragma mark -
#pragma mark Touch Events management

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(sortedTouches == nil)
        sortedTouches = [[NSMutableArray alloc] init];
    
    for(UITouch *touch in touches)
    {
        if(![sortedTouches containsObject:touch])
        {
            [sortedTouches addObject:touch];
        }
    }
    
    lastTouchMoved = [NSDate dateWithTimeIntervalSinceNow: 0.100];
    
    [self touchProcessing:YES];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{   
	for(UITouch *touch in touches)
    {
        if(![sortedTouches containsObject:touch])
        {
            [sortedTouches addObject:touch];
        }
    }
    
    if([lastTouchMoved compare:[NSDate date]] == NSOrderedAscending)
    {
        lastTouchMoved = [NSDate dateWithTimeIntervalSinceNow: 0.05];
        [self touchProcessing:YES];
    }
    else
    {
        [self touchProcessing:NO];
    }
    
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        if([sortedTouches containsObject:touch])
        {
            [sortedTouches removeObject:touch];
        }
    }
    
    [self touchProcessing:YES];
	[self setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{    
    [sortedTouches removeAllObjects];
    
    [self touchProcessing:NO];
    [self setNeedsDisplay];
}

- (void)removeTouchesActiveTouches:(NSArray *)activeTouches
{ 
    NSArray *storedTouches = [NSArray arrayWithArray: [_touchDictionary keys]];
    
    for(UITouch *touch in storedTouches)
    {
        if (activeTouches == nil || ![activeTouches containsObject:touch])
        {
            UIView *fingerView = [_touchDictionary objectForKey: touch];
            [_touchDictionary removeObjectForKey: touch];
            [UIView animateWithDuration:0.4f animations:^{ fingerView.alpha = 0.0f; } completion:^(BOOL completed){ [fingerView removeFromSuperview]; }];
        }
    }
}

- (void)touchProcessing:(BOOL)shouldTransmitData
{
    NSArray* activeTouches = [sortedTouches copy];
    NSInteger touchCount = [sortedTouches count];
    NSString *colorString;
    
    if(touchCount >= 1)
    {
        colorString = [NSString stringWithFormat:@"Touch_%ld",(long)touchCount];
        
        for(UITouch *touch in activeTouches)
        { 
            UIView *fingerView = [_touchDictionary objectForKey: touch];
            
            if (touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded)
            {
                if (fingerView != NULL)
                {
                    [_touchDictionary removeObjectForKey: touch];
                    
                    [UIView animateWithDuration:0.3f animations:^{ fingerView.alpha = 0.0f; } completion:^(BOOL completed){ [fingerView removeFromSuperview]; }];
                }
            }
            else
            {
                CGPoint location = [touch locationInView:touch.view];
                
                UIColor *currentColor;
                if((location.y >= 0) && (location.y<height))
                {                    
                    currentColor = [self colorAtX:location.x y:location.y];
                }
                else
                {
                    currentColor = [self colorAtX:location.x y:0];
                }                
                    
                if (currentColor)
                {
                    const CGFloat *components = CGColorGetComponents(currentColor.CGColor);                     
                    UInt32 color = components[2]*255*256*256+components[1]*255*256+components[0]*255;                    
                    colorString = [NSString stringWithFormat:@"%@_%u",colorString,(unsigned int)color];
                }
                
                if (fingerView == NULL)
                {
                    fingerView = [self fingerViewAtPoint:location withColor:currentColor];
                  
                    [self insertSubview:fingerView atIndex:2];
                    [_touchDictionary setObject:fingerView forKey:touch];
                }
                else
                {
                    fingerView.center = location;
                    fingerView.layer.backgroundColor = currentColor.CGColor;
                }                    
            }
        }
        
        touch_type touchType = touchUp;
        /*
        if (touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded) touchType = touchUp;
        if (touch.phase == UITouchPhaseBegan) touchType = touchDown;
        if (touch.phase == UITouchPhaseMoved) touchType = touchMove;
        */
        colorString = [NSString stringWithFormat:@"%@_%u",colorString,(unsigned int)touchType];
        
        if (shouldTransmitData)
            [self spectrumViewGotColorStringReady: colorString];
    }
    [self removeTouchesActiveTouches:activeTouches];
}

- (void)setDelegate:(id)aDelegate
{
    delegate = aDelegate;
}

@end

#pragma mark -
#pragma mark SpectrumView Delegate

@implementation SpectrumView (SpectrumViewDelegate)

- (void)spectrumViewGotColorStringReady:(NSString*)colorString
{
    if ([delegate respondsToSelector: _cmd])
        [delegate spectrumViewGotColorStringReady: colorString];
}

@end
