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
            //todo: refactor
            if ( [type hasPrefix : @"APPLE"] ) self.manufacturer = @"Apple Inc.";
        }
        
        //self.uid = macAddress;
        self.uid = [NSString stringWithFormat : @"lan:%@%@",
                    [[[UIDevice currentDevice] identifierForVendor] UUIDString], ipAddress];
        
        self.ipAddress = ipAddress;
        self.macAddress = macAddress;
        
        return self;
    } else {
        return nil;
    }
}

@end
