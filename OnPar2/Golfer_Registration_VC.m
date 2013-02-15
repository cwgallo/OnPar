//
//  RegistrationVC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Golfer_Registration_VC.h"
#import "GolferVC.h"

@interface Golfer_Registration_VC ()

@end

@implementation Golfer_Registration_VC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    // do stuff with info here
    
    [self goBackTwoViews];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)goBackTwoViews
{
    NSLog(@"Here");
    int count = [[self.navigationController viewControllers] count];
    NSLog(@"Count is %i", count);
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count-2] animated:YES];
}
@end
