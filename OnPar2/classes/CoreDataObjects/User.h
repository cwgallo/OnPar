//
//  User.h
//  OnPar2
//
//  Created by Kevin R Benton on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * memberID;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * tee;
@property (nonatomic, retain) NSNumber * order;

@end
