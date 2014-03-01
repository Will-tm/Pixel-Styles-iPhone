//
//  AboutViewController.m
//  Pick Me Up I'm Drunk 2.0
//
//  Created by William Markezana on 03/11/2013.
//  Copyright (c) 2013 Will™. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
{
    UIButton *contactButton;
    UILabel *contactLabel;
}

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"About";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        
        contactButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, 120, 120)];
        contactButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [contactButton setImage:[UIImage imageNamed:@"icon"] forState:UIControlStateNormal];
        contactButton.layer.masksToBounds = NO;
        contactButton.layer.cornerRadius = 60.0;
        contactButton.imageView.layer.cornerRadius = 60.0;
        contactButton.layer.borderColor = [UIColor whiteColor].CGColor;
        contactButton.layer.borderWidth = 3.0f;
        contactButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        contactButton.layer.shouldRasterize = YES;
        contactButton.clipsToBounds = YES;

        contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 154, 320, 26)];
        contactLabel.text = @"Pixel Styles";
        contactLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        contactLabel.backgroundColor = [UIColor clearColor];
        contactLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        contactLabel.textAlignment = NSTextAlignmentCenter;
        
        [view addSubview:contactButton];
        [view addSubview:contactLabel];
        view;
    });
    
    self.livePreviewAlpha = 0.8;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"AboutCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSArray *titles = @[@"Version"];
        NSArray *details = @[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        cell.textLabel.text = titles[0];
        cell.detailTextLabel.text = details[0];
    }
    
    return cell;
}

@end
