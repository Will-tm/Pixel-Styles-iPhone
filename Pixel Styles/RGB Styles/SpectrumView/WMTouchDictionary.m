//
//  WMTouchDictionary.m
//  iBeLight
//
//  Created by William Markezana on 02/03/2012.
//  Copyright (c) 2012 Measurement Specialties. All rights reserved.
//

#import "WMTouchDictionary.h"

@implementation WMTouchDictionary

@synthesize keys = keys_;
@synthesize values = values_;

- (id)init
{
    self = [super init];
    if (self)
    {
        keys_ = [[NSMutableArray alloc] init];
        values_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)count
{
    return [keys_ count];
}

- (id)objectForKey:(id)key
{
    if ([keys_ containsObject:key])
    {
        return [values_ objectAtIndex: [keys_ indexOfObject:key]];
    }
    return nil;
}

- (void)setObject:(id)object forKey:(id)key
{
    if ([keys_ containsObject:key])
    {
        [values_ replaceObjectAtIndex:[keys_ indexOfObject:key] withObject:object];
    }
    else
    {
        [keys_ addObject:key];
        [values_ addObject:object];
    }
}

- (void)removeObjectForKey:(id)key
{
    if ([keys_ containsObject:key])
    {
        [values_ removeObjectAtIndex:[keys_ indexOfObject:key]];
        [keys_ removeObject:key];
    }
}

@end
