//
//  WMCoreDataService.h
//  iBeLight 2.0
//
//  Created by William Markezana on 15/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WMCoreDataGroup;

@interface WMCoreDataService : NSManagedObject

@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet * groups;

@end

@interface WMCoreDataService (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(WMCoreDataGroup *)value;
- (void)removeGroupsObject:(WMCoreDataGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
