//
//  WMBonjourController.m
//  iBeLight 2.0
//
//  Created by William Markezana on 12/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "WMBonjourController.h"

//#define __DEBUG__
#ifdef __DEBUG__
#   define LOG(fmt, ...)   NSLog(@"%s:%d (%s): " fmt, __FILE__, __LINE__, __func__, ## __VA_ARGS__)
#else
#   define LOG(fmt, ...)
#endif

@interface WMBonjourController () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    NSNetServiceBrowser *domainBrowser;
    NSMutableArray *rawServices;
    NSMutableArray *wmServices;
    BOOL searching;
}

@end

@implementation WMBonjourController

WMBonjourController* sharedInstance;

- (id)init
{
    self = [super init];
    if (self)
    {
        rawServices = [NSMutableArray new];
        wmServices = [NSMutableArray new];
        _services = wmServices;
        searching = NO;
        
        domainBrowser = [[NSNetServiceBrowser alloc] init];
        [domainBrowser setDelegate:self];
        [domainBrowser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        _jsonParser = [SBJsonParser new];
        
        _asyncUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        
        [_asyncUdpSocket setIPv4Enabled:YES];
        [_asyncUdpSocket setIPv6Enabled:NO];
        [_asyncUdpSocket enableBroadcast:YES error:&error];
        
        if (![_asyncUdpSocket  bindToPort:56616 error:&error]) {
            NSLog(@"Error starting server (bind): %@", error);
        }
        else if (![_asyncUdpSocket beginReceiving:&error]){
            [_asyncUdpSocket close];
            NSLog(@"Error starting server (recv): %@", error);
        }
    }
    sharedInstance = self;
    return self;
}

+ (WMBonjourController*)sharedInstance
{
    return sharedInstance;
}

- (void)searchForServices
{
    [domainBrowser stop];
    [domainBrowser searchForServicesOfType:@"_PixelStyles._tcp." inDomain:@"local."];
}

- (BOOL)rawServicesContainsName:(NSString *)name
{
    for (NSNetService *service in rawServices) {
        if ([service.name isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    searching = YES;
    
    if ([_delegate respondsToSelector:@selector(didStartSearchingForServices )]) {
        [_delegate didStartSearchingForServices];
    }
    
    // Delay execution of my block for 10 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [domainBrowser stop];
    });
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    searching = NO;
    
    if ([_delegate respondsToSelector:@selector(didEndSearchingForServices)]) {
        [_delegate didEndSearchingForServices];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict
{
    LOG(@"%s",__FUNCTION__);
    
    searching = NO;
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
    
    if([_delegate respondsToSelector:@selector(didNotFindAnyServices)])
    {
        [_delegate didNotFindAnyServices];
    }
}

- (BOOL)addServiceWithName:(NSString *)name domain:(NSString *)domain type:(NSString *)type
{
    NSNetService* aNetService = [[NSNetService alloc] initWithDomain:domain type:type name:name];
    if(![rawServices containsObject: aNetService] && ![self rawServicesContainsName:name]) {
        [self netServiceBrowser:domainBrowser didFindService:aNetService moreComing:NO];
        return YES;
    }
    return NO;
}

- (void)removeService:(WMService*)service
{
    [rawServices removeObject:service.netService];
    [wmServices removeObject:service];
    service = nil;
}

- (void)tryResolveService:(WMService*)service
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    LOG(@"%s %@ %d",__FUNCTION__,aNetService.name,moreComing);
    
    if(![rawServices containsObject: aNetService] &&![self rawServicesContainsName:aNetService.name]) {
        [rawServices addObject: aNetService];
        [aNetService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [aNetService setDelegate:self];
        
        WMService *wmService = [[WMService alloc] initWithService:aNetService delegate:self];
        [wmServices addObject:wmService];
        
        wmService.resolving = YES;
        [wmService.netService resolveWithTimeout:8.0];
    }
    else
        LOG(@"Already contains service '%@'",aNetService.name);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    LOG(@"%s",__FUNCTION__);
    
    [rawServices removeObject:aNetService];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    LOG(@"%s",__FUNCTION__);
    
    for (WMService *wmService in wmServices) {
        if (wmService.netService == sender) {
            if ([_delegate respondsToSelector:@selector(serviceDidNotResolve:)]) {
                wmService.resolved = NO;
                wmService.resolving = NO;
                [_delegate serviceDidNotResolve: wmService];
                break;
            }
        }
    }
    /*
    if ([_delegate respondsToSelector:@selector(serviceDidNotResolveWithName:)]) {
        [_delegate serviceDidNotResolveWithName: sender.name];
    }
    
    [rawServices removeObject:sender];
     */
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    LOG(@"%s",__FUNCTION__);

    for (WMService *wmService in wmServices) {
        if (wmService.netService == sender) {
            if([_delegate respondsToSelector:@selector(serviceDidAppear:)]) {
                wmService.resolved = YES;
                wmService.resolving = NO;
                [_delegate serviceDidAppear:wmService];
                [wmService tryConnect];
                break;
            };
        }
    }
}

- (void)handleError:(NSNumber *)error
{
    LOG(@"An error occurred. Error code = %@", error);
}

- (void)updateSearching
{
    LOG(@"%s",__FUNCTION__);
    
}

- (void)didConnectToService:(WMService*)service
{
    LOG(@"%s",__FUNCTION__);
    
    if([_delegate respondsToSelector:@selector(serviceDidConnect:)]) {
        [_delegate serviceDidConnect:service];
    }
}

- (void)didNotConnectToService:(WMService*)service
{
    LOG(@"%s",__FUNCTION__);
    
    if([_delegate respondsToSelector:@selector(serviceDidNotConnect:)]) {
        [_delegate serviceDidNotConnect:service];
    }
}

- (void)didDisconnectFromService:(WMService*)service
{
    LOG(@"%s",__FUNCTION__);
    
    if([_delegate respondsToSelector:@selector(serviceDidDisconnect:)]) {
        [_delegate serviceDidDisconnect:service];
    }
}

- (void)serviceProtocolVersionTooOld:(WMService*)service
{
    LOG(@"%s",__FUNCTION__);
}

- (void)sendGeneralMessage:(NSString*)message
{
    for (WMService *service in wmServices)
    {
        if (service.selected)
        {
            [service sendMessage:message];
        }
    }
}

- (void)didUpdateLivePreview:(UIImage*)image
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    [userInfo setObject:image forKey:@"image"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdateLivePreview"object:nil userInfo:userInfo];
}

- (NSArray *)selectedServices
{
    NSMutableArray *selected = [NSMutableArray new];
    for (WMService *service in wmServices) {
        if (service.selected) {
            [selected addObject:service];
        }
    }
    return selected;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSDictionary *jsonImage = [_jsonParser objectWithData:[self gunzip:data]];
    if (jsonImage != nil)
    {
        NSString *macAddress = [jsonImage objectForKey:@"mac_address"];
        if (macAddress != nil) {
            for (WMService *service in _services) {
                if (service.connected && [service.macAddress isEqualToString:macAddress] && service.acceptUdpMessage) {
                    [service parseJsonImage:jsonImage];
                }
            }
        }
    }
}

- (NSData*)gunzip:(NSData*)data
{
    if ([data length] == 0) return data;
    
    unsigned full_length = (unsigned)[data length];
    unsigned half_length = (unsigned)[data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

@end