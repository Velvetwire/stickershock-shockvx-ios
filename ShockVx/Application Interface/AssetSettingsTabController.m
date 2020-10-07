//
//  project: ShockVx
//     file: AssetSettingsTabController.m
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetSettingsTabController.h"

@interface AssetSettingsTabController ( )

@property (weak, nonatomic) IBOutlet UISegmentedControl *   telemetrySettings;
@property (weak, nonatomic) IBOutlet UISegmentedControl *   archiveSettings;

@property (weak, nonatomic) IBOutlet UISwitch *             surfaceEnable;
@property (weak, nonatomic) IBOutlet UILabel *              minimumSurface;
@property (weak, nonatomic) IBOutlet UILabel *              maximumSurface;
@property (weak, nonatomic) IBOutlet UIStepper *            minimumSurfaceStepper;
@property (weak, nonatomic) IBOutlet UIStepper *            maximumSurfaceStepper;

@property (weak, nonatomic) IBOutlet UISwitch *             ambientEnable;
@property (weak, nonatomic) IBOutlet UILabel *              minimumAmbient;
@property (weak, nonatomic) IBOutlet UILabel *              maximumAmbient;
@property (weak, nonatomic) IBOutlet UIStepper *            minimumAmbientStepper;
@property (weak, nonatomic) IBOutlet UIStepper *            maximumAmbientStepper;

@property (weak, nonatomic) IBOutlet UISegmentedControl *   careSettings;
@property (weak, nonatomic) IBOutlet UISegmentedControl *   orientationSettings;

@property (weak, nonatomic) IBOutlet UISwitch *             angleEnable;
@property (weak, nonatomic) IBOutlet UILabel *              angleLimit;
@property (weak, nonatomic) IBOutlet UIStepper *            angleStepper;

@end

@implementation AssetSettingsTabController

static  NSString *      temperatureFormat   = @"%i \u2103";
static  NSString *      angleFormat         = @"%i \u00b0";

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    // If the telemetry and recording intervals are not yet known, disable
    // the respective selectors.
    
    if ( !(self.telemetryInterval = self.sensor.telemetry.interval) ) [self.telemetrySettings setEnabled:NO];
    if ( !(self.archiveInterval = self.sensor.telemetry.archival) ) [self.archiveSettings setEnabled:NO];
    
    // If the surface temperature range values are not yet known, disable
    // the surface alarm enable switch.
    
    if ( !(self.surfaceMinimum = self.sensor.surface.temperatureMinimum ) ) [self.surfaceEnable setEnabled:NO];
    if ( !(self.surfaceMaximum = self.sensor.surface.temperatureMaximum ) ) [self.surfaceEnable setEnabled:NO];

    // If the ambient temperature range values are not yet known, disable
    // the ambient alarm enable switch.
    
    if ( !(self.ambientMinimum = self.sensor.atmosphere.ambientMinimum ) ) [self.ambientEnable setEnabled:NO];
    if ( !(self.ambientMaximum = self.sensor.atmosphere.ambientMaximum ) ) [self.ambientEnable setEnabled:NO];

    // If the angle limit is not yet known, disable the alarm switch.
    
    //if ( !(self.orientation = self.sensor.handling.facePreferred) ) [self.orientationSettings setEnabled:NO];
    //if ( !(self.angleMaximum = self.sensor.handling.angleLimit) ) [self.angleEnable setEnabled:NO];
    
    // If the force limit is not yet known, disable the care selector.
    
    if ( !(self.forceMaximum = self.sensor.handling.forceLimit) ) [self.careSettings setEnabled:NO];
    
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // Update the telemetry interval selector settings if the interval
    // is known.
    
    if ( self.telemetryInterval ) {
    
        if ( [self.telemetryInterval floatValue] >= kTelemetryIntervalSlow ) [self.telemetrySettings setSelectedSegmentIndex:kTelemetrySettingSlow];
        else [self.telemetrySettings setSelectedSegmentIndex:kTelemetrySettingFast];
            
    }
    
    // Update the recording interval selector settings if the interval
    // is known.
    
    if ( self.archiveInterval ) {
    
        if ( [self.archiveInterval floatValue] >= kArchiveIntervalSlow ) [self.archiveSettings setSelectedSegmentIndex:kArchiveSettingSlow];
        else [self.archiveSettings setSelectedSegmentIndex:kArchiveSettingFast];
    
    }
    
    // If there is a defined surface temperature range, set the values in the
    // table. Otherwise, clear the values in the table.
    
    if ( [self.surfaceMaximum integerValue] > [self.surfaceMinimum integerValue] ) {
    
        [self.minimumSurface setText:[NSString stringWithFormat:temperatureFormat, [self.surfaceMinimum intValue]]];
        [self.minimumSurfaceStepper setValue:[self.surfaceMinimum integerValue]];
        [self.minimumSurfaceStepper setEnabled:YES];

        [self.maximumSurface setText:[NSString stringWithFormat:temperatureFormat, [self.surfaceMaximum intValue]]];
        [self.maximumSurfaceStepper setValue:[self.surfaceMaximum integerValue]];
        [self.maximumSurfaceStepper setEnabled:YES];

        [self.surfaceEnable setOn:YES];

    } else {
    
        [self.minimumSurface setText:@"--"];
        [self.minimumSurfaceStepper setEnabled:NO];

        [self.maximumSurface setText:@"--"];
        [self.maximumSurfaceStepper setEnabled:NO];

        //[self.surfaceEnable setOn:NO];

    }

    // If there is a defined ambient temperature range, set the values in the
    // table. Otherwise, clear the values in the table.
    
    if ( [self.ambientMaximum integerValue] > [self.ambientMinimum integerValue] ) {
    
        [self.minimumAmbient setText:[NSString stringWithFormat:temperatureFormat, [self.ambientMinimum intValue]]];
        [self.minimumAmbientStepper setValue:[self.ambientMinimum integerValue]];
        [self.minimumAmbientStepper setEnabled:YES];

        [self.maximumAmbient setText:[NSString stringWithFormat:temperatureFormat, [self.ambientMaximum intValue]]];
        [self.maximumAmbientStepper setValue:[self.ambientMaximum integerValue]];
        [self.maximumAmbientStepper setEnabled:YES];

        [self.ambientEnable setOn:YES];

    } else {
    
        [self.minimumAmbient setText:@"--"];
        [self.minimumAmbientStepper setEnabled:NO];

        [self.maximumAmbient setText:@"--"];
        [self.maximumAmbientStepper setEnabled:NO];

        //[self.ambientEnable setOn:NO];

    }

    // If there is a defined angle limit, set the values in the table. Otherwise,
    // clear the values.
    
    if ( [self.angleMaximum integerValue] > 0 ) {
    
        [self.angleLimit setText:[NSString stringWithFormat:angleFormat, [self.angleMaximum intValue]]];
        [self.angleStepper setValue:[self.angleMaximum integerValue]];
        [self.angleStepper setEnabled:YES];
        
        [self.angleEnable setOn:YES];
    
    } else {

        [self.angleLimit setText:@"--"];
        [self.angleStepper setEnabled:NO];

        //[self.angleEnable setOn:NO];

    }

    // Update the care and handling settings if the force limit is known.
    
    if ( self.forceMaximum ) {
    
        if ( [self.forceMaximum floatValue] >= kForceLimitCareful ) [self.careSettings setSelectedSegmentIndex:kCareSettingCareful];
        else if ( [self.forceMaximum floatValue] > 0 ) [self.careSettings setSelectedSegmentIndex:kCareSettingFragile];
        else [self.careSettings setSelectedSegmentIndex:kCareSettingNone];
    
    }
    
    // If the preferred orientation is specified.
    
    if ( self.orientation ) {
        
        switch ( self.orientation ) {
            case kOrientationFaceUp:
            case kOrientationFaceDown:  [self.orientationSettings setSelectedSegmentIndex:kPreferredOrientationFlat]; break;
            default:                    [self.orientationSettings setSelectedSegmentIndex:kPreferredOrientationUpright]; break;
        }
        
        [self.orientationSettings setEnabled:YES];
        
    } //else [self.orientationSettings setEnabled:NO];
    
}

#pragma mark - Surface Alarm Settings

- (IBAction) surfaceAlarmSwitch:(id)sender {

    // Check whether the alarm was toggled on or off. Update the
    // sensor limits accordingly and enable or disable the limit
    // steppers as appropriate.
    
    if ( [(UISwitch *)sender isOn] ) {

        [self.sensor.surface setTemperatureMinimum:self.surfaceMinimum];
        [self.sensor.surface setTemperatureMaximum:self.surfaceMaximum];

        [self.minimumSurface setText:[NSString stringWithFormat:temperatureFormat, [self.surfaceMinimum intValue]]];
        [self.minimumSurfaceStepper setValue:[self.surfaceMinimum integerValue]];
        [self.minimumSurfaceStepper setEnabled:YES];

        [self.maximumSurface setText:[NSString stringWithFormat:temperatureFormat, [self.surfaceMaximum intValue]]];
        [self.maximumSurfaceStepper setValue:[self.surfaceMaximum integerValue]];
        [self.maximumSurfaceStepper setEnabled:YES];

    } else {

        [self.sensor.surface setTemperatureMinimum:[NSNumber numberWithInteger:0]];
        [self.sensor.surface setTemperatureMaximum:[NSNumber numberWithInteger:0]];

        [self.minimumSurface setText:@"--"];
        [self.minimumSurfaceStepper setEnabled:NO];

        [self.maximumSurface setText:@"--"];
        [self.maximumSurfaceStepper setEnabled:NO];

    }

}

- (IBAction) minimumSurfaceStep:(id)sender {

    NSNumber *  value = [NSNumber numberWithDouble:[(UIStepper *)sender value]];
    
    if ( (_surfaceMinimum = value) ) {
        
        if ( [value integerValue] > [self.surfaceMaximum integerValue] ) {
        
            [self.maximumSurface setText:[NSString stringWithFormat:temperatureFormat, [value intValue]]];
            [self.maximumSurfaceStepper setValue:[(_surfaceMaximum = value) integerValue]];

        }
        
        [self.minimumSurface setText:[NSString stringWithFormat:temperatureFormat, [value intValue]]];
                
    }
    
    [self.sensor.surface setTemperatureMinimum:self.surfaceMinimum];
    [self.sensor.surface setTemperatureMaximum:self.surfaceMaximum];

}

- (IBAction) maximumSurfaceStep:(id)sender {

    NSNumber *  value = [NSNumber numberWithDouble:[(UIStepper *)sender value]];

    if ( (_surfaceMaximum = value) ) {
        
        if ( [value integerValue] < [self.surfaceMinimum integerValue] ) {

            [self.minimumSurface setText:[NSString stringWithFormat:temperatureFormat, [value intValue]]];
            [self.minimumSurfaceStepper setValue:[(_surfaceMinimum = value) integerValue]];

        }

        [self.maximumSurface setText:[NSString stringWithFormat:temperatureFormat, [value intValue]]];

    }

    [self.sensor.surface setTemperatureMinimum:self.surfaceMinimum];
    [self.sensor.surface setTemperatureMaximum:self.surfaceMaximum];

}

- (void) setSurfaceMinimum:(NSNumber *)minimum {

    if ( (_surfaceMinimum = minimum )) {

        // If the temperature range is defined, switch on the temperature alarm
        // and set the range limit values.
        
        if ( [self.surfaceMaximum integerValue] > [self.surfaceMinimum integerValue] ) {

            [self.minimumSurface setText:[NSString stringWithFormat:temperatureFormat, [self.surfaceMinimum intValue]]];
            [self.minimumSurfaceStepper setValue:[self.surfaceMinimum integerValue]];
            [self.minimumSurfaceStepper setEnabled:YES];

            [self.maximumSurface setText:[NSString stringWithFormat:temperatureFormat, [self.surfaceMaximum intValue]]];
            [self.maximumSurfaceStepper setValue:[self.surfaceMaximum integerValue]];
            [self.maximumSurfaceStepper setEnabled:YES];

            [self.surfaceEnable setOn:YES];
        
        }
        
        [self.surfaceEnable setEnabled:YES];
        
    }
    
}

- (void) setSurfaceMaximum:(NSNumber *)maximum {

    if ( (_surfaceMaximum = maximum )) {

        // If the temperature range is defined, switch on the temperature alarm
        // and set the range limit values.

        if ( [self.surfaceMaximum integerValue] > [self.surfaceMinimum integerValue] ) {

            [self.minimumSurface setText:[NSString stringWithFormat:temperatureFormat, [self.surfaceMinimum intValue]]];
            [self.minimumSurfaceStepper setValue:[self.surfaceMinimum integerValue]];
            [self.minimumSurfaceStepper setEnabled:YES];

            [self.maximumSurface setText:[NSString stringWithFormat:temperatureFormat, [self.surfaceMaximum intValue]]];
            [self.maximumSurfaceStepper setValue:[self.surfaceMaximum integerValue]];
            [self.maximumSurfaceStepper setEnabled:YES];

            [self.surfaceEnable setOn:YES];
        
        }

        [self.surfaceEnable setEnabled:YES];
        
    }

}

#pragma mark - Ambient Alarm Settings

- (IBAction) ambientAlarmSwitch:(id)sender {

    // Check whether the alarm was toggled on or off. Update the
    // sensor limits accordingly and enable or disable the limit
    // steppers as appropriate.
    
    if ( [(UISwitch *)sender isOn] ) {

        [self.sensor.atmosphere setAmbientMinimum:self.ambientMinimum];
        [self.sensor.atmosphere setAmbientMaximum:self.ambientMaximum];

        [self.minimumAmbient setText:[NSString stringWithFormat:temperatureFormat, [self.ambientMinimum intValue]]];
        [self.minimumAmbientStepper setValue:[self.ambientMinimum integerValue]];
        [self.minimumAmbientStepper setEnabled:YES];

        [self.maximumAmbient setText:[NSString stringWithFormat:temperatureFormat, [self.ambientMaximum intValue]]];
        [self.maximumAmbientStepper setValue:[self.ambientMaximum integerValue]];
        [self.maximumAmbientStepper setEnabled:YES];

    } else {

        [self.sensor.atmosphere setAmbientMinimum:[NSNumber numberWithInteger:0]];
        [self.sensor.atmosphere setAmbientMaximum:[NSNumber numberWithInteger:0]];

        [self.minimumAmbient setText:@"--"];
        [self.minimumAmbientStepper setEnabled:NO];

        [self.maximumAmbient setText:@"--"];
        [self.maximumAmbientStepper setEnabled:NO];

    }
    
}

- (IBAction) minimumAmbientStep:(id)sender {

    NSNumber *  value = [NSNumber numberWithDouble:[(UIStepper *)sender value]];

    if ( (_ambientMinimum = value) ) {
        
        if ( [value integerValue] > [self.ambientMaximum integerValue] ) {
        
            [self.maximumAmbient setText:[NSString stringWithFormat:temperatureFormat, [value intValue]]];
            [self.maximumAmbientStepper setValue:[(_ambientMaximum = value) integerValue]];

        }
        
        [self.minimumAmbient setText:[NSString stringWithFormat:temperatureFormat, [value intValue]]];
    
    }

    [self.sensor.atmosphere setAmbientMinimum:self.ambientMinimum];
    [self.sensor.atmosphere setAmbientMaximum:self.ambientMaximum];

}

- (IBAction) maximumAmbientStep:(id)sender {

    NSNumber *  value = [NSNumber numberWithDouble:[(UIStepper *)sender value]];

    if ( (_ambientMaximum = value) ) {
        
        if ( [value integerValue] < [self.ambientMinimum integerValue] ) {
        
            [self.minimumAmbient setText:[NSString stringWithFormat:temperatureFormat, [value intValue]]];
            [self.minimumAmbientStepper setValue:[(_ambientMinimum = value) integerValue]];

        }

        [self.maximumAmbient setText:[NSString stringWithFormat:temperatureFormat, [value intValue]]];
    
    }

    [self.sensor.atmosphere setAmbientMinimum:self.ambientMinimum];
    [self.sensor.atmosphere setAmbientMaximum:self.ambientMaximum];
    
}

- (void) setAmbientMinimum:(NSNumber *)minimum {

    if ( (_ambientMinimum = minimum )) {

        // If the temperature range is defined, switch on the temperature alarm
        // and set the range limit values.
        
        if ( [self.ambientMaximum integerValue] > [self.ambientMinimum integerValue] ) {

            [self.minimumAmbient setText:[NSString stringWithFormat:temperatureFormat, [self.ambientMinimum intValue]]];
            [self.minimumAmbientStepper setValue:[self.ambientMinimum integerValue]];
            [self.minimumAmbientStepper setEnabled:YES];

            [self.maximumAmbient setText:[NSString stringWithFormat:temperatureFormat, [self.ambientMaximum intValue]]];
            [self.maximumAmbientStepper setValue:[self.ambientMaximum integerValue]];
            [self.maximumAmbientStepper setEnabled:YES];

            [self.ambientEnable setOn:YES];
        
        }
        
        [self.ambientEnable setEnabled:YES];
        
    }
    
}

- (void) setAmbientMaximum:(NSNumber *)maximum {

    if ( (_ambientMaximum = maximum )) {

        // If the temperature range is defined, switch on the temperature alarm
        // and set the range limit values.

        if ( [self.ambientMaximum integerValue] > [self.ambientMinimum integerValue] ) {

            [self.minimumAmbient setText:[NSString stringWithFormat:temperatureFormat, [self.ambientMinimum intValue]]];
            [self.minimumAmbientStepper setValue:[self.ambientMinimum integerValue]];
            [self.minimumAmbientStepper setEnabled:YES];

            [self.maximumAmbient setText:[NSString stringWithFormat:temperatureFormat, [self.ambientMaximum intValue]]];
            [self.maximumAmbientStepper setValue:[self.ambientMaximum integerValue]];
            [self.maximumAmbientStepper setEnabled:YES];

            [self.ambientEnable setOn:YES];
        
        }

        [self.ambientEnable setEnabled:YES];
        
    }

}

#pragma mark - Preferred Orientation Settings

- (IBAction) orientationSelection:(id)sender {

    NSUInteger  index   = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    switch ( index ) {
    
        case kPreferredOrientationFlat:     _orientation = kOrientationFaceUp; break;
        case kPreferredOrientationUpright:  _orientation = kOrientationFaceUpright; break;
            
    }
    
    [self.sensor.handling setFacePreferred:self.orientation];

}

- (void) setOrientation:(OrientationFace)orientation {

    if ( (_orientation = orientation) ) {

        switch ( orientation ) {
        
            case kOrientationFaceUp:
            case kOrientationFaceDown:  [self.orientationSettings setSelectedSegmentIndex:kPreferredOrientationUpright]; break;
            default:                    [self.orientationSettings setSelectedSegmentIndex:kPreferredOrientationFlat]; break;
                
        }
        
        [self.orientationSettings setEnabled:YES];

    }
    
}

#pragma mark - Tilt Angle Settings

- (IBAction) angleAlarmSwitch:(id)sender {

    // Check whether the alarm was toggled on or off. Update the
    // sensor limits accordingly and enable or disable the limit
    // steppers as appropriate.
    
    if ( [(UISwitch *)sender isOn] ) {

        [self.sensor.handling setAngleLimit:self.angleMaximum];

        [self.angleLimit setText:[NSString stringWithFormat:angleFormat, [self.angleMaximum intValue]]];
        [self.angleStepper setValue:[self.angleMaximum integerValue]];
        [self.angleStepper setEnabled:YES];

    } else {

        [self.sensor.handling setAngleLimit:[NSNumber numberWithInteger:0]];

        [self.angleLimit setText:@"--"];
        [self.angleStepper setEnabled:NO];

    }
    
}

- (IBAction) angleLimitStep:(id)sender {

    NSNumber *  value = [NSNumber numberWithDouble:[(UIStepper *)sender value]];

    if ( (_angleMaximum = value) ) {
        
        [self.angleLimit setText:[NSString stringWithFormat:angleFormat, [value intValue]]];
    
    }

    [self.sensor.handling setAngleLimit:self.angleMaximum];

}

- (void) setAngleMaximum:(NSNumber *)maximum {

    if ( (_angleMaximum = maximum) ) {

        // If the angle limit is defined, switch on the tilt alarm and set the value.

        if ( [self.angleMaximum integerValue] > 0 ) {

            [self.angleLimit setText:[NSString stringWithFormat:angleFormat, [maximum intValue]]];
            [self.angleStepper setValue:[maximum integerValue]];
            [self.angleStepper setEnabled:YES];
            
            [self.angleEnable setOn:YES];
        
        }

        [self.angleEnable setEnabled:YES];
        
    }

}

#pragma mark - Telemetry Measurement and Archive Intervals

- (IBAction) telemetryIntervalSelected:(id)sender {

    NSUInteger  index   = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    if ( index == kTelemetrySettingSlow ) { _telemetryInterval = [NSNumber numberWithFloat:kTelemetryIntervalSlow]; }
    else { _telemetryInterval = [NSNumber numberWithFloat:kTelemetryIntervalFast]; }
    
    [self.sensor.telemetry setInterval:self.telemetryInterval];
    
}

- (void) setTelemetryInterval:(NSNumber *)interval {

    if ( (_telemetryInterval = interval) ) {

        if ( [interval floatValue] >= kTelemetryIntervalSlow ) [self.telemetrySettings setSelectedSegmentIndex:kTelemetrySettingSlow];
        else [self.telemetrySettings setSelectedSegmentIndex:kTelemetrySettingFast];
        
        [self.telemetrySettings setEnabled:YES];
        
    }

}

- (IBAction) archiveIntervalSelected:(id)sender {

    NSUInteger  index   = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    if ( index == kArchiveSettingSlow ) { _archiveInterval = [NSNumber numberWithFloat:kArchiveIntervalSlow]; }
    else { _archiveInterval = [NSNumber numberWithFloat:kArchiveIntervalFast]; }
    
    [self.sensor.telemetry setArchival:self.archiveInterval];
    
}

- (void) setArchiveInterval:(NSNumber *)interval {

    if ( (_archiveInterval = interval) ) {

        if ( [interval floatValue] >= kArchiveIntervalSlow ) [self.archiveSettings setSelectedSegmentIndex:kArchiveSettingSlow];
        else [self.archiveSettings setSelectedSegmentIndex:kArchiveSettingFast];

        [self.archiveSettings setEnabled:YES];
        
    }

}

#pragma mark - Handling and Care Settings

- (IBAction) careSelection:(id)sender {
    
    NSUInteger  index   = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    switch ( index ) {
    
        case kCareSettingFragile:   _forceMaximum = [NSNumber numberWithFloat:kForceLimitFragile]; break;
        case kCareSettingCareful:   _forceMaximum = [NSNumber numberWithFloat:kForceLimitCareful]; break;
        default:                    _forceMaximum = [NSNumber numberWithInteger:0]; break;
            
    }
    
    [self.sensor.handling setForceLimit:self.forceMaximum];

}

- (void) setForceMaximum:(NSNumber *)maximum {

    if ( (_forceMaximum = maximum) ) {

        if ( [maximum floatValue] >= kForceLimitCareful ) [self.careSettings setSelectedSegmentIndex:kCareSettingCareful];
        else if ( [maximum floatValue] > 0 ) [self.careSettings setSelectedSegmentIndex:kCareSettingFragile];
        else [self.careSettings setSelectedSegmentIndex:kCareSettingNone];

        [self.careSettings setEnabled:YES];

    }
    
}

@end
