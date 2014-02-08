//
//  WMTouchDictionary.h
//  iBeLight
//
//  Created by William Markezana on 02/03/2012.
//  Copyright (c) 2012 Measurement Specialties. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMTouchDictionary : NSObject
{
    NSMutableArray *keys_;
    NSMutableArray *values_;
}

@property (nonatomic, readonly, strong) NSMutableArray *keys;
@property (nonatomic, readwrite, strong) NSMutableArray *values;

- (NSInteger)count;
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end
