//
//  LITDeviceDetailViewController.h
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITDevice.h"

@interface LITDeviceDetailViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray *mRateImages;
}

@property LITDevice *currentDevice;

@end