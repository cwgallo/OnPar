//
//  MainViewController.m
//  OnPar2
//
//  Created by Chad Galloway on 2/12/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "MainViewController.h"
#import "Golfer_VC.h"
#import "Config.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize continueButton;

@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self hideNavBar];

}

- (void)viewWillAppear:(BOOL)animated
{
    // pull information from the database
    // if there is any, show the continue button
    // and give them the choice to continue the started round
    
    // obtain count of Users in the DB
    NSMutableArray *golfers = [[NSMutableArray alloc] init];
    
    // load golfers that are in database
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"User"
                                              inManagedObjectContext: [appDelegate managedObjectContext]];
    [fetchRequest setEntity: entity];
    NSArray *fetchedObjects = [[appDelegate managedObjectContext] executeFetchRequest: fetchRequest error: &error];
    for (User *u in fetchedObjects) {
        [golfers addObject: u];
    }
    
    if ([golfers count] > 0) {
        continueButton.hidden = NO;
    } else {
        continueButton.hidden = YES;
    }
    
    [self hideNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller
/*
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}
 */

- (void)hideNavBar
{
    self.navigationController.navigationBar.hidden = YES;
}


- (IBAction)startButton:(id)sender
{
    // either a new round or deleting the current info and
    // start a new round(s)
    
    [self deleteEverything: (id)[[UIApplication sharedApplication] delegate]];
    
    [self performSegueWithIdentifier:@"main2options" sender:self];
}

- (IBAction)continueRound:(id)sender
{
    // segue straight to the Play_VC
    // should be able to determine everything from the DB
    
    [self performSegueWithIdentifier:@"main2play" sender:self];
}

- (void)deleteEverything: (id)appDelegate
{
    // clear the User Table
    NSError *error;
    
    NSFetchRequest *userFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *user = [NSEntityDescription entityForName: @"User"
                                            inManagedObjectContext: [appDelegate managedObjectContext]];
    [userFetch setEntity: user];
    NSArray *users = [[appDelegate managedObjectContext] executeFetchRequest: userFetch error: &error];
    for (User *u in users) {
        [[appDelegate managedObjectContext] deleteObject: u];
    }
    
    // clear the Round Table
    NSFetchRequest *roundFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *round = [NSEntityDescription entityForName: @"Round"
                                             inManagedObjectContext: [appDelegate managedObjectContext]];
    [roundFetch setEntity: round];
    NSArray *rounds = [[appDelegate managedObjectContext] executeFetchRequest: roundFetch error: &error];
    for (Round *r in rounds) {
        [[appDelegate managedObjectContext] deleteObject: r];
    }
}

@end
