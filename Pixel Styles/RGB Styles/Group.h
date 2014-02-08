//
//  Group.h
//  iBeLight 2.0
//
//  Created by William Markezana on 17/10/2013.
//  Copyright (c) 2013 RGB Styles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Service;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *services;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addServicesObject:(Service *)value;
- (void)removeServicesObject:(Service *)value;
- (void)addServices:(NSSet *)values;
- (void)removeServices:(NSSet *)values;

@end
