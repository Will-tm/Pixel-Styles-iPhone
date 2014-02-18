//
//  WMServiceModeSetting.h
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	ihmSpinEdit, ihmSpinEditFloat, ihmCheckbox, ihmSegmentedControl, ihmTrackbar, ihmLogTrackbar, ihmButton, ihmColorSelector
} ihm_type;


@interface WMServiceModeSetting : NSObject

@property (nonatomic) id delegate;
@property (nonatomic, strong) NSString* caption;
@property (nonatomic, strong) NSString* section;
@property (nonatomic, strong) NSString* value;
@property (nonatomic) float minValue;
@property (nonatomic) float maxValue;
@property (nonatomic) ihm_type kind;

- (void)updateValue:(NSString*)value;

@end

@protocol WMServiceModeSettingDelegate
@optional
- (void)settingsValueDidUpdate:(WMServiceModeSetting*)setting;
@end
