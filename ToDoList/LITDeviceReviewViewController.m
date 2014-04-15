//
//  LITDeviceReviewViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 4/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDeviceReviewViewController.h"
#define REVIEW_PLACEHOLDER_TEXT @"What did you like or dislike?\nWould you recommend this device?" 

@interface LITDeviceReviewViewController ()

@property IBOutlet UIButton       *rateButton1;
@property IBOutlet UIButton       *rateButton2;
@property IBOutlet UIButton       *rateButton3;
@property IBOutlet UIButton       *rateButton4;
@property IBOutlet UIButton       *rateButton5;

@property IBOutlet UITextView     *reviewTextView;
@property IBOutlet UITextField    *titleTextField;

@end

@implementation LITDeviceReviewViewController

- (id)initWithNibName : (NSString *) nibNameOrNil
               bundle : (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName : nibNameOrNil
                           bundle : nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mRateButtons = @[self.rateButton1,
                     self.rateButton2,
                     self.rateButton3,
                     self.rateButton4,
                     self.rateButton5];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden : YES];
    [self showPlaceholder : REVIEW_PLACEHOLDER_TEXT
               inTextView : self.reviewTextView];
}

- (IBAction) rateButtonTapped : (id) sender
{
    int rate = [[sender restorationIdentifier] intValue];
    UIImage* goldStarImage = [UIImage imageNamed : @"star-gold-64"];
    
    for ( int i = 0; i < rate ; i++ ) {
        UIButton *button = [mRateButtons objectAtIndex : i];
        [button setImage : goldStarImage
                forState : UIControlStateNormal];
    }
    
    UIImage* grayStarImage = [UIImage imageNamed : @"star-gray-64"];
    
    for ( int i = rate; i < 5 ; i++ ) {
        UIButton *button = [mRateButtons objectAtIndex : i];
        [button setImage : grayStarImage
                forState : UIControlStateNormal];
    }
}

- (void)touchesBegan : (NSSet *) touches
           withEvent : (UIEvent *) event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ( [self.reviewTextView isFirstResponder]
        && [touch view] != self.reviewTextView ) {
        
        [self.reviewTextView resignFirstResponder];
        
    } else if ( [self.titleTextField isFirstResponder]
               && [touch view] != self.titleTextField ) {
        
        [self.titleTextField resignFirstResponder];
    }
    
    [super touchesBegan : touches withEvent : event];
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

- (void) showPlaceholder : (NSString*) text
              inTextView : (UITextView *) aTextview {
    if ( [aTextview.text isEqualToString : @""] ) {
        aTextview.text = text;
        aTextview.textColor = [UIColor lightGrayColor];
    }
}

#pragma mark - TextView delegate
- (void) textViewDidBeginEditing : (UITextView *) textView {
    
    if ( [textView.text isEqualToString : REVIEW_PLACEHOLDER_TEXT] ) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self showPlaceholder : REVIEW_PLACEHOLDER_TEXT
               inTextView : textView];
    
    [textView resignFirstResponder];
}

@end
