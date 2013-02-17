//
//  MainViewController.h
//  OnPar2
//
//  Created by Chad Galloway on 2/12/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

@interface MainViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)startButton:(id)sender;

- (void)deleteEverything:(id)appDelegate;

@end
