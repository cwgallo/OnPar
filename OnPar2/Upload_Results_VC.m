//
//  Upload_Results_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Upload_Results_VC.h"

@interface Upload_Results ()

@end

@implementation Upload_Results

@synthesize golfer1Label, golfer1Switch;
@synthesize golfer2Label, golfer2Switch;
@synthesize golfer3Label, golfer3Switch;
@synthesize golfer4Label, golfer4Switch;
@synthesize navBar;

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
    
    // TODO - get users
    NSMutableArray *golfers = [[NSMutableArray alloc] initWithObjects:@"chad45@gmail.com", @"krb224@msstate.edu", @"josh@josh.com", nil];
    
    // Use info to change labels
    switch (golfers.count)
    {
        case 4:
            golfer4Switch.onTintColor = [UIColor blackColor];
            golfer4Switch.onText = @"YES";
            golfer4Switch.offText = @"NO";
            golfer4Switch.onTintColor = [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1];
            golfer4Switch.on = YES;
            //[golfer4Switch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            golfer4Switch.hidden = NO;
            golfer4Label.text = [golfers objectAtIndex: 3];
            golfer4Label.hidden = NO;
        
        case 3:
            golfer3Switch.onTintColor = [UIColor blackColor];
            golfer3Switch.onText = @"YES";
            golfer3Switch.offText = @"NO";
            golfer3Switch.onTintColor = [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1];
            golfer3Switch.on = YES;
            //[golfer3Switch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            golfer3Switch.hidden = NO;
            golfer3Label.text = [golfers objectAtIndex: 2];
            golfer3Label.hidden = NO;
            
        case 2:
            golfer2Switch.onTintColor = [UIColor blackColor];
            golfer2Switch.onText = @"YES";
            golfer2Switch.offText = @"NO";
            golfer2Switch.onTintColor = [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1];
            golfer2Switch.on = YES;
            //[golfer2Switch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];

            golfer2Switch.hidden = NO;
            golfer2Label.text = [golfers objectAtIndex: 1];
            golfer2Label.hidden = NO;
            
        case 1:
            golfer1Switch.onTintColor = [UIColor blackColor];
            golfer1Switch.onText = @"YES";
            golfer1Switch.offText = @"NO";
            golfer1Switch.onTintColor = [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1];
            golfer1Switch.on = YES;
            //[golfer1Switch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            golfer1Switch.hidden = NO;
            golfer1Label.text = [golfers objectAtIndex: 0];
            golfer1Label.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadResults:(id)sender {
}
@end
