//
//  Review.h
//  ToDoList
//
//  Created by Shah Hossain on 4/16/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Review : NSManagedObject

@property (nonatomic, retain) NSString * deviceType;
@property (nonatomic, retain) NSString * reviewerId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * reviewText;
@property (nonatomic, retain) NSString * reviewDate;
@property (nonatomic, retain) NSNumber * rating;

+ (NSString *) restEndpoint : (NSString *) deviceType;
+ (instancetype) insertNewObjectIntoContext : (NSManagedObjectContext *) context;
+ (NSArray *) parseReviews : (NSArray *) fromJSONArray
               intoContext : (NSManagedObjectContext *) context;

- (NSData *) toJSONData;

@end
