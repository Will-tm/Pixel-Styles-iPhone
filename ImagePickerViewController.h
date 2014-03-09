//
//  ImagePickerViewController.h
//  Pixel Styles
//
//  Created by William Markezana on 09/03/14.
//  Copyright (c) 2014 RGB Styles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WMBonjourController.h"
#import "WMLiveTableViewController.h"

@interface ImagePickerViewController : WMLiveTableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) WMService *service;
@property (nonatomic) WMServiceMode *mode;

@end
