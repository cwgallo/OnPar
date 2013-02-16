//
//  Play_VC.m
//  OnPar2
//
//  Created by Chad Galloway on 2/16/13.
//  Copyright (c) 2013 Chad Galloway. All rights reserved.
//

#import "Play_VC.h"
#import "Config.h"

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

- (IBAction)selectGolfer:(id)sender
{
    
    if ([ZFloatingManager shouldFloatingWithIdentifierAppear:@"Golfers"])
    {
            
            ZAction *cancel = [ZAction actionWithTitle:@"Cancel" target:self action:nil object:nil];
            
            // GET ARRAY OF GOLFERS
            NSMutableArray *golfers = [[NSMutableArray alloc] init];
        
            // load golfers that are in database
            id appDelegate = (id)[[UIApplication sharedApplication] delegate];
        
            NSError *error;
        
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName: @"User"
                                                  inManagedObjectContext: [appDelegate managedObjectContext]];
            [fetchRequest setEntity: entity];
            NSArray *fetchedObjects = [[appDelegate managedObjectContext] executeFetchRequest: fetchRequest error: &error];
            for (User *u in fetchedObjects)
            {
                [golfers addObject: u];
            }

        
            ZAction *option1, *option2, *option3, *option4;
            ZActionSheet *sheet;
            NSMutableArray *options = [[NSMutableArray alloc] init];
        
            // DETERMINE HOW TO DISPLAY THEM
            switch (golfers.count)
            {
                case 4:
                    option4 = [ZAction actionWithTitle:@"Orange"/*golfers name*/ target:self action:@selector(colorAction:) object:[UIColor orangeColor]];
                    [options addObject:option4];
                case 3:
                    option3 = [ZAction actionWithTitle:@"Green"/*golfers name*/ target:self action:@selector(colorAction:) object:[UIColor greenColor]];
                    [options addObject:option3];
                case 2:
                    option2 = [ZAction actionWithTitle:@"Red"/*golfers name*/ target:self action:@selector(colorAction:) object:[UIColor redColor]];
                    [options addObject:option2];
                case 1:
                    option1 = [ZAction actionWithTitle:@"Blue"/*golfers name*/ target:self action:@selector(colorAction:) object:[UIColor blueColor]];
                    [options addObject:option1];
                    
                // Reverse array so options are in correct order
                   NSArray* reversedArray = [[options reverseObjectEnumerator] allObjects];
                    
                         sheet = [[ZActionSheet alloc] initWithTitle:@"Select A Golfer" cancelAction:cancel destructiveAction:nil otherActions:reversedArray];
                        [sheet setTitle:@"Select A Golfer"];
                        [sheet setCancelAction:cancel];
                        sheet.identifier = @"Golfers";
                        [sheet showFromBarButtonItem:sender animated:YES];
            }
    }
}

- (void)colorAction:(id)object
{
	NSParameterAssert([object isKindOfClass:[UIColor class]]);
	self.view.backgroundColor = object;
}

- (void)changeGolfer:(id)object
{
    // Make golfer change here
}

@end
