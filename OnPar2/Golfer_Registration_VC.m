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

@synthesize firstNameTextField, lastNameTextField;
@synthesize emailAddressTextField;
@synthesize membershipNumberTextField;
@synthesize nicknameTextField;

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
    
    // TODO - Find way to dismiss keyboard
    
    // make sure the User is connected to the club house's WiFi
    Reachability *reach = [Reachability reachabilityWithHostname: BASE_URL];
    
    if ([reach isReachable]) {
    
        // display progress spinner
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        hud.labelText = @"Loading...";
        hud.detailsLabelText = @"Registering";
        
        // make sure required fields are set
        if (lastNameTextField.text.length != 0
            && firstNameTextField.text.length != 0
            && emailAddressTextField.text.length != 0) {
        
            // format the name string correctly
            NSString *name = [NSString stringWithFormat: @"%@%@%@", lastNameTextField.text, @", ", firstNameTextField.text];
        
            // create NSDictionary representing the User to send to the API
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
            [params setObject: self.membershipNumberTextField.text.length != 0 ? self.membershipNumberTextField.text : [NSNull null] forKey: @"memberID"];
            [params setObject: self.nicknameTextField.text.length != 0 ? self.nicknameTextField.text : [NSNull null] forKey: @"nickname"];
            [params setObject: name ? name : [NSNull null] forKey: @"name"];
            [params setObject: self.emailAddressTextField.text ? self.emailAddressTextField.text : [NSNull null] forKey: @"email"];
        
            NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys: params, @"user" , nil];

            // send the request
            [[LRResty authenticatedClientWithUsername: API_USERNAME
                                             password: API_PASSWORD
              ]
             post: [NSString stringWithFormat: @"%@%@", BASE_URL, @"users/"]
             payload: [[SBJsonWriter alloc] stringWithObject: user]
             headers: [NSDictionary dictionaryWithObject: @"application/json"
                                              forKey: @"Content-Type"
                       ]
             withBlock: ^(LRRestyResponse *r) {
                 // once the request finished, hide the spinner thing
                 [MBProgressHUD hideHUDForView: self.view animated: YES];
                 
                 if (r.status == 201) {
                     // Success
                     // Dismiss View and add golfer
                     // decode the json
                     SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                     NSDictionary *jsonObject = [jsonParser objectWithData: r.responseData];
                     NSDictionary *user = [jsonObject valueForKey: @"user"];
                     
                     // obtain the appDelegate to get the managedObjectContext
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
                     
                     // set up the DB
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
                     
                     [self dismissViewControllerAnimated:YES completion:nil];
                 } else {
                     if (r.status >= 500) {
                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                                           message:@"The server is experiencing problems. Please try again later."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                         [message show];
                     } else if (r.status == 400) {
                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"User Error"
                                                                           message:@"Please insert all required information."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                         [message show];
                     } else if (r.status == 412) {
                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"User Error"
                                                                           message:@"MemberID and email already taken."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                         [message show];
                     } else if (r.status == 406) {
                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"User Error"
                                                                           message:@"MemberID already taken."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                         [message show];
                     } else if (r.status == 409) {
                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"User Error"
                                                                           message:@"Email already taken."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                         [message show];
                     } else {
                         // handle this error better
                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Unknown Error"
                                                                           message:@"Something went terribly wrong."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                         [message show];
                     }
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

@end
