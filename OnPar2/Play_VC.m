//
//  Play_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Play_VC.h"
#import "Config.h"
#import "Math.h" // for aimGPS
#import "MainViewController.h" // needed for deleteEverything

@interface Play_VC ()

@end

@implementation Play_VC{
    NSMutableDictionary *golfers;
    NSMutableDictionary *rounds;
    
    // for the club selection
    NSArray *types;
    NSArray *woods;
    NSArray *hybrids;
    NSArray *irons;
    NSArray *wedges;
    
    User *currentGolfer;
    Round *currentRound;
    Hole *currentHole;
    Shot *currentShot;
    
    int clubSelection;
    int clubType;
}

@synthesize myImageView, myScrollView, navBar;
@synthesize startButton, endButton, finishButton, skipButton;
//@synthesize clubTypeSegment, clubPicker, clubSelectionTable;

@synthesize locationMgr = _locationMgr;
@synthesize lastLocation = _lastLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Loads

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // for club selection
    types = [[NSArray alloc] initWithObjects: @"Woods", @"Hybrids", @"Irons", @"Wedges", nil];
    
    // location manager
    self.locationMgr = [[CLLocationManager alloc] init];
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationMgr.delegate = self;
    
    // just constantly track satelite location
    [self.locationMgr startUpdatingLocation];
    
    // should only have to retrieve the golfers once
    golfers = [[NSMutableDictionary alloc] init];
    rounds = [[NSMutableDictionary alloc] init];
    
    // load golfers that are in database
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    NSFetchRequest *userFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *user = [NSEntityDescription entityForName: @"User"
                                            inManagedObjectContext: [appDelegate managedObjectContext]];
    [userFetch setEntity: user];
    NSArray *users = [[appDelegate managedObjectContext] executeFetchRequest: userFetch error: &error];
    
    // load the rounds from the database to see if there are any
    // there should always be some in the DB
    NSFetchRequest *roundFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *round = [NSEntityDescription entityForName: @"Round"
                                             inManagedObjectContext: [appDelegate managedObjectContext]];
    [roundFetch setEntity: round];
    NSArray *DBrounds = [[appDelegate managedObjectContext] executeFetchRequest: roundFetch error: &error];
    
    if (DBrounds.count != 0) {
        for (Round *r in DBrounds) {
            [rounds setObject: r forKey: r.userID];
        }
    }
    
    for (User *u in users) {
        [golfers setObject: u forKey: u.userID];
        
        // check to see if this is the current golfer
        if ([u.stageInfo.currentGolfer isEqualToNumber: [NSNumber numberWithBool: YES]]) {
            currentGolfer = u;
        }
    }
    
    
    // set correct hole image
    if (currentGolfer.nickname != nil)
        [navBar setTitle:currentGolfer.nickname];
    else
        [navBar setTitle:currentGolfer.name];
    
    //[self setHoleImageForUser: currentGolfer];
}

- (void)viewWillAppear:(BOOL)animated
{
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    // set the picture for the golfer
    [self setHoleImageForUser: currentGolfer];
    
    // check to see what hole the golfer is on
    // if 18, hide the skip button
    if ([currentGolfer.stageInfo.holeNumber isEqualToNumber: [NSNumber numberWithInt: 18]]) {
        skipButton.hidden = YES;
    } else {
        skipButton.hidden = NO;
    }
    
    // set the current Round, Hole, and Shot
    currentRound = [rounds objectForKey: currentGolfer.userID];
    
    currentHole = nil;
    currentShot = nil;
    
    for (Hole *h in currentRound.holes) {
        if ([currentGolfer.stageInfo.holeNumber isEqualToNumber: h.holeNumber]) {
            currentHole = h;
            for (Shot *s in currentHole.shots) {
                if ([currentGolfer.stageInfo.shotNumber isEqualToNumber: s.shotNumber]) {
                    currentShot = s;
                    break;
                }
            }
            break;
        }
    }
    
    NSLog(@"CURRENT GOLFER: %@", currentGolfer);
    NSLog(@"CURRENT ROUND: %@", currentRound);
    NSLog(@"CURRENT HOLE: %@", currentHole);
    NSLog(@"CURRENT SHOT: %@", currentShot);
    
    if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_START]]) {
        NSLog(@"Stage START for golfer: %@", currentGolfer.name);
        // hide end button and show start
        endButton.hidden = YES;
        startButton.hidden = NO;
        
        finishButton.hidden = NO;
        
    } else if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_CLUB_SELECT]]) {
        NSLog(@"Stage CLUB_SELECT for golfer: %@", currentGolfer.name);
        // there won't be any real change here since it's just another alert
        // hide end button and start
        endButton.hidden = YES;
        startButton.hidden = YES;
        
        finishButton.hidden = YES;
        
        // manually call club select function
        [self selectClub];
        
    } else if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_AIM]]) {
        NSLog(@"Stage AIM for golfer: %@", currentGolfer.name);
        // hide end button and start button
        endButton.hidden = YES;
        startButton.hidden = YES;
        
        finishButton.hidden = YES;
        
    } else if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_END]]) {
        NSLog(@"Stage END for golfer: %@", currentGolfer.name);
        // show end button and hide start button
        endButton.hidden = NO;
        startButton.hidden = YES;
        
        finishButton.hidden = YES;
        
    } else {
        NSLog(@"Stage DONE for golfer: %@", currentGolfer.name);
        // stage done
        // dont shoe any buttons
        startButton.hidden = YES;
        endButton.hidden = YES;
        skipButton.hidden = YES;
        finishButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Hole Options

- (IBAction)skipHole:(id)sender
{
    // if there is a current shot, discard it
    // update the holeNumber and stage of the User's stage info
    currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_START];
    
    int hole = [currentGolfer.stageInfo.holeNumber intValue];
    currentGolfer.stageInfo.holeNumber = [NSNumber numberWithInt: hole + 1];
    
    // create a new hole to add to the hole object with the updated hole number
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    if (![[appDelegate managedObjectContext] save: &error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [self viewWillAppear: NO];
}

- (IBAction)finishHole:(id)sender
{
    // make sure the current shot is finished
    // save the hole to the database
    // update the User's holeNumber in the User's stageInfo
    
    if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_START]]) {
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        int holeNumber = [currentGolfer.stageInfo.holeNumber intValue];

        // do not advance to hole 19
        if (holeNumber + 1 != 19) {
            currentGolfer.stageInfo.holeNumber = [NSNumber numberWithInt: holeNumber + 1];
        } else {
            // if they finish hole 18, set them to stage done
            currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_DONE];
        }

        // create a new hole to add to the hole object with the updated hole number
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
    } else {
        // tell the User to finish the hole
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Error" message:@"You must finish the current shot before ending the hole."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    }
    
    [self viewWillAppear: NO];
}


#pragma mark - Shot Options

- (IBAction)startShot:(id)sender
{
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSError *error;
    
    // check to see if the current shot was reached
    // if there is no current shot, create one
    if (currentShot == nil) {
        Shot *s = [NSEntityDescription
                   insertNewObjectForEntityForName: @"Shot"
                   inManagedObjectContext: [appDelegate managedObjectContext]];
        
        s.shotNumber = currentGolfer.stageInfo.shotNumber;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        } else {
            currentShot = s;
        }
    }
    
    // alert to tell them to press OK at the location of the ball
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Start Shot" message:@"Press OK when at the ball's location for the start of the shot."];
    [alert applyCustomAlertAppearance];
    __weak AHAlertView *weakAlert = alert;
    [alert addButtonWithTitle:@"OK" block:^{
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        currentShot.startLatitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.latitude];
        currentShot.startLongitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.longitude];
        
        currentShot.hole = currentHole;
        [currentHole addShotsObject: currentShot];
        
        // update the user's stage info to be at STAGE_CLUB_SELECT
        currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_CLUB_SELECT];
        
        // save to core data
        
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        // calling view will appear will make club selection alert come up
        [self viewWillAppear: NO];
        
        weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
    }];
    [alert show];
}

- (IBAction)endShot:(id)sender
{
    // collect the end lat and long of the shot
    // make sure all the fields of the shot are there
    // save shot to DB
    // update user's shotNumber
    // set User's stage to stage_start
    
    currentShot.endLatitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.latitude];
    currentShot.endLongitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.longitude];
    
    if (currentShot.startLatitude == nil || currentShot.startLongitude == nil ||
        currentShot.aimLatitude == nil || currentShot.aimLongitude == nil ||
        currentShot.endLatitude == nil || currentShot.endLongitude == nil ||
        currentShot.club == nil || currentShot.shotNumber == nil) {
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Error" message:@"Some field is not set."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    } else {
        currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_START];
        int shotNumber = [currentGolfer.stageInfo.shotNumber intValue];
        currentGolfer.stageInfo.shotNumber = [NSNumber numberWithInt: shotNumber + 1];
        
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"End Shot" message:@"Press OK when at the ball's location for the end of the shot."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            currentShot.startLatitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.latitude];
            currentShot.startLongitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.longitude];
            
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
        
        // make sure the shot is relationed to the hole
        currentShot.hole = currentHole;
        [currentHole addShotsObject: currentShot];
        
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    [self viewWillAppear: NO];
}


#pragma mark - Ending Game

- (IBAction)endGame:(id)sender
{
    if ([ZFloatingManager shouldFloatingWithIdentifierAppear:@"Golfers"])
    {
        
        ZAction *cancel = [ZAction actionWithTitle:@"Cancel" target:self action:nil object:nil];
        
        NSMutableArray *options = [[NSMutableArray alloc] init];
            
        ZAction *option;
        
        option = [ZAction actionWithTitle: @"Upload Results" target:self action:@selector(uploadResults) object:nil];

        [options addObject: option];
        
        option = [ZAction actionWithTitle: @"Discard Results"  target:self action:@selector(discardResults) object:nil];
            
        [options addObject: option];
        
        ZActionSheet *sheet = [[ZActionSheet alloc] initWithTitle:@"End Game?" cancelAction:cancel destructiveAction:nil otherActions: options];
        sheet.identifier = @"End";
        [sheet showFromBarButtonItem:sender animated:YES];
    }
}

- (void)uploadResults
{
    // Does not matter if all user's have finished the round
    // sometimes a User might leave early, the group may only
    // play nine holes, etc.
    // It is up to the User to decide when the end of the
    // round is.
    
    // Going to a new page so updating location is no
    // longer needed.
    [self.locationMgr stopUpdatingLocation];
    
    // Go to upload page
    [self performSegueWithIdentifier: @"play2upload" sender:self];
}

- (void)discardResults
{
    // TODO - Display alert
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Discard Round" message:@"Are you sure you wish to discard the results?"];
    [alert applyCustomAlertAppearance];
    __weak AHAlertView *weakAlert = alert;
    [alert setCancelButtonTitle:@"No" block:^{
        // do nothing
        weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
    }];
    [alert addButtonWithTitle:@"Yes" block:^{
        // Going to a new page so updating location is no
        // longer needed.
        [self.locationMgr stopUpdatingLocation];
        
        // Delete everything
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        MainViewController *mvc = [[MainViewController alloc] init];
        [mvc deleteEverything:appDelegate];
        
        // Return to main page
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }];
    [alert show];
}


#pragma mark - Changing Golfers

- (IBAction)selectGolfer:(id)sender;
{
    
    if ([ZFloatingManager shouldFloatingWithIdentifierAppear:@"End"])
    {
        
        ZAction *cancel = [ZAction actionWithTitle:@"Cancel" target:self action:nil object:nil];
        
        NSMutableArray *options = [[NSMutableArray alloc] init];
        
        int counter = 1;
        for (NSNumber *key in golfers) {
            ZAction *option;
            
            User *u = [golfers objectForKey: key];
            
            if (u.nickname != nil)
                option = [ZAction actionWithTitle: u.nickname  target:self action:@selector(changeGolfer:) object: u];
            else
                option = [ZAction actionWithTitle: u.name  target:self action:@selector(changeGolfer:) object: u];
            
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
    currentGolfer = object;
    
    for (NSNumber *key in golfers) {
        User *u = [golfers objectForKey: key];
        
        if ([u.userID isEqualToNumber: currentGolfer.userID]) {
            u.stageInfo.currentGolfer = [NSNumber numberWithBool: YES];
        } else {
            u.stageInfo.currentGolfer = [NSNumber numberWithBool: NO];
        }
    }
    
    // save the user's stage to the DB
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    if (![[appDelegate managedObjectContext] save: &error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    // Set nav bar title
    if (currentGolfer.nickname != nil) {
        self.navBar.title = [[NSString alloc] initWithFormat:@"%@", currentGolfer.nickname];
    } else {
        self.navBar.title = [[NSString alloc] initWithFormat:@"%@", currentGolfer.name];
    }
    
    [self viewWillAppear: NO];
}


#pragma mark - helper functions

- (void)setHoleImageForUser: (User *)u
{
    NSNumber *hole = u.stageInfo.holeNumber;
    
    NSString *filename = [NSString stringWithFormat:@"%@%@%@", @"hole", hole, @".png"];
    
    UIImage *image = [UIImage imageNamed:filename];
    
    [myImageView setImage: image];
}

- (void) selectClub
{
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Club Selection" message:@"\n\n\n\n"];
    [alert applyCustomAlertAppearance];
    __weak AHAlertView *weakAlert = alert;
    [alert addButtonWithTitle:@"OK" block:^{
        currentShot.club = [NSNumber numberWithInt: DRIVER];
        weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
    }];
    //[alert addSubview: self.clubSelectionTable];
    [alert show];
    
    // set User's stage to STAGE_AIM
    currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_AIM];
    
    // save the club selection and user's stage to the DB
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSError *error;
    
    if (![[appDelegate managedObjectContext] save: &error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [self viewWillAppear: NO];
}


#pragma mark - core location

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (!self.lastLocation) {
        self.lastLocation = newLocation;
    }
    
    if (newLocation.coordinate.latitude != self.lastLocation.coordinate.latitude &&
        newLocation.coordinate.longitude != self.lastLocation.coordinate.longitude) {
        self.lastLocation = newLocation;
        [self.locationMgr stopUpdatingLocation];
    }
}

#pragma mark - Gestures

- (IBAction)handleTap: (UIGestureRecognizer *)recognizer
{
    // Get tap location within myImageView
    CGPoint location = [recognizer locationInView:self.myImageView];
    
    // myImageView is 1/2 size of original image so multiply by 2 to get original pixel values
    location.x *= 2;
    location.y *= 2;
    
    XYPair *aim = [[XYPair alloc] initWithX:location.x andY:location.y];
    
    LLPair *llpair = [self calculateAimLLWithAimXY:aim];
    
    // set the User's curent shot aim lat/long
    if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_AIM]]) {
        // set aim lat/long here
        currentShot.aimLatitude = [NSNumber numberWithDouble: llpair._lat];
        currentShot.aimLongitude = [NSNumber numberWithDouble: llpair._lon];
        
        // set User's stage to STAGE_AIM
        currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_END];
        
        // save the club selection and user's stage to the DB
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        NSError *error;
        
        if (![[appDelegate managedObjectContext] save: &error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        [self viewWillAppear: NO];
    } else {
        // tell the User to start the shot before aiming
        AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Error" message:@"You must start the shot before aiming."];
        [alert applyCustomAlertAppearance];
        __weak AHAlertView *weakAlert = alert;
        [alert addButtonWithTitle:@"OK" block:^{
            weakAlert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        }];
        [alert show];
    }
}

#pragma mark - Calculate Aim LL

- (LLPair*)calculateAimLLWithAimXY: (XYPair*)aimXY{
    
    // retrieve known points for this hole
    
    // TODO - these points are defined for hole 1 but should be found dynamically
    XYPair *teeXY0 = [[XYPair alloc] initWithX: [currentHole.firstRefX doubleValue] andY: [currentHole.firstRefY doubleValue]];
    LLPair *teeLLDeg = [[LLPair alloc] initWithLat: [currentHole.firstRefLat doubleValue] andLon: [currentHole.firstRefLong doubleValue]];
    LLPair *teeLLRad = [[LLPair alloc] initWithLLPair:[teeLLDeg deg2rad]];
    XYPair *teeLLRadFlat = [[XYPair alloc] initWithX:teeLLRad._lon andY:teeLLRad._lat];
    
    XYPair *centerXY0 = [[XYPair alloc] initWithX: [currentHole.thirdRefX doubleValue] andY: [currentHole.thirdRefY doubleValue]];
    LLPair *centerLLDeg = [[LLPair alloc] initWithLat: [currentHole.thirdRefLat doubleValue] andLon: [currentHole.thirdRefLong doubleValue]];
    LLPair *centerLLRad = [[LLPair alloc] initWithLLPair:[centerLLDeg deg2rad]];
    XYPair *centerLLRadFlat = [[XYPair alloc] initWithX:centerLLRad._lon andY:centerLLRad._lat];
    
    XYPair *aimXY0 = [[XYPair alloc] initWithXYPair:aimXY];
    LLPair *aimLLDeg = [[LLPair alloc] init];
    LLPair *aimLLRad = [[LLPair alloc] init];
    
    // Get height of image
    double height = myImageView.bounds.size.height * 2; // times 2 bc it is only half size
    
    // 1st coordinate conversion
    XYPair *teeXY1 = [self convertXY0toXY1WithXYPair:teeXY0 andHeight:height];
    XYPair *centerXY1 = [self convertXY0toXY1WithXYPair:centerXY0 andHeight:height];
    XYPair *aimXY1 = [self convertXY0toXY1WithXYPair:aimXY0 andHeight:height];
    
    // Calculate angle of rotation
    double rotation = [self angleOfRotationUsingTeeXY:teeXY1 andTeeLL:teeLLRad andCenterXY:centerXY1 andCenterLL:centerLLRad];
    
    // 2nd coordinate conversion
    XYPair *teeXY2 = [self convertXY1toXY2WithXYPair:teeXY1 andAngle:rotation];
    XYPair *centerXY2 = [self convertXY1toXY2WithXYPair:centerXY1 andAngle:rotation];
    XYPair *aimXY2 = [self convertXY1toXY2WithXYPair:aimXY1 andAngle:rotation];
    
    // Get Flat Earth Scaling Factors
    XYPair *scaleFactors = [[XYPair alloc] initWithXYPair:[self getFlatEarthScaleUsingTeeXY:teeXY2 andTeeLLRadFlat:teeLLRadFlat andCenterXY:centerXY2 andCenterLLRadFlat:centerLLRadFlat]];
    
    // Get Aim LL
    aimLLRad = [self getAimLLUsingAimXY: (XYPair*)aimXY2 andCenterXY: (XYPair*)centerXY2 andCenterLLRadFlat: (XYPair*)centerLLRadFlat andScaleFactors: (XYPair*) scaleFactors];
    aimLLDeg = [aimLLRad rad2deg];
    
    // calculate distances to display
    // from current location to aim point
    // from aim point to center of green
    // from current location to green
    
    // changing to return the lat/long degress
    //return aimLLRad;
    return aimLLDeg;
}


#pragma mark - Coordinate Conversions

- (XYPair*)convertXY0toXY1WithXYPair: (XYPair*)xy andHeight: (double)height{
    
    XYPair *results = [[XYPair alloc] init];
    results._x = xy._x;
    results._y = height - xy._y;
    return results;
}

- (XYPair*)convertXY1toXY2WithXYPair: (XYPair*)xy andAngle: (double)angle{
    
    XYPair *results = [[XYPair alloc] init];
    results._x = xy._x*cos(angle) - xy._y*sin(angle);
    results._y = xy._x*sin(angle) - xy._y*cos(angle);
    return results;
}


#pragma mark - Angle of Rotation

- (double)angleOfRotationUsingTeeXY: (XYPair*)teeXY1 andTeeLL: (LLPair*)teeLLRad andCenterXY: (XYPair*)centerXY1 andCenterLL: (LLPair*)centerLLRad{
    
    // Calculate sin and cos in XY
    double sinXY = [self sinPixelUsingPoint1: (XYPair*)teeXY1 andPoint2: (XYPair*)centerXY1];
    double cosXY = [self cosPixelUsingPoint1: (XYPair*)teeXY1 andPoint2: (XYPair*)centerXY1];
    
    // Calculate sin and cos in LL
    double sinLL = [self sinGPSUsingPoint1:teeLLRad andPoint2:centerLLRad];
    double cosLL = [self cosGPSUsingPoint1:teeLLRad andPoint2:centerLLRad];
    
    // Calculate sin and cos of angle of rotation
    double sinRot = [self sinLLminusXYUsingSinLL:sinLL andCosLL:cosLL andSinXY:sinXY andCosXY:cosXY];
    double cosRot = [self cosLLminusXYUsingSinLL:sinLL andCosLL:cosLL andSinXY:sinXY andCosXY:cosXY];
    
    // Calculate angle
    double sinRotation = asin(sinRot);
    double cosRotation = acos(cosRot);
	
    return sinRotation;
}


#pragma mark - Trig Angle Identities

- (double)sinPixelUsingPoint1: (XYPair*)point1 andPoint2: (XYPair*)point2{
    
    return [point1 distanceInY:point2] / [point1 distanceInXY:point2];
}

- (double)cosPixelUsingPoint1: (XYPair*)point1 andPoint2: (XYPair*)point2{
    
    return [point1 distanceInX:point2] / [point1 distanceInXY:point2];
}

- (double)sinGPSUsingPoint1: (LLPair*)point1 andPoint2: (LLPair*)point2{
    
    return [point1 distanceInLat:point2] / [point1 distanceInLatLon:point2];
}

- (double)cosGPSUsingPoint1: (LLPair*)point1 andPoint2: (LLPair*)point2{
    
    return [point1 distanceInLon:point2] / [point1 distanceInLatLon:point2];
}


#pragma mark - Trig Sum and Diff Formulas

- (double)sinLLplusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return sinLL*cosXY + cosLL*sinXY;
}

- (double)sinLLminusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return sinLL*cosXY - cosLL*sinXY;
}

- (double)cosLLplusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return cosLL*cosXY - sinLL*sinXY;
}

- (double)cosLLminusXYUsingSinLL: (double)sinLL andCosLL: (double)cosLL andSinXY: (double)sinXY andCosXY: (double)cosXY{
    
    return cosLL*cosXY + sinLL*sinXY;
}


#pragma mark - Scaling

- (XYPair*)getFlatEarthScaleUsingTeeXY: (XYPair*)teeXY2 andTeeLLRadFlat: (XYPair*)teeLLRadFlat andCenterXY: (XYPair*)centerXY2 andCenterLLRadFlat: (XYPair*)centerLLRadFlat{
    
    double scaleX = [teeLLRadFlat distanceInX:centerLLRadFlat] / [teeXY2 distanceInX:centerXY2];
    double scaleY = [teeLLRadFlat distanceInY:centerLLRadFlat] / [teeXY2 distanceInY:centerXY2];
    
    XYPair *results = [[XYPair alloc] init];
    results._x = scaleX;
    results._y = scaleY;
    
    return results;
}


#pragma mark - Get Aim LL
- (LLPair*)getAimLLUsingAimXY: (XYPair*)aimXY2 andCenterXY: (XYPair*)centerXY2 andCenterLLRadFlat: (XYPair*)centerLLRadFlat andScaleFactors: (XYPair*) scaleFactors{
    
    double aimLon = centerLLRadFlat._x + (aimXY2._x - centerXY2._x) * scaleFactors._x;
    double aimLat = centerLLRadFlat._y + (aimXY2._y - centerXY2._y) * scaleFactors._y;
    
    LLPair *results = [[LLPair alloc] init];
    results._lat = aimLat;
    results._lon = aimLon;
    
    return results;
}


@end
