//
//  Golfer_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Golfer_VC.h"

@implementation GolferVC{
    NSMutableArray *golfers;
}

@synthesize golferTableView;
@synthesize holeStepper;
@synthesize addButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self showNavBar];
    [self stepperInitialization];
    
    self.holeNumberLabel.text = [NSString stringWithFormat:@"%.f", holeStepper.value];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"Golfers_VC appeared");
    
    [self showNavBar];
    
    golfers = [[NSMutableArray alloc] init];
    
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
    
    [golferTableView reloadData];
    
    if (golfers.count == 0)
    {
        // disable start button
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        // enable start button
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    if (golfers.count == 4)
    {
        // hide add button
        addButton.hidden = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"Golfers_VC disappeared");
}

#pragma mark - TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 /*
    // Number of rows is the number of time zones in the region for the specified section.
    Golfer *golfer = [golfers objectAtIndex:section];
    return [region.timeZoneWrappers count];
   */
   
    NSLog(@"golfer count is %i", [golfers count]);
    return [golfers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"golfer";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    User *u = [golfers objectAtIndex: indexPath.row];
    
    // if they have a nickname, display the username
    // else display the full name
    // for the details, display what tee they are using.
    
    if (u.nickname) {
        cell.textLabel.text = u.nickname;
    } else {
        cell.textLabel.text = u.name;
    }
    
    if (u.tee == [NSNumber numberWithInt: AGGIES]) {
        cell.detailTextLabel.text = @"Aggies";
    } else if (u.tee == [NSNumber numberWithInt: COWBELLS]) {
        cell.detailTextLabel.text = @"Cowbells";
    } else if (u.tee == [NSNumber numberWithInt: MAROONS]) {
        cell.detailTextLabel.text = @"Maroons";
    } else {
        cell.detailTextLabel.text = @"Bulldogs";
    }
    
    return cell;
}

#pragma  mark - Custom Header methods


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0.0f,-50.0f, tableView.contentSize.width,70.0f)];
    myHeaderView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.text = @"Golfers:";
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [myHeaderView addSubview:label];
    
    return myHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

#pragma mark - Custom Footer methods

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* myFooterView = [[UIView alloc] initWithFrame: CGRectMake(0.0f,-50.0f, tableView.contentSize.height,70.0f )];
    myFooterView.backgroundColor = [UIColor clearColor];
    [tableView addSubview:myFooterView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width-22, 18)];
    label.textAlignment = NSTextAlignmentCenter;
    
    // change footer text
    if (golfers.count == 0)
        label.text = @"Add Some Golfers!";
    else
        label.text = @"Maximum of 4";
        
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [myFooterView addSubview:label];
    
    return myFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0;
}

- (IBAction)startRound:(id)sender {
    
    // create round
    
    // transition
    [self performSegueWithIdentifier:@"settings2play" sender:self];
    
}

- (IBAction)valueChanged:(id)sender {
    double stepperValue = holeStepper.value;
    self.holeNumberLabel.text = [NSString stringWithFormat:@"%.f", stepperValue];
}

- (void)showNavBar
{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)stepperInitialization
{
    // Hole Stepper Setup
    self.holeStepper.minimumValue = 1;
    self.holeStepper.maximumValue = 18;
    self.holeStepper.stepValue = 1;
    self.holeStepper.wraps = YES;
    self.holeStepper.autorepeat = YES;
    self.holeStepper.continuous = YES;
}

@end
