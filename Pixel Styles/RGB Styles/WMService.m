//
//  WMService.m
//  iBeLight 2.0
//
//  Created by William Markezana on 12/08/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "WMService.h"

#include <netinet/tcp.h>
#include <netinet/in.h>
 #include <arpa/inet.h>

#import "NSMutableArray+QueueAdditions.h"

#define __DEBUG__
#ifdef __DEBUG__
#   define LOG(fmt, ...)   NSLog(@"%s:%d (%s): " fmt, __FILE__, __LINE__, __func__, ## __VA_ARGS__)
#else
#   define LOG(fmt, ...)
#endif

#define GET_JSON_TAG        100
#define GET_JSON_IMAGE_TAG  101
#define GET_IMAGE_TAG       102

@interface WMService () <NSNetServiceDelegate>
{
}

@end

@implementation WMService

- (id)initWithService:(NSNetService*)service delegate:(id)delegate
{
    self = [super init];
    if (self)
    {
        _connected = NO;
        _connecting = NO;
        _delegate = delegate;
        _netService = service;
        _ip = [NSKeyedArchiver archivedDataWithRootObject:_netService.addresses];
        _name = service.name;
        _jsonParser = [SBJsonParser new];
        _resolved = NO;
        _resolving = NO;
        _retryCount = 0;
    }
    return self;
}

- (void)keepAlive
{
    [self sendMessage:@"alive"];
}

- (NSDictionary *)dictionaryFromTXTRecordData:(NSData *)txtData
{
	NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:txtData];
	NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:[dict count]];
    
	for (id key in dict)
	{
		NSData *data = [dict objectForKey:key];
		if ([data isEqual:[NSNull null]]) { break; }
		NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		
		if (str)
		{
			[mDict setObject:str forKey:key];
		}
		else
		{
			LOG(@"Unable to get string from key \"%@\"", key);
		}
	}
	return mDict;
}

- (void)setResolved:(BOOL)resolved
{
    _resolved = resolved;
    
    _txtRecords = [self dictionaryFromTXTRecordData:[_netService TXTRecordData]];
    _hostType = [_txtRecords objectForKey:@"kHostType"];
    _hostVersion = [_txtRecords objectForKey:@"kHostVersion"];
    _protocolVersion = [_txtRecords objectForKey:@"kProtocolVersion"];
    _subtitle = [NSString stringWithFormat:@"%@ - %@", _hostType, _hostVersion];
    if (_protocolVersion == nil) _protocolVersion = @"1.0";
}

- (void)tryConnect
{
    _asyncSocket = nil;
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_asyncSocket performBlock:^{
        int fd = [_asyncSocket socketFD];
        int on = 1;
        if (setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, (char*)&on, sizeof(on)) == -1){
            /* handle error */
        }
    }];
    
	BOOL done = NO;
    _connected = NO;
    _connecting = YES;
    NSMutableArray *adresses = [[_netService addresses] mutableCopy];
	
	while (!done && ([adresses count] > 0))
	{
		NSData *addr;
	
		if (YES) // Iterate forwards
		{
			addr = [adresses objectAtIndex:0];
			[adresses removeObjectAtIndex:0];
		}
		else // Iterate backwards
		{
			addr = [adresses lastObject];
			[adresses removeLastObject];
		}
		
		//NSLog(@"Attempting connection to %@", addr);
		
		NSError *err = nil;
		if ([_asyncSocket connectToAddress:addr error:&err])
		{
			done = YES;
		}
		else
		{
			NSLog(@"Unable to connect: %@", err);
		}
	}
	
	if (!done)
	{
		NSLog(@"Unable to connect to any resolved address");
        
        _connecting = NO;
        _connected = NO;
        if([_delegate respondsToSelector:@selector(didNotConnectToService:)])
        {
            [_delegate didNotConnectToService:self];
        }
        if (_tryConnectWithCompletionBlock) {
            _tryConnectWithCompletionBlock(NO);
        }
	}
}

- (void)tryConnectWithCompletionBlock:(void(^)(BOOL connected))completion
{
    _tryConnectWithCompletionBlock = completion;
    [self tryConnect];
}

- (void)tryResolveWithCompletionBlock:(void(^)(BOOL resolved))completion
{
    _resolving = YES;
    _resolved = NO;
    _tryResolveWithCompletionBlock = completion;
    _netService.delegate = self;
    [_netService resolveWithTimeout:8.0];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    _resolving = NO;
    self.resolved = YES;
    if (_tryResolveWithCompletionBlock) {
        _tryResolveWithCompletionBlock(YES);
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    _resolving = NO;
    self.resolved = NO;
    if (_tryResolveWithCompletionBlock) {
        _tryResolveWithCompletionBlock(NO);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if ([_protocolVersion doubleValue] < MIN_PROTOCOL_VERSION)
    {
        NSLog(@"Socket:DidConnectToHost: %@ Port: %hu but protocol version is too old (%@)", host, port,_protocolVersion);
        
        [_asyncSocket disconnect];
        if([_delegate respondsToSelector:@selector(serviceProtocolVersionTooOld:)])
        {
            [_delegate serviceProtocolVersionTooOld:self];
        }
        if (_tryConnectWithCompletionBlock) {
            _tryConnectWithCompletionBlock(NO);
        }
    }
    else
    {
        [self sendMessage:@"GetJSON"];
        [_asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:5.0 tag:GET_JSON_TAG];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"SocketDidDisconnect:WithError: %@", err);
	
    _connecting = NO;
    _connected = NO;

    if([_delegate respondsToSelector:@selector(didDisconnectFromService:)])
    {
        [_delegate didDisconnectFromService:self];
    }
    if (_tryConnectWithCompletionBlock) {
        _tryConnectWithCompletionBlock(NO);
    }
    
    [_keepAliveTimer invalidate];
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

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    switch (tag)
    {
        case GET_JSON_TAG:
            LOG(@"%@",[NSString stringWithUTF8String:[data bytes]]);
            _jsonItems = [_jsonParser objectWithData:[self gunzip:data]];
            
            if (_jsonItems == nil) {
                NSLog(@"_jsonItems = nil");
                [sock disconnect];

            } else {
                [self parseJsonItems:_jsonItems];
                
                _connecting = NO;
                _connected = YES;
                _retryCount = 0;
                
                if([_delegate respondsToSelector:@selector(didConnectToService:)])
                {
                    [_delegate didConnectToService:self];
                }
                if (_tryConnectWithCompletionBlock) {
                    _tryConnectWithCompletionBlock(YES);
                }
                
                _keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(keepAlive) userInfo:nil repeats:YES];
            }
            break;
            
        default:
            NSLog(@"Invalid tag");
        break;
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    NSTimeInterval result = 0.0;
    switch (tag)
    {
        case GET_JSON_TAG:
            
            NSLog(@"Unable to get JSON");
            
            _connecting = NO;
            _connected = NO;
            if([_delegate respondsToSelector:@selector(didNotConnectToService:)])
            {
                [_delegate didNotConnectToService:self];
            }
            
            if (_tryConnectWithCompletionBlock) {
                _tryConnectWithCompletionBlock(NO);
            }
            
            break;
            
        default:
            NSLog(@"Invalid tag");
            break;
    }
    return result;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    _done = YES;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    NSLog(@"%s %ld",__FUNCTION__,tag);
    return 0;
}

- (void)sendMessage:(NSString*)message
{
    [self sendMessage:message withTimeout:0.5];
}

- (void)sendMessage:(NSString*)message withTimeout:(NSTimeInterval)timeout;
{
    _done = NO;
    
    NSTimeInterval date = [NSDate timeIntervalSinceReferenceDate] * 100000;
    UInt64 tag = date;
    [_asyncSocket writeData:[[message stringByAppendingString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:timeout tag:tag&0x7FFFFFFF];
    
    while(!_done)
    {
		@autoreleasepool
        {
			NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:timeout];
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:date];
		}
	}
    if(!_done)
        NSLog(@"write timeout for tag %llu",tag&0x7FFFFFFF);
}

- (void)parseJsonItems:(NSArray*)jsonItems
{
    //NSLog(@"jsonItems = %@",jsonItems);
    
    _activeModeName = [[jsonItems objectAtIndex:0] objectForKey:@"active_mode"];
    _macAddress = [[jsonItems objectAtIndex:0] objectForKey:@"mac_address"];
    
    _width = [[[jsonItems objectAtIndex:0] objectForKey:@"width"] integerValue];
    _height = [[[jsonItems objectAtIndex:0] objectForKey:@"height"] integerValue];
    
    NSArray *modes = [[jsonItems objectAtIndex:1] objectForKey:@"modes"];
    _modes = [NSMutableArray new];
    for (NSDictionary *mode in modes)
    {
        WMServiceMode *_mode = [WMServiceMode new];
        _mode.delegate = self;
        _mode.name = [mode objectForKey:@"name"];
        _mode.ui = (ui_type)[[mode objectForKey:@"ui"] integerValue];
        _mode.image = [self parseImagePixels:[mode objectForKey:@"pixels"] width:_width height:_height];
        
        NSArray *settings = [mode objectForKey:@"settings"];
        for (NSDictionary *setting in settings)
        {
            WMServiceModeSetting *_setting = [WMServiceModeSetting new];
            _setting.delegate = _mode;
            _setting.caption = [setting objectForKey:@"caption"];
            _setting.kind = (ihm_type)[[setting objectForKey:@"kind"] integerValue];
            _setting.maxValue = [[setting objectForKey:@"maxValue"] floatValue];
            _setting.minValue = [[setting objectForKey:@"minValue"] floatValue];
            _setting.section = [setting objectForKey:@"section"];
            _setting.value = [setting objectForKey:@"value"];
            
            [_mode.settings addObject:_setting];
        }
        [_modes addObject:_mode];
    }
}

- (NSInteger)activeModeIndex
{
    for (WMServiceMode *mode in _modes)
    {
        if ([mode.name isEqualToString:_activeModeName])
        {
            return [_modes indexOfObject:mode];
        }
    }
    return -1;
}

- (void)parseImageJsonItems:(NSDictionary*)jsonItems
{
    NSInteger width = [[jsonItems objectForKey:@"Width"] integerValue];
    NSInteger height = [[jsonItems objectForKey:@"Height"] integerValue];
    NSString *pixels = [jsonItems objectForKey:@"Pixels"];
    
    UIImage *image = [self parseImagePixels:pixels width:width height:height];
    if(image != nil && [_delegate respondsToSelector:@selector(didUpdateLivePreview:)])
    {
        [_delegate didUpdateLivePreview:image];
    }
    image = nil;
}

- (void)settingsValueDidUpdate:(WMServiceModeSetting*)setting forMode:(WMServiceMode*)mode
{
    if (_connected) {
        [self sendMessage:[NSString stringWithFormat:@"SetModeSettingValue_%@_%@_%@", mode.name, setting.caption, setting.value]];
    }
}

- (void)modeDidReceiveTouchEvent:(NSString*)touchString
{
    [self sendMessage:touchString];
}

- (void)parseJsonImage:(NSDictionary*)jsonImage
{
    NSInteger width = [[jsonImage objectForKey:@"width"] integerValue];
    NSInteger height = [[jsonImage objectForKey:@"height"] integerValue];
    NSString *pixels = [jsonImage objectForKey:@"pixels"];
    
    __weak UIImage *image = [self parseImagePixels:pixels width:width height:height];
    if(image != nil && [_delegate respondsToSelector:@selector(didUpdateLivePreview:)])
    {
        [_delegate didUpdateLivePreview:image];
    }
    image = nil;
}

- (NSData *)dataFromHexString:(NSString *)string
{
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    NSInteger length = string.length;
    int i = 0;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
        if (i % 6 == 0) {
            whole_byte = 0xFF;
            [data appendBytes:&whole_byte length:1];
        }
    }
    return data;
}

- (UIImage*)parseImagePixels:(NSString*)pixels width:(NSInteger)width height:(NSInteger)height
{
    __weak UIImage *image = nil;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)[self dataFromHexString:pixels]);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big, provider,  NULL, FALSE, kCGRenderingIntentDefault);
    CFRelease(colorSpace);
    CFRelease(provider);
    image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return image;
}

@end
