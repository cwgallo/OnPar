//
//  GolferVC.h
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GolferVC : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *golferTableView;

@end
