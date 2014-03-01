//
//  SettingsViewController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "SettingsViewController.h"

#import "WMDictionary.h"
#import "UIImage+BoxBlur.h"
#import "UIImage+Additions.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SettingsViewController ()
{
    WMDictionary *_sections;
    UIImageView *liveBackground;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLivePreview:) name:@"didUpdateLivePreview" object:nil];

    liveBackground = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView = liveBackground;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = _mode.name;
}

- (void)setMode:(WMServiceMode *)mode
{
    _mode = mode;
    
    _sections = [WMDictionary new];
    for (WMServiceModeSetting *setting in _mode.settings) {
        if (![_sections valueForKey:setting.section]) {
            [_sections setValue:@(1) forKey:setting.section];
        } else {
            [_sections setValue:@(((NSNumber*)[_sections objectForKey:setting.section]).intValue + 1) forKey:setting.section];
        }
    }
    [self.tableView reloadData];
}

- (void)didUpdateLivePreview:(NSNotification *)notification
{
    liveBackground.image = [[[notification.userInfo objectForKey:@"image"] imageByReplacingColor:0 withColor:0xFFFFFF] drn_boxblurImageWithBlur:0.1 withTintColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[_sections allKeys] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSNumber*)[_sections objectForKey:[[_sections allKeys] objectAtIndex:section]]).intValue;
}

- (NSInteger)settingIndexForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = 0;
    for (NSInteger i = 0; i < indexPath.section; i++) {
        index += ((NSNumber*)[_sections objectForKey:[[_sections allKeys] objectAtIndex:i]]).integerValue;
    }
    return indexPath.row+index;
}

- (WMServiceModeSetting *)settingForIndexPath:(NSIndexPath *)indexPath
{
    return [_mode.settings objectAtIndex:[self settingIndexForIndexPath:indexPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    WMServiceModeSetting *setting = [self settingForIndexPath:indexPath];
    cell.textLabel.text = setting.caption;
    NSInteger index = [self settingIndexForIndexPath:indexPath];
    
    switch (setting.kind)
    {
        case ihmCheckbox:
        {
            UISwitch *checkbox = [[UISwitch alloc] initWithFrame:CGRectMake(253, 8,   0,  0)];
            [checkbox addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventValueChanged];
            checkbox.on = [setting.value boolValue];
            checkbox.tag = index;
            [cell addSubview:checkbox];
        }
        break;
            
        case ihmSegmentedControl:
        {
            //NSArray *segmentItems;
            UISegmentedControl *segmentedControl;
            segmentedControl.tag = index;
            [cell addSubview:segmentedControl];
        }
        break;
            
        case ihmSpinEdit:
        case ihmSpinEditFloat:
        {
            TextStepperField *spinEdit = [[TextStepperField alloc] initWithFrame:CGRectMake(180, 8, 120, 27)];
            [spinEdit addTarget:self action:@selector(spinEditDidStep:) forControlEvents:UIControlEventValueChanged];
            spinEdit.NumDecimals = 0;
            spinEdit.IsEditableTextField = NO;
            spinEdit.Minimum = setting.minValue;
            spinEdit.Maximum = setting.maxValue;
            spinEdit.Step = 1.0f;
            spinEdit.Current = [setting.value floatValue];
            spinEdit.tag = index;
            [cell addSubview:spinEdit];
        }
        break;
            
        case ihmLogTrackbar:
        case ihmTrackbar:
        {
            UISlider *trackbar = [[UISlider alloc] initWithFrame:CGRectMake(180, 8, 120, 30)];
            trackbar.tag = index;
            
            [trackbar addTarget:self action:@selector(trackbarChanged:) forControlEvents:UIControlEventValueChanged];
            trackbar.maximumValue = setting.maxValue;
            trackbar.minimumValue = setting.minValue;
             [trackbar setValue:[setting.value floatValue]];
            
            [cell addSubview:trackbar];
        }
        break;
            
        case ihmButton:
        {
            
        }
        break;
            
        case ihmColorSelector:
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(275, 8, 30, 30)];
            
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, [UIScreen mainScreen].scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextAddEllipseInRect(context, imageView.bounds);
            CGContextSetFillColorWithColor(context, UIColorFromRGB((long)[setting.value integerValue]).CGColor);
            CGContextFillPath(context);
            imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
    
            [cell addSubview:imageView];
        }
        break;
            
    }
    
    return cell;
}

#pragma mark - Controls Events

- (void)checkboxAction:(UISwitch*)sender
{
    WMServiceModeSetting *setting = [_mode.settings objectAtIndex:sender.tag];
    [setting updateValue:[NSString stringWithFormat:@"%i", sender.on]];
}

- (void)trackbarChanged:(UISlider*)sender
{
    WMServiceModeSetting *setting = [_mode.settings objectAtIndex:sender.tag];
    [setting updateValue:[NSString stringWithFormat:@"%f", sender.value]];
}

- (void)spinEditDidStep:(TextStepperField *)sender
{
    WMServiceModeSetting *setting = [_mode.settings objectAtIndex:sender.tag];
    [setting updateValue:[NSString stringWithFormat:@"%f", sender.Current]];
}

@end
