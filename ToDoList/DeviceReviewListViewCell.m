//
//  ReviewListViewCell.m
//  ToDoList
//
//  Created by Shah Hossain on 4/16/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "DeviceReviewListViewCell.h"

@implementation DeviceReviewListViewCell


- (NSArray *) ratingImages
{
    if ( mRateImages == nil ) {
        mRateImages = @[self.rateImage1,
                        self.rateImage2,
                        self.rateImage3,
                        self.rateImage4,
                        self.rateImage5];
    }
    
    return mRateImages;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
