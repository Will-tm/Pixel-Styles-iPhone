//
//  WMServiceMode.m
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "WMServiceMode.h"

@implementation WMServiceMode

- (id)init
{
    self = [super init];
    if (self)
    {
        _settings = [NSMutableArray new];
    }
    return self;
}

- (void)settingsValueDidUpdate:(WMServiceModeSetting*)setting
{
    if ([_delegate respondsToSelector:@selector(settingsValueDidUpdate:forMode:)])
    {
        [_delegate settingsValueDidUpdate:setting forMode:self];
    }
}

- (void)sendTouchEvent:(NSString*)touchString
{
    if ([_delegate respondsToSelector:@selector(modeDidReceiveTouchEvent:)])
    {
        [_delegate modeDidReceiveTouchEvent:touchString];
    }
}

@end
