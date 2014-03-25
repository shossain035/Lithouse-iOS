//
//  XYZAddToDoItemViewController.h
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYZDevice.h"
#import "XYZBluetoothLEManager.h"

@interface XYZAddToDoItemViewController : UIViewController

@property XYZDevice *toDoItem;
@property ( weak ) id < XYZBluetoothLEManager > bluetoothManager;

@end