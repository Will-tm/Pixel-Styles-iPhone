//
//  LiveViewController.h
//  Pixel Styles
//
//  Created by William Markezana on 08/02/14.
//  Copyright (c) 2014 RGB Styles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveViewController : UIViewController

@property (nonatomic, readonly, weak) UIImage *image;

- (void)updateWithImage:(UIImage*)image;

@end
