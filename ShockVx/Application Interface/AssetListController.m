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
#import "AssetListController.h"
#import "AssetTabsController.h"
#import "AssetViewController.h"
#import "UpdateDeviceController.h"
#import "AccountRegistrationViewController.h"

@interface AssetListController ( )

@property (nonatomic, weak, readonly)   AppSettings *           settings;
@property (nonatomic, weak, readonly)   AssetRegistry *         registry;
@property (nonatomic, strong)           CBCentralManager *      manager;

@property (nonatomic, strong)           NSMutableDictionary *   records;
@property (nonatomic, strong)           NSMutableDictionary *   devices;

@property (nonatomic, strong)           NSTimer *               centralTimer;
@property (nonatomic, strong)           NSTimer *               signalTimer;

@property (nonatomic, strong)           AssetDevice *           assetDevice;
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
    _devices                    = [[NSMutableDictionary alloc] init];
    _manager                    = [[CBCentralManager alloc] initWithDelegate:self
                                                                       queue:dispatch_queue_create("com.velvetwire.shock.vx.central", DISPATCH_QUEUE_SERIAL)
                                                                     options:@{ CBCentralManagerOptionShowPowerAlertKey:@NO, CBCentralManagerScanOptionAllowDuplicatesKey:@NO }];

    // Construct a central manager timer to refresh the scan every minute and
    // a signal timer to refresh the broadcast signal table every 7.5 seconds.
    
    _centralTimer               = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                                   target:self
                                                                 selector:@selector(centralTimer:)
                                                                 userInfo:nil
                                                                  repeats:YES];

    _signalTimer                = [NSTimer scheduledTimerWithTimeInterval:7.5
                                                                   target:self
                                                                 selector:@selector(centralTimer:)
                                                                 userInfo:nil
                                                                  repeats:YES];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void) viewWillAppear:(BOOL)animated {

    // Make sure the navigation bar is restored when transitioning back to the stack.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewWillAppear:animated];
    
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
    
    if ( [segue.identifier isEqualToString:@"showSensor"] ) {
        
        AssetViewController *       controller  = (AssetViewController *) [segue destinationViewController];

    }

    // If tranisitioning to the device update controller, prepare.
    
    if ( [segue.identifier isEqualToString:@"connectUpdate"] ) {

        UpdateDevice *              device      = (UpdateDevice *) sender;
        UpdateDeviceController *    controller  = (UpdateDeviceController *) [segue destinationViewController];

        [self.navigationController setNavigationBarHidden:YES animated:YES];

        [controller setDevice:device];

    }
    
    // If tranisitioning to the connected asset controller, prepare.
    
    if ( [segue.identifier isEqualToString:@"connectSensor"] ) {

        SensorDevice *              sensor      = (SensorDevice *) sender;
        NSData *                    identifier  = [sensor.unitIdentifier identifierData];
        NSDictionary *              record      = [self.registry assetForIdentifier:identifier];
        AssetTabsController *       controller  = (AssetTabsController *) [segue destinationViewController];

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
- (IBAction) completeRegistration:(UIStoryboardSegue *)segue {

    AccountRegistrationViewController * controller  = (AccountRegistrationViewController *) [segue sourceViewController];

    // Update the settings with the registration information from the form.
    
    [self.settings setUserName:controller.userName code:controller.userCode];
    [self.settings setUserMail:controller.userMail password:controller.userPassword];
    
}

//
//
- (IBAction) updgradeDevice:(UIStoryboardSegue *)segue {

    NSUUID *        controlService  = [[NSUUID alloc] initWithUUIDString:kDeviceAccessServiceUUID];
    NSUUID *        upgradeService  = [[NSUUID alloc] initWithUUIDString:kUpdateControlServiceUUID];
    AssetDevice *   device          = [UpdateDevice updateWithUnit:self.assetDevice.unitIdentifier
                                                              node:self.assetDevice.nodeIdentifier
                                                    controlService:controlService
                                                    primaryService:upgradeService];
    
    dispatch_async( dispatch_get_main_queue( ), ^{ [self setAssetDevice:device]; });
    
}

//
// Connection to device has been dropped
- (IBAction) disconnectDevice:(UIStoryboardSegue *)segue {

    // NOTE: connection dropped
    
}

//
// Connection to sensor has been closed
- (IBAction) disconnectSensor:(UIStoryboardSegue *)segue {

    AssetTabsController *       controller  = (AssetTabsController *) [segue sourceViewController];
    NSData *                    identifier  = [controller.sensor.unitIdentifier identifierData];
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
// Connection to tracker has been closed
- (IBAction) disconnectTracker:(UIStoryboardSegue *)segue {

    // NOTE: placeholder

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

    // Stop scanning while we analyze the tag.
    
    if ( [self.manager isScanning] ) for ( [self centralManagerCeaseScan:self.manager]; [self.manager isScanning]; );

    // If this is tagged as the boot loader device, construct a reference to a new
    // firmware update device.
    
    if ( [[tag.primaryService UUIDString] isEqualToString:kUpdateControlServiceUUID]
      || [[tag.primaryService UUIDString] isEqualToString:kLoaderControlServiceUUID] ) {

        [self setAssetDevice:[UpdateDevice updateWithUnit:tag.assetUnit node:tag.assetUnit controlService:tag.controlService primaryService:tag.primaryService]];

    }
    
    // If this is tagged as a Vx sensor, construct a reference to a new sensor device.
    
    if ( [[tag.primaryService UUIDString] isEqualToString:kSensorControlServiceUUID] ) {

        [self setAssetDevice:[SensorDevice sensorWithUnit:tag.assetUnit node:tag.assetUnit controlService:tag.controlService primaryService:tag.primaryService]];

    }
    
    // NOTE: check for tracker here
    
    // Restart scanning and clear the tag reference.
    
    [self centralManagerStartScan:self.manager];
    [self setAssetTag:nil];
    
}

- (void) tag:(AssetTag *)tag error:(NSError *)error {

    [self setAssetTag:nil];
    
}

#pragma mark - Bluetooth Central Manager

//
// Central manager scan refresh timer
- (void) centralTimer:(NSTimer *)timer {

    // Pause and restart the scan after 2.5 seconds.
    
    if ( timer == self.centralTimer ) {
    
        [self centralManagerCeaseScan:self.manager];
        [self performSelector:@selector(centralManagerStartScan:) withObject:self.manager afterDelay:2.5];

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

    // Start scanning for beacon broadcasts.
    
    if ( central.state == CBManagerStatePoweredOn ) { [self centralManagerStartScan:self.manager]; }
    
}

- (void) centralManagerStartScan:(CBCentralManager *)central { [self centralManagerStartScan:central forServices:nil]; }

- (void) centralManagerStartScan:(CBCentralManager *)central forServices:(NSArray *)services {

    if ( self.manager.state == CBManagerStatePoweredOn && !self.manager.isScanning ) {
        
        [self.manager scanForPeripheralsWithServices:services
                                             options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES } ];
    
    }
    
}

- (void) centralManagerCeaseScan:(CBCentralManager *)central {

    if ( self.manager.state == CBManagerStatePoweredOn && self.manager.isScanning ) [self.manager stopScan];
    
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisement RSSI:(NSNumber *)rssi {

    NSDictionary *          productData = [advertisement objectForKey:CBAdvertisementDataManufacturerDataKey];
    NSDictionary *          serviceData = [advertisement objectForKey:CBAdvertisementDataServiceDataKey];
    NSArray *               serviceList = [advertisement objectForKey:CBAdvertisementDataServiceUUIDsKey];

    // Get the unit identfier from advertisement service data and determine
    // whether it is connectable.
    
    NSData *                identifier  = [serviceData objectForKey:[CBUUID UUIDWithString:kDeviceInformationServiceUUID]];
    NSNumber *              connectable = [advertisement objectForKey:CBAdvertisementDataIsConnectable];

    if ( identifier ) {
    
        // Associate the identifier with the peripheral.
        
        [self.devices setValue:[AssetIdentifier identifierWithData:identifier] forKey:[peripheral.identifier UUIDString]];

        // If the peripheral is connectable and has been targeted for connection,
        // request a connection to the device.

        if ( connectable && [self.assetDevice.unitIdentifier matchesData:identifier] ) {
            
            [self.assetDevice assignPeripheral:peripheral];
            
            if ( peripheral.state == CBPeripheralStateDisconnected ) [central connectPeripheral:peripheral options:nil];

        }
        
    }

    // If a broadcast is available, in either the standard or the extended
    // service data class, process the broadcast data. Update the items in
    // the asset table that are refreshed.

    if ( serviceData ) {
    
        NSMutableSet *          indexSet    = [[NSMutableSet alloc] init];
        NSData *                standard    = [serviceData objectForKey:[CBUUID UUIDWithString:kAssetBroadcastStandardUUID]];
        NSData *                extended    = [serviceData objectForKey:[CBUUID UUIDWithString:kAssetBroadcastExtendedUUID]];
        NSIndexPath *           item        = nil;
            
        if ( standard && (item = [self centralManager:central didReceivePeripheral:peripheral broadcastData:standard RSSI:rssi]) ) [indexSet addObject:item];
        if ( extended && (item = [self centralManager:central didReceivePeripheral:peripheral broadcastData:extended RSSI:rssi]) ) [indexSet addObject:item];

        if ( [indexSet count] ) dispatch_async( dispatch_get_main_queue( ), ^{
        
            if ( ! [self.tableView isEditing] ) {
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:[indexSet allObjects] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        
        });
        
    }

}

- (NSIndexPath *) centralManager:(CBCentralManager *)central didReceivePeripheral:(CBPeripheral *)peripheral broadcastData:(NSData *)data RSSI:(NSNumber *)rssi {

    AssetBroadcast *        broadcast   = [AssetBroadcast broadcastFromData:data];
    AssetIdentifier *       identifier  = [self.devices objectForKey:[peripheral.identifier UUIDString]];

    // If we don't already have the asset identifier associated with this
    // peripheral, attempt to assign one from the broadcast, if provided.
    
    if ( ! identifier ) {
        
        if ( (identifier = broadcast.identifier) ) [self.devices setObject:identifier forKey:[peripheral.identifier UUIDString]];
        else return nil;
        
    }
    
    // Look up the data record associated with the asset identifier.
    
    NSMutableDictionary *   record      = [self.records objectForKey:[identifier identifierString]];
    NSUInteger              index       = [self.registry indexOfAssetWithIdentifier:[identifier identifierData]];

    // If no record exists, construct a basic record, starting with the signal
    // level received over Bluetooth.

    if ( ! record ) { [self.records setObject:(record = [[NSMutableDictionary alloc] init]) forKey:[identifier identifierString]]; }
    if ( ! record ) return nil;
    
    [record setObject:rssi forKey:@"signal"];

    // Add additional information about the beacon horizon and device
    // battery level if we have it.

    if ( broadcast.battery ) { [record setObject:broadcast.battery forKey:@"battery"]; }
    if ( broadcast.horizon ) { [record setObject:broadcast.horizon forKey:@"horizon"]; }

    // If present in the broadcast, add the basic temperature information.

    if ( broadcast.temperature ) { [record setObject:broadcast.temperature forKey:@"surface"]; }

    // If present in the broadcast, add atmospheric telemetry items.

    if ( broadcast.airTemperature) { [record setObject:broadcast.airTemperature forKey:@"ambient"]; }
    if ( broadcast.airHumidity ) { [record setObject:broadcast.airHumidity forKey:@"humidity"]; }
    if ( broadcast.airPressure ) { [record setObject:broadcast.airPressure forKey:@"pressure"]; }
    
    // If present in the broadcast, add orientation handling information.

    if ( broadcast.orientationFace ) { [record setObject:broadcast.orientationFace forKey:@"orientation"]; }
    if ( broadcast.tiltAngle ) { [record setObject:broadcast.tiltAngle forKey:@"angle"]; }

    // Finally, return with the index path of the reference in the table.
    
    if ( NSNotFound != index ) return [NSIndexPath indexPathForRow:index inSection:0];
    else return nil;
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    [self.assetDevice attachWithManager:central usingKey:nil];

    if ( [self.assetDevice isKindOfClass:[UpdateDevice class]] ) dispatch_async( dispatch_get_main_queue( ), ^{

        [self didConnectUpdate:(UpdateDevice *)self.assetDevice];
        
    });
    
    if ( [self.assetDevice isKindOfClass:[SensorDevice class]] ) dispatch_async( dispatch_get_main_queue( ), ^{

        [self didConnectSensor:(SensorDevice *)self.assetDevice];
        
    });

}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    [self setAssetDevice:nil];

}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {

    if ( self.assetDevice ) dispatch_async( dispatch_get_main_queue( ), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNotificationDropped object:self.assetDevice userInfo:nil];

        [self setAssetDevice:nil];
        
    });

}

#pragma mark - Live device connections

- (void) didConnectUpdate:(UpdateDevice *)update {

    // Segue to the device firmware update controller.
    
    [self performSegueWithIdentifier:@"connectUpdate" sender:update];

}

- (void) didConnectSensor:(SensorDevice *)sensor {

    NSData *        identifier  = [sensor.unitIdentifier identifierData];
    NSDictionary *  asset       = [self.registry assetForIdentifier:identifier];
  
    // If there is no record of this asset, construct a new record and update
    // the first row in the asset section of the table.
    
    if ( !(asset) && [self.registry assetWithIdentifier:identifier label:@"New Asset"] ) {
    
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
    }

    // Segue to the connected sensor controller.
    
    [self performSegueWithIdentifier:@"connectSensor" sender:sensor];
    
}

@end
