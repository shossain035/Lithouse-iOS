//
//  XYZToDoListViewController.h
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "UPnPDB.h"

@interface XYZToDoListViewController : UITableViewController < CBCentralManagerDelegate, UPnPDBObserver > {
    NSArray *mDevices; //BasicUPnPDevice*
}

//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender;
-(void)UPnPDBUpdated:(UPnPDB*)sender;

@end
