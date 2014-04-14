//
//  XYZToDoItem.m
//  ToDoList
//
//  Created by Shah Hossain on 1/15/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDevice.h"

@implementation LITDevice

- (void) updateType : (NSString *) type withManufacturer : (NSString *) aManufacturer {
    self.manufacturer = aManufacturer;
    self.type = [NSString stringWithFormat:@"%@-%@", type, aManufacturer ];
}

@end
