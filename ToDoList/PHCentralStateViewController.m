//
//  PHCentralStateViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 4/24/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "PHCentralStateViewController.h"

@interface PHCentralStateViewController ()

@property UIBarButtonItem * activityIndicatorButton;

@end

@implementation PHCentralStateViewController

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
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle : UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    self.activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView : activityIndicator];
    self.navigationItem.rightBarButtonItem = self.activityIndicatorButton;
    self.navigationItem.title = @"Searching...";
    [self.navigationController setToolbarHidden : YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
