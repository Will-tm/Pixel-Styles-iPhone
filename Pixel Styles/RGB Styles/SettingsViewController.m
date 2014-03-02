//
//  SettingsViewController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "SettingsViewController.h"
#import "ColorPickerViewController.h"

#import "WMDictionary.h"
#import "UIImage+BoxBlur.h"
#import "UIImage+Additions.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SettingsViewController ()
{
    WMDictionary *_sections;
}

@end

@implementation SettingsViewController

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
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self action:@selector(buttonColorSelectorPressed:) forControlEvents:UIControlEventTouchDown];
            button.frame = CGRectMake(253, 8, 51, 31);
            button.tag = index;
            button.backgroundColor = UIColorFromRGB((long)[setting.value integerValue]);
            button.layer.cornerRadius = button.bounds.size.height / 2.0;
            [cell addSubview:button];
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

- (void)buttonColorSelectorPressed:(UIButton *)sender
{
    ColorPickerViewController *colorPickerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"colorPickerViewController"];
    colorPickerViewController.delegate = self;
    colorPickerViewController.tag = sender.tag;
    colorPickerViewController.currentColor = sender.backgroundColor;
    colorPickerViewController.button = sender;
    [self.navigationController pushViewController:colorPickerViewController animated:YES];
}

- (void)colorPicker:(ColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color
{
    colorPicker.button.backgroundColor = color;
    WMServiceModeSetting *setting = [_mode.settings objectAtIndex:colorPicker.tag];
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    UInt32 colorInt = components[2]*255*256*256+components[1]*255*256+components[0]*255;
    [setting updateValue:[NSString stringWithFormat:@"%d", colorInt]];
}

@end
