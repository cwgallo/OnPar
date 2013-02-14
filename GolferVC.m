//
//  GolferVC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "GolferVC.h"

@implementation GolferVC{
    NSMutableArray *golfers;
}

@synthesize golferTableView;

- (void)viewWillAppear:(BOOL)animated{
    
    // retrieve golfers
    NSString *golfer1 = @"Chad";
    NSString *golfer2 = @"Kevin";
    
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
    /*
     if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier]];
    }
     */
    

    NSString *g = [golfers objectAtIndex:indexPath.row];

    cell.textLabel.text = g;
//    cell.detailTextLabel.text = @"123456789";
    return cell;
}

#pragma  mark - Custom Header methods

/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0.0f,-50.0f, tableView.contentSize.width,70.0f)];
    myHeaderView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.text = @"Golfers";
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [myHeaderView addSubview:label];
    
    return myHeaderView;
}
*/


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
    
    // create the button object
    UIButton * headerBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    headerBtn.backgroundColor = [UIColor clearColor];
    headerBtn.opaque = NO;
    headerBtn.frame = CGRectMake(10.0, 0.0, 100.0, 30.0);
    [headerBtn setTitle:@"<Put here whatever you want to display>" forState:UIControlEventTouchUpInside];
    [headerBtn addTarget:self action:@selector(ActionEventForButton:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:headerBtn];
    
    return customView;
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
    label.text = @"Maximum of 4";
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [myFooterView addSubview:label];
    
    return myFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0;
}

@end
