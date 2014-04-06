//
//  LITDeviceDetailViewController.h
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITDevice.h"
#import "XYZBluetoothLEManager.h"

@interface LITDeviceDetailViewController : UIViewController

@property LITDevice *toDoItem;
@property ( weak ) id < XYZBluetoothLEManager > bluetoothManager;

@end