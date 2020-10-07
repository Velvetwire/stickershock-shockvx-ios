//
//  project: Shock Vx
//     file: SensorHandling.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol SensorHandlingDelegate;

// Handling and abuse service

#define kSensorHandlingServiceUUID      @"48610000-5657-5353-2020-56454C564554"

// Handling values and limits characteristics

#define kSensorHandlingValueUUID        @"48614D76-5657-5353-2020-56454C564554"
#define kSensorHandlingLimitUUID        @"48614C76-5657-5353-2020-56454C564554"

typedef struct __attribute__ (( packed )) {

    float           force;              // Force (in gravs)
    float           angle;              // Angle (in degrees)
          
    unsigned char   orientation;        // Orientation face (0 = unknown, don't care)

} handling_values_t;

// Orientation face codes

typedef NS_ENUM ( NSUInteger, OrientationFace ) {

    kOrientationFaceUnknown = 0,
    kOrientationFaceUpright,
    kOrientationFaceInverted,
    kOrientationFaceLeftHand,
    kOrientationFaceRightHand,
    kOrientationFaceDown,
    kOrientationFaceUp,
    kOrientationFaces
    
};

//
// Sensor handling service
@interface SensorHandling : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@property (readonly, strong)    NSNumber *      angle;
@property (nonatomic, strong)   NSNumber *      angleLimit;

@property (readonly, strong)    NSNumber *      force;
@property (nonatomic, strong)   NSNumber *      forceLimit;

@property (readonly)            OrientationFace face;
@property (nonatomic)           OrientationFace facePreferred;

@end

//
// Sensor handling delegate
@protocol SensorHandlingDelegate <NSObject>

- (void) sensorHandling:(SensorHandling *)handling;
- (void) sensorLimitHandling:(SensorHandling *)handling;

@end
