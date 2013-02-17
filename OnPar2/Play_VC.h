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

@interface Play_VC : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *myImageView;


- (IBAction)skipHole:(id)sender;
- (IBAction)finishHole:(id)sender;
- (IBAction)startShot:(id)sender;
- (IBAction)endShot:(id)sender;

@end
