//
//  AppDelegate.h
//  ToDoList
//
//  Created by Shah Hossain on 1/12/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>

@class PHHueSDK;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext       * managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel         * managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;

@property (readonly, strong, nonatomic) PHHueSDK                     * phHueSDK;

+ (PHHueSDK *) getHueSDK;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
