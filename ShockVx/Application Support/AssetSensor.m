//
//  project: Shock Vx
//     file: AssetSensor.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetSensor.h"

@interface AssetSensor ( )

@property (nonatomic, strong)   CBPeripheral *      peripheral;
@property (nonatomic, weak)     CBCentralManager *  manager;
@property (nonatomic, strong)   NSUUID *            key;

@end

@implementation AssetSensor

+ (instancetype) sensorForPeripheral:(CBPeripheral *)peripheral withIdentifier:(AssetIdentifier *)identifier accessKey:(NSUUID *)key { return [[AssetSensor alloc] initWithPeripheral:peripheral identifier:identifier key:key]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral identifier:(AssetIdentifier *)identifier key:(NSUUID *)key {

    if ( (self = [super init]) ) {
        
        _peripheral = peripheral;
        _identifier = identifier;
        
    } else return ( self );

    [self.peripheral setDelegate:self];
    [self setKey:key];

    return ( self );
    
}

#pragma mark - Peripheral Interface

- (bool) attachPeripheral:peripheral toManager:(CBCentralManager *)manager {

    if ( (peripheral == self.peripheral) && (_manager = manager) ) {
        
        [self.peripheral discoverServices:nil];
        [self.peripheral readRSSI];
    
    } else return ( false );
    
    return ( true );
    
}

- (void) detachFromManager {

    if ( self.peripheral.state == CBPeripheralStateConnected ) [self.manager cancelPeripheralConnection:self.peripheral];
    
}

#pragma mark - Peripheral Delegate

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {

    for ( CBService * service in peripheral.services ) {

        if ( [service.UUID isEqual:[SensorAccess serviceIdentifier]] && self.access == nil ) [self setAccess:[SensorAccess serviceForPeripheral:peripheral delegate:self]];
        if ( [service.UUID isEqual:[SensorControl serviceIdentifier]] && self.control == nil ) [self setControl:[SensorControl serviceForPeripheral:peripheral delegate:self]];
        if ( [service.UUID isEqual:[SensorBattery serviceIdentifier]] && self.battery == nil ) [self setBattery:[SensorBattery serviceForPeripheral:peripheral delegate:self]];

        if ( [service.UUID isEqual:[SensorInformation serviceIdentifier]] && self.information == nil ) [self setInformation:[SensorInformation serviceForPeripheral:peripheral delegate:self]];

        if ( [service.UUID isEqual:[SensorTelemetry serviceIdentifier]] && self.telemetry == nil ) [self setTelemetry:[SensorTelemetry serviceForPeripheral:peripheral delegate:self]];
        if ( [service.UUID isEqual:[SensorHandling serviceIdentifier]] && self.handling == nil ) [self setHandling:[SensorHandling serviceForPeripheral:peripheral delegate:self]];
        if ( [service.UUID isEqual:[SensorRecords serviceIdentifier]] && self.records == nil ) [self setRecords:[SensorRecords serviceForPeripheral:peripheral delegate:self]];


        [peripheral discoverCharacteristics:nil forService:service];
    
    }
    
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    for ( CBCharacteristic * characteristic in service.characteristics ) {

        if ( [service.UUID isEqual:[SensorAccess serviceIdentifier]] ) [self.access discoveredCharacteristic:characteristic];
        if ( [service.UUID isEqual:[SensorControl serviceIdentifier]] ) [self.control discoveredCharacteristic:characteristic];
        if ( [service.UUID isEqual:[SensorBattery serviceIdentifier]] ) [self.battery discoveredCharacteristic:characteristic];

        if ( [service.UUID isEqual:[SensorInformation serviceIdentifier]] ) [self.information discoveredCharacteristic:characteristic];

        if ( [service.UUID isEqual:[SensorTelemetry serviceIdentifier]] ) [self.telemetry discoveredCharacteristic:characteristic];
        if ( [service.UUID isEqual:[SensorHandling serviceIdentifier]] ) [self.handling discoveredCharacteristic:characteristic];
        if ( [service.UUID isEqual:[SensorRecords serviceIdentifier]] ) [self.records discoveredCharacteristic:characteristic];

        // If the characteristic is notifying, enable notification. If the characteristic
        // can be read, read the characteristic.
        
        if ( characteristic.properties & CBCharacteristicPropertyNotify ) { [peripheral setNotifyValue:YES forCharacteristic:characteristic]; }
        if ( characteristic.properties & CBCharacteristicPropertyRead ) { [peripheral readValueForCharacteristic:characteristic]; }

    }
    
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {

    [self.access retrievedCharacteristic:characteristic];
    [self.control retrievedCharacteristic:characteristic];
    [self.battery retrievedCharacteristic:characteristic];

    [self.information retrievedCharacteristic:characteristic];

    [self.handling retrievedCharacteristic:characteristic];
    [self.telemetry retrievedCharacteristic:characteristic];
    [self.records retrievedCharacteristic:characteristic];

}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {

    [self.access confirmedCharacteristic:characteristic];
    [self.control confirmedCharacteristic:characteristic];

}

- (void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {

    if ( ! error ) { _signal = RSSI; }
    if ( self.signal ) dispatch_async( dispatch_get_main_queue( ), ^{ [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationSignalUpdate object:self userInfo:@{@"signal":self.signal}]; });

    dispatch_after( dispatch_time( DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC ), dispatch_get_main_queue( ), ^{ if ( self.peripheral.state == CBPeripheralStateConnected ) [self.peripheral readRSSI]; });

}

- (void) peripheralDidUpdateName:(CBPeripheral *)peripheral {

}

#pragma mark - Access Delegate

- (void) accessReponse:(AccessResponse)response {

    // Send a notice that the sensor unit information has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationAccessResponse object:self userInfo:@{@"response":[NSNumber numberWithUnsignedInteger:response]}];

}

- (void) accessStatus:(AccessStatus)status {

    // If access is locked, attept to unlock with the pass key. If there
    // is no key, send a restricted access notice.
    
    if ( status == kAccessStatusLocked ) {
            
        if ( self.key ) {
            
            unsigned char   passkey [ 16 ];
            
            [self.key getUUIDBytes:passkey];
            [self.access useAccessKey:[NSData dataWithBytes:passkey length:sizeof(passkey)]];
        
        } else { [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationAccessRestricted object:nil]; }
        
    }
    
    // If access is open send an open access notice.
    
    if ( status == kAccessStatusOpened ) { [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationAccessUnlocked object:nil]; }
    
}

#pragma mark - Control Delegate

- (void) sensorControl:(SensorControl *)control {

    // Send a notice that the sensor unit information has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationControlSettings object:self userInfo:@{@"control":self.control}];

}

- (void) sensorControl:(SensorControl *)control trackingWindow:(TrackingWindow)window {

    // Detach from the manager once receiving a tracking window change confirmation.
    
    [self detachFromManager];
    
}

#pragma mark - Battery Delegate

- (void) sensorBattery:battery level:(NSNumber *)level {

    // Send a notice that the sensor battery level has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationBatteryUpdate object:self userInfo:@{@"level":level}];

}

- (void) sensorBattery:battery charging:(bool)charging {

    // Send a notice that the sensor battery charging status has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationBatteryUpdate object:self userInfo:nil];

}

#pragma mark - Telemetry Delegate

- (void) sensorTelemetry:(SensorTelemetry *)telemetry interval:(NSNumber *)interval {

    // Send a notice that the telemetry interval is known.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationTelemetryInterval object:self userInfo:@{@"interval":interval}];

}

- (void) sensorTelemetry:(SensorTelemetry *)telemetry {

    // Send a notice that new telemetry data is available.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationTelemetryValues object:self userInfo:nil];

}

- (void) sensorMinimumTelemetry:(SensorTelemetry *)telemetry {

    // Send a notice that telemetry minimums are known.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationTelemetryLimits object:self userInfo:nil];

}

- (void) sensorMaximumTelemetry:(SensorTelemetry *)telemetry {

    // Send a notice that telemetry maximums are known.

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationTelemetryLimits object:self userInfo:nil];

}

#pragma mark - Handling Delegate

- (void) sensorHandling:(SensorHandling *)handling {

    // Send a notice that new handling data is available.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationHandlingValues object:self userInfo:nil];

}

- (void) sensorLimitHandling:(SensorHandling *)handling {

    // Send a notice that handling limits are known.

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationHandlingLimits object:self userInfo:nil];

}

#pragma mark - Records Delegate

- (void) sensorRecords:(SensorRecords *)records interval:(NSNumber *)interval {

    // Send a notice that the telemetry interval is known.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationRecordsInterval object:self userInfo:@{@"interval":interval}];

}

#pragma mark - Information Delegate

- (void) sensorInformation:(SensorInformation *)information {

    // Send a notice that the sensor unit information has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationInformationUpdate object:self userInfo:@{@"information":self.information}];
    
}

@end
