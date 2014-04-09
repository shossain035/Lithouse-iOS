//
//  LITLANDevice.h
//  ToDoList
//
//  Created by Shah Hossain on 4/7/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDevice.h"

//todo: get these from service
#define DEVICE_TYPE_MAC         @"APPLE_MAC"
#define DEVICE_TYPE_PC          @"MSFT_PC"
#define DEVICE_TYPE_IOS         @"APPLE_IOS"
#define DEVICE_TYPE_PRINTER     @"PRINTER"

#define DEVICE_PORT_MAC         548
#define DEVICE_PORT_PC          139
#define DEVICE_PORT_IOS         62078
#define DEVICE_PORT_PRINTER     631


@interface LITLANDevice : LITDevice

@property NSString *ipAddress;
@property NSString *macAddress;

- (id)initWithName : (NSString *) name
         ipAddress : (NSString *) ipAddress
        macAddress : (NSString *) macAddress
              type : (NSString *) type;

@end
