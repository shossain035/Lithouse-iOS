//
//  LITBLEDevice.m
//  ToDoList
//
//  Created by Shah Hossain on 4/7/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITBLEDevice.h"

@implementation LITBLEDevice


- (id) initWithCBPeripheral : (CBPeripheral *) aCBPeripheral
          withManufacturer  : (NSString *) manufacturer
           withDeviceModel  : (NSString *) model
{
    if ( self = [super init] ) {
        self.name = [aCBPeripheral name];
        
        //todo: refactor
        if ( [self.name hasPrefix:@"Flex"] ) self.smallIcon = [UIImage imageNamed:@"fitbit"];
        else if ( [self.name hasPrefix:@"iSmart"] ) self.smallIcon = [UIImage imageNamed:@"lumen"];        
        
        self.manufacturer = manufacturer;
        self.type = [NSString stringWithFormat:@"%@-%@", manufacturer, model];
        self.uid = [[aCBPeripheral identifier] UUIDString];
        
        self.peripheral = aCBPeripheral;
        return self;
    } else {
        return nil;
    }
}


@end
