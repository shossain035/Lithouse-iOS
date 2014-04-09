//
//  LITLANDevice.m
//  ToDoList
//
//  Created by Shah Hossain on 4/7/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITLANDevice.h"

@implementation LITLANDevice

- (id)initWithName:(NSString *) name ipAddress: (NSString *) ipAddress macAddress:(NSString *) macAddress {
    if ( self = [super init] ) {
        self.name = name;
        
        //todo: refactor
        self.smallIcon = [UIImage imageNamed:@"unknown"];
        
        //self.manufacturer = [aBasicUPnPDevice manufacturer];
        //self.type = [aBasicUPnPDevice modelNumber];
        self.uid = macAddress;
        
        self.ipAddress = ipAddress;
        self.macAddress = macAddress;
        
        return self;
    } else {
        return nil;
    }
}

@end
