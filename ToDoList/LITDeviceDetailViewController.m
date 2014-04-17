//
//  XYZAddToDoItemViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDeviceDetailViewController.h"
#import "LITDeviceReviewViewController.h"

#define SEGUE_ID_DEVICE_DETAIL_TO_REVIEW @"segue-device-detail-to-review"

@interface LITDeviceDetailViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *deviceImage;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *manufacturer;

@end

@implementation LITDeviceDetailViewController


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

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = [self.currentDevice name];
    self.name.text = [self.currentDevice name];
    self.deviceImage.image = [self.currentDevice smallIcon];
    self.manufacturer.text = [self.currentDevice manufacturer];
    
    [self.navigationController setToolbarHidden : YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle : @""
                                                                             style : UIBarButtonItemStylePlain
                                                                            target : nil
                                                                            action : nil];
    
    if ( [[segue identifier] isEqualToString : SEGUE_ID_DEVICE_DETAIL_TO_REVIEW] ) {
        LITDeviceReviewViewController *targetVC = (LITDeviceReviewViewController *) segue.destinationViewController;
        targetVC.currentDevice = self.currentDevice;
    }

}

@end
