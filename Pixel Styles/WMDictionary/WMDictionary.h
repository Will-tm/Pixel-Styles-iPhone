//
//  WMDictionary.h
//
//  Created by William Markezana on 14/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMDictionary : NSMutableDictionary

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex;
- (id)keyAtIndex:(NSUInteger)anIndex;
- (NSEnumerator *)reverseKeyEnumerator;

@end
