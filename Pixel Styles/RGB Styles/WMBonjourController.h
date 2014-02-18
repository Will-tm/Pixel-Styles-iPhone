//
//  WMBonjourController
//  iBeLight 2.0
//
//  Created by William Markezana on 12/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMService.h"

typedef enum
{
    WMConnectionStateConnecting,
    WMConnectionStateConnected,
    WMConnectionStateDisconnected
}WMConnectionState;

@interface WMBonjourController : NSObject

@property (nonatomic, strong) GCDAsyncUdpSocket *asyncUdpSocket;
@property (nonatomic, strong) SBJsonParser *jsonParser;
@property (nonatomic) id delegate;
@property (nonatomic, weak, readonly) NSArray* services;

- (void)searchForServices;
- (BOOL)addServiceWithName:(NSString *)name domain:(NSString *)domain type:(NSString *)type;
- (void)removeService:(WMService*)service;
+ (WMBonjourController*)sharedInstance;

@end

@protocol WMBonjourControllerDelegate
@optional
- (void)didStartSearchingForServices;
- (void)didEndSearchingForServices;
- (void)didNotFindAnyServices;
- (void)serviceDidNotResolveWithName:(NSString *)name;
- (void)serviceDidNotResolve:(WMService *)service;
- (void)serviceDidAppear:(WMService*)service;
- (void)serviceDidDisappear:(WMService*)service;
- (void)serviceDidConnect:(WMService*)service;
- (void)serviceDidNotConnect:(WMService*)service;
- (void)serviceDidDisconnect:(WMService*)service;

@end