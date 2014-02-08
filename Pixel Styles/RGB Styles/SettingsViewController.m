//
//  SettingsViewController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)setServices:(NSArray *)services
{
    _services = services;
    if (services != nil && services.count) {
        _service = services[0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLivePreview:) name:@"didUpdateLivePreview" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = _mode.name;

    [_service beginLivePreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_service endLivePreview];
}

- (void)setMode:(WMServiceMode *)mode
{
    _mode = mode;
    [self.tableView reloadData];
}

- (void)didUpdateLivePreview:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    _livePreview.image = [userInfo objectForKey:@"image"];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _livePreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10.0)];
    return _livePreview;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mode.settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    WMServiceModeSetting *setting = [_mode.settings objectAtIndex:indexPath.row];
    
    cell.textLabel.text = setting.caption;
    
    switch (setting.kind)
    {
        case ihmCheckbox:
        {
            UISwitch *checkbox         = [[UISwitch         alloc] initWithFrame:CGRectMake(253, 8,   0,  0)];
            [checkbox addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventValueChanged];
            checkbox.on = [setting.value boolValue];
            checkbox.tag = indexPath.row;
            [cell addSubview:checkbox];
        }
            break;
            
        case ihmSegmentedControl:
        {
            /*
            NSArray * segmentItems;
            UISegmentedControl *segmentedControl;
            segmentedControl.tag = indexPath.row;
            [cell addSubview:segmentedControl];
             */
        }
            break;
            
        case ihmSpinEdit:
        {
            TextStepperField *spinEdit = [[TextStepperField alloc] initWithFrame:CGRectMake(180, 8, 120, 27)];
            spinEdit.tag = indexPath.row;
            [cell addSubview:spinEdit];
        }
            break;
            
        case ihmSpinEditFloat:
        {
            TextStepperField *spinEdit = [[TextStepperField alloc] initWithFrame:CGRectMake(180, 8, 120, 27)];
            spinEdit.tag = indexPath.row;
            [cell addSubview:spinEdit];
        }
            break;
            
        case ihmTrackbar:
        {
            UISlider *trackbar         = [[UISlider         alloc] initWithFrame:CGRectMake(180, 8, 120, 30)];
            trackbar.tag = indexPath.row;
            
            [trackbar addTarget:self action:@selector(trackbarChanged:) forControlEvents:UIControlEventValueChanged];
            trackbar.maximumValue = setting.maxValue;
            trackbar.minimumValue = setting.minValue;
             [trackbar setValue:[setting.value floatValue]];
            
            [cell addSubview:trackbar];
        }
            break;
    }
    
    return cell;
}

#pragma mark - Controls Events

- (void)checkboxAction:(UISwitch*)sender
{
    //WMServiceModeSetting *setting = [_mode.settings objectAtIndex:sender.tag];
    //[setting updateValue:[NSString stringWithFormat:@"%i", sender.on]];
    [self updateSettingsAtIndex:sender.tag withValue:[NSString stringWithFormat:@"%i", sender.on]];
}

- (void)trackbarChanged:(UISlider*)sender
{
    //WMServiceModeSetting *setting = [_mode.settings objectAtIndex:sender.tag];
    //[setting updateValue:[NSString stringWithFormat:@"%f", sender.value]];
    [self updateSettingsAtIndex:sender.tag withValue:[NSString stringWithFormat:@"%f", sender.value]];
}

- (void)updateSettingsAtIndex:(NSInteger)index withValue:(NSString *)value
{
    for (WMService *service in _services) {
        for (WMServiceMode *mode in service.modes) {
            if ([mode.name isEqualToString: _mode.name]) {
                WMServiceModeSetting *setting = [mode.settings objectAtIndex:index];
                [setting updateValue:value];
            }
        }
    }
}

@end
