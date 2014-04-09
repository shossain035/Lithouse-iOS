//
//  LITLANDevice.h
//  ToDoList
//
//  Created by Shah Hossain on 4/7/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDevice.h"

@interface LITLANDevice : LITDevice

@property NSString *ipAddress;
@property NSString *macAddress;

- (id)initWithName:(NSString *) name ipAddress: (NSString *) ipAddress macAddress:(NSString *) macAddress;

@end
