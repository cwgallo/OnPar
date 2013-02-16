//
//  Play_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Play_VC.h"

@interface Play_VC ()

@end

@implementation Play_VC

@synthesize myImageView, myScrollView;

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
    
    myScrollView.contentSize = myImageView.bounds.size;
    [myScrollView setDelegate:self];
    [myScrollView setScrollEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)skipHole:(id)sender {
}

- (IBAction)finishHole:(id)sender {
}

- (IBAction)startShot:(id)sender {
}

- (IBAction)endShot:(id)sender {
}
@end
