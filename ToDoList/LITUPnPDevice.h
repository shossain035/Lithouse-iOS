//
//  LITUPnPDevice.h
//  ToDoList
//
//  Created by Shah Hossain on 4/7/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDevice.h"
#import "BasicUPnPDevice.h"

@interface LITUPnPDevice : LITDevice

@property NSString *uPnPDeviceType;
@property BasicUPnPDevice *uPnPDevice;

- (id)initWithBasicUPnPDevice:(BasicUPnPDevice *) aBasicUPnPDevice;

@end
