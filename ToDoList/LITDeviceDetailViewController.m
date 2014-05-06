//
//  XYZAddToDoItemViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDeviceDetailViewController.h"
#import "LITDeviceReviewViewController.h"
#import "Review.h"
#import "AppDelegate.h"
#import "DeviceReviewListViewCell.h"

#define DEVICE_REVIEW_LIST_CELL_ID           @"deviceReviewCollectionCellID"
#define SEGUE_ID_DEVICE_DETAIL_TO_REVIEW     @"segue-device-detail-to-review"

@interface LITDeviceDetailViewController ()

@property (strong, nonatomic) IBOutlet UIImageView             * deviceImage;
@property (strong, nonatomic) IBOutlet UILabel                 * name;
@property (strong, nonatomic) IBOutlet UILabel                 * manufacturer;
@property (strong, nonatomic) IBOutlet UILabel                 * ipAddress;

@property (strong, nonatomic) IBOutlet UIImageView             * rateImage1;
@property (strong, nonatomic) IBOutlet UIImageView             * rateImage2;
@property (strong, nonatomic) IBOutlet UIImageView             * rateImage3;
@property (strong, nonatomic) IBOutlet UIImageView             * rateImage4;
@property (strong, nonatomic) IBOutlet UIImageView             * rateImage5;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView * loadingView;
@property (strong, nonatomic) IBOutlet UILabel                 * reviewCount;
@property (strong, nonatomic) IBOutlet UICollectionView        * reviewCollectionView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem         * controlButton;

@property NSArray *reviews;
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
    
    mRateImages = @[self.rateImage1,
                    self.rateImage2,
                    self.rateImage3,
                    self.rateImage4,
                    self.rateImage5];
}

- (void) viewWillAppear : (BOOL) animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = [self.currentDevice name];
    self.name.text = [self.currentDevice name];
    self.deviceImage.image = [self.currentDevice smallIcon];
    self.manufacturer.text = [self.currentDevice manufacturer];
    self.ipAddress.text = [self.currentDevice ipAddress];
    
    //review is not allowed for "unknown" types 
    if ( [self.currentDevice.type isEqualToString : DEVICE_TYPE_UNKNOWN] ) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self fetchReviews];
    
    [self configureControlButton];
    
    //todo: refactor
    //scan & connect to BLE shield
    if ( [self.currentDevice.type isEqualToString : DEVICE_TYPE_RB_BLE_SHIELD] ) {
        AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate scanForPeripherals];
    }
}

-(void) viewWillDisappear : (BOOL)animated
{
    //todo: refactor
    //scan & connect to BLE shield
    if ( [self.currentDevice.type isEqualToString : DEVICE_TYPE_RB_BLE_SHIELD] ) {
        AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate disconnectFromActivePeripheral];
    }
}

- (void) toggleBarButton : (UIBarButtonItem *) button
              shouldShow : (bool) show
               withTitle : (NSString *) title
{
    if ( show ) {
        button.style = UIBarButtonItemStyleBordered;
        button.enabled = true;
        button.title = title;
        [self.navigationController setToolbarHidden : NO];

    } else {
        button.style = UIBarButtonItemStylePlain;
        button.enabled = false;
        button.title = nil;
        [self.navigationController setToolbarHidden : YES];
    }
}

- (void) configureControlButton
{
    //todo: refactor
    if ( [self.currentDevice.type hasPrefix : DEVICE_TYPE_PHILLIPS_HUE_BRIDGE] ) {
        [self toggleBarButton : self.controlButton
                   shouldShow : YES
                    withTitle : @"Lights"];
    } else {
        [self toggleBarButton : self.controlButton
                   shouldShow : NO
                    withTitle : nil];
    }
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

- (void) fetchReviews
{
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    [self.view bringSubviewToFront : self.loadingView];
    self.reviewCount.hidden = YES;
    [self updateRatingStars : mRateImages
               withGoldStar : [UIImage imageNamed : @"star-gold-48"]
               withGrayStar : [UIImage imageNamed : @"star-gray-48"]
                    basedOn : 0];
    
    NSURL *url = [NSURL URLWithString : [Review restEndpoint : self.currentDevice.type]];
    NSURLRequest *request = [NSURLRequest requestWithURL : url];
    
    [NSURLConnection sendAsynchronousRequest : request
                                       queue : [NSOperationQueue mainQueue]
                           completionHandler : ^(NSURLResponse *response,
                                                 NSData *data,
                                                 NSError *connectionError)
     {
         if ( data.length > 0 && connectionError == nil ) {
             NSDictionary *result = [NSJSONSerialization JSONObjectWithData : data
                                                                    options : 0
                                                                      error : NULL];
             NSLog(@"result %@", result);
             int totalNumberOfReviews = [[result objectForKey : @"totalNumberOfReviews"] intValue];
             int sumOfAllRatings = [[result objectForKey : @"sumOfAllRatings"] intValue];
             
             [self updateRating : sumOfAllRatings withTotalNumberOfReviews : totalNumberOfReviews];
             
             AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
             self.reviews = [Review parseReviews : [result objectForKey : @"reviews"]
                                     intoContext : [appDelegate managedObjectContext]];
             
             [self.reviewCollectionView reloadData];
         } else {
             //todo: show error
         }
     }];
}
     
- (void) updateRating : (int) sumOfAllRatings withTotalNumberOfReviews : (int) totalNumberOfReviews
{
    self.loadingView.hidden = YES;
    self.reviewCount.hidden = NO;
    [self.view bringSubviewToFront : self.reviewCount];
    
    NSString * reviewTotalText = [NSString stringWithFormat : @"%d Review", totalNumberOfReviews];
    
    if ( totalNumberOfReviews > 1 ) {
        reviewTotalText = [NSString stringWithFormat : @"%@s", reviewTotalText];
    }
    
    self.reviewCount.text = reviewTotalText;
    
    if ( totalNumberOfReviews > 0 ) {
        int rate = sumOfAllRatings / totalNumberOfReviews;
        
        if ( rate > 0 ) {
            [self updateRatingStars : mRateImages
                       withGoldStar : [UIImage imageNamed : @"star-gold-48"]
                       withGrayStar : [UIImage imageNamed : @"star-gray-48"]
                            basedOn : rate];
        }
    }
}

- (void) updateRatingStars : (NSArray *) starImages
              withGoldStar : (UIImage *) goldStarImage
              withGrayStar : (UIImage *) grayStarImage
                   basedOn : (int) rating
{
    for ( int i = 0; i < rating ; i++ ) {
        UIImageView * rateImageView = [starImages objectAtIndex : i];
        [rateImageView setImage : goldStarImage];
    }
    
    for ( int i = rating; i < 5 ; i++ ) {
        UIImageView * rateImageView = [starImages objectAtIndex : i];
        [rateImageView setImage : grayStarImage];
    }

}

#pragma mark - Collection view data source

- (NSInteger) collectionView : (UICollectionView *) view
      numberOfItemsInSection : (NSInteger) section;
{
    return [self.reviews count];
}


- (UICollectionViewCell *) collectionView : (UICollectionView *) cv
                   cellForItemAtIndexPath : (NSIndexPath *) indexPath {
    
    DeviceReviewListViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier : DEVICE_REVIEW_LIST_CELL_ID
                                                                   forIndexPath : indexPath];
    
    Review *review = [self.reviews objectAtIndex : indexPath.row];
    
    cell.reviewText.text = review.reviewText;
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [self updateRatingStars : [cell ratingImages]
               withGoldStar : [UIImage imageNamed : @"star-gold-32"]
               withGrayStar : [UIImage imageNamed : @"star-gray-32"]
                    basedOn : [review.rating intValue]];
    return cell;
}

@end
