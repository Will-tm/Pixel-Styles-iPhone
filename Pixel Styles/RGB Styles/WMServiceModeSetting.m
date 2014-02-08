//
//  WMServiceModeSetting.m
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "WMServiceModeSetting.h"

@implementation WMServiceModeSetting

- (void)setValue:(NSString *)value
{
    _value = value;
    if ([value isEqualToString:@"True"]) _value = @"1";
    if ([value isEqualToString:@"true"]) _value = @"1";
    if ([value isEqualToString:@"False"]) _value = @"0";
    if ([value isEqualToString:@"false"]) _value = @"0";
}

- (void)updateValue:(NSString*)value
{
    self.value = value;
    
    if ([_delegate respondsToSelector:@selector(settingsValueDidUpdate:)])
    {
        [_delegate settingsValueDidUpdate:self];
    }
}

@end
