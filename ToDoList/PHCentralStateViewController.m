//
//  PHCentralStateViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 4/24/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "PHCentralStateViewController.h"
#import <HueSDK_iOS/HueSDK.h>

@interface PHCentralStateViewController ()

@property (strong, nonatomic) PHHueSDK                       * phHueSDK;
@property (nonatomic, strong) PHBridgeSearching              * bridgeSearch;
@property UIBarButtonItem                                    * activityIndicatorButton;
@property (nonatomic, strong) PHBridgePushLinkViewController * pushLinkViewController;


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
    
    // Create sdk instance
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging : YES];
    
    // Listen for notifications
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    /***************************************************
     The SDK will send the following notifications in response to events
     *****************************************************/
    
    [notificationManager registerObject : self
                           withSelector : @selector ( localConnection )
                        forNotification : LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject : self
                           withSelector : @selector ( noLocalConnection )
                        forNotification : NO_LOCAL_CONNECTION_NOTIFICATION];
    /***************************************************
     If there is no authentication against the bridge this notification is sent
     *****************************************************/
    
    [notificationManager registerObject : self
                           withSelector : @selector ( notAuthenticated )
                        forNotification : NO_LOCAL_AUTHENTICATION_NOTIFICATION];
}

- (void) viewWillAppear : (BOOL) animated
{
    /***************************************************
     The local heartbeat is a regular  timer event in the SDK. Once enabled the SDK regular collects the current state of resources managed
     by the bridge into the Bridge Resources Cache
     *****************************************************/
    
    [self enableLocalHeartbeat];
}

- (void) viewWillDisappear : (BOOL) animated
{
    [self disableLocalHeartbeat];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Heartbeat control

/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if ( cache != nil && cache.bridgeConfiguration != nil
        && cache.bridgeConfiguration.ipaddress != nil ) {
        //
        self.navigationItem.title = @"Connecting...";
        
        // Enable heartbeat with interval of 10 seconds
        [self.phHueSDK enableLocalConnectionUsingInterval:10];
    } else {
        // Automaticly start searching for bridges
        [self searchForBridgeLocal];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    self.navigationItem.title = @"Searching...";
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    
    // Start search
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch : YES
                                                      andPortalSearch : NO
                                                    andIpAdressSearch : NO];
    
    [self.bridgeSearch startSearchWithCompletionHandler : ^( NSDictionary *bridgesFound ) {
        
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
        if (bridgesFound.count > 0) {
            NSLog ( @"bridges: %@", bridgesFound );
            //warning: selecting first bridge by default.
            //todo: create a bridge selection view.
            NSString * macAddress = [bridgesFound.allKeys objectAtIndex : 0];
            [self.phHueSDK setBridgeToUseWithIpAddress : [bridgesFound objectForKey : macAddress]
                                            macAddress : macAddress];
        }
        else {
            NSLog ( @"No HUE bridge found" );
//            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle : @"No bridge found"
//                                                                 message : @"Could not find a Hue bridge. Please make sure that the bridge is powered up and connected to router."
//                                                       cancelButtonTitle : @"Cancel"
//                                                       otherButtonTitles : NSLocalizedString(@"Retry", @"No bridge found alert retry button"),NSLocalizedString(@"Cancel", @"No bridge found alert cancel button"), nil];
//            [alertView show];
        }
    }];
}


#pragma mark - HueSDK

/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // Check current connection state
    NSLog ( @"localConnection" );
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
    NSLog ( @"noLocalConnection" );
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    NSLog ( @"notAuthenticated" );
    
    self.pushLinkViewController = [[PHBridgePushLinkViewController alloc]
                                   initWithHueSDK  : self.phHueSDK
                                            bundle : [NSBundle mainBundle]
                                          delegate : self];
    
    [self.navigationController presentViewController:self.pushLinkViewController animated:YES completion:^{
        /***************************************************
         Start the push linking process.
         *****************************************************/
        
        // Start pushlinking when the interface is shown
        [self.pushLinkViewController startPushLinking];
    }];
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

#pragma mark - PHBridgePushLinkViewController
/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
 */
- (void)pushlinkSuccess {
    // Remove pushlink view controller
    [self.navigationController dismissViewControllerAnimated : YES completion : nil];
    self.pushLinkViewController = nil;
    
    // Start local heartbeat
    [self performSelector : @selector(enableLocalHeartbeat)
               withObject : nil
               afterDelay : 1];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */

- (void)pushlinkFailed:(PHError *)error {
    // Remove pushlink view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.pushLinkViewController = nil;
    
    // Check which error occured
    if (error.code == PUSHLINK_NO_CONNECTION) {
        // No local connection to bridge
        [self noLocalConnection];
        
        // Start local heartbeat (to see when connection comes back)
        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
    }
    else {
        // Bridge button not pressed in time
        [[[UIAlertView alloc] initWithTitle : NSLocalizedString(@"Authentication failed", @"Authentication failed alert title")
                                    message : NSLocalizedString(@"Make sure you press the button within 30 seconds", @"Authentication failed alert message")
                                   delegate : self
                          cancelButtonTitle : nil
                          otherButtonTitles : NSLocalizedString(@"Retry", @"Authentication failed alert retry button"), NSLocalizedString(@"Cancel", @"Authentication failed cancel button"), nil] show];
    }
}


@end
