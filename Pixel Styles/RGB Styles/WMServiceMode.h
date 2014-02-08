//
//  WMServiceMode.h
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMServiceModeSetting.h"

typedef enum
{
    uiSpectrum,
    uiSettings
}ui_type;

@interface WMServiceMode : NSObject

@property (nonatomic) id delegate;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSMutableArray* settings;
@property (nonatomic) ui_type ui;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;

- (void)sendTouchEvent:(NSString*)touchString;

@end

@protocol WMServiceModeDelegate
@optional
- (void)settingsValueDidUpdate:(WMServiceModeSetting*)setting forMode:(WMServiceMode*)mode;
- (void)modeDidReceiveTouchEvent:(NSString*)touchString;
@end
