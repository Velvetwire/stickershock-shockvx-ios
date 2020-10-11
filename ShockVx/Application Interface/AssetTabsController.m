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

//
// Connected sensor tab controller instance
//

@interface AssetTabsController ( ) <CLLocationManagerDelegate>

@property (nonatomic, weak)     AssetSettingsTabController *    settingsController;
@property (nonatomic, weak)     AssetTrackingTabController *    trackingController;
@property (nonatomic, weak)     AssetTelemetryTabController *   telemetryController;

@property (nonatomic, strong)   NSString *                      unwindSegue;

@property (nonatomic, strong)   CLLocationManager *             locationManager;
@property (nonatomic, strong)   CLLocation *                    locationFix;

@end

//
// Connected sensor tab controller interface
//

@implementation AssetTabsController

- (void) viewDidLoad {

    [super viewDidLoad];

    // If location services are available, register the location manager.

    if ( [CLLocationManager locationServicesEnabled] ) { _locationManager = [[CLLocationManager alloc] init]; }

    // Register for connection notices
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMeasureSignal:) name:kDeviceNotificationSignal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDropConnection:) name:kDeviceNotificationDropped object:nil];

    // Register for security access notices
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRestrictAccess:) name:kDeviceNotificationAccessRestricted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRespondToAccess:) name:kDeviceNotificationAccessResponse object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAllowAccess:) name:kDeviceNotificationAccessUnlocked object:nil];

    // Register for device information and control notices
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateInformation:) name:kDeviceNotificationInformation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateControl:) name:kSensorNotificationControlSettings object:nil];
    
    // Register for telemetry settings updates
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTelemetryInterval:) name:kSensorNotificationMeasureInterval object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetArchiveInterval:) name:kSensorNotificationArchiveInterval object:nil];

    // Register for atmospheric telmetry updates
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAtmosphericLimits:) name:kSensorNotificationAtmosphericLimits object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAtmosphericValues:) name:kSensorNotificationAtmosphericValues object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSurfaceLimits:) name:kSensorNotificationSurfaceLimits object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSurfaceValues:) name:kSensorNotificationSurfaceValues object:nil];

    // Register for handling updates
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHandlingLimits:) name:kSensorNotificationHandlingLimits object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHandlingValues:) name:kSensorNotificationHandlingValues object:nil];

    // Prepare each of the tab controllers
    
    [self viewPrepareControllers];
        
}

- (void) viewPrepareControllers {

    // Assign this controller as the delegate for each of the tab controllers
    // that support a delegate reference.
    
    for ( UIViewController * controller in self.viewControllers ) {
    
        if ( [controller isKindOfClass:[AssetSettingsTabController class]] ) { [(AssetSettingsTabController *)controller setDelegate:self]; }
        if ( [controller isKindOfClass:[AssetTrackingTabController class]] ) { [(AssetTrackingTabController *)controller setDelegate:self]; }

    }

}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if ( self.locationManager ) {
    
        [self.locationManager setDelegate:self];
    
        switch ( [self.locationManager authorizationStatus] ) {
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            case kCLAuthorizationStatusAuthorizedAlways:
                [self.locationManager requestLocation];
                break;
            
            default:
                [self.locationManager requestWhenInUseAuthorization];
                break;
                
        }
        
    }
    
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
    
    if ( self.isMovingFromParentViewController) { [self.sensor detachFromManager]; }
    
}

#pragma mark - Asychronous connection notifications

- (void) didMeasureSignal:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;
    NSNumber *              signal      = [notification.userInfo objectForKey:@"signal"];
    
    // If this sensor has been dropped, unwind...
    
    if ( [self.sensor isEqual:sensor] ) {
        
        [self.trackingController setSignal:signal];
        [self.trackingController setBattery:sensor.battery.batteryLevel];

    }

}

- (void) didDropConnection:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

    // If this sensor has been dropped, unwind...
    
    if ( [self.sensor isEqual:sensor] ) {
        
        if ( self.unwindSegue ) [self performSegueWithIdentifier:self.unwindSegue sender:self];
        else  [self performSegueWithIdentifier:@"lostConnection" sender:self];
        
    }

}

#pragma mark - Asynchronous security access notifications

- (void) didRespondToAccess:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;
    NSNumber *              response    = [notification.userInfo objectForKey:@"response"];

    // Make sure that this update is intended for this sensor instance
    
    if ( [self.sensor isEqual:sensor] ) {

        // NOTE: placeholder
        
    }
    
}

- (void) didRestrictAccess:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

    // Make sure that this update is intended for this sensor instance
    
    if ( [self.sensor isEqual:sensor] ) {

        NSLog ( @"Access restricted" );
        
    }

}

- (void) didAllowAccess:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

    // Make sure that this update is intended for this sensor instance
    
    if ( [self.sensor isEqual:sensor] ) {

        NSLog ( @"Access allowed" );
        
    }

}

#pragma mark - Device control notices

- (void) didUpdateControl:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;
    SensorControl *         control     = (SensorControl *) [notification.userInfo objectForKey:@"control"];
    
    // Make sure that this update is intended for this sensor instance

    if ( [sensor isEqual:self.sensor] ) {

        [self.trackingController setDateOpened:control.timeOpened];
        [self.trackingController setDateClosed:control.timeClosed];
        
    }
    
}

#pragma mark - Sensor information notices

- (void) didUpdateInformation:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;
    DeviceInformation *     information = (DeviceInformation *) [notification.userInfo objectForKey:@"information"];
    
    // Make sure that this update is intended for this sensor instance
    // and update the information.
    
    if ( [self.sensor isEqual:sensor] ) {
    
        [self.trackingController setAssetNumber:information.number];
        [self.settingsController refreshInformation];
        
    }

}

#pragma mark - Sensor telemetry notices

- (void) didGetTelemetryInterval:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;
    NSNumber *              interval    = (NSNumber *) [notification.userInfo objectForKey:@"interval"];

    if ( [sensor isEqual:self.sensor] ) {

        [self.settingsController setTelemetryInterval:interval];
        
    }

}

- (void) didGetArchiveInterval:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;
    NSNumber *              interval    = (NSNumber *) [notification.userInfo objectForKey:@"interval"];

    if ( [sensor isEqual:self.sensor] ) {

        [self.settingsController setArchiveInterval:interval];
        
    }

}

#pragma mark - Sensor atmospheric notices

- (void) didGetAtmosphericLimits:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

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

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setAmbient:sensor.atmosphere.ambient];
        [self.telemetryController setHumidity:sensor.atmosphere.humidity];
        [self.telemetryController setPressure:sensor.atmosphere.pressure];

    }

}

#pragma mark - Sensor handling notices

- (void) didGetHandlingLimits:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setAngleMaximum:sensor.handling.angleLimit];
        [self.telemetryController setForceMaximum:sensor.handling.forceLimit];

        [self.settingsController setOrientation:sensor.handling.facePreferred];
        [self.settingsController setAngleMaximum:sensor.handling.angleLimit];
        [self.settingsController setForceMaximum:sensor.handling.forceLimit];
        
    }

}

- (void) didGetHandlingValues:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setOrientation:[NSNumber numberWithUnsignedInteger:sensor.handling.face]];
        [self.telemetryController setAngle:sensor.handling.angle];
        [self.telemetryController setForce:sensor.handling.force];

    }

}


#pragma mark - Sensor surface readings

- (void) didGetSurfaceLimits:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {
   
        [self.telemetryController setSurfaceMinimum:sensor.surface.temperatureMinimum];
        [self.telemetryController setSurfaceMaximum:sensor.surface.temperatureMaximum];
        [self.settingsController setSurfaceMinimum:sensor.surface.temperatureMinimum];
        [self.settingsController setSurfaceMaximum:sensor.surface.temperatureMaximum];

    }

}

- (void) didGetSurfaceValues:(NSNotification *)notification {

    SensorDevice *          sensor      = (SensorDevice *) notification.object;

    if ( [self.sensor isEqual:sensor] ) {

        [self.telemetryController setSurface:sensor.surface.temperature];

    }

}

#pragma mark - Asset values

@synthesize assetDescription = _assetDescription;
@synthesize assetLocale = _assetLocale;

- (void) setAssetDescription:(NSString *)description { [self.trackingController setAssetDescription:(_assetDescription = description)]; }

- (NSString *) assetDescription { return (_assetDescription = [self.trackingController assetDescription]); }

- (void) setAssetLocale:(NSString *)locale { [self.trackingController setAssetLocale:(_assetLocale = locale)]; }
- (NSString *) assetLocale { return (_assetLocale = [self.trackingController assetLocale]); }

#pragma mark - Asset tracking delegate

- (void) assetTrackingOpened { [self setUnwindSegue:@"closeConnection"]; }
- (void) assetTrackingClosed { [self setUnwindSegue:@"closeConnection"]; }

#pragma mark - Asset settings delegate

- (void) assetSettingsUpdate { [self setUnwindSegue:@"resetConnection"]; }

#pragma mark - Location manager delegate

- (void) locationManagerDidChangeAuthorization:(CLLocationManager *)manager {

    switch ( manager.authorizationStatus ) {
    
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager requestLocation];
            break;
            
        default:
            NSLog ( @"Location not authorized!" );
            break;
            
    }
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    if ( (_locationFix = [locations firstObject]) ) {

        CLGeocoder *    geocoder    = [[CLGeocoder alloc] init];
        
        [geocoder reverseGeocodeLocation:self.locationFix
                       completionHandler:^(NSArray * placemarks, NSError * error) { [self locationManager:manager didGeolocatePlaces:placemarks]; }];
    
        [self.trackingController setLocation:self.locationFix];
        
    }
    
}

- (void) locationManager:(CLLocationManager *)manager didGeolocatePlaces:(NSArray *)places {

    CLPlacemark *       placemark   = [places firstObject];
    
    [self.trackingController setPlacemark:placemark];
    
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    // NOTE: problem gathering location
    
}

@end
