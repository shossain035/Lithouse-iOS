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
        self.smallIcon = [UIImage imageNamed : @"unknown"];
    }
    return self;
}

- (void) setType : (NSString *) type
{
    NSRange range = NSMakeRange ( 0, type.length );
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern : @"[^a-zA-Z0-9]"
                                                                           options : 0
                                                                             error : nil ];
    
    _type = [regex stringByReplacingMatchesInString : type
                                             options: 0
                                              range : range
                                       withTemplate : @"-"];
    
}

- (NSString *) type
{
    return _type;
}

@end
