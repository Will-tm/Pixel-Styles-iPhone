//
//  WMLiveTableViewController.m
//  Pixel Styles
//
//  Created by William Markezana on 01/03/14.
//  Copyright (c) 2014 RGB Styles. All rights reserved.
//

#import "WMLiveTableViewController.h"

#import "UIImage+BoxBlur.h"
#import "UIImage+Additions.h"

@interface WMLiveTableViewController ()
{
    UIImageView *liveBackground;
}

@end

@implementation WMLiveTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    _livePreviewAlpha = 0.6;
    _livePreviewBlurRadius = 0.1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLivePreview:) name:@"didUpdateLivePreview" object:nil];
    
    liveBackground = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView = liveBackground;
}

- (void)didUpdateLivePreview:(NSNotification *)notification
{
    _livePreviewImage = [notification.userInfo objectForKey:@"image"];
    liveBackground.image = [[_livePreviewImage imageByReplacingColor:0 withColor:0xFFFFFF] drn_boxblurImageWithBlur:_livePreviewBlurRadius withTintColor:[UIColor colorWithWhite:1.0 alpha:_livePreviewAlpha]];
}

@end
