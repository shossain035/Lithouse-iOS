//
//  AppDelegate.m
//  ToDoList
//
//  Created by Shah Hossain on 1/12/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "AppDelegate.h"

#define LUMEN_LEVEL_BRIGHT             400

@interface AppDelegate() <BLEDelegate>
@property (readonly, strong, nonatomic) PHHueSDK * phHueSDK;
@property (readonly, strong, nonatomic) BLE      * ble;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize phHueSDK = _phHueSDK;
@synthesize ble = _ble;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Create hue sdk instance
    _phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging : YES];
    
    //Create Redbearlab BLE SDK instance
    _ble = [[BLE alloc] init];
    [self.ble controlSetup];
    self.ble.delegate = self;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TestCoreData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


+ (PHHueSDK *) getHueSDK
{
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    return [appDelegate phHueSDK];
}

+ (void) updateLastReachableHueLight : (BOOL) toState
{
    PHBridgeResourcesCache * cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    PHLight * light = nil;
    
    //grab the last light. todo: consider more than one hue light
    for ( PHLight * currentlight in cache.lights.allValues ) {
        if ( [currentlight.lightState.reachable boolValue] ) {
            light = currentlight;
        }
    }
    PHLightState * lightState = [[PHLightState alloc] init];
    
    [lightState setOnBool : toState];
    
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    
    [bridgeSendAPI updateLightStateForId : light.identifier
                           withLighState : lightState
                       completionHandler : ^(NSArray *errors) {
                           if (errors != nil) {
                               NSString * message = [NSString stringWithFormat : @"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                               
                               NSLog(@"Response: %@",message);
                           }
                       }];

}

#pragma mark - BLE delegate

 -(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    // send reset
    UInt8 bufReset[] = {0x04, 0x00, 0x00};
    NSData * data = [[NSData alloc] initWithBytes : bufReset
                                           length : 3];
    [self.ble write : data];
    
    UInt8 bufAnalogIn[] = {0xA0, 0x01, 0x00};
    
    //send analog in
    data = [[NSData alloc] initWithBytes : bufAnalogIn
                                  length : 3];
    [self.ble write : data];
}

-(void) bleDidDisconnect
{
    NSLog(@"->Disonnected");
}

// When data is comming, this will be called
-(void) bleDidReceiveData : (unsigned char *) data
                   length : (int) length
{
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3) {
        
        if (data[i] == 0x0A) {
            /*
            if (data[i+1] == 0x01)
                swDigitalIn.on = true;
            else
                swDigitalIn.on = false;
             */
        }
        else if (data[i] == 0x0B) {
            UInt16 value;
            
            value = data[i+2] | data[i+1] << 8;
            NSLog ( @"lumen: %@", [NSString stringWithFormat:@"%d", value]);
            
            if ( value > LUMEN_LEVEL_BRIGHT ) {
                [AppDelegate updateLastReachableHueLight : NO];
            } else {
                [AppDelegate updateLastReachableHueLight : YES];
            }
        }        
    }
}

#pragma mark - Actions

// Connect button will call to this
- (void) scanForPeripherals
{
    //already connected just return
    if(self.ble.activePeripheral.state == CBPeripheralStateConnected) {
        return;
    }
    
    self.ble.peripherals = nil;
    
    //search for 2 seconds
    [self.ble findBLEPeripherals : 2];
    
    [NSTimer scheduledTimerWithTimeInterval : 2.0f
                                     target : self
                                   selector : @selector(bleScanTimeoutTimer:)
                                   userInfo : nil
                                    repeats : NO];
}

-(void) bleScanTimeoutTimer : (NSTimer *)timer
{
    //connect with the first shield
    if (self.ble.peripherals.count > 0) {
        [self.ble connectPeripheral : [self.ble.peripherals objectAtIndex:0]];
    }
    else {
        
    }
}

- (void) disconnectFromActivePeripheral
{
    [[self.ble CM] cancelPeripheralConnection : [self.ble activePeripheral]];
}


@end
