//
//  WMTableViewCell.m
//  iBeLight 2.0
//
//  Created by William Markezana on 15/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import "WMTableViewCell.h"

@implementation WMTableViewCell

- (void)awakeFromNib
{
    _service = nil;
    _state = WMConnectionStateConnecting;
}

@end
