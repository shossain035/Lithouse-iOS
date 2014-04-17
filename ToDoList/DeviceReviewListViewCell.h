//
//  ReviewListViewCell.h
//  ToDoList
//
//  Created by Shah Hossain on 4/16/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceReviewListViewCell : UICollectionViewCell {
    NSArray *mRateImages;
}


@property (strong, nonatomic) IBOutlet UIImageView *rateImage1;
@property (strong, nonatomic) IBOutlet UIImageView *rateImage2;
@property (strong, nonatomic) IBOutlet UIImageView *rateImage3;
@property (strong, nonatomic) IBOutlet UIImageView *rateImage4;
@property (strong, nonatomic) IBOutlet UIImageView *rateImage5;

@property (strong, nonatomic) IBOutlet UILabel     *title;
@property (strong, nonatomic) IBOutlet UITextView  *reviewText;

- (NSArray *) ratingImages;

@end
