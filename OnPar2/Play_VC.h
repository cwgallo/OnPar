//
//  Play_VC.h
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import <CoreLocation/CoreLocation.h>

@interface Play_VC : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;


#pragma mark - Buttons

@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet UIButton *finishButton;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *endButton;

#pragma mark - core location

@property (nonatomic, retain) CLLocationManager *locationMgr;
@property (nonatomic, retain) CLLocation *lastLocation;


#pragma mark - Actions

- (IBAction)selectGolfer:(id)sender;
- (IBAction)endGame:(id)sender;
- (IBAction)skipHole:(id)sender;
- (IBAction)finishHole:(id)sender;
- (IBAction)startShot:(id)sender;
- (IBAction)endShot:(id)sender;

#pragma mark - Club Select

/*@property (strong, nonatomic) IBOutlet UITableView *clubSelectionTable;
@property (strong, nonatomic) IBOutlet UISegmentedControl *clubTypeSegment;
@property (strong, nonatomic) IBOutlet UIPickerView *clubPicker;

- (IBAction)clubTypeChange:(id)sender;
- (IBAction)clubPickChange:(id)sender;*/

#pragma mark - Gesture
- (IBAction)handleTap: (UIGestureRecognizer *)recognizer;

@end
