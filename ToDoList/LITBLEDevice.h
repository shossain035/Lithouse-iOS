//
//  LITBLEDevice.h
//  ToDoList
//
//  Created by Shah Hossain on 4/7/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface LITBLEDevice : LITDevice

@property CBPeripheral *peripheral;

- (id)initWithCBPeripheral:(CBPeripheral *) aCBPeripheral;

@end
