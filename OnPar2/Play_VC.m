//
//  Play_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Play_VC.h"
#import "MainViewController.h" // needed for deleteEverything
#import "Config.h"

@interface Play_VC ()

@end

@implementation Play_VC{
    NSMutableArray *golfers;
    NSMutableArray *rounds;
    
    // current golfer should be the index for both user in the golfers array
    // and the round in the round array
    int currentGolfer;
}

@synthesize myImageView, myScrollView, navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // should only have to retrieve the golfers once
    golfers = [[NSMutableArray alloc] init];
    rounds = [[NSMutableArray alloc] init];
    
    // initialize current golfer to golfer 1
    currentGolfer = 0;
    
    // load golfers that are in database
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    NSFetchRequest *userFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *user = [NSEntityDescription entityForName: @"User"
                                              inManagedObjectContext: [appDelegate managedObjectContext]];
    [userFetch setEntity: user];
    NSArray *users = [[appDelegate managedObjectContext] executeFetchRequest: userFetch error: &error];
    for (User *u in users) {
        [golfers addObject: u];
        
        // create a round for each user and store it in the same location
        Round *r = [NSEntityDescription
                   insertNewObjectForEntityForName: @"Round"
                   inManagedObjectContext: [appDelegate managedObjectContext]];
        
        // the course ID can maybe change at a later time
        r.courseID = @1;
        r.userID = u.userID;
        r.teeID = u.tee;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        
        NSString *dateString = [formatter stringFromDate: [NSDate date]];
        
        r.startTime  = dateString;
        
        // create the first hole for every golfer
        Hole *h = [NSEntityDescription
                    insertNewObjectForEntityForName: @"Hole"
                    inManagedObjectContext: [appDelegate managedObjectContext]];
        
        h.holeNumber = @1;
        
        // set relationships
        h.round = r;
        [r addHolesObject: h];
        
        // save the round and hole
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        } else {
            // add the object to the rounds array
            [rounds addObject: r];
        }
    }
    
    /*NSFetchRequest *roundFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *round = [NSEntityDescription entityForName: @"Round"
                                            inManagedObjectContext: [appDelegate managedObjectContext]];
    [roundFetch setEntity: round];
    NSArray *DBrounds = [[appDelegate managedObjectContext] executeFetchRequest: roundFetch error: &error];
    
    for (Round *r in DBrounds) {
        NSLog(@"%@", r);
    }*/
    
    
    // get current golfer info
    User *u = [golfers objectAtIndex:currentGolfer];
    
    NSLog(@"Hole number: %@", u.stageInfo.holeNumber);
    
    // set correct hole image
    if (u.nickname != nil)
        [navBar setTitle:u.nickname];
    else
        [navBar setTitle:u.name];
    
    [self setHoleImageForUser:u];
    
    /*
    myScrollView.contentSize = myImageView.bounds.size;
    [myScrollView setDelegate:self];
    [myScrollView setScrollEnabled:YES];
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    // take the current golfer and display only the proper buttons
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)skipHole:(id)sender
{
    // update the holeNumber and stage of the User's stage info
    User *u = [golfers objectAtIndex: currentGolfer];
    u.stageInfo.stage = [NSNumber numberWithInt: STAGE_AIM];
    
    int hole = [u.stageInfo.holeNumber intValue];
    u.stageInfo.holeNumber = [NSNumber numberWithInt: hole + 1];
    
    // create a new hole to add to the hole object with the updated hole number
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    Round *r = [rounds objectAtIndex: currentGolfer];
    
    // create the first hole for every golfer
    Hole *h = [NSEntityDescription
               insertNewObjectForEntityForName: @"Hole"
               inManagedObjectContext: [appDelegate managedObjectContext]];
    
    h.holeNumber = u.stageInfo.holeNumber;
    
    // set relationships
    h.round = r;
    [r addHolesObject: h];
    
    NSError *error;
    
    if (![[appDelegate managedObjectContext] save: &error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    NSLog(@"Current hole: %@", h);
}

- (IBAction)finishHole:(id)sender
{
    
}

- (IBAction)startShot:(id)sender
{
    // alert to tell them to press OK at the location of the ball
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Start Shot" message:@"Press OK when at the ball's location for the start of the shot."];
    [alert applyCustomAlertAppearance];
    __weak AHAlertView *weakAlert = alert;
    [alert addButtonWithTitle:@"OK" block:^{
        
        
        
        weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
    }];
    [alert show];
}

- (IBAction)endShot:(id)sender
{
    
}


- (IBAction)endGame:(id)sender
{
    if ([ZFloatingManager shouldFloatingWithIdentifierAppear:@"Golfers"])
    {
        
        ZAction *cancel = [ZAction actionWithTitle:@"Cancel" target:self action:nil object:nil];
        
        NSMutableArray *options = [[NSMutableArray alloc] init];
            
        ZAction *option;
        
        option = [ZAction actionWithTitle: @"Upload Results" target:self action:@selector(uploadResults) object:nil];

        [options addObject: option];
        
        option = [ZAction actionWithTitle: @"Discard Results"  target:self action:@selector(discardGame) object:nil];
            
        [options addObject: option];
        
        ZActionSheet *sheet = [[ZActionSheet alloc] initWithTitle:@"End Game?" cancelAction:cancel destructiveAction:nil otherActions: options];
        sheet.identifier = @"End";
        [sheet showFromBarButtonItem:sender animated:YES];
    }
}

- (void)uploadResults
{
    // Check to see if all users have finished
    
    // Display alert if not all finished
    
    // Go to upload page
    [self performSegueWithIdentifier: @"play2upload" sender:self];
}

- (void)discardGame
{
    // TODO - Display alert
    
    // TODO - Delete everything
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    MainViewController *mvc = [[MainViewController alloc] init];
    [mvc deleteEverything:appDelegate];
    
    // Return to main page
    [[self navigationController] popToRootViewControllerAnimated:YES];
}


- (IBAction)selectGolfer:(id)sender;
{
    
    if ([ZFloatingManager shouldFloatingWithIdentifierAppear:@"End"])
    {
        
        ZAction *cancel = [ZAction actionWithTitle:@"Cancel" target:self action:nil object:nil];
        
        NSMutableArray *options = [[NSMutableArray alloc] init];
        
        int counter = 1;
        for (User *u in golfers) {
            NSNumber *current;
            
            if (counter == 1) {
                current = [NSNumber numberWithInt: 0];
            } else if (counter == 2) {
                current = [NSNumber numberWithInt: 1];
            } else if (counter == 3) {
                current = [NSNumber numberWithInt: 2];
            } else {
                current = [NSNumber numberWithInt: 3];
            }
            
            ZAction *option;
            
            if (u.nickname != nil)
                option = [ZAction actionWithTitle: u.nickname  target:self action:@selector(changeGolfer:) object:current];
            else
                option = [ZAction actionWithTitle: u.name  target:self action:@selector(changeGolfer:) object:current];
            
            [options addObject: option];
            
            counter++;
        }
        
        ZActionSheet *sheet = [[ZActionSheet alloc] initWithTitle:@"Select A Golfer" cancelAction:cancel destructiveAction:nil otherActions:options];
        
        sheet.identifier = @"Golfers";
        [sheet showFromBarButtonItem:sender animated:YES];
        
    }
}

- (void)changeGolfer:(id)object
{
    // Make golfer change here
    NSLog(@"Change golfer");
    currentGolfer = [object intValue];
    
    // Get new golfer's information
    User *u = [golfers objectAtIndex:currentGolfer];
    
    // Set nav bar title
    self.navBar.title = [[NSString alloc] initWithFormat:@"%@", u.name];
    
    // Use stage number to set up screen for new golfer
    //u.stageInfo.stage
}


- (void)setHoleImageForUser: (User *)u
{
    NSNumber *hole = @2;//u.stageInfo.holeNumber;
    
    NSString *filename = [NSString stringWithFormat:@"%@%@%@", @"hole", hole, @".png"];
    
    NSLog(@"Loading file: %@", filename);
    
    UIImage *image = [UIImage imageNamed:filename];
    
    [myImageView setImage: image];
}

@end
