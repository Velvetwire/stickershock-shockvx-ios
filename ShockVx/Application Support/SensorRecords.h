//
//  project: Shock Vx
//     file: SensorRecords.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol SensorRecordsDelegate;

// Records service

#define kSensorRecordsServiceUUID       @"54720000-5657-5353-2020-56454C564554"

// Records time interval.

#define kSensorRecordsIntervalUUID      @"54725269-5657-5353-2020-56454C564554"

// Records data retrieval characteristics.

typedef   struct __attribute__ (( packed )) {

    unsigned short      index;          //  record index
    unsigned short      count;          //  record count

} records_cursor_t;

#define kSensorRecordsCursorUUID        @"54725263-5657-5353-2020-56454C564554"
#define kSensorRecordsDataUUID          @"54725264-5657-5353-2020-56454C564554"

@interface SensorRecords : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, strong)   NSNumber *      interval;

@end

//
// Sensor records delegate
@protocol SensorRecordsDelegate <NSObject>

- (void) sensorRecords:(SensorRecords *)records interval:(NSNumber *)interval;

@end
