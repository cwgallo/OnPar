//
//  MainViewController.h
//  OnPar2
//
//  Created by Chad Galloway on 2/12/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

@interface MainViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
