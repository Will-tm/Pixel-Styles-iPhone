//
//  WMServicesController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 15/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import "WMServicesController.h"

#define __DEBUG__
#ifdef __DEBUG__
#   define LOG(fmt, ...)   NSLog(@"%d (%s): " fmt, __LINE__, __func__, ## __VA_ARGS__)
#else
#   define LOG(fmt, ...)
#endif

@interface WMServicesController ()
{
    WMBonjourController *mBonjourController;
    NSManagedObjectContext *mManagedObjectContext;
}

@end

@implementation WMServicesController

WMServicesController *sharedInstance = nil;

+ (WMServicesController*)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [WMServicesController new];
    }
    return sharedInstance;
}

- (id)init
{
    if (sharedInstance != nil) {
        return sharedInstance;
    }
    self = [super init];
    if (self)
    {
        mBonjourController = [WMBonjourController new];
        mBonjourController.delegate = self;
        
        [mBonjourController searchForServices];
    }
    sharedInstance = self;
    return self;
}

#pragma mark - Public Tools

- (NSArray *)services
{
    return mBonjourController.services;
}

- (void)searchForServicesWithCompletion:(void(^)(NSArray *services))completion
                                arrival:(void(^)(WMService *service))arrival
                             connection:(void(^)(WMService *service))connection
                          disconnection:(void(^)(WMService *service))disconnection
                                  error:(void(^)(NSString *service))error;
{
    _searchForServicesWithCompletionBlock = completion;
    _searchForServicesWithArrivalBlock = arrival;
    _searchForServicesWithConnectionBlock = connection;
    _searchForServicesWithDisconnectionSBlock = disconnection;
    _searchForServicesWithErrorBlock = error;
    
    [mBonjourController searchForServices];
}

- (void)deleteService:(WMService *)service
{
    LOG(@"%@",service.name);

    [mBonjourController removeService:service];
}

#pragma mark - Tiny Tools

- (void)removeWMService:(WMService*)service;
{
    [mBonjourController removeService:service];
}

#pragma mark - Bonjour Controller

- (void)didStartSearchingForServices
{
    LOG();
}

- (void)didEndSearchingForServices
{
    LOG();
    
    if (_searchForServicesWithCompletionBlock) {
        _searchForServicesWithCompletionBlock(mBonjourController.services);
        
        _searchForServicesWithCompletionBlock = nil;
        _searchForServicesWithArrivalBlock = nil;
        _searchForServicesWithConnectionBlock = nil;
        _searchForServicesWithDisconnectionSBlock = nil;
        _searchForServicesWithErrorBlock = nil;
    }
}

- (void)didNotFindAnyServices
{
    LOG();
    
    if (_searchForServicesWithCompletionBlock) {
        _searchForServicesWithCompletionBlock(nil);
        
        _searchForServicesWithCompletionBlock = nil;
        _searchForServicesWithArrivalBlock = nil;
        _searchForServicesWithConnectionBlock = nil;
        _searchForServicesWithDisconnectionSBlock = nil;
        _searchForServicesWithErrorBlock = nil;
    }
}

- (void)serviceDidAppear:(WMService*)service
{
    LOG(@"%@", service.name);
    
    if (_searchForServicesWithArrivalBlock) {
        _searchForServicesWithArrivalBlock(service);
    }
}

- (void)serviceDidConnect:(WMService*)service
{
    LOG(@"%@", service.name);
    
    if (_searchForServicesWithConnectionBlock) {
        _searchForServicesWithConnectionBlock(service);
    }
}

- (void)serviceDidNotResolve:(WMService*)service
{
    LOG(@"%@", service.name);

    if (++service.retryCount > 3) {
        service.retryCount = 0;
        if (_searchForServicesWithDisconnectionSBlock) {
            _searchForServicesWithDisconnectionSBlock(service);
        }
    } else {
        [service tryResolveWithCompletionBlock:nil];
    }
}

- (void)serviceDidNotConnect:(WMService*)service
{
    LOG(@"%@", service.name);
    
    if (++service.retryCount > 3) {
        service.retryCount = 0;

        if (_searchForServicesWithDisconnectionSBlock) {
            _searchForServicesWithDisconnectionSBlock(service);
        }
    } else {
        [service tryConnect];
    }
}

- (void)serviceDidDisconnect:(WMService*)service
{
    LOG(@"%@", service.name);
    
    if (++service.retryCount > 3) {
        service.retryCount = 0;
        
        if (_searchForServicesWithDisconnectionSBlock) {
            _searchForServicesWithDisconnectionSBlock(service);
        }
        
        if([_hostsViewControllerDelegate respondsToSelector:@selector(didLostConnectionToService:)]) {
            [_hostsViewControllerDelegate didLostConnectionToService:service];
        }
    } else {
        [service tryConnect];
    }
}

#pragma mark - Getters



@end
