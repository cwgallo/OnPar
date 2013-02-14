//
//  Hole.h
//  OnPar2
//
//  Created by Kevin R Benton on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Round;
@class Shot;

@interface Hole : NSManagedObject

@property (nonatomic, retain) NSNumber * holeNumber;
@property (nonatomic, retain) NSNumber * holeScore;
@property (nonatomic, retain) NSNumber * fairway_in_reg;
@property (nonatomic, retain) NSNumber * green_in_reg;
@property (nonatomic, retain) NSNumber * putts;
@property (nonatomic, retain) Round *round;
@property (nonatomic, retain) NSSet *shots;
@end

@interface Hole (CoreDataGeneratedAccessors)

- (void)addShotsObject:(Shot *)value;
- (void)removeShotsObject:(Shot *)value;
- (void)addShots:(NSSet *)values;
- (void)removeShots:(NSSet *)values;

@end
