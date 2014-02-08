//
//  WMServicesController.h
//  iBeLight 2.0
//
//  Created by William Markezana on 15/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMBonjourController.h"

@interface WMServicesController : NSObject

@property (nonatomic) id hostsViewControllerDelegate;
@property (nonatomic, strong, readonly) NSArray *groupsName;
@property (nonatomic, strong, readonly) NSArray *services;
@property (nonatomic, strong, readonly) NSArray *selectedServices;

+ (WMServicesController*)sharedInstance;

@property (copy) void(^searchForServicesWithCompletionBlock)(NSArray *services);
@property (copy) void(^searchForServicesWithArrivalBlock)(WMService *service);
@property (copy) void(^searchForServicesWithConnectionBlock)(WMService *service);
@property (copy) void(^searchForServicesWithDisconnectionSBlock)(WMService *service);
@property (copy) void(^searchForServicesWithErrorBlock)(NSString *service);
- (void)searchForServicesWithCompletion:(void(^)(NSArray *services))completion
                                arrival:(void(^)(WMService *service))arrival
                             connection:(void(^)(WMService *service))connection
                          disconnection:(void(^)(WMService *service))disconnection
                                  error:(void(^)(NSString *service))error;

@end

@protocol WMServicesControllerDelegate
@optional
- (void)didLostConnectionToService:(WMService *)service;
@end