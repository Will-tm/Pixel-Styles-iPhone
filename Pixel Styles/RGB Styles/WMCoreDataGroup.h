//
//  WMCoreDataGroup.h
//  iBeLight 2.0
//
//  Created by William Markezana on 15/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WMCoreDataService;

@interface WMCoreDataGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *services;
@end

@interface WMCoreDataGroup (CoreDataGeneratedAccessors)

- (void)addServicesObject:(WMCoreDataService *)value;
- (void)removeServicesObject:(WMCoreDataService *)value;
- (void)addServices:(NSSet *)values;
- (void)removeServices:(NSSet *)values;

@end