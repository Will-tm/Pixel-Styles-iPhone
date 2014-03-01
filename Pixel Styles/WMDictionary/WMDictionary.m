//
//  WMDictionary.m
//
//  Created by William Markezana on 14/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import "WMDictionary.h"

@interface WMDictionary ()
{
	NSMutableDictionary *dictionary;
	NSMutableArray *keys;
}

@end

@implementation WMDictionary

- (id)init
{
	return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
    
	if (self != nil) {
		dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
		keys = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
    
	return self;
}

- (id)copy
{
	return [self mutableCopy];
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	if (![dictionary objectForKey:aKey]) {
		[keys addObject:aKey];
	}
	[dictionary setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
	[dictionary removeObjectForKey:aKey];
	[keys removeObject:aKey];
}

- (NSUInteger)count
{
	return [keys count];
}

- (id)objectForKey:(id)aKey
{
	return [dictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
	return [keys objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator
{
	return [keys reverseObjectEnumerator];
}

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex
{
	if ([dictionary objectForKey:aKey]) {
		[self removeObjectForKey:aKey];
	}
	[keys insertObject:aKey atIndex:anIndex];
	[dictionary setObject:anObject forKey:aKey];
}

- (id)keyAtIndex:(NSUInteger)anIndex
{
	return [keys objectAtIndex:anIndex];
}

@end
