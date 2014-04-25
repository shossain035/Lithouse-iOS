//
//  LITDevice.h
//  ToDoList
//
//  Created by Shah Hossain on 1/15/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEVICE_TYPE_UNKNOWN             @"UNKNOWN"
#define DEVICE_TYPE_PHILLIPS_HUE_BRIDGE @"Royal-Philips-Electronics-Philips-hue-bridge"


@interface LITDevice : NSObject

@property NSString * uid;
@property NSString * name;
@property NSString * type;
@property NSString * manufacturer;
@property UIImage  * smallIcon;
@property NSString * ipAddress;


- (LITDevice *) updateDeviceList : (NSMutableArray *) aDeviceList
            withDeviceDictionary : (NSMutableDictionary *) aDeviceDictionary
                         withKey : (id) key;

- (NSString *) toJSONString;
+ (NSString *) toJSONString : (NSArray *) fromDeviceArray;
+ (NSString *) restEndpoint : (NSString *) scannerId;

@end