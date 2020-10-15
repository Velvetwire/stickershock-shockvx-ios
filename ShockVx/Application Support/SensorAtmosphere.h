//
//  project: Shock Vx
//     file: SensorAtmosphere.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol SensorAtmosphereDelegate;

// Atmospherics data service

#define kSensorAtmosphereServiceUUID    @"41740000-5657-5353-2020-56454C564554"

// Atmospheric values and limits characteristics

#define kSensorAtmosphereValueUUID      @"41744D76-5657-5353-2020-56454C564554"
#define kSensorAtmosphereLowerUUID      @"41744C6C-5657-5353-2020-56454C564554"
#define kSensorAtmosphereUpperUUID      @"4174556C-5657-5353-2020-56454C564554"

typedef struct __attribute__ (( packed )) {

    float       ambient;                // Ambient temperature (deg C)
    float       humidity;               // Humidity (saturation)
    float       pressure;               // Air pressure (bars)

} atmosphere_values_t;

// Atmospheric archive events

#define kSensorAtmosphereCountUUID      @"41745263-5657-5353-2020-56454C564554"
#define kSensorAtmosphereEventUUID      @"41745265-5657-5353-2020-56454C564554"

typedef struct __attribute__ (( packed )) {

    unsigned        time;               // UTC time stamp

    signed short    temperature;        // Temperature value (1/100 Degree Celsius)
    signed short    humidity;           // Humidity value (1/100 percent)
    signed short    pressure;           // Pressure value (millibars)

} atmosphere_event_t;

//
// Sensor atmospherics service
@interface SensorAtmosphere : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@property (readonly, strong)    NSNumber *      ambient;
@property (nonatomic, strong)   NSNumber *      ambientMinimum;
@property (nonatomic, strong)   NSNumber *      ambientMaximum;

@property (readonly, strong)    NSNumber *      humidity;
@property (nonatomic, strong)   NSNumber *      humidityMinimum;
@property (nonatomic, strong)   NSNumber *      humidityMaximum;

@property (readonly, strong)    NSNumber *      pressure;
@property (nonatomic, strong)   NSNumber *      pressureMinimum;
@property (nonatomic, strong)   NSNumber *      pressureMaximum;

@property (nonatomic, readonly) NSUInteger      number;
@property (nonatomic, readonly) NSArray *       events;

@end

//
// Sensor atmospherics delegate
@protocol SensorAtmosphereDelegate <NSObject>

- (void) sensorAtmosphere:(SensorAtmosphere *)atmosphere;
- (void) sensorAtmosphere:(SensorAtmosphere *)atmosphere eventIndex:(NSNumber *)index;

- (void) sensorMinimumAtmosphere:(SensorAtmosphere *)atmosphere;
- (void) sensorMaximumAtmosphere:(SensorAtmosphere *)atmosphere;

@end
