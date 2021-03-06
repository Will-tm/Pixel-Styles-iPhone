//
//  MasterViewController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 14/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import "HostsViewController.h"
#import "ModesViewController.h"
#import "AboutViewController.h"

#import "WMServicesController.h"
#import "WMTableViewCell.h"
#import "URBMediaFocusViewController.h"

#define __DEBUG__
#ifdef __DEBUG__
#   define LOG(fmt, ...)   NSLog(@"%d (%s): " fmt, __LINE__, __func__, ## __VA_ARGS__)
#else
#   define LOG(fmt, ...)
#endif

@interface HostsViewController ()
{
    WMServicesController *mServicesController;
    AboutViewController *aboutViewController;
}

@end

@implementation HostsViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutViewController"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mServicesController = [WMServicesController sharedInstance];
    mServicesController.hostsViewControllerDelegate = self;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchForServices)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self searchForServices];
}

- (IBAction)showAbout:(id)sender
{
    UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
    [self.navigationController presentViewController:ctrl animated:YES completion:nil];
}

- (void)searchForServices
{
    [mServicesController searchForServicesWithCompletion:^(NSArray *services) {
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchForServices)];
        self.navigationItem.rightBarButtonItem = buttonItem;
        [self.tableView reloadData];
        
    } arrival:^(WMService *service) {
        [self.tableView reloadData];
        
    } connection:^(WMService *service) {
        [self.tableView reloadData];
        
    } disconnection:^(WMService *service) {
        [self.tableView reloadData];
        
    } error:^(NSString *service) {
        [self.tableView reloadData];
        
    }];
    
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = loadingView;
    [self.tableView reloadData];
}

- (void)didLostConnectionToService:(WMService *)service
{
    service.active = NO;
    [[URBMediaFocusViewController sharedInstance] dismiss:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tableView reloadData];
    
    [mServicesController activateFistConnectedService];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mServicesController.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HostCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WMService *service = [mServicesController.services objectAtIndex:indexPath.row];
    if (service != nil) {
        if (service.connected)
        {
            [mServicesController activateService:service];
            ModesViewController *modesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"modesViewController"];
            modesViewController.service = service;
            [self.navigationController pushViewController:modesViewController animated:YES];
        } else {
            if (!service.resolved && !service.resolving) {
                [service tryResolveWithCompletionBlock:^(BOOL resolved) {
                    [self.tableView reloadData];
                    
                    if (resolved) {
                        [service tryConnectWithCompletionBlock:^(BOOL connected) {
                            [self.tableView reloadData];
                        }];
                    }
                }];
            }
            else if (!service.connected && !service.connecting) {
                [service tryResolveWithCompletionBlock:^(BOOL resolved) {
                    [self.tableView reloadData];
                    
                    if (resolved) {
                        [service tryConnectWithCompletionBlock:^(BOOL connected) {
                            [self.tableView reloadData];
                        }];
                    }
                }];
            }
        }
    }

    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
        tableViewHeaderFooterView.backgroundView = [[UIView alloc] initWithFrame:view.frame];
        tableViewHeaderFooterView.backgroundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return mServicesController.services.count > 0 ? @"Discovered devices" : nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMService *service = [mServicesController.services objectAtIndex:indexPath.row];
    cell.textLabel.text = service.name;
    
    [cell.imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Connected
    if (service.connected) {
        cell.imageView.image = [UIImage imageNamed:@"TcpOk"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - version %@",service.ip, service.version];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    // Connecting
    else if (service.connecting) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIImage *whiteback = [UIImage imageNamed:@"Blank"];
        cell.imageView.image = whiteback;
        [cell.imageView addSubview:spinner];
        [spinner startAnimating];
        cell.detailTextLabel.text = @"Connecting...";
        
    }
    // Connecting
    else if (service.resolving) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIImage *whiteback = [UIImage imageNamed:@"Blank"];
        cell.imageView.image = whiteback;
        [cell.imageView addSubview:spinner];
        [spinner startAnimating];
        cell.detailTextLabel.text = @"Resolving...";
        
    }
    // Disconnected
    else {
        cell.imageView.image = [UIImage imageNamed:@"TcpNok"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (service.resolved) {
            cell.detailTextLabel.text = @"Unable to connect";
        } else {
            cell.detailTextLabel.text = @"Unable to resolve";
        }
    }
}

@end
