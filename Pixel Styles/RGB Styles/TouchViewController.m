//
//  TouchViewController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 15/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "TouchViewController.h"

@interface TouchViewController ()

@end

@implementation TouchViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.livePreviewAlpha = 0.0;
}

- (void)setMode:(WMServiceMode *)mode
{
    _mode = mode;
    [self.tableView reloadData];
}

- (void)didUpdateLivePreview:(NSNotification *)notification
{
    [super didUpdateLivePreview:notification];

    _livePreview.image = self.livePreviewImage;
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
    
    return cell;
}

- (void)spectrumViewGotColorStringReady:(NSString*)colorString
{
    [_mode sendTouchEvent:colorString];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
