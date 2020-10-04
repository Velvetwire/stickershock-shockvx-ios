//
//  project: ShockVx
//     file: AssetTabsController.m
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "AssetTabsController.h"
#import "AssetSettingsTabController.h"
#import "AssetTrackingTabController.h"
#import "AssetTelemetryTabController.h"

@interface AssetTabsController ( )

@property (nonatomic, weak) AssetSettingsTabController *    settingsController;
@property (nonatomic, weak) AssetTrackingTabController *    trackingController;
@property (nonatomic, weak) AssetTelemetryTabController *   telemetryController;

@end

@implementation AssetTabsController

- (void) viewDidLoad {

    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDropConnection:) name:kSensorNotificationDropped object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMeasureSignal:) name:kSensorNotificationSignalUpdate object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRespondToAccess:) name:kSensorNotificationAccessResponse object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRestrictAccess:) name:kSensorNotificationAccessRestricted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAllowAccess:) name:kSensorNotificationAccessUnlocked object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateInformation:) name:kSensorNotificationInformationUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateControl:) name:kSensorNotificationControlSettings object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTelemetryInterval:) name:kSensorNotificationTelemetryInterval object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTelemetryLimits:) name:kSensorNotificationTelemetryLimits object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTelemetryValues:) name:kSensorNotificationTelemetryValues object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHandlingLimits:) name:kSensorNotificationHandlingLimits object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHandlingValues:) name:kSensorNotificationHandlingValues object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRecordingInterval:) name:kSensorNotificationRecordsInterval object:nil];

}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    for ( UIViewController * controller in self.viewControllers ) {
    
        if ( [controller isKindOfClass:[AssetSettingsTabController class]] ) { [(_settingsController = (AssetSettingsTabController *)controller) setSensor:self.sensor]; }
        if ( [controller isKindOfClass:[AssetTrackingTabController class]] ) { [(_trackingController = (AssetTrackingTabController *)controller) setSensor:self.sensor]; }
        if ( [controller isKindOfClass:[AssetTelemetryTabController class]] ) { [(_telemetryController = (AssetTelemetryTabController *)controller) setSensor:self.sensor]; }

    }
    
    if ( _assetDescription ) [self.trackingController setAssetDescription:_assetDescription];
    if ( _assetLocale ) [self.trackingController setAssetLocale:_assetLocale];
    
}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) { [self.sensor detachFromManager]; }
    
}

#pragma mark - Asychronous Notifications

- (void) didMeasureSignal:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;
    NSNumber *              signal      = [notification.userInfo objectForKey:@"signal"];
    
    // If this sensor has been dropped, unwind...
    
    if ( [self.sensor isEqual:sensor] ) {
        
        [self.trackingController setSignal:signal];
        [self.trackingController setBattery:sensor.battery.batteryLevel];

    }

}

- (void) didDropConnection:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    // If this sensor has been dropped, unwind...
    
    if ( [self.sensor isEqual:sensor] ) { [self performSegueWithIdentifier:@"unwindConnection" sender:self]; }

}

- (void) didRespondToAccess:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;
    NSNumber *              response    = [notification.userInfo objectForKey:@"response"];

    // Make sure that this update is intended for this sensor instance
    
    if ( [self.sensor isEqual:sensor] ) {

        NSLog ( @"Access response %i", [response intValue] );

    }
    
}

- (void) didRestrictAccess:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    // Make sure that this update is intended for this sensor instance
    
    if ( [self.sensor isEqual:sensor] ) {

        NSLog ( @"Access restricted" );
        
    }

}

- (void) didAllowAccess:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    // Make sure that this update is intended for this sensor instance
    
    if ( [self.sensor isEqual:sensor] ) {

        NSLog ( @"Access allowed" );
        
    }

}

- (void) didUpdateControl:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;
    SensorControl *         control     = (SensorControl *) [notification.userInfo objectForKey:@"control"];
    
    // Make sure that this update is intended for this sensor instance

    if ( [sensor isEqual:self.sensor] ) {

        [self.trackingController setDateOpened:control.timeOpened];
        [self.trackingController setDateClosed:control.timeClosed];
        
    }
    
}

#pragma mark - Sensor Information

- (void) didUpdateInformation:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;
    SensorInformation *     information = (SensorInformation *) [notification.userInfo objectForKey:@"information"];
    
    // Make sure that this update is intended for this sensor instance
    // and update the information.
    
    if ( [self.sensor isEqual:sensor] ) {
    
        [self.trackingController setAssetNumber:information.number];
        
    }

}

#pragma mark - Sensor Telemetry

- (void) didGetTelemetryInterval:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;
    NSNumber *              interval     = (NSNumber *) [notification.userInfo objectForKey:@"interval"];

    if ( [sensor isEqual:self.sensor] ) {

        [self.settingsController setTelemetryInterval:interval];
        
    }

}

- (void) didGetTelemetryLimits:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {
    
        // If an air pressure range has been defined, submit the limits.

        [self.telemetryController setPressureMinimum:sensor.telemetry.pressureMinimum];
        [self.telemetryController setPressureMaximum:sensor.telemetry.pressureMaximum];
        [self.settingsController setPressureMinimum:sensor.telemetry.pressureMinimum];
        [self.settingsController setPressureMaximum:sensor.telemetry.pressureMaximum];

        // If a relative humidity range has been defined, submit the limits.

        [self.telemetryController setHumidityMinimum:sensor.telemetry.humidityMinimum];
        [self.telemetryController setHumidityMaximum:sensor.telemetry.humidityMaximum];
        [self.settingsController setHumidityMinimum:sensor.telemetry.humidityMinimum];
        [self.settingsController setHumidityMaximum:sensor.telemetry.humidityMaximum];

        // If an ambient temperature range has been defined, submit the limits.

        [self.telemetryController setAmbientMinimum:sensor.telemetry.ambientMinimum];
        [self.telemetryController setAmbientMaximum:sensor.telemetry.ambientMaximum];
        [self.settingsController setAmbientMinimum:sensor.telemetry.ambientMinimum];
        [self.settingsController setAmbientMaximum:sensor.telemetry.ambientMaximum];

        // If a surface temperature range has been defined, submit the limits.

        [self.telemetryController setSurfaceMinimum:sensor.telemetry.surfaceMinimum];
        [self.telemetryController setSurfaceMaximum:sensor.telemetry.surfaceMaximum];
        [self.settingsController setSurfaceMinimum:sensor.telemetry.surfaceMinimum];
        [self.settingsController setSurfaceMaximum:sensor.telemetry.surfaceMaximum];

    }

}

- (void) didGetTelemetryValues:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        // Update the telemetry values
        
        [self.telemetryController setPressure:sensor.telemetry.pressure];
        [self.telemetryController setHumidity:sensor.telemetry.humidity];
        [self.telemetryController setAmbient:sensor.telemetry.ambient];
        [self.telemetryController setSurface:sensor.telemetry.surface];

    }

}

#pragma mark - Sensor Handling

- (void) didGetHandlingLimits:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setAngleMaximum:sensor.handling.angleLimit];
        [self.telemetryController setForceMaximum:sensor.handling.forceLimit];

        [self.settingsController setOrientation:sensor.handling.preferredFace];
        [self.settingsController setAngleMaximum:sensor.handling.angleLimit];
        [self.settingsController setForceMaximum:sensor.handling.forceLimit];
        
    }

}

- (void) didGetHandlingValues:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setOrientation:[NSNumber numberWithUnsignedInteger:sensor.handling.face]];
        [self.telemetryController setAngle:sensor.handling.angle];
        [self.telemetryController setForce:sensor.handling.force];

    }

}

#pragma mark - Sensor Records

- (void) didGetRecordingInterval:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;
    NSNumber *              interval     = (NSNumber *) [notification.userInfo objectForKey:@"interval"];

    if ( [sensor isEqual:self.sensor] ) {

        [self.settingsController setRecordingInterval:interval];
        
    }

}

#pragma mark - Asset Values

@synthesize assetDescription = _assetDescription;
@synthesize assetLocale = _assetLocale;

- (void) setAssetDescription:(NSString *)description { [self.trackingController setAssetDescription:(_assetDescription = description)]; }

- (NSString *) assetDescription { return (_assetDescription = [self.trackingController assetDescription]); }

- (void) setAssetLocale:(NSString *)locale { [self.trackingController setAssetLocale:(_assetLocale = locale)]; }
- (NSString *) assetLocale { return (_assetLocale = [self.trackingController assetLocale]); }

@end
