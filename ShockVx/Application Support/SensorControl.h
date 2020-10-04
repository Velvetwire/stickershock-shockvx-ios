//
//  project: Shock Vx
//     file: SensorControl.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AssetIdentifier.h"

@protocol SensorControlDelegate;

// Control service

#define kSensorControlServiceUUID       @"56780000-5657-5353-2020-56454C564554"

// Tracking identification characteristics

#define kSensorControlNodeUUID          @"5678546E-5657-5353-2020-56454C564554"
#define kSensorControlLockUUID          @"5678546C-5657-5353-2020-56454C564554"

// Tracking window characteristics

#define kSensorControlOpenedUUID        @"5678546F-5657-5353-2020-56454C564554"
#define kSensorControlClosedUUID        @"56785463-5657-5353-2020-56454C564554"
#define kSensorControlWindowUUID        @"56785477-5657-5353-2020-56454C564554"

typedef struct __attribute__ (( packed )) {

    unsigned                opened;     // UTC time opened (0 = not opened)
    unsigned                closed;     // UTC time closed (0 = not closed)

} control_window_t;

typedef NS_ENUM( NSUInteger, TrackingWindow ) {

    kTrackingWindowOpened,
    kTrackingWindowClosed,
    
};

// Sensor identification characteristic

#define kSensorControlIdentifyUUID      @"56784964-5657-5353-2020-56454C564554"

//
// Sensor control service
@interface SensorControl : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

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

- (void) identifySensor:(unsigned char)seconds;

@end

//
// Sensor control delegate
@protocol SensorControlDelegate <NSObject>

- (void) sensorControl:(SensorControl *)control;
- (void) sensorControl:(SensorControl *)control trackingWindow:(TrackingWindow)window;

@end
