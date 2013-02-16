//
//  UserStageInfo.h
//  OnPar2
//
//  Created by Kevin R Benton on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserStageInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * stage;
@property (nonatomic, retain) NSNumber * holeNumber;
@property (nonatomic, retain) NSNumber * shotNumber;
@property (nonatomic, retain) User *user;

@end
