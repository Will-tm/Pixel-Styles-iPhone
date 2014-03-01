//
//  WMLiveTableViewController.h
//  Pixel Styles
//
//  Created by William Markezana on 01/03/14.
//  Copyright (c) 2014 RGB Styles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMLiveTableViewController : UITableViewController

@property (nonatomic, readonly, weak)  UIImage *livePreviewImage;
@property (nonatomic, readwrite, assign) CGFloat livePreviewAlpha;
@property (nonatomic, readwrite, assign) CGFloat livePreviewBlurRadius;

- (void)didUpdateLivePreview:(NSNotification *)notification;

@end
