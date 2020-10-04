//
//  project: Shock Vx
//     file: AssetBroadcast.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetIdentifier.h"

#define BROADCAST_TYPE_NORMAL(t)    (t)         // Normal broadcast record
#define BROADCAST_TYPE_SECURE(t)    (0x80 | t)  // Secure broadcast record

typedef struct __attribute__ (( packed )) {     // Broadcast record:

    unsigned char           size;               //  Record size in bytes
    unsigned char           type;               //  Record type code

} broadcast_record_t;

#define BROADCAST_TYPE_IDENTITY     0x01        // Identity code

typedef unsigned long long  hash_t;
typedef struct __attribute__ (( packed )) {     // Broadcast identity record:

    unsigned                timecode;           //  Unit secure time-code nonce

    hash_t                  identity;           //  Identity code (64-bit)
    hash_t                  security;           //  Security hash (64-bit ignored if not secure)

    signed char             horizon;            //  Signal horizon (standard dB at 1 meter)
    signed char             battery;            //  Battery level (negative = charging)

} broadcast_identity_t;

#define BROADCAST_TYPE_VARIANT      0x07

typedef struct __attribute__ (( packed )) {     // Broadcast variant record:

    unsigned short          type;               //  variant type code

} broadcast_variant_t;

#define BROADCAST_TYPE_TEMPERATURE  0x21

typedef struct __attribute__ (( packed )) {     // Broadcast measurement record:

    signed short            measurement;        // Recent measurement (degrees Celsius / 100)
    unsigned short          incursion;          // Time inside limits (minutes)
    unsigned short          excursion;          // Time outside limits (minutes)

} broadcast_measurement_t;

typedef broadcast_measurement_t     broadcast_temperature_t;

#define BROADCAST_TYPE_ATMOSPHERE   0x23

typedef struct __attribute__ (( packed )) {     // Broadcast atmosphere record:

    broadcast_measurement_t temperature;        //  Air temperature
    broadcast_measurement_t humidity;           //  Air humidity level
    broadcast_measurement_t pressure;           //  Air pressure

} broadcast_atmosphere_t;

#define BROADCAST_TYPE_HANDLING     0x31

typedef struct __attribute__ (( packed )) {     // Broadcast handling record:

    unsigned char           orientation;        //  Orientation code
    signed char             angle;              //  Tilt angle (+/- 90)

} broadcast_handling_t;

#define BROADCAST_ORIENTATION_FACE  (1 << 7)    //  Orientation alert flag
#define BROADCAST_ORIENTATION_DROP  (1 << 6)    //  Drop alert flag
#define BROADCAST_ORIENTATION_BUMP  (1 << 5)    //  Bump alert flag
#define BROADCAST_ORIENTATION_TILT  (1 << 4)    //  Tilt alert flag
#define BROADCAST_ORIENTATION_ANGLE (1 << 3)    //  Valid angle flag

#define BROADCAST_HANLDING_FACE(o)  (o & 3)     //  Face ordinal (0 = unknown)

@interface AssetBroadcast : NSObject

+ (instancetype) broadcastFromData:(NSData *)data;

@property (nonatomic, readonly) AssetIdentifier *   identifier;
@property (nonatomic, readonly) unsigned short      variant;

@property (nonatomic, readonly) NSNumber *          battery;
@property (nonatomic, readonly) NSNumber *          horizon;

@property (nonatomic, readonly) NSNumber *          temperature;

@property (nonatomic, readonly) NSNumber *          airTemperature;
@property (nonatomic, readonly) NSNumber *          airHumidity;
@property (nonatomic, readonly) NSNumber *          airPressure;

@property (nonatomic, readonly) NSNumber *          orientationFace;
@property (nonatomic, readonly) bool                orientationAlarm;

@property (nonatomic, readonly) NSNumber *          tiltAngle;
@property (nonatomic, readonly) bool                tiltAlarm;

@property (nonatomic, readonly) bool                bumpAlarm;
@property (nonatomic, readonly) bool                dropAlarm;

@end
