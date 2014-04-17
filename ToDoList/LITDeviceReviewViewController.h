//
//  LITDeviceReviewViewController.h
//  ToDoList
//
//  Created by Shah Hossain on 4/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITDevice.h"

@interface LITDeviceReviewViewController : UIViewController <UITextViewDelegate> {
    NSArray *mRateButtons;
}

@property LITDevice *currentDevice;

@end