//
//  XYZToDoListViewController.m
//  ToDoList
//
//  Created by Shah Hossain on 1/14/14.
//  Copyright (c) 2014 Shah Hossain. All rights reserved.
//

#import "XYZToDoListViewController.h"
#import "XYZDevice.h"
#import "XYZAddToDoItemViewController.h"

@interface XYZToDoListViewController ()

@property NSMutableArray *devices;
@property NSTimer *timer;
@property NSMutableDictionary *devicesDictionary;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) CBCentralManager *mCentralManager;
@end

@implementation XYZToDoListViewController


- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    XYZAddToDoItemViewController *source = [segue sourceViewController];
    XYZDevice *item = source.toDoItem;
    if (item != nil) {
        [self.devices addObject:item];
        [self.tableView reloadData];
    }
}

- (IBAction)refresh:(id)sender
{
    [self.devices removeAllObjects];
    [self.devicesDictionary removeAllObjects];
    [self.tableView reloadData];
    [self scanForPeripherals];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int) scanForPeripherals
{
    if (self.mCentralManager.state != CBCentralManagerStatePoweredOn)
    {
        NSLog(@"CoreBluetooth is %s", [self centralManagerStateToString:self.mCentralManager.state] );
        return -1;
    }
    self.refreshButton.enabled = NO;
    
    NSLog(@"Starting to scan");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.mCentralManager scanForPeripheralsWithServices:nil options:nil];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval: ( 15.0 )
             target: self
             selector: @selector ( onTimer )
             userInfo: nil repeats: NO];
    
    return 0;
}

- (void) onTimer
{
    NSLog ( @"timer fired" );
    self.refreshButton.enabled = YES;
    [self.mCentralManager stopScan];
    self.timer = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    XYZDevice *device = [self.devices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.deviceName;
    
    //todo: refactor
    if ( [device.deviceName hasPrefix:@"Flex"] ) cell.imageView.image = [UIImage imageNamed:@"fitbit"];
    else if ( [device.deviceName hasPrefix:@"Stick"] ) cell.imageView.image = [UIImage imageNamed:@"sticknfind"];
    else if ( [device.deviceName hasPrefix:@"iSmart"] ) cell.imageView.image = [UIImage imageNamed:@"lumen"];
    
    else cell.imageView.image = [UIImage imageNamed:@"unknown"];
    
    NSLog( @"row=%d value=%@", indexPath.row, device.deviceName);
//    if (toDoItem.completed) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    //XYZToDoItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    //tappedItem.completed = !tappedItem.completed;
    //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
        [self scanForPeripherals];
    }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ( ( [peripheral.name length] == 0 )
        || ( [self.devicesDictionary objectForKey:peripheral.identifier] != nil )) return;
    
    NSLog( @"Received peripheral :%@, id :%@", peripheral.name, peripheral.identifier );
    NSLog( @"Ad data :%@", advertisementData );
    
    XYZDevice *device = [[XYZDevice alloc] init];
    device.deviceName = peripheral.name;
    [self.devices addObject:device];
    [self.devicesDictionary setObject:device forKey:peripheral.identifier];
    [self.tableView reloadData];
}


- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected peripheral %@",peripheral);
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Error occured :%@",[error localizedDescription]);
}
@end
