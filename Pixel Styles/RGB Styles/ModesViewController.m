//
//  ModesViewController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 13/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "ModesViewController.h"

#import "SettingsViewController.h"
#import "LiveViewController.h"

#import "UIImage+ScaledToSize.h"
#import "URBMediaFocusViewController.h"

@interface ModesViewController ()
{
    LiveViewController *liveViewController;
}

@end

@implementation ModesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    liveViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"liveView"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (_service != nil) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_service.activeModeIndex inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
        self.navigationItem.title = _service.name;
    }
}

- (void)setService:(WMService *)service
{
    _service = service;
    [self.tableView reloadData];
}

- (void)didUpdateLivePreview:(NSNotification *)notification
{
    [super didUpdateLivePreview:notification];

    WMServiceMode *mode = [_service.modes objectAtIndex:_service.activeModeIndex];
    mode.image = self.livePreviewImage;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: _service.activeModeIndex inSection: 0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (_service.height > 1) {
        cell.imageView.image = [UIImage getIconOfSize:CGSizeMake(32, 32) icon:[[[UIImage alloc] init] imageScaledToSize:CGSizeMake(32, 32)] withOverlay:mode.image];
        
        if ([URBMediaFocusViewController sharedInstance].isShowing) {
            [liveViewController updateWithImage:self.livePreviewImage];
            [[URBMediaFocusViewController sharedInstance] updateCurrentImage:liveViewController.image];
        }
    }
    else {
        mode.imageView.image = mode.image;
        
        for (WMServiceMode *aMode in _service.modes) {
            if ([_service.activeModeName isEqualToString:aMode.name]) {
                aMode.imageView.alpha = 1.0;
            } else {
                aMode.imageView.alpha = CELL_IMAGE_VIEW_INACTIVE_ALPHA;
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _service.modes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Modes availables";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
        tableViewHeaderFooterView.backgroundView = [[UIView alloc] initWithFrame:view.frame];
        tableViewHeaderFooterView.backgroundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierSettings = @"ModeCellSettings";
    static NSString *CellIdentifierSpectrum = @"ModeCellSpectrum";
    static NSString *CellIdentifierImagePicker = @"ModeCellImagePicker";
    UITableViewCell *cell;
    
    WMServiceMode *mode = [_service.modes objectAtIndex:indexPath.row];
    
    if (mode.ui == uiSpectrum)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSpectrum forIndexPath:indexPath];
    }
    else if (mode.ui == uiImagePicker)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierImagePicker forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSettings forIndexPath:indexPath];
    }
    
    if ([cell viewWithTag:CELL_IMAGE_VIEW_TAG] == nil)
    {
        if (_service.height > 1)
        {
            cell.imageView.image = [UIImage getIconOfSize:CGSizeMake(32, 32) icon:[[[UIImage alloc] init] imageScaledToSize:CGSizeMake(32, 32)] withOverlay:mode.image];
            cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            cell.imageView.layer.borderWidth = 1.0;
            cell.imageView.tag = indexPath.row;
        
            [cell.imageView.layer setMagnificationFilter:kCAFilterNearest];
            cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
            cell.imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCellImageView:)];
            tapRecognizer.numberOfTouchesRequired = 1;
            [cell.imageView addGestureRecognizer:tapRecognizer];
        }
        else
        {
            mode.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-CELL_IMAGE_VIEW_HEIGH, cell.frame.size.width, CELL_IMAGE_VIEW_HEIGH)];
            mode.imageView.tag = CELL_IMAGE_VIEW_TAG;
            mode.imageView.image = mode.image;
            [cell addSubview:mode.imageView];
            
            if ([_service.activeModeName isEqualToString:mode.name]) {
                mode.imageView.alpha = 1.0;
            } else {
                mode.imageView.alpha = CELL_IMAGE_VIEW_INACTIVE_ALPHA;
            }
        }
    }
    
    cell.textLabel.text = mode.name;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (mode.ui == uiSettings && mode.settings.count == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if(indexPath.row == _service.activeModeIndex)
    {
        cell.selected = YES;
    }
    
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.3]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMServiceMode *mode = [_service.modes objectAtIndex:indexPath.row];
    _service.activeModeName = mode.name;
    [_service sendMessage:[NSString stringWithFormat:@"SetModeName_%@", mode.name]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    WMServiceMode *mode = [_service.modes objectAtIndex:indexPath.row];
    _service.activeModeName = mode.name;
    [_service sendMessage:[NSString stringWithFormat:@"SetModeName_%@", mode.name]];
}

- (void)didTapCellImageView:(UITapGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:recognizer.view.tag inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];

        WMServiceMode *mode = [_service.modes objectAtIndex:recognizer.view.tag];
        _service.activeModeName = mode.name;
        [_service sendMessage:[NSString stringWithFormat:@"SetModeName_%@", mode.name]];
        
        [[URBMediaFocusViewController sharedInstance] showImage:liveViewController.image fromRect:[recognizer.view convertRect:recognizer.view.frame toView:self.view]];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSettingsOfMode"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WMServiceMode *mode = [_service.modes objectAtIndex:indexPath.row];
 
        [[segue destinationViewController] setService:_service];
        [[segue destinationViewController] setMode:mode];
    }
    if ([[segue identifier] isEqualToString:@"showTouchOfMode"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WMServiceMode *mode = [_service.modes objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setService:_service];
        [[segue destinationViewController] setMode:mode];
    }
    if ([[segue identifier] isEqualToString:@"showImagePickerOfMode"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WMServiceMode *mode = [_service.modes objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setService:_service];
        [[segue destinationViewController] setMode:mode];
    }
}

@end
