//
//  WMService.h
//  iBeLight 2.0
//
//  Created by William Markezana on 12/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "SBJson.h"
#import "WMServiceMode.h"
#import <zlib.h>

#define MIN_PROTOCOL_VERSION    1.0

#define MAX_RETRY_COUNT         5

@interface WMService : NSObject

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) BOOL connecting;
@property (nonatomic) BOOL resolved;
@property (nonatomic) BOOL resolving;
@property (nonatomic) id delegate;
@property (nonatomic, strong, readonly) NSString *ip;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *version;
@property (nonatomic, strong, readonly) NSString *subtitle;
@property (nonatomic, strong, readonly) NSString *hostType;
@property (nonatomic, strong, readonly) NSString *hostVersion;
@property (nonatomic, strong, readonly) NSString *protocolVersion;
@property (nonatomic, strong, readonly) NSString *macAddress;
@property (nonatomic, strong) NSDictionary *txtRecords;
@property (nonatomic, strong) SBJsonParser *jsonParser;
@property (nonatomic, strong) NSArray *jsonItems;
@property (nonatomic, strong) NSDictionary *jsonImage;
@property (nonatomic, strong) NSString *activeModeName;
@property (nonatomic, strong) NSMutableArray *modes;
@property (nonatomic, readonly) NSInteger activeModeIndex;
@property (nonatomic, strong) NSTimer *keepAliveTimer;
@property (nonatomic) bool done;
@property (nonatomic) NSInteger retryCount;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) BOOL active;

- (id)initWithService:(NSNetService*)service delegate:(id)delegate;
- (void)tryConnect;
- (void)sendMessage:(NSString*)message;
- (void)sendMessage:(NSString*)message withTimeout:(NSTimeInterval)timeout;
- (void)parseJsonImage:(NSDictionary*)jsonImage;

@property (copy) void(^tryConnectWithCompletionBlock)(BOOL connected);
- (void)tryConnectWithCompletionBlock:(void(^)(BOOL connected))completion;

@property (copy) void(^tryResolveWithCompletionBlock)(BOOL resolved);
- (void)tryResolveWithCompletionBlock:(void(^)(BOOL resolved))completion;

@end

@protocol WMServiceDelegate
@optional
- (void)didConnectToService:(WMService*)service;
- (void)didNotConnectToService:(WMService*)service;
- (void)serviceProtocolVersionTooOld:(WMService*)service;
- (void)didDisconnectFromService:(WMService*)service;
- (void)didUpdateLivePreview:(UIImage*)image;
@end
