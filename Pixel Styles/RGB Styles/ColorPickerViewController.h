//
//  ColorPickerViewController.h
//  iBeLight 2.0
//
//  Created by William Markezana on 15/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMBonjourController.h"
#import "SpectrumView.h"
#import "WMLiveTableViewController.h"

@interface ColorPickerViewController : WMLiveTableViewController

@property (nonatomic) id delegate;
@property (nonatomic, strong) UIImageView *livePreview;
@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, weak) UIButton *button;

@end

@interface NSObject (ColorPickerViewControllerDelegate)

- (void)colorPicker:(ColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color;

@end