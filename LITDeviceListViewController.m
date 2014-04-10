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

#define DEVICE_LIMIT 50

@interface LITDeviceListViewController ()

@property NSMutableArray *devices;
@property NSMutableDictionary *devicesDictionary;
@property IBOutlet UIBarButtonItem *refreshButton;
@property UIBarButtonItem *activityIndicatorButton;
@property (strong, nonatomic) CBCentralManager *mCentralManager;
@property ScanLAN *lanScanner;

@end

@implementation LITDeviceListViewController

- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
//    LITDeviceDetailViewController *source = [segue sourceViewController];
//    LITDevice *item = source.toDoItem;
//    if (item != nil) {
//        [self.devices addObject:item];
//        [self.tableView reloadData];
//    }
}

- (IBAction)refresh:(id)sender
{
    [self startScanningForDevices];
    NSLog( @"Refresh button clicked" );
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.devices = [[NSMutableArray alloc] init];
    self.devicesDictionary = [[NSMutableDictionary alloc] init];
    self.mCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UPnPDB* db = [[UPnPManager GetInstance] DB];
    mBasicUPnPDevices = [db rootDevices];
    [db addObserver:(UPnPDBObserver*)self];
    //Optional; set User Agent
    [[[UPnPManager GetInstance] SSDP] setUserAgentProduct:@"lithouse/1.0" andOS:@"OSX"];
    mLANDevices = [[NSMutableArray alloc] init];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle : UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    self.activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView : activityIndicator];
    
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
    if (self.mCentralManager.state != CBCentralManagerStatePoweredOn)
    {
        NSLog(@"CoreBluetooth is %s", [self centralManagerStateToString:self.mCentralManager.state] );
        return -1;
    }
    
    [self.devices removeAllObjects];
    [self.devicesDictionary removeAllObjects];
    [self.tableView reloadData];
    [mLANDevices removeAllObjects];
    
    NSLog(@"Starting to scan");
    
    self.navigationItem.rightBarButtonItem = self.activityIndicatorButton;
    
    //search for upnp devices. Being defensive by stopping SSDP
    [[[UPnPManager GetInstance] SSDP] stopSSDP];
    [[[UPnPManager GetInstance] SSDP] startSSDP];
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
    //search for ble devices
    [self.mCentralManager scanForPeripheralsWithServices:nil options:nil];
    //search for lan devices
    [self.lanScanner stopScan];
    self.lanScanner = [[ScanLAN alloc] initWithDelegate:self];
    [self.lanScanner startScan];
    
    return 0;
}


- (void) stopScanningForDevices {
    NSLog ( @"stopping scan" );
    [self.mCentralManager stopScan];
    [self.lanScanner stopScan];
    [[[UPnPManager GetInstance] SSDP] stopSSDP];
    
    NSLog ( @"UPnP device count = %lu", (unsigned long) [mBasicUPnPDevices count] );
    NSLog ( @"LAN device count = %lu", (unsigned long) [mLANDevices count] );
    
    for ( BasicUPnPDevice* uPnPDevice in mBasicUPnPDevices ) {
        [self registerUPnPDevice : uPnPDevice];
    }
    
    
    for ( LITLANDevice *lanDevice in mLANDevices ) {
        [self addDeviceToList : lanDevice withKey : [lanDevice ipAddress]];
    }
    
    NSLog ( @"Total device count = %lu", (unsigned long) [self.devices count] );
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = self.refreshButton;
}

- (LITUPnPDevice *) registerUPnPDevice: (BasicUPnPDevice *) uPnPDevice {
    LITUPnPDevice *device = [[LITUPnPDevice alloc] initWithBasicUPnPDevice:uPnPDevice];
    
    return (LITUPnPDevice *) [self addDeviceToList : device withKey : [device ipAddress]];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView: (UITableView *) tableView numberOfRowsInSection : (NSInteger) section
{
    return [self.devices count];
}

- (UITableViewCell *) tableView : (UITableView *) tableView cellForRowAtIndexPath : (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    LITDevice *device = [self.devices objectAtIndex:indexPath.row];
    
    cell.textLabel.text = device.name;
    cell.imageView.image = device.smallIcon;
        
//    if (toDoItem.completed) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LITDevice *device = [ self.devices objectAtIndex:indexPath.row ];
    //@TODO consider other devices
   /* if ( [device.name hasPrefix:@"Stick"] ) {
        self.currentDevice = device;
    
        NSLog ( @"going to alert with %@: ", device.peripheral.name );
    
        [self performSegueWithIdentifier: @"sticknfind.seague" sender: self];
    }*/
}

- (void) prepareForSegue: ( UIStoryboardSegue * ) segue sender : ( id ) sender
{
    //LITDeviceDetailViewController *targetVC = ( LITDeviceDetailViewController* ) segue.destinationViewController;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

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
    
    LITBLEDevice *device = [[LITBLEDevice alloc] initWithCBPeripheral:peripheral];
    [self addDeviceToList : device withKey : peripheral.identifier];
    
    [self.tableView reloadData];
    
    [self.mCentralManager connectPeripheral : peripheral options:nil ];
}


- (void) centralManager : (CBCentralManager *) central
   didConnectPeripheral : (CBPeripheral *) peripheral
{
    NSLog(@"Connected peripheral %@",peripheral);
    //@TODO branch for different ble devices
    
    peripheral.delegate = self;
    //look for device information
    NSArray *services = @[[CBUUID UUIDWithString : @"180A"]];
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
        if ( [service.UUID isEqual : [CBUUID UUIDWithString : @"180A"]] ) {
            //look for manufacturer info
            NSArray *characteristics = @[[CBUUID UUIDWithString : @"2A29"]];

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
    
    if ( [service.UUID isEqual : [CBUUID UUIDWithString : @"180A"]] ) {
        for ( CBCharacteristic *characteristic in service.characteristics ) {
            
            if ( [characteristic.UUID isEqual : [CBUUID UUIDWithString : @"2A29"]] ) {
                
                [peripheral readValueForCharacteristic : characteristic];
                NSString *manufacturer = [NSString stringWithUTF8String : [[characteristic value] bytes]];
                NSLog ( @"Manufacturer %@", manufacturer );
                
                LITDevice *device = [self.devicesDictionary objectForKey : peripheral.identifier];
                device.manufacturer = manufacturer;
            }
        }
    }
    
    [self.mCentralManager cancelPeripheralConnection : peripheral];
}

//Todo: move to new class, make it thread safe
- (LITDevice *) addDeviceToList : (LITDevice *) device withKey : (id) key {
    if ( [self.devices count] >= DEVICE_LIMIT ) {
        [self stopScanningForDevices];
        return nil;
    }
    
    if ( [self.devicesDictionary objectForKey : key] != nil ) return nil;
    
    [self.devices addObject : device];
    [self.devicesDictionary setObject : device forKey : key];
    
    return device;
}

#pragma mark protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender{
    NSLog(@"UPnPDBWillUpdate %lu", (unsigned long)[mBasicUPnPDevices count]);
}

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    NSLog(@"UPnPDBUpdated %lu", (unsigned long)[mBasicUPnPDevices count]);
    //BasicUPnPDevice* basicUPnPdevice = [ mBasicUPnPDevices objectAtIndex: ([mBasicUPnPDevices count]-1) ];
    
    //LITUPnPDevice *device = [self registerUPnPDevice:basicUPnPdevice];
    
    //[self.tableView reloadData];

    //NSLog(@"upnp name = %@ uid = %@ type = %@ manufacturer = %@", [device name], [device uid], [device type], [device manufacturer]);
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
    [mLANDevices addObject:device];
}

- (void)scanLANDidFinishScanning {
    NSLog(@"Scan finished");
    [self stopScanningForDevices];
}

@end
