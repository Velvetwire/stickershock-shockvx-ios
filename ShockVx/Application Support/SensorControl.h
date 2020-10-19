//
//  project: Shock Vx
//     file: SensorControl.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "AssetIdentifier.h"

@protocol SensorControlDelegate;

// Control service identifier

#define kSensorControlServicePrefix     @"56780000"
#define kSensorControlIdentifyPrefix    @"56784964"

// Tracking identification characteristics

#define kSensorControlNodePrefix        @"5678546E"
#define kSensorControlLockPrefix        @"5678546C"

// Tracking window characteristics

#define kSensorControlOpenedPrefix      @"5678546F"
#define kSensorControlClosedPrefix      @"56785463"
#define kSensorControlWindowPrefix      @"56785477"

typedef struct __attribute__ (( packed )) {

    unsigned                opened;     // UTC time opened (0 = not opened)
    unsigned                closed;     // UTC time closed (0 = not closed)

} control_window_t;

typedef NS_ENUM( NSUInteger, TrackingWindow ) {

    kTrackingWindowOpened,
    kTrackingWindowClosed,
    
};

// Summary status characteristic

#define kSensorControlSummaryPrefix     @"56784975"

typedef struct __attribute__ (( packed )) {

    unsigned short          status;         // Status flags
    unsigned char           memory;         // Memory percentage available (0 - 100)
    unsigned char           storage;        // Storage percentage available (0 - 100)

} control_summary_t;

#define kControlSurfaceSensorOK             (1 << 0)
#define kControlAmbientSensorOK             (1 << 1)
#define kControlHumiditySensorOK            (1 << 2)
#define kControlPressureSensorOK            (1 << 3)
#define kControlMovementSensorOK            (1 << 4)

//
// Sensor control service
@interface SensorControl : NSObject

+ (instancetype) controlService:(NSUUID *)service forPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;
- (void) confirmedCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, strong)   AssetIdentifier *   trackingNode;
@property (nonatomic, strong)   NSUUID *            trackingLock;

@property (nonatomic, readonly) NSUUID *            uuidOpened;
@property (nonatomic, readonly) NSUUID *            uuidClosed;
@property (nonatomic, readonly) NSDate *            timeOpened;
@property (nonatomic, readonly) NSDate *            timeClosed;

- (void) openUsingIdentifier:(NSUUID *)identifier;
- (void) closeUsingIdentifier:(NSUUID *)identifier;

@property (nonatomic, readonly) NSNumber *          storageUsed;
@property (nonatomic, readonly) NSNumber *          memoryUsed;

@property (nonatomic, readonly) bool                surfaceSensor;
@property (nonatomic, readonly) bool                ambientSensor;
@property (nonatomic, readonly) bool                humiditySensor;
@property (nonatomic, readonly) bool                pressureSensor;
@property (nonatomic, readonly) bool                movementSensor;

- (void) identifySensor:(unsigned char)seconds;

@end

//
// Sensor control delegate
@protocol SensorControlDelegate <NSObject>

- (void) sensorControl:(SensorControl *)control;
- (void) sensorControl:(SensorControl *)control trackingWindow:(TrackingWindow)window;

@end
