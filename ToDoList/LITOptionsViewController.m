//
//  LITOptionsViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 4/10/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITOptionsViewController.h"
#import <Social/Social.h>

#define ITUNES_APP_URL_IOS7 @"http://itunes.apple.com/app/id353372460"

@interface LITOptionsViewController ()

@end

@implementation LITOptionsViewController

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

- (IBAction) reviewApp : (id) sender {
    [[UIApplication sharedApplication] openURL : [NSURL URLWithString : ITUNES_APP_URL_IOS7]];
}

- (IBAction) twittTapped : (id) sender {
    
    if ( [SLComposeViewController isAvailableForServiceType : SLServiceTypeTwitter] ) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType : SLServiceTypeTwitter];
        [tweetSheet setInitialText : [NSString stringWithFormat : @"%@ by @lithouseIoT is the easiest way to connect #Internet-of-Things",
                                      ITUNES_APP_URL_IOS7]];
        
        [self presentViewController : tweetSheet animated : YES completion : nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                            initWithTitle : @"Sorry"
                                  message : @"You can't tweet right now. Please make sure that you have a Twitter account setup."
                                 delegate : self
                        cancelButtonTitle : @"OK"
                        otherButtonTitles : nil];
        
        [alertView show];
    }
}

- (IBAction) emailFriends : (id) sender {
    NSString *messageBody = [NSString stringWithFormat : @"Hey,</br>Find your connected devices with <a href=\"%@\">Lithouse</a>.</br>",
                             ITUNES_APP_URL_IOS7];
    
    [self sendEmailWithContent : messageBody
                   withSubject : @"Lookup Connected Things"
                   toRecipents : nil];
}

- (IBAction) contactUs : (id) sender {
    //todo: get encrypted unique id
    [self sendEmailWithContent : [NSString stringWithFormat : @"</br></br></br>%@", @"dfsdf"]
                   withSubject : @"Feedback from iOS app"
                   toRecipents : [NSArray arrayWithObject : @"nahid@lithouse.co"]];
}

- (void) sendEmailWithContent : (NSString *) content
                  withSubject : subject
                  toRecipents : (NSArray *) recipients {
    
    MFMailComposeViewController *emailComposer = [[MFMailComposeViewController alloc] init];
    [emailComposer setSubject : subject];
    [emailComposer setMessageBody : content isHTML : YES];
    [emailComposer setToRecipients : recipients];
    emailComposer.mailComposeDelegate = self;
    
    [self presentViewController : emailComposer animated : YES completion : NULL];
    
}

#pragma mark - Mail Compose ViewController Delegate
- (void) mailComposeController : (MFMailComposeViewController *) controller
           didFinishWithResult : (MFMailComposeResult) result
                         error : (NSError *) error {
    [self dismissViewControllerAnimated : YES completion : NULL];
}

@end
