//
//  LiveViewController.m
//  Pixel Styles
//
//  Created by William Markezana on 08/02/14.
//  Copyright (c) 2014 RGB Styles. All rights reserved.
//

#import "LiveViewController.h"

#import "UIViewController+CWPopup.h"
#import "WMGridView.h"

@interface LiveViewController ()
{
    WMGridView *localGridView;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *gridView;

@end

@implementation LiveViewController

- (void)awakeFromNib
{
    localGridView = nil;
}

- (void)updateWithImage:(UIImage*)image
{
    if (localGridView == nil)
    {
        CGFloat viewHeight = self.view.bounds.size.height / image.size.width * image.size.height;
        
        localGridView = [[WMGridView alloc] initWithFrame:CGRectMake(0.0, (_imageView.bounds.size.height - viewHeight) / 2.0, _imageView.bounds.size.width, viewHeight)gridSize:image.size];
        localGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        
        [_gridView addSubview: localGridView];
        [_gridView bringSubviewToFront: localGridView];
        
        [_imageView.layer setMagnificationFilter:kCAFilterNearest];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    }
    
    _imageView.image = image;
}

@end
