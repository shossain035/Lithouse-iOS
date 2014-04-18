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
@dynamic reviewText;
@dynamic reviewDate;
@dynamic rating;

+ (NSString *) entityName
{
    return @"Review";
}

+ (NSString *) restEndpoint : (NSString *) deviceType
{
    return [NSString stringWithFormat : @"%@devices/%@/reviews", LITHOUSE_API_URL, deviceType];
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

+ (NSArray *) parseReviews : (NSArray *) fromJSONArray
                   intoContext : (NSManagedObjectContext *) context
{
    NSMutableArray * reviews = [[NSMutableArray alloc] init];
    
    for ( NSDictionary * reviewDictionary in fromJSONArray ) {
        Review * review = [Review insertNewObjectIntoContext : context];
        
        for ( NSString * key in reviewDictionary ) {
            if ([review respondsToSelector : NSSelectorFromString ( key )]) {
                [review setValue:[reviewDictionary valueForKey : key] forKey : key];
            }
        }
        
        [reviews addObject : review];
    }
    
    return reviews;
}


@end
