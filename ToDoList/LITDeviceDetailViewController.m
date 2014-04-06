//
//  XYZAddToDoItemViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDeviceDetailViewController.h"

@interface LITDeviceDetailViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation LITDeviceDetailViewController

- (IBAction)alertStickNFind:(id)sender
{
    [ self.bluetoothManager alertStickNFind ];
    NSLog( @"Alert button clicked" );
    
}

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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.doneButton) return;
    if (self.textField.text.length > 0) {
        self.toDoItem = [[LITDevice alloc] init];
        //self.toDoItem.itemName = self.textField.text;
        //self.toDoItem.completed = NO;
    }
}

@end
