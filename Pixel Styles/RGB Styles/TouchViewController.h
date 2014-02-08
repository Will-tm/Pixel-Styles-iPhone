//
//  TouchViewController.h
//  iBeLight 2.0
//
//  Created by William Markezana on 15/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMBonjourController.h"
#import "SpectrumView.h"

@interface TouchViewController : UITableViewController

@property (nonatomic) WMService *service;
@property (nonatomic) NSArray *services;
@property (nonatomic) WMServiceMode *mode;
@property (nonatomic, strong) UIImageView *livePreview;

@end
