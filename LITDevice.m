//
//  XYZToDoItem.m
//  ToDoList
//
//  Created by Shah Hossain on 1/15/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDevice.h"

@implementation LITDevice

@synthesize type = _type;

- (id) init
{
    self = [super init];
    if ( self ) {
        self.type = DEVICE_TYPE_UNKNOWN;
    }
    return self;
}

- (void) setType : (NSString *) type
{
    //todo: remove special chars
    _type = type;
}

- (NSString *) type
{
    return _type;
}

@end
