//
//  LITDeviceReviewViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 4/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDeviceReviewViewController.h"
#import "AppDelegate.h"
#import "Review.h"

#define REVIEW_PLACEHOLDER_TEXT   @"What did you like or dislike?\nWould you recommend this device?" 

@interface LITDeviceReviewViewController ()

@property IBOutlet UIButton       *rateButton1;
@property IBOutlet UIButton       *rateButton2;
@property IBOutlet UIButton       *rateButton3;
@property IBOutlet UIButton       *rateButton4;
@property IBOutlet UIButton       *rateButton5;

@property IBOutlet UITextView     *reviewTextView;
@property IBOutlet UITextField    *titleTextField;
@property NSInteger               rating;

@end

@implementation LITDeviceReviewViewController

- (IBAction) addButtonTapped : (id) sender
{
    [self submitReview];
}

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
    
    [self.reviewTextView.layer setBorderColor : [[UIColor lightGrayColor] CGColor]];
    [self.reviewTextView.layer setBorderWidth : 0.5];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.reviewTextView.layer.cornerRadius = 5;
    self.reviewTextView.clipsToBounds = YES;
}

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = [NSString stringWithFormat : @"Review %@", [self.currentDevice name]];
    [self.navigationController setToolbarHidden : YES];
    
    //check for previous review in db
    [self showPlaceholder : REVIEW_PLACEHOLDER_TEXT
               inTextView : self.reviewTextView];
}

- (IBAction) rateButtonTapped : (id) sender
{
    self.rating = [[sender restorationIdentifier] integerValue];
    UIImage* goldStarImage = [UIImage imageNamed : @"star-gold-64"];
    
    for ( int i = 0; i < self.rating ; i++ ) {
        UIButton *button = [mRateButtons objectAtIndex : i];
        [button setImage : goldStarImage
                forState : UIControlStateNormal];
    }
    
    UIImage* grayStarImage = [UIImage imageNamed : @"star-gray-64"];
    
    for ( int i = self.rating; i < 5 ; i++ ) {
        UIButton *button = [mRateButtons objectAtIndex : i];
        [button setImage : grayStarImage
                forState : UIControlStateNormal];
    }
}

//hide keyboard when touched outside
- (void)touchesBegan : (NSSet *) touches
           withEvent : (UIEvent *) event
{
    
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

- (BOOL) isReviewComplete
{
    return NO;
}

- (void) postReviewToService : (Review *) review
{
    NSLog(@"review %@", review);
    NSURL * url = [NSURL URLWithString : [Review restEndpoint : review.deviceType]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL : url];

    request.HTTPMethod = @"POST";
    [request setValue : @"application/json; charset=utf-8" forHTTPHeaderField : @"Content-Type"];
    request.HTTPBody = [review toJSONData];
    
    [NSURLConnection sendAsynchronousRequest : request
                                       queue : [NSOperationQueue mainQueue]
                           completionHandler : ^(NSURLResponse *response,
                                                 NSData *data,
                                                 NSError *connectionError)
     {
         if ( data.length > 0 && connectionError == nil ) {
             NSLog(@"review posted data %@, response %@", data, response);
         } else {
             NSLog(@"response %@, error %@", response, connectionError);
             //todo: show alert
         }
     }];
}

- (void) submitReview
{
    //if ( [self isReviewComplete] == NO ) return;
    
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    Review * review = [Review insertNewObjectIntoContext : [appDelegate managedObjectContext]];
    review.deviceType = self.currentDevice.type;
    //todo: change to user login
    review.reviewerId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    review.title = self.titleTextField.text;
    review.reviewText = self.reviewTextView.text;
    review.rating = [NSNumber numberWithInteger : self.rating];
    
    [self postReviewToService : review];
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
