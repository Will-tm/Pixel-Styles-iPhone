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
#import "UIViewController+CWPopup.h"
#import "UIImage+BoxBlur.h"
#import "UIImage+Additions.h"

@interface ModesViewController ()
{
    LiveViewController *liveViewController;
    UIImageView *liveBackground;
}

@end

@implementation ModesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLivePreview:) name:@"didUpdateLivePreview" object:nil];
    
    liveViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"liveView"];
    
    liveBackground = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView = liveBackground;
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
    
    [self.navigationController dismissPopupViewControllerAnimated:NO completion:nil];
}

- (void)setService:(WMService *)service
{
    _service = service;
    [self.tableView reloadData];
}

- (void)didUpdateLivePreview:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
  
    WMServiceMode *mode = [_service.modes objectAtIndex:_service.activeModeIndex];
    mode.image = [userInfo objectForKey:@"image"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: _service.activeModeIndex inSection: 0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.imageView.image = [UIImage getIconOfSize:CGSizeMake(32, 32) icon:[[[UIImage alloc] init] imageScaledToSize:CGSizeMake(32, 32)] withOverlay:mode.image];
    
    [liveViewController updateWithImage:mode.image];
    liveBackground.image = [[mode.image imageByReplacingColor:0 withColor:0xFFFFFF] drn_boxblurImageWithBlur:0.1 withTintColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierSettings = @"ModeCellSettings";
    static NSString *CellIdentifierSpectrum = @"ModeCellSpectrum";
    UITableViewCell *cell;
    
    WMServiceMode *mode = [_service.modes objectAtIndex:indexPath.row];
    
    if (mode.ui == uiSpectrum)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSpectrum forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSettings forIndexPath:indexPath];
    }
    
    if ([cell viewWithTag:CELL_IMAGE_VIEW_TAG] == nil)
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
        
        [self.navigationController presentPopupViewController:liveViewController animated:YES completion:nil];
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
}

@end
