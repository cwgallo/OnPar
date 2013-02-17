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
}

@synthesize myImageView, myScrollView, navBar;
@synthesize startButton, endButton, finishButton, skipButton;

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
    // if some exists, do not create new rounds, just use the ones already in the DB
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
            NSLog(@"The current golfer is: %@", u.name);
            currentGolfer = u;
        }
        
        if ([rounds count] == 0) {
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
                [rounds setObject: r forKey: u.userID];
            }
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
    // set the picture for the golfer
    [self setHoleImageForUser: currentGolfer];
    
    // check to see what hole the golfer is on
    // if 18, hide the skip button
    if ([currentGolfer.stageInfo.holeNumber isEqualToNumber: [NSNumber numberWithInt: 18]]) {
        skipButton.hidden = YES;
    } else {
        skipButton.hidden = NO;
    }
    
    
    if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_START]]) {
        NSLog(@"Stage START for golfer: %@", currentGolfer.name);
        // hide end button and show start
        endButton.hidden = YES;
        startButton.hidden = NO;
        
        // should still show finish unless they are in the middle of a shot
        finishButton.hidden = NO;
    } else if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_CLUB_SELECT]]) {
        NSLog(@"Stage CLUB_SELECT for golfer: %@", currentGolfer.name);
        // there won't be any real change here since it's just another alert
        // hide end button and start
        endButton.hidden = YES;
        startButton.hidden = YES;
        
        // should still show finish unless they are in the middle of a shot
        finishButton.hidden = NO;
        
        // manually call club select function
        [self selectClub];
        
    } else if ([currentGolfer.stageInfo.stage isEqualToNumber: [NSNumber numberWithInt: STAGE_AIM]]) {
        NSLog(@"Stage AIM for golfer: %@", currentGolfer.name);
        // hide end button and start button
        endButton.hidden = YES;
        startButton.hidden = YES;
        
        // hide the finish button
        // can't finish the hole with half a shot
        finishButton.hidden = YES;
    } else {
        NSLog(@"Stage END for golfer: %@", currentGolfer.name);
        // stage STAGE_END
        // show end button and hide start button
        endButton.hidden = NO;
        startButton.hidden = YES;
        
        // still hide finish
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
    
    Round *r = [rounds objectForKey: currentGolfer.userID];
    
    // create the first hole for every golfer
    Hole *h = [NSEntityDescription
               insertNewObjectForEntityForName: @"Hole"
               inManagedObjectContext: [appDelegate managedObjectContext]];
    
    h.holeNumber = currentGolfer.stageInfo.holeNumber;
    
    // set relationships
    h.round = r;
    [r addHolesObject: h];
    
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
        int holeNumber = [currentGolfer.stageInfo.holeNumber intValue];
        currentGolfer.stageInfo.holeNumber = [NSNumber numberWithInt: holeNumber + 1];
        
        // create a new hole to add to the hole object with the updated hole number
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        Round *r = [rounds objectForKey: currentGolfer.userID];
        
        // create the first hole for every golfer
        Hole *h = [NSEntityDescription
                   insertNewObjectForEntityForName: @"Hole"
                   inManagedObjectContext: [appDelegate managedObjectContext]];
        
        h.holeNumber = currentGolfer.stageInfo.holeNumber;
        
        // set relationships
        h.round = r;
        [r addHolesObject: h];
        
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
    // alert to tell them to press OK at the location of the ball
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:@"Start Shot" message:@"Press OK when at the ball's location for the start of the shot."];
    [alert applyCustomAlertAppearance];
    __weak AHAlertView *weakAlert = alert;
    [alert addButtonWithTitle:@"OK" block:^{
        Round *r = [rounds objectForKey: currentGolfer.userID];
        
        id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        Shot *s = [NSEntityDescription
                   insertNewObjectForEntityForName: @"Shot"
                   inManagedObjectContext: [appDelegate managedObjectContext]];
        
        s.startLatitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.latitude];
        s.startLongitude = [NSNumber numberWithDouble: self.lastLocation.coordinate.longitude];
        
        s.shotNumber = currentGolfer.stageInfo.shotNumber;
        
        for (Hole *h in r.holes) {
            if ([h.holeNumber isEqualToNumber: currentGolfer.stageInfo.holeNumber]) {
                s.hole = h;
                [h addShotsObject: s];
            }
        }
        
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
    // Check to see if all users have finished
    
    // Display alert if not all finished
    
    // Go to upload page
    [self performSegueWithIdentifier: @"play2upload" sender:self];
}

- (void)discardResults
{
    // TODO - Display alert
    
    // TODO - Delete everything
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    MainViewController *mvc = [[MainViewController alloc] init];
    [mvc deleteEverything:appDelegate];
    
    // Return to main page
    [[self navigationController] popToRootViewControllerAnimated:YES];
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
    NSLog(@"Change golfer to %@", object);
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
    
    NSLog(@"Loading file: %@", filename);
    
    UIImage *image = [UIImage imageNamed:filename];
    
    [myImageView setImage: image];
}

- (void) selectClub
{
    Round *r = [rounds objectForKey: currentGolfer.userID];
    
    for (Hole *h in r.holes) {
        if ([h.holeNumber isEqualToNumber: currentGolfer.stageInfo.holeNumber]) {
            for (Shot *s in h.shots) {
                if ([s.shotNumber isEqualToNumber: currentGolfer.stageInfo.shotNumber]) {
                    // set club here
                    s.club = [NSNumber numberWithInt: DRIVER];
                    
                    // set User's stage to STAGE_AIM
                    currentGolfer.stageInfo.stage = [NSNumber numberWithInt: STAGE_AIM];
                    
                    // save the club selection and user's stage to the DB
                    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
                    
                    NSError *error;
                    
                    if (![[appDelegate managedObjectContext] save: &error]) {
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                    
                    break;
                }
            }
            break;
        }
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
        NSLog(@"New location: %f, %f",
              self.lastLocation.coordinate.latitude,
              self.lastLocation.coordinate.longitude);
        [self.locationMgr stopUpdatingLocation];
    }
}

#pragma mark - Gestures

- (IBAction)handleTap: (UIGestureRecognizer *)recognizer
{
    // Get tap location within myImageView
    CGPoint location = [recognizer locationInView:self.myImageView];
    NSLog(@"ImageView location tap x : %f, y : %f", location.x, location.y);
    
    // myImageView is 1/2 size of original image so multiply by 2 to get original pixel values
    location.x *= 2;
    location.y *= 2;
    
    XYPair *aim = [[XYPair alloc] initWithX:location.x andY:location.y];
    
    [self calculateAimLLWithAimXY:aim];
}

#pragma mark - Calculate Aim LL

- (LLPair*)calculateAimLLWithAimXY: (XYPair*)aimXY{
    
    // retrieve known points for this hole
    
    // TODO - these points are defined for hole 1 but should be found dynamically
    XYPair *teeXY0 = [[XYPair alloc] initWithX:212 andY:696];
    LLPair *teeLLDeg = [[LLPair alloc] initWithLat:33.478658 andLon:-88.733421];
    LLPair *teeLLRad = [[LLPair alloc] initWithLLPair:[teeLLDeg deg2rad]];
    XYPair *teeLLRadFlat = [[XYPair alloc] initWithX:teeLLRad._lon andY:teeLLRad._lat];
    NSLog(@"FlatTee is %@", teeLLRadFlat);
    
    XYPair *centerXY0 = [[XYPair alloc] initWithX:193 andY:127];
    LLPair *centerLLDeg = [[LLPair alloc] initWithLat:33.48124 andLon:-88.734538];
    LLPair *centerLLRad = [[LLPair alloc] initWithLLPair:[centerLLDeg deg2rad]];
    XYPair *centerLLRadFlat = [[XYPair alloc] initWithX:centerLLRad._lon andY:centerLLRad._lat];
    NSLog(@"FlatCenter is %@", centerLLRadFlat);
    
    XYPair *aimXY0 = [[XYPair alloc] initWithXYPair:aimXY];
    LLPair *aimLLDeg = [[LLPair alloc] init];
    LLPair *aimLLRad = [[LLPair alloc] init];
    
    // Get height of image
    double height = myImageView.bounds.size.height * 2; // times 2 bc it is only half size
    
    NSLog(@"Height of image is: %f", height);
    
    // 1st coordinate conversion
    XYPair *teeXY1 = [self convertXY0toXY1WithXYPair:teeXY0 andHeight:height];
    XYPair *centerXY1 = [self convertXY0toXY1WithXYPair:centerXY0 andHeight:height];
    XYPair *aimXY1 = [self convertXY0toXY1WithXYPair:aimXY0 andHeight:height];
    
    // Calculate angle of rotation
    double rotation = [self angleOfRotationUsingTeeXY:teeXY1 andTeeLL:teeLLRad andCenterXY:centerXY1 andCenterLL:centerLLRad];
    
    // 2nd coordinate conversion
    XYPair *teeXY2 = [self convertXY1toXY2WithXYPair:teeXY1 andAngle:rotation];
    NSLog(@"TeeXY2 is %@", teeXY2);
    XYPair *centerXY2 = [self convertXY1toXY2WithXYPair:centerXY1 andAngle:rotation];
    NSLog(@"CenterXY2 is %@", centerXY2);
    XYPair *aimXY2 = [self convertXY1toXY2WithXYPair:aimXY1 andAngle:rotation];
    NSLog(@"AimXY2 is %@", aimXY2);
    
    // Get Flat Earth Scaling Factors
    XYPair *scaleFactors = [[XYPair alloc] initWithXYPair:[self getFlatEarthScaleUsingTeeXY:teeXY2 andTeeLLRadFlat:teeLLRadFlat andCenterXY:centerXY2 andCenterLLRadFlat:centerLLRadFlat]];
    
    NSLog(@"Scaling factors are %@", scaleFactors);
    
    // Get Aim LL
    aimLLRad = [self getAimLLUsingAimXY: (XYPair*)aimXY2 andCenterXY: (XYPair*)centerXY2 andCenterLLRadFlat: (XYPair*)centerLLRadFlat andScaleFactors: (XYPair*) scaleFactors];
    aimLLDeg = [aimLLRad rad2deg];
    
    NSLog(@"AimLLRad is %@", aimLLRad);
    NSLog(@"AimLLDeg is %@", aimLLDeg);
    
    // calculate distances to display
    // from current location to aim point
    // from aim point to center of green
    // from current location to green
    
    return aimLLRad;
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
    
    // TESTING
    NSLog(@"Angle of rotation derived... ");
    NSLog(@"From SIN");
    NSLog(@"\tDegrees: %f", sinRotation*180.0/M_PI);
    NSLog(@"\tRadians: %f", sinRotation);
    NSLog(@"From COS");
    NSLog(@"\tDegrees: %f", cosRotation*180.0/M_PI);
    NSLog(@"\tRadians: %f", cosRotation);
	
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
    
    NSLog(@"SFs are %@", results);
    
    return results;
}


#pragma mark - Get Aim LL
- (LLPair*)getAimLLUsingAimXY: (XYPair*)aimXY2 andCenterXY: (XYPair*)centerXY2 andCenterLLRadFlat: (XYPair*)centerLLRadFlat andScaleFactors: (XYPair*) scaleFactors{
    
    double aimLon = centerLLRadFlat._x + (aimXY2._x - centerXY2._x) * scaleFactors._x;
    NSLog(@"Aim longitude is %.8f", aimLon);
    double aimLat = centerLLRadFlat._y + (aimXY2._y - centerXY2._y) * scaleFactors._y;
    NSLog(@"Aim latitude is %.8f", aimLat);
    
    LLPair *results = [[LLPair alloc] init];
    results._lat = aimLat;
    results._lon = aimLon;
    return results;
}


@end
