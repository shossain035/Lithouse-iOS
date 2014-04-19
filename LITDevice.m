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

- (LITDevice *) updateDeviceList : (NSMutableArray *) aDeviceList
            withDeviceDictionary : (NSMutableDictionary *) aDeviceDictionary
                         withKey : (id) key
{
    @synchronized ( aDeviceDictionary ) {
        if ( [aDeviceDictionary objectForKey : key] != nil ) return nil;
    
        [aDeviceList addObject : self];
        [aDeviceDictionary setObject : self forKey : key];
    
        return self;
    }
}

- (NSString *) toJSONString
{
    return [NSString stringWithFormat : @"{\"uid\":\"%@\",\"name\":\"%@\",\"type\":\"%@\",\"manufacturer\":\"%@\"}",
            self.uid, self.name, self.type, self.manufacturer];
}

+ (NSString *) toJSONString : (NSArray *) fromDeviceArray
{
    NSString * result = @"{\"devices\":[";
    BOOL firstDevice = YES;
    
    for ( LITDevice * device in fromDeviceArray ) {
        if ( !firstDevice ) {
            result = [result stringByAppendingString : @","];
        }
        result = [result stringByAppendingFormat : @"%@", [device toJSONString]];
        firstDevice = NO;
    }
    //delete
    NSLog(@"%@", [result stringByAppendingString : @"]}"]);
    return [result stringByAppendingString : @"]}"];
}

+ (NSString *) restEndpoint : (NSString *) scannerId
{
    return [NSString stringWithFormat : @"%@devices?scannerId=%@", LITHOUSE_API_URL, scannerId];
}

@end
