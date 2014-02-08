//
//  MasterViewController.h
//  iBeLight 2.0
//
//  Created by William Markezana on 14/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(NSArray*);

@interface HostsViewController : UITableViewController

@property (nonatomic, copy) CompletionBlock completionBlock;

@end
