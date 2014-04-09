//
//  LITLANDevice.m
//  ToDoList
//
//  Created by Shah Hossain on 4/7/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITLANDevice.h"

@implementation LITLANDevice

- (id)initWithName : (NSString *) name
         ipAddress : (NSString *) ipAddress
        macAddress : (NSString *) macAddress
              type : (NSString *) type {
    if ( self = [super init] ) {
        self.name = name;
        
        
        //self.manufacturer = [aBasicUPnPDevice manufacturer];
        if ( type != nil ) {
            self.type = type;
            self.smallIcon = [UIImage imageNamed : type];
        } else {
            self.smallIcon = [UIImage imageNamed : @"unknown"];
        }
        
        self.uid = macAddress;
        
        self.ipAddress = ipAddress;
        self.macAddress = macAddress;
        
        return self;
    } else {
        return nil;
    }
}

@end
