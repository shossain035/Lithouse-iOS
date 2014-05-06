//
//  AppDelegate.h
//  ToDoList
//
//  Created by Shah Hossain on 1/12/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HueSDK_iOS/HueSDK.h>
#import "BLE.h"

@class PHHueSDK;
@class BLE;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext       * managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel         * managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (PHHueSDK *) getHueSDK;
+ (void) updateLastReachableHueLight : (BOOL) toState;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) scanForPeripherals;
- (void) disconnectFromActivePeripheral;

@end
