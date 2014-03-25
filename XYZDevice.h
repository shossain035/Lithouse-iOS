//
//  XYZToDoItem.h
//  ToDoList
//
//  Created by Shah Hossain on 1/15/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface XYZDevice : NSObject

@property NSString *deviceName;
@property UIImage *smallIcon;
@property CBPeripheral *peripheral;

@end