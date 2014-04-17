//
//  LITDevice.h
//  ToDoList
//
//  Created by Shah Hossain on 1/15/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEVICE_TYPE_UNKNOWN     @"UNKNOWN"

@interface LITDevice : NSObject

@property NSString *uid;
@property NSString *name;
@property NSString *type;
@property NSString *manufacturer;
@property UIImage  *smallIcon;

@end