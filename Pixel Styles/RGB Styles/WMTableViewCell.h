//
//  WMTableViewCell.h
//  iBeLight 2.0
//
//  Created by William Markezana on 15/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMBonjourController.h"

@interface WMTableViewCell : UITableViewCell

@property (nonatomic , weak) WMService *service;
@property (nonatomic) WMConnectionState state;

@end
