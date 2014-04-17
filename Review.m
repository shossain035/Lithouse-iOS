//
//  Review.m
//  ToDoList
//
//  Created by Shah Hossain on 4/16/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "Review.h"


@implementation Review

@dynamic deviceType;
@dynamic reviewerId;
@dynamic title;
@dynamic reviewText;
@dynamic reviewDate;
@dynamic rating;

+ (NSString *) entityName
{
    return @"Review";
}

- (NSString *) restEndpoint
{
    return [NSString stringWithFormat : @"%@devices/%@/reviews", LITHOUSE_API_URL, self.deviceType];
}

+ (instancetype) insertNewObjectIntoContext : (NSManagedObjectContext *) context
{
    return [NSEntityDescription insertNewObjectForEntityForName : [self entityName]
                                         inManagedObjectContext : context];
}

- (NSDictionary *) toDictionary
{
    NSArray *attributes = [[self.entity attributesByName] allKeys];
    return [self dictionaryWithValuesForKeys : attributes];
}

- (NSData *) toJSONData
{
    NSError * error;
    return [NSJSONSerialization dataWithJSONObject : [self toDictionary]
                                           options : NSJSONWritingPrettyPrinted
                                             error : &error];
    //todo: handle error
}


@end