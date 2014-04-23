//
//  XYZToDoListViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "LITDeviceListViewController.h"
#import "LITDevice.h"
#import "LITUPnPDevice.h"
#import "LITBLEDevice.h"
#import "LITLANDevice.h"
#import "LITDeviceDetailViewController.h"
#import "UPnPManager.h"
#import "DeviceListViewCell.h"
#import "Reachability.h"

#define WATCHDOG_TIMER_TIMEOUT               15.0
#define DEVICE_LIMIT                         50
#define DEVICE_LIST_CELL_ID                  @"deviceCollectionCellID"
#define SEGUE_ID_DEVICE_LIST_TO_DETAIL       @"segue-device-list-to-detail"

#define BLE_SERVICE_DEVICE_INFORMATION       @"180A"
#define BLE_CHARACTERISTICS_DEVICE_MODEL     @"2A24"
#define BLE_CHARACTERISTICS_MANUFACTURER     @"2A29"


@interface LITDeviceListViewController ()

@property NSMutableArray *devices;
@property NSMutableDictionary *devicesDictionary;
@property NSMutableSet *uPnPIPSet;
@property NSCache * deviceImageCache;
@property IBOutlet UIBarButtonItem *refreshButton;
@property IBOutlet UIBarButtonItem *deviceTotalLabel;
@property IBOutlet UIBarButtonItem * settingsButton;
@property UIBarButtonItem *activityIndicatorButton;
@property (strong, nonatomic) CBCentralManager *mCentralManager;
@property ScanLAN *lanScanner;

@end

@implementation LITDeviceListViewController

NSTimer *watchdogTimer;

- (IBAction)refresh:(id)sender
{
    [self startScanningForDevices];
    NSLog( @"Refresh button clicked" );
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.settingsButton.title = @"\u2699";
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys : [UIFont fontWithName : @"Helvetica" size : 28.0],
                          NSFontAttributeName, nil];
    [self.settingsButton setTitleTextAttributes : dict
                                       forState : UIControlStateNormal];
    
    self.deviceImageCache = [[NSCache alloc]init];
    self.devices = [[NSMutableArray alloc] init];
    self.uPnPIPSet = [[NSMutableSet alloc] init];
    
    self.devicesDictionary = [[NSMutableDictionary alloc] init];
    self.mCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    UPnPDB* db = [[UPnPManager GetInstance] DB];
    mBasicUPnPDevices = [db rootDevices];
    [db addObserver:(UPnPDBObserver*)self];
    //Optional; set User Agent
    [[[UPnPManager GetInstance] SSDP] setUserAgentProduct:@"lithouse/1.0" andOS:@"OSX"];
    //giving upnp a head start
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
    
    mBLEDevices = [[NSMutableArray alloc] init];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle : UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    self.activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView : activityIndicator];
    
}

- (void) viewWillAppear : (BOOL) animated {
    [self.navigationController setToolbarHidden : NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopScanningForDevices];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int) startScanningForDevices
{
    self.deviceTotalLabel.title = @"";
    if (self.mCentralManager.state != CBCentralManagerStatePoweredOn)
    {
        NSLog(@"CoreBluetooth is %s", [self centralManagerStateToString:self.mCentralManager.state] );
        return -1;
    }
    
    [self.devices removeAllObjects];
    [self.devicesDictionary removeAllObjects];
    [self.collectionView reloadData];
    [self.uPnPIPSet removeAllObjects];
    [mBLEDevices removeAllObjects];
    
    NSLog(@"Starting to scan");
    
    self.navigationItem.rightBarButtonItem = self.activityIndicatorButton;
    //important: during refresh, db update needs to be triggered manually
    //as upnpn db will hold onto discovered devices. 
    [self UPnPDBUpdated : nil];
    
    //search for upnp devices. Being defensive by stopping SSDP
    [[[UPnPManager GetInstance] SSDP] stopSSDP];
    [[[UPnPManager GetInstance] SSDP] startSSDP];
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
    //search for ble devices
    [self.mCentralManager scanForPeripheralsWithServices:nil options:nil];
    //search for lan devices - only if wifi is available
    if ( [self isWiFiAvailable] ) {
        [self.lanScanner stopScan];
        self.lanScanner = [[ScanLAN alloc] initWithDelegate:self];
        [self.lanScanner startScan];
    }
    
    watchdogTimer = [NSTimer scheduledTimerWithTimeInterval : ( WATCHDOG_TIMER_TIMEOUT )
                                                     target : self
                                                   selector : @selector ( onWatchdogTimerFired )
                                                   userInfo : nil
                                                     repeats: NO];

    return 0;
}

- (void) stopScanningForDevices {
    [watchdogTimer invalidate];
    
    NSLog ( @"stopping scan" );
    //close any open ble connection
    for ( CBPeripheral * peripheral in mBLEDevices ) {
        [self.mCentralManager cancelPeripheralConnection : peripheral];
    }
    
    [self postDeviceList];
    [self.mCentralManager stopScan];
    [self.lanScanner stopScan];
    [[[UPnPManager GetInstance] SSDP] stopSSDP];
    
    self.navigationItem.rightBarButtonItem = self.refreshButton;
}

- (void) onWatchdogTimerFired
{
    [self stopScanningForDevices];
}

-(BOOL) isWiFiAvailable
{
    Reachability * reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    return (status == ReachableViaWiFi);
}

- (void) postDeviceList
{
    NSURL * url = [NSURL URLWithString : [LITDevice restEndpoint :
                                          [[[UIDevice currentDevice] identifierForVendor] UUIDString]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL : url];
    
    request.HTTPMethod = @"POST";
    [request setValue : @"application/json; charset=utf-8" forHTTPHeaderField : @"Content-Type"];
    request.HTTPBody = [[LITDevice toJSONString : self.devices] dataUsingEncoding : NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest : request
                                       queue : [NSOperationQueue mainQueue]
                           completionHandler : ^(NSURLResponse *response,
                                                 NSData *data,
                                                 NSError *connectionError)
     {
     }];
}

- (const char *) centralManagerStateToString: (int)state
{
    switch(state)
    {
        case CBCentralManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    
    return "Unknown state";
}

#pragma mark - Collection view data source

- (NSInteger) collectionView : (UICollectionView *) view
      numberOfItemsInSection : (NSInteger) section;
{
    return [self.devices count];
}


- (UICollectionViewCell *) collectionView : (UICollectionView *) cv
                   cellForItemAtIndexPath : (NSIndexPath *) indexPath {
    
    DeviceListViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier : DEVICE_LIST_CELL_ID
                                                             forIndexPath : indexPath];
    
    LITDevice *device = [self.devices objectAtIndex : indexPath.row];
    
    cell.label.text = device.name;
    cell.image.image = device.smallIcon;
    
    [self fetchImagesAsync : cell withSourceDevice : device];
    
    return cell;
}

//todo : cleanup
- (void) fetchImagesAsync : (DeviceListViewCell *) aCell withSourceDevice : (LITDevice *) aDevice
{
    if ( aCell.image.image ) return;
    
    aCell.image.image = aDevice.smallIcon = [UIImage imageNamed : @"unknown"];
    
    NSString * urlString = [NSString stringWithFormat :
                            @"https://s3-us-west-1.amazonaws.com/lit-device-images/%@/default.png",
                            aDevice.type];
    
    UIImage * image = [self.deviceImageCache objectForKey : urlString];
    if ( image ) {
        aCell.image.image = aDevice.smallIcon = image;
        
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL :
                             [NSURL URLWithString : urlString]];
    
    [NSURLConnection sendAsynchronousRequest : request
                                       queue : [NSOperationQueue mainQueue]
                           completionHandler : ^(NSURLResponse *response,
                                                 NSData *data,
                                                 NSError *connectionError)
     {
         NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
         int statusCode = [httpResponse statusCode];
         
         if ( data.length > 0 && connectionError == nil  && statusCode == 200 ) {
             aCell.image.image = aDevice.smallIcon = [[UIImage alloc] initWithData:data];
             
             [self.deviceImageCache setObject : aCell.image.image
                                       forKey : urlString];
         }
     }];
    
}

- (void) prepareForSegue: ( UIStoryboardSegue * ) segue sender : ( id ) sender
{
    if ( [[segue identifier] isEqualToString : SEGUE_ID_DEVICE_LIST_TO_DETAIL] ) {
        //get the selected index
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex : 0];
        
        LITDeviceDetailViewController *targetVC = (LITDeviceDetailViewController *) segue.destinationViewController;
        targetVC.currentDevice = [self.devices objectAtIndex : indexPath.row];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle : @""
                                                                             style : UIBarButtonItemStylePlain
                                                                            target : nil
                                                                            action : nil];
}

#pragma mark -Central manager delegate method

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{    
    NSLog( @"CBT central state :%s", [self centralManagerStateToString:self.mCentralManager.state] );
    if ( self.mCentralManager.state == CBCentralManagerStatePoweredOn ) {
        //initial scan
        [self startScanningForDevices];
    }
}

- (void) centralManager : (CBCentralManager *) central
  didDiscoverPeripheral : (CBPeripheral *) peripheral
      advertisementData : (NSDictionary *) advertisementData
                   RSSI : (NSNumber *)RSSI
{
    if (( [peripheral.name length] == 0 )
        || ( [self.devicesDictionary objectForKey:peripheral.identifier] != nil )) return;
    
    NSLog( @"Received peripheral :%@, id :%@", peripheral.name, peripheral.identifier );
    
    //retaining ble devices
    [mBLEDevices addObject : peripheral];
    [self.mCentralManager connectPeripheral : peripheral options:nil ];
}


- (void) centralManager : (CBCentralManager *) central
   didConnectPeripheral : (CBPeripheral *) peripheral
{
    NSLog(@"Connected peripheral %@",peripheral);
    //@TODO branch for different ble devices
    
    peripheral.delegate = self;
    //look for device information
    NSArray *services = @[[CBUUID UUIDWithString : BLE_SERVICE_DEVICE_INFORMATION]];
    [peripheral discoverServices : services];
}


- (void) centralManager : (CBCentralManager *) central didFailToConnectPeripheral : (CBPeripheral *) peripheral
                  error : (NSError *)error
{
    NSLog(@"Error occured :%@",[error localizedDescription]);
}

#pragma mark protocol CBPeripheralDelegate

- (void) peripheral : (CBPeripheral *) peripheral didDiscoverServices : (NSError *) error {
    if ( error != nil ) {
        NSLog ( @"ERROR! failed device discovery %@", error );
        return;
    }
    
    for ( CBService *service in peripheral.services ) {
        if ( [service.UUID isEqual : [CBUUID UUIDWithString : BLE_SERVICE_DEVICE_INFORMATION]] ) {
            //look for manufacturer info
            NSArray *characteristics = @[[CBUUID UUIDWithString : BLE_CHARACTERISTICS_MANUFACTURER],
                                         [CBUUID UUIDWithString : BLE_CHARACTERISTICS_DEVICE_MODEL]];

            [peripheral discoverCharacteristics : characteristics forService : service];
        }
    }
    
}

- (void) peripheral : (CBPeripheral *) peripheral didDiscoverCharacteristicsForService : (CBService *) service
              error : (NSError *) error {
    if ( error != nil ) {
        NSLog ( @"ERROR! failed characteristics discovery %@", error );
        return;
    }
    
    NSString *manufacturer, *model;
    
    if ( [service.UUID isEqual : [CBUUID UUIDWithString : BLE_SERVICE_DEVICE_INFORMATION]] ) {
        for ( CBCharacteristic *characteristic in service.characteristics ) {
            
            if ( [characteristic.UUID isEqual : [CBUUID UUIDWithString : BLE_CHARACTERISTICS_MANUFACTURER]] ) {
                
                [peripheral readValueForCharacteristic : characteristic];
                if ( [characteristic value] == NULL ) return;
                manufacturer = [NSString stringWithUTF8String : [[characteristic value] bytes]];
                NSLog ( @"Manufacturer %@", manufacturer );
            } else if ( [characteristic.UUID isEqual : [CBUUID UUIDWithString : BLE_CHARACTERISTICS_DEVICE_MODEL]] ) {
                
                [peripheral readValueForCharacteristic : characteristic];
                if ( [characteristic value] == NULL ) return;
                model = [NSString stringWithUTF8String : [[characteristic value] bytes]];
                NSLog ( @"Model %@", model );
            }
        }
    }
    
    //add the ble device to list
    LITBLEDevice *device = [[LITBLEDevice alloc] initWithCBPeripheral : peripheral
                                                     withManufacturer : manufacturer
                                                      withDeviceModel : model];
    [self addDeviceToList : device withKey : peripheral.identifier];
    
    [self.mCentralManager cancelPeripheralConnection : peripheral];
}

- (LITDevice *) addDeviceToList : (LITDevice *) device
                        withKey : (id) key
{
    if ( [self.devices count] >= DEVICE_LIMIT ) {
        [self stopScanningForDevices];
        return nil;
    }
    
    LITDevice * addedDevice = [device updateDeviceList : self.devices
                                  withDeviceDictionary : self.devicesDictionary
                                               withKey : key];
    
    if ( addedDevice ) {
        self.deviceTotalLabel.title = [NSString stringWithFormat
                                       : @"Devices: %lu", (unsigned long)[self.devices count]];
        [self.collectionView reloadData];
    }
    
    return addedDevice;
}

#pragma mark protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender{
    NSLog(@"UPnPDBWillUpdate %lu", (unsigned long)[mBasicUPnPDevices count]);
}

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    NSLog(@"UPnPDBUpdated %lu", (unsigned long)[mBasicUPnPDevices count]);
    //todo: optimize the loop
    for ( BasicUPnPDevice * aBasicUPnPDevice in mBasicUPnPDevices ) {
        NSString * ipAddress = [[aBasicUPnPDevice baseURL] host];
    
        if ( [self.uPnPIPSet containsObject : ipAddress] == NO ) {
           [self.uPnPIPSet addObject : ipAddress];
            LITUPnPDevice * device = [[LITUPnPDevice alloc] initWithBasicUPnPDevice : aBasicUPnPDevice];
            [self addDeviceToList : device withKey : ipAddress];
        }
    }
}

#pragma mark LAN Scanner delegate method
- (void)scanLANDidFindNewAdrress : (NSString *) address
                  havingHostName : (NSString *) hostName
                havingMACAddress : (NSString *) macAddress
                      havingType : (NSString *) type {
    
    NSLog ( @"found  %@, type %@", address, type );
    LITLANDevice *device = [[LITLANDevice alloc] initWithName : hostName
                                                    ipAddress : address
                                                   macAddress : macAddress
                                                         type : type];
    
    [self addDeviceToList : device withKey : address];
}

- (void)scanLANDidFinishScanning {
    NSLog(@"Scan finished");
    [self stopScanningForDevices];
}

@end
