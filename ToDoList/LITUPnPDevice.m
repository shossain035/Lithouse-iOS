//
//  LITUPnPDevice.m
//  ToDoList
//
//  Created by Shah Hossain on 4/7/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITUPnPDevice.h"

@implementation LITUPnPDevice

- (id)initWithBasicUPnPDevice:(BasicUPnPDevice *) aBasicUPnPDevice {
    if ( self = [super init] ) {
        self.name = [aBasicUPnPDevice friendlyName];
        self.smallIcon = [aBasicUPnPDevice smallIcon];
        self.manufacturer = [aBasicUPnPDevice manufacturer];
        self.type = [NSString stringWithFormat:@"%@-%@-%@",
                     [aBasicUPnPDevice modelName], [aBasicUPnPDevice modelNumber], [aBasicUPnPDevice manufacturer]];
        self.uid = [aBasicUPnPDevice uuid];
        
        self.ipAddress = [[aBasicUPnPDevice baseURL] host];
        self.uPnPDeviceType = [aBasicUPnPDevice deviceType];
        self.uPnPDevice = aBasicUPnPDevice;
        return self;
    } else {
        return nil;
    }
}

@end
