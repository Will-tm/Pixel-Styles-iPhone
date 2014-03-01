//
//  ColorPickerViewController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 15/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "ColorPickerViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)(rgbValue & 0xFF))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue & 0xFF0000) >> 16))/255.0 alpha:1.0];

@interface ColorPickerViewController ()

@end

@implementation ColorPickerViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.livePreviewAlpha = 0.0;
    self.tag = 0;
}

- (void)setMode:(WMServiceMode *)mode
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _livePreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10.0)];
    [_livePreview setOpaque:YES];
    _livePreview.backgroundColor = _currentColor;
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TouchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
    UIView *contentView = [cell viewWithTag:40];
    SpectrumView *view = (SpectrumView*)[contentView viewWithTag:50];
    [view becomeFirstResponder];
    [view setDelegate:self];
    view.maxTouchCount = 1;
    
    return cell;
}

- (void)spectrumViewGotColorStringReady:(NSString*)colorString
{
    NSArray *items = [colorString componentsSeparatedByString:@"_"];
    self.currentColor = UIColorFromRGB([items[2] intValue]);
    
    if ([_delegate respondsToSelector:@selector(colorPicker:didSelectColor:)]) {
        [_delegate colorPicker:self didSelectColor:_currentColor];
    }
}

- (void)setCurrentColor:(UIColor *)currentColor
{
    _currentColor = currentColor;
    _livePreview.backgroundColor = _currentColor;
}

@end
