//
//  PHLightListViewCell.h
//  ToDoList
//
//  Created by Shah Hossain on 5/2/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHLightListViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UISwitch * onOffSwitch;
@property (strong, nonatomic) IBOutlet UILabel  * nameLabel;

@end
