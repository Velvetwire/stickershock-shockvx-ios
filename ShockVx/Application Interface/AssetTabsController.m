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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetArchiveInterval:) name:kSensorNotificationArchiveInterval object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAtmosphericLimits:) name:kSensorNotificationAtmosphericLimits object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAtmosphericValues:) name:kSensorNotificationAtmosphericValues object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHandlingLimits:) name:kSensorNotificationHandlingLimits object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHandlingValues:) name:kSensorNotificationHandlingValues object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSurfaceLimits:) name:kSensorNotificationSurfaceLimits object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSurfaceValues:) name:kSensorNotificationSurfaceValues object:nil];

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

#pragma mark - Sensor Telemetry Settings

- (void) didGetTelemetryInterval:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;
    NSNumber *              interval     = (NSNumber *) [notification.userInfo objectForKey:@"interval"];

    if ( [sensor isEqual:self.sensor] ) {

        [self.settingsController setTelemetryInterval:interval];
        
    }

}

- (void) didGetArchiveInterval:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;
    NSNumber *              interval     = (NSNumber *) [notification.userInfo objectForKey:@"interval"];

    if ( [sensor isEqual:self.sensor] ) {

        [self.settingsController setArchiveInterval:interval];
        
    }

}

#pragma mark - Sensor Atmospherics

- (void) didGetAtmosphericLimits:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {
    
        [self.telemetryController setAmbientMinimum:sensor.atmosphere.ambientMinimum];
        [self.telemetryController setAmbientMaximum:sensor.atmosphere.ambientMaximum];
        [self.settingsController setAmbientMinimum:sensor.atmosphere.ambientMinimum];
        [self.settingsController setAmbientMaximum:sensor.atmosphere.ambientMaximum];

        [self.telemetryController setHumidityMinimum:sensor.atmosphere.humidityMinimum];
        [self.telemetryController setHumidityMaximum:sensor.atmosphere.humidityMaximum];
        [self.settingsController setHumidityMinimum:sensor.atmosphere.humidityMinimum];
        [self.settingsController setHumidityMaximum:sensor.atmosphere.humidityMaximum];

        [self.telemetryController setPressureMinimum:sensor.atmosphere.pressureMinimum];
        [self.telemetryController setPressureMaximum:sensor.atmosphere.pressureMaximum];
        [self.settingsController setPressureMinimum:sensor.atmosphere.pressureMinimum];
        [self.settingsController setPressureMaximum:sensor.atmosphere.pressureMaximum];

    }

}

- (void) didGetAtmosphericValues:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setAmbient:sensor.atmosphere.ambient];
        [self.telemetryController setHumidity:sensor.atmosphere.humidity];
        [self.telemetryController setPressure:sensor.atmosphere.pressure];

    }

}

#pragma mark - Sensor Handling

- (void) didGetHandlingLimits:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setAngleMaximum:sensor.handling.angleLimit];
        [self.telemetryController setForceMaximum:sensor.handling.forceLimit];

        [self.settingsController setOrientation:sensor.handling.facePreferred];
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


#pragma mark - Sensor Surface Readings

- (void) didGetSurfaceLimits:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {
   
        [self.telemetryController setSurfaceMinimum:sensor.surface.temperatureMinimum];
        [self.telemetryController setSurfaceMaximum:sensor.surface.temperatureMaximum];
        [self.settingsController setSurfaceMinimum:sensor.surface.temperatureMinimum];
        [self.settingsController setSurfaceMaximum:sensor.surface.temperatureMaximum];

    }

}

- (void) didGetSurfaceValues:(NSNotification *)notification {

    AssetSensor *           sensor      = (AssetSensor *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setSurface:sensor.surface.temperature];

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
