//
//  ModesViewController/h
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMBonjourController.h"

#define CELL_IMAGE_VIEW_TAG             (101)
#define CELL_IMAGE_VIEW_HEIGH           (5)
#define CELL_IMAGE_VIEW_INACTIVE_ALPHA  (0.3)

@interface ModesViewController : UITableViewController <UIGestureRecognizerDelegate>

@property (nonatomic) WMService *service;

@end
