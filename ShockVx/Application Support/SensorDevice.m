//
//  project: Shock Vx
//     file: SensorDevice.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorDevice.h"

//
// Sensor implementation
@implementation SensorDevice

#pragma mark - Device instantiation

//
// Instantiate a new sensor asset.
+ (instancetype) sensorWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary {
    
    return [[SensorDevice alloc] initWithUnit:unit node:node controlService:control primaryService:primary];
    
}

//
// Initialize the instance.
- (instancetype) initWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary {
 
    // Instantiate the sensor.

    if ( (self = [super initWithUnit:unit node:node controlService:control primaryService:primary]) ) {
    
    }
    
    // Return with the instance.
    
    return ( self );
    
}

#pragma mark - Service characteristics

//
// Services have been discovered.
- (void) peripheral:(CBPeripheral *)peripheral service:(CBService *)service {

    [super peripheral:peripheral service:service];

    // If this is the primary service, construct the device update service as the primary.
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithNSUUID:self.primaryService]] && self.control == nil ) [self setControl:[SensorControl controlService:self.primaryService forPeripheral:peripheral delegate:self]];

    // Instantiate the telemetry control service is discovered.
    
    if ( [service.UUID isEqual:[SensorTelemetry serviceIdentifier]] && self.telemetry == nil ) [self setTelemetry:[SensorTelemetry serviceForPeripheral:peripheral delegate:self]];
    
    // Instantiate the sensor services if discovered.
    
    if ( [service.UUID isEqual:[SensorAtmosphere serviceIdentifier]] && self.atmosphere == nil ) [self setAtmosphere:[SensorAtmosphere serviceForPeripheral:peripheral delegate:self]];
    if ( [service.UUID isEqual:[SensorHandling serviceIdentifier]] && self.handling == nil ) [self setHandling:[SensorHandling serviceForPeripheral:peripheral delegate:self]];
    if ( [service.UUID isEqual:[SensorSurface serviceIdentifier]] && self.surface == nil ) [self setSurface:[SensorSurface serviceForPeripheral:peripheral delegate:self]];

}

//
// Service characteristics have been discovered.
- (void) peripheral:(CBPeripheral *)peripheral service:(CBService *)service characteristic:(CBCharacteristic *)characteristic {

    [super peripheral:peripheral service:service characteristic:characteristic];
    
    // If these belong to the primary service, forward to the sensor control service.
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithNSUUID:self.primaryService]] ) [self.control discoveredCharacteristic:characteristic];

    // Check for telemetry service characteristics.
    
    if ( [service.UUID isEqual:[SensorTelemetry serviceIdentifier]] ) [self.telemetry discoveredCharacteristic:characteristic];

    // Check for sensor service characeristics.
    
    if ( [service.UUID isEqual:[SensorAtmosphere serviceIdentifier]] ) [self.atmosphere discoveredCharacteristic:characteristic];
    if ( [service.UUID isEqual:[SensorHandling serviceIdentifier]] ) [self.handling discoveredCharacteristic:characteristic];
    if ( [service.UUID isEqual:[SensorSurface serviceIdentifier]] ) [self.surface discoveredCharacteristic:characteristic];

}

//
// Charactistic value retrieved.
- (void) peripheral:(CBPeripheral *)peripheral retrievedCharacteristic:(CBCharacteristic *)characteristic {

    [super peripheral:peripheral retrievedCharacteristic:characteristic];

    [self.control retrievedCharacteristic:characteristic];
    [self.telemetry retrievedCharacteristic:characteristic];

    [self.atmosphere retrievedCharacteristic:characteristic];
    [self.handling retrievedCharacteristic:characteristic];
    [self.surface retrievedCharacteristic:characteristic];

}

//
// Characteristic write confirmed.
- (void) peripheral:(CBPeripheral *)peripheral confirmedCharacteristic:(CBCharacteristic *)characteristic {
    
    [super peripheral:peripheral confirmedCharacteristic:characteristic];
    
    [self.control confirmedCharacteristic:characteristic];
    
}

#pragma mark - Sensor control delegate

//
// Sensor control settings have changed.
- (void) sensorControl:(SensorControl *)control {

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationControlSettings
                                                        object:self
                                                      userInfo:@{@"control":self.control}];

}

//
// Detach from sensor peripheral once tracking window change is confirmed.
- (void) sensorControl:(SensorControl *)control trackingWindow:(TrackingWindow)window {

    [self detachFromManager];
    
}

#pragma mark - Sensor telemetry control delegate

//
// Telemetry measurement interval is known.
- (void) sensorTelemetry:(SensorTelemetry *)telemetry interval:(NSNumber *)interval {

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationMeasureInterval
                                                        object:self
                                                      userInfo:@{@"interval":interval}];

}

//
// Telemetry archive interval is known.
- (void) sensorTelemetry:(SensorTelemetry *)telemetry archival:(NSNumber *)archival {

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationArchiveInterval
                                                        object:self
                                                      userInfo:@{@"interval":archival}];

}

#pragma mark - Surface temperature delegate

//
// Surface temperature reading received.
- (void) sensorSurface:(SensorSurface *)surface {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationSurfaceValues
                                                        object:self
                                                      userInfo:nil];

}

//
// Surface temperature minimum recieved.
- (void) sensorMinimumSurface:(SensorSurface *)surface {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationSurfaceLimits
                                                        object:self
                                                      userInfo:nil];

}

//
// Surface temperature maximum recieved.
- (void) sensorMaximumSurface:(SensorSurface *)surface {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationSurfaceLimits
                                                        object:self
                                                      userInfo:nil];

}

#pragma mark - Atmospherics delegate

//
// Atmospheric readings recieved.
- (void) sensorAtmosphere:(SensorAtmosphere *)atmosphere {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationAtmosphericValues
                                                        object:self
                                                      userInfo:nil];

}

//
// Atmospheric minimums recieved.
- (void) sensorMinimumAtmosphere:(SensorAtmosphere *)atmosphere {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationAtmosphericLimits
                                                        object:self
                                                      userInfo:nil];

}

//
// Atmospheric maximums recieved.
- (void) sensorMaximumAtmosphere:(SensorAtmosphere *)atmosphere {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationAtmosphericLimits
                                                        object:self
                                                      userInfo:nil];

}

#pragma mark - Handling and orienatation delegate

//
// Handling values recieved.
- (void) sensorHandling:(SensorHandling *)handling {

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationHandlingValues
                                                        object:self
                                                      userInfo:nil];

}

//
// Handling limits recieved.
- (void) sensorLimitHandling:(SensorHandling *)handling {

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorNotificationHandlingLimits
                                                        object:self
                                                      userInfo:nil];

}

@end
