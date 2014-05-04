//
//  PHLightListViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 5/2/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "PHLightListViewController.h"
#import "PHLightListViewCell.h"
#import "AppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>

#define HUE_LIGHT_LIST_CELL_ID                  @"hueLightCollectionCellID"

@interface PHLightListViewController ()
@end

@implementation PHLightListViewController

- (IBAction) stopButtonTapped : (id) sender
{
    [((PHLightListViewController *) self.lightListViewControllerDelegate).navigationController popViewControllerAnimated : NO];
    [self dismissViewControllerAnimated : YES completion:nil];
}

- (IBAction) switchValueChanged : (UISwitch *) theSwitch
{
    PHBridgeResourcesCache * cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    //todo: refactor
    PHLight * light = nil;
    
    for ( PHLight * currentlight in cache.lights.allValues ) {
        if ( [currentlight.lightState.reachable boolValue] ) {
            light = currentlight;
        }
    }
    PHLightState * lightState = [[PHLightState alloc] init];
    
    [lightState setOnBool : theSwitch.on];
    
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    
    [bridgeSendAPI updateLightStateForId : light.identifier
                           withLighState : lightState
                       completionHandler : ^(NSArray *errors) {
        if (errors != nil) {
            NSString * message = [NSString stringWithFormat : @"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            
            NSLog(@"Response: %@",message);
        }
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) viewWillAppear : (BOOL) animated
{
    //PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    //todo: enable heartbeat
}

- (void)viewWillDisappear : (BOOL) animated
{
    //todo: disable heartbeat
}

#pragma mark - Collection view

- (NSInteger) collectionView : (UICollectionView *) view
      numberOfItemsInSection : (NSInteger) section
{
    PHBridgeResourcesCache * cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    int reachableLightsCount = 0;
    
    for (PHLight * light in cache.lights.allValues) {
        if ( [light.lightState.reachable boolValue] ) {
            NSLog ( @"light: %@", light.name );
            reachableLightsCount++;
        }
    }
    
    return reachableLightsCount;
}

- (UICollectionViewCell *) collectionView : (UICollectionView *) cv
                   cellForItemAtIndexPath : (NSIndexPath *) indexPath;
{
    PHLightListViewCell * cell = [cv dequeueReusableCellWithReuseIdentifier : HUE_LIGHT_LIST_CELL_ID
                                                               forIndexPath : indexPath];
    
    //todo: optimize
    int reachableLightsCount = 0;
    PHBridgeResourcesCache * cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    for ( PHLight * light in cache.lights.allValues ) {
        if ( [light.lightState.reachable boolValue] ) {
            if ( reachableLightsCount == indexPath.row ) {
                cell.nameLabel.text = light.name;

                if ( [light.lightState.on intValue] == YES ) {
                    [cell.onOffSwitch setOn : YES];
                } else {
                    [cell.onOffSwitch setOn : NO];
                }
                
                //[self.switchDictionary setObject : light forKey : ];
            }
            
            reachableLightsCount++;
        }
    }
    
    return cell;
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
