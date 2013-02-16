//
//  AddGolferVC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/14/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Golfer_Add_VC.h"

@interface Golfer_Add_VC ()

@end

@implementation Golfer_Add_VC

@synthesize emailAddressTextField;

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

- (void)viewWillAppear:(BOOL)animated
{
    
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
    // make sure the User is connected to the club house's WiFi
    Reachability *reach = [Reachability reachabilityWithHostname: BASE_URL];
    
    if (1){//[reach isReachable]) {
        
        // display progress spinner
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        hud.labelText = @"Loading...";
        
        // make sure required fields are set
        if (emailAddressTextField.text.length != 0) {
            
            // send the request
            [[LRResty authenticatedClientWithUsername: API_USERNAME
                                             password: API_PASSWORD
              ]
             get: [NSString stringWithFormat: @"%@%@%@", BASE_URL, @"users/", emailAddressTextField.text]
             parameters: nil
             headers: [NSDictionary dictionaryWithObject: @"application/json"
                                                  forKey: @"Content-Type"
                       ]
             withBlock: ^(LRRestyResponse *r) {
                 // once the request finished, hide the spinner thing
                 [MBProgressHUD hideHUDForView: self.view animated: YES];

                 if (r.status == 200) {
                     // Success
                     // Dismiss View and add golfer
                     // decode the json
                     SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                     NSDictionary *jsonObject = [jsonParser objectWithData: r.responseData];
                     NSDictionary *user = [jsonObject valueForKey: @"user"];
                     
                     // obtain the app delegate
                     id appDelegate = (id)[[UIApplication sharedApplication] delegate];
                     
                     // create an error object
                     NSError *error;
                     
                     NSMutableArray *golfers = [[NSMutableArray alloc] init];
                     
                     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                     NSEntityDescription *entity = [NSEntityDescription entityForName: @"User"
                                                               inManagedObjectContext: [appDelegate managedObjectContext]];
                     [fetchRequest setEntity: entity];
                     NSArray *fetchedObjects = [[appDelegate managedObjectContext] executeFetchRequest: fetchRequest error: &error];
                     for (User *u in fetchedObjects) {
                         [golfers addObject: u];
                     }
                     
                     if ([golfers count] == 4) {
                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                           message:@"No more golfers can be added."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                         [message show];
                     } else {
                         BOOL exists = NO;
                         for (User *uCheck in golfers) {
                             if (uCheck.userID == [[NSNumber alloc] initWithInt: [[user valueForKey: @"id"] intValue]]) {
                                 exists = YES;
                                 UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                   message:@"This golfer is already playing."
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                 [message show];
                                 break;
                             }
                         }
                         
                         if (!exists) {
                             // create a new User
                             User *u = [NSEntityDescription
                                        insertNewObjectForEntityForName: @"User"
                                        inManagedObjectContext: [appDelegate managedObjectContext]];
                             
                             // required fields
                             u.userID =    [[NSNumber alloc] initWithInt: [[user valueForKey: @"id"] intValue]];
                             u.name =      [user valueForKey: @"name"];
                             u.email =     [user valueForKey: @"email"];
                             
                             // optional fields
                             if ([user valueForKey: @"memberID"] != [NSNull null]) {
                                 u.memberID =  [user valueForKey: @"memberID"];
                             }
                             if ([user valueForKey: @"nickname"] != [NSNull null]) {
                                 u.nickname =  [user valueForKey: @"nickname"];
                             }
                             
                             // set the tee
                             // TODO - change
                             u.tee = @3;
                             u.order = [NSNumber numberWithInt: [golfers count] + 1];
                             
                             if (![[appDelegate managedObjectContext] save: &error]) {
                                 NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                             }
                         }
                         
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }
                 } else if (r.status == 204) {
                     UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"User Error"
                                                                       message:@"This User email does not exist."
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:@"Register", nil];
                     [message show];
                 }
             }
             ];
        } else {
            // once the request finished, hide the spinner thing
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Please fill out all required fields."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }
    } else {
        // once the request finished, hide the spinner thing
        [MBProgressHUD hideHUDForView: self.view animated: YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                          message:@"You must be connected to the Wi-Fi at the club house for this action."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Register"])
    {
        NSLog(@"Register was selected.");
        // Find out how to segue to registration page
        // and dynamically fill in the email field
        
    }
}

@end
