//
//  project: ShockVx
//     file: AssetListController.m
//
//  Asset list table view controller with sections for
//  shipped assets and received assets.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "AssetListCell.h"
#import "AssetListController.h"
#import "AssetTabsController.h"
#import "AssetViewController.h"
#import "AccountRegistrationViewController.h"

@interface AssetListController ( )

@property (nonatomic, weak, readonly)   AppSettings *           settings;
@property (nonatomic, weak, readonly)   AssetRegistry *         registry;
@property (nonatomic, strong)           CBCentralManager *      manager;
@property (nonatomic, strong)           NSMutableDictionary *   records;

@property (nonatomic, strong)           NSTimer *               centralTimer;
@property (nonatomic, strong)           NSTimer *               signalTimer;

@property (nonatomic, strong)           AssetSensor *           assetSensor;
@property (nonatomic, strong)           AssetIdentifier *       assetUnit;
@property (nonatomic, strong)           AssetIdentifier *       assetNode;
@property (nonatomic, strong)           AssetTag *              assetTag;

@end

@implementation AssetListController

- (void) viewDidLoad {

    AppDelegate *   application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    _registry                   = application.registry;
    _settings                   = application.settings;

    [super viewDidLoad];

    // Construct the Bluetooth LE central manager to look for nearby sensors.
    
    _records                    = [[NSMutableDictionary alloc] init];
    _manager                    = [[CBCentralManager alloc] initWithDelegate:self
                                                                       queue:dispatch_queue_create("com.velvetwire.shock.vx.central", DISPATCH_QUEUE_SERIAL)
                                                                     options:@{ CBCentralManagerOptionShowPowerAlertKey:@NO, CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];

    // Construct a central manager timer to refresh the scan every minute and
    // a signal timer to refresh the broadcast signal table every 5 seconds.
    
    _centralTimer               = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                                   target:self
                                                                 selector:@selector(centralTimer:)
                                                                 userInfo:nil
                                                                  repeats:YES];

    _signalTimer                = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                   target:self
                                                                 selector:@selector(centralTimer:)
                                                                 userInfo:nil
                                                                  repeats:YES];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // If there is no user code set, show the registration...
    if ( ! self.settings.userCode ) [self performSegueWithIdentifier:@"showRegistration" sender:nil];

}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)table { return ( 1 ); }

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return [self.registry assetCount]; }

- (UITableViewCell *) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {

    AssetListCell *     cell        = [table dequeueReusableCellWithIdentifier:@"assetCell" forIndexPath:path];
    NSDictionary *      asset       = [self.registry assetAtIndex:path.row];
    AssetIdentifier *   identifier  = [AssetIdentifier identifierWithData:[asset objectForKey:@"identifier"]];
    NSDictionary *      broadcast   = nil;
    
    if ( cell ) {
    
        NSDate *        opened      = [asset objectForKey:@"opened"];
        NSDate *        closed      = [asset objectForKey:@"closed"];
        
        [cell setIdentity:[identifier identifierString]];

        [cell setLocation:[asset objectForKey:@"location"]];
        [cell setLabel:[asset objectForKey:@"label"]];
        
        if ( closed ) {
            
            NSDateFormatter *   formatter   = [[NSDateFormatter alloc] init];
            formatter.dateStyle             = NSDateFormatterShortStyle;
            formatter.timeStyle             = NSDateFormatterShortStyle;
            
            [cell setStatus:[NSString stringWithFormat:@"closed %@",[formatter stringFromDate:closed]]];

        } else if ( opened ) {
            
            NSDateFormatter *   formatter   = [[NSDateFormatter alloc] init];
            formatter.dateStyle             = NSDateFormatterShortStyle;
            formatter.timeStyle             = NSDateFormatterShortStyle;
            
            [cell setStatus:[NSString stringWithFormat:@"opened %@",[formatter stringFromDate:opened]]];

        } else [cell setStatus:nil];
        
    } else return nil;
        
    if ( identifier && (broadcast = [self.records objectForKey:[identifier identifierString]]) ) {
    
        NSNumber *      signal      = [broadcast objectForKey:@"signal"];
        NSNumber *      battery     = [broadcast objectForKey:@"battery"];
        
        if ( signal ) [cell setRange:[NSString stringWithFormat:@"%i dB", [signal intValue]]];
        if ( battery ) [cell setBattery:battery];

        NSNumber *      surface     = [broadcast objectForKey:@"surface"];
        NSNumber *      ambient     = [broadcast objectForKey:@"ambient"];
        NSNumber *      humidity    = [broadcast objectForKey:@"humidity"];
        NSNumber *      pressure    = [broadcast objectForKey:@"pressure"];
        
        [cell setSurface:surface];
        [cell setAmbient:ambient];
        [cell setHumidity:humidity];
        [cell setPressure:pressure];
        
    } else {
    
        [cell setPressure:nil];
        [cell setHumidity:nil];
        [cell setAmbient:nil];
        [cell setSurface:nil];
        
        [cell setBattery:nil];
        [cell setRange:nil];
        
    }

    return ( cell );

}

- (BOOL) tableView:(UITableView *)table canEditRowAtIndexPath:(NSIndexPath *)path { return YES; }

- (void) tableView:(UITableView *)table commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)path {

    NSDictionary *  asset       = [self.registry assetAtIndex:path.row];
    NSData *        identifier  = [asset objectForKey:@"identifier"];
    
    if ( style == UITableViewCellEditingStyleDelete ) {

        [self.registry removeAssetWithIdentifier:identifier];
        [table deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    
    }

}

#pragma mark - Navigation

//
// Prepare for a segue transition to another view
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // If transitioning to the asset summary view...
    
    if ( [segue.identifier isEqualToString:@"showAsset"] ) {
        
        AssetViewController *       controller  = (AssetViewController *) [segue destinationViewController];

    }

    // If tranisitioning to the connected asset view, set the asset sensor.
    
    if ( [segue.identifier isEqualToString:@"connectAsset"] ) {

        AssetTabsController *       controller  = (AssetTabsController *) [segue destinationViewController];
        AssetSensor *               sensor      = (AssetSensor *) sender;
        NSDictionary *              record      = [self.registry assetForIdentifier:[sensor.identifier identifierData]];
        
        [controller setAssetDescription:[record objectForKey:@"label"]];
        [controller setAssetLocale:[record objectForKey:@"location"]];

        [controller setSensor:sensor];
        
    }
    
    // If transitioning to registration, hide the navigation bar.
    
    if ( [segue.identifier isEqualToString:@"showRegistration"] ) {

        [self.navigationController setNavigationBarHidden:YES animated:YES];

    }
    
}

//
// Registration form has been completed
- (IBAction) unwindRegistration:(UIStoryboardSegue *)segue {

    AccountRegistrationViewController * controller  = (AccountRegistrationViewController *) [segue sourceViewController];

    // Update the settings with the registration information from the form.
    
    [self.settings setUserName:controller.userName code:controller.userCode];
    [self.settings setUserMail:controller.userMail password:controller.userPassword];
    
    // Restore the navigation bar.
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

}

//
// Connection to sensor has been dropped
- (IBAction) disconnectSensor:(UIStoryboardSegue *)segue {

    AssetTabsController *       controller  = (AssetTabsController *) [segue sourceViewController];
    NSData *                    identifier  = [controller.sensor.identifier identifierData];
    NSUInteger                  index       = [self.registry indexOfAssetWithIdentifier:identifier];
    
    [self.registry setLabel:controller.assetDescription
                andLocation:controller.assetLocale
     forAssetWithIdentifier:identifier];

    [self.registry setOpened:controller.sensor.control.timeOpened
                   andClosed:controller.sensor.control.timeClosed
      forAssetWithIdentifier:identifier];
    
    if ( index != NSNotFound ) {
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    
    }
    
}

//
// Connection to sensor has been dropped
- (IBAction) disconnectTracker:(UIStoryboardSegue *)segue {

    // Placeholder
    
}

#pragma mark - Asset Tag Scanning

- (IBAction) scanAsset:(id)sender {

    // Get the name of the mobile device and construct a prompt to instruct
    // the operator to read the equipment tag.
    
    NSString *  name    = [[UIDevice currentDevice] name];
    NSString *  prompt  = [NSString stringWithFormat:@"Place %@ near the top of the sensor to scan its activation code.", name];
    
    // Start an NFC tag reading session to read the sensor tag.
    
    [self setAssetTag:[[AssetTag alloc] initWithDelegate:self]];
    [self.assetTag scanWithPrompt:prompt];
    
}

- (void) tag:(AssetTag *)tag unit:(NSData *)unit {

    if ( unit ) { NSLog ( @"Scanned unit %@", [tag.assetUnit identifierString] ); }

    // Restart the central scanner
    
    if ( [self.manager isScanning] ) for ( [self centralManagerCeaseScan:self.manager]; [self.manager isScanning]; );
    [self centralManagerStartScan:self.manager];

    // Select the unit and release the sensor tag instace.
    
    [self setAssetUnit:tag.assetUnit];
    [self setAssetNode:tag.assetNode];
    [self setAssetTag:nil];
    
}

- (void) tag:(AssetTag *)tag error:(NSError *)error {

    [self setAssetUnit:nil];
    [self setAssetNode:nil];
    [self setAssetTag:nil];
    
}

#pragma mark - Bluetooth Central Manager

//
// Central manager scan refresh timer
- (void) centralTimer:(NSTimer *)timer {

    // Pause and restart the scan after 5 seconds.
    
    if ( timer == self.centralTimer ) {
    
        [self centralManagerCeaseScan:self.manager];
        [self performSelector:@selector(centralManagerStartScan:) withObject:self.manager afterDelay:5.0];
    
    }
    
    // Check the list of broadcast records and clear the received
    // signal element. If there is no signal element, remove the
    // record from the list.
    
    if ( timer == self.signalTimer ) {
    
        NSMutableArray *    lost    = [[NSMutableArray alloc] init];
        NSMutableArray *    rows    = [[NSMutableArray alloc] init];

        for ( NSString * identity in [self.records allKeys] ) {
            
            NSMutableDictionary *   record      = [self.records objectForKey:identity];
        
            if ( [record objectForKey:@"signal"] ) [record removeObjectForKey:@"signal"];
            else [lost addObject:identity];
        
        }

        for ( NSString * identity in lost ) {
            
            AssetIdentifier *   identifier  = [AssetIdentifier identifierWithString:identity];
            NSUInteger          index       = [self.registry indexOfAssetWithIdentifier:[identifier identifierData]];
            
            if ( index != NSNotFound ) [rows addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            
        }

        if ( lost.count ) [self.records removeObjectsForKeys:lost];
        
        if ( ! [self.tableView isEditing] ) {
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
        }
        
    }
    
}

//
// Respond to bluetooth state changes
- (void) centralManagerDidUpdateState:(CBCentralManager *)central {

    if ( central.state == CBManagerStatePoweredOn ) { [self centralManagerStartScan:self.manager]; }
    
}

- (void) centralManagerStartScan:(CBCentralManager *)central {

    NSMutableArray *    services    = [[NSMutableArray alloc] init];
    
    // Scan for devices that publish the control service.
    
    //[services addObject:[CBUUID UUIDWithString:kSensorControlServiceUUID]];
    
    if ( self.manager.state == CBManagerStatePoweredOn && !self.manager.isScanning ) {
        [self.manager scanForPeripheralsWithServices:services options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES } ];
    }
    
}

- (void) centralManagerCeaseScan:(CBCentralManager *)central {

    if ( self.manager.state == CBManagerStatePoweredOn && self.manager.isScanning ) {
        [self.manager stopScan];
    }
    
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisement RSSI:(NSNumber *)rssi {

    NSDictionary *          productData = [advertisement objectForKey:CBAdvertisementDataManufacturerDataKey];
    NSDictionary *          serviceData = [advertisement objectForKey:CBAdvertisementDataServiceDataKey];
    NSArray *               serviceList = [advertisement objectForKey:CBAdvertisementDataServiceUUIDsKey];

    // Get the unit identfier from advertisement service data and associate the
    // peripheral reference.
    
    NSData *                broadcast   = [serviceData objectForKey:[CBUUID UUIDWithString:@"5657"]];
    NSData *                identifier  = [serviceData objectForKey:[CBUUID UUIDWithString:kSensorInformationServiceUUID]];
    NSNumber *              connectable = [advertisement objectForKey:CBAdvertisementDataIsConnectable];

    // If the sensor unit identifier has been targeted for connection, start the peripheral
    // connection process.
    
    if ( connectable ) {

        if ( identifier && [identifier isEqualToData:[self.assetUnit identifierData]] ) {
        
            if ( peripheral.state == CBPeripheralStateDisconnected ) {
            
                [self setAssetSensor:[AssetSensor sensorForPeripheral:peripheral withIdentifier:self.assetUnit accessKey:nil]];
                [self.manager connectPeripheral:peripheral options:nil];
            
            }
            
        }

    }

    // If broadcast data is available, parse the broadcast packet
    
    if ( broadcast ) [self centralManager:central didReceivePeripheral:peripheral broadcastData:broadcast RSSI:rssi];
    
}

- (void) centralManager:(CBCentralManager *)central didReceivePeripheral:(CBPeripheral *)peripheral broadcastData:(NSData *)data RSSI:(NSNumber *)rssi {

    AssetBroadcast *        broadcast   = [AssetBroadcast broadcastFromData:data];
    NSString *              identifier  = [broadcast.identifier identifierString];
    NSUInteger              index       = NSNotFound;
    NSMutableDictionary *   record      = nil;
    
    if ( identifier ) {
        
        if ( ! (record = [self.records objectForKey:identifier]) ) { [self.records setObject:[[NSMutableDictionary alloc] initWithDictionary:@{@"signal":rssi}] forKey:identifier]; }
        else { [record setObject:rssi forKey:@"signal"]; }
    
    }
    
    if ( record ) {
        
        if ( broadcast.battery ) [record setObject:broadcast.battery forKey:@"battery"];
        if ( broadcast.horizon ) [record setObject:broadcast.horizon forKey:@"horizon"];
        
        if ( broadcast.temperature ) [record setObject:broadcast.temperature forKey:@"surface"];
        
        if ( broadcast.airTemperature) [record setObject:broadcast.airTemperature forKey:@"ambient"];
        if ( broadcast.airHumidity ) [record setObject:broadcast.airHumidity forKey:@"humidity"];
        if ( broadcast.airPressure ) [record setObject:broadcast.airPressure forKey:@"pressure"];
        
        if ( broadcast.orientationFace ) [record setObject:broadcast.orientationFace forKey:@"orientation"];
        if ( broadcast.tiltAngle ) [record setObject:broadcast.tiltAngle forKey:@"angle"];
        
    }

    if ( NSNotFound != (index = [self.registry indexOfAssetWithIdentifier:[broadcast.identifier identifierData]]) ) dispatch_async( dispatch_get_main_queue( ), ^{
    
        NSIndexPath *       path        = [NSIndexPath indexPathForRow:index inSection:0];

        if ( ! [self.tableView isEditing] ) {
        
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        
        }
        
    });
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    NSData *        identifier  = [self.assetUnit identifierData];
    NSDictionary *  asset       = [self.registry assetForIdentifier:identifier];
    
    if ( [self.assetSensor attachPeripheral:peripheral toManager:central] ) dispatch_async( dispatch_get_main_queue( ), ^{
        
        if ( !(asset) && [self.registry assetWithIdentifier:identifier label:@"New Asset"] ) {
        
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
        }
        
        [self performSegueWithIdentifier:@"connectAsset" sender:self.assetSensor];
        
    });
    
    [self setAssetUnit:nil];
    [self setAssetNode:nil];

}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    [self setAssetSensor:nil];
    
    [self setAssetUnit:nil];
    [self setAssetNode:nil];

}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {

    if ( self.assetSensor ) dispatch_async( dispatch_get_main_queue( ), ^{
    
        [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationDropped object:self.assetSensor userInfo:nil];
        [self setAssetSensor:nil];
    
    });
                                           
}

@end
