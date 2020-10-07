//
//  project: ShockVx
//     file: AssetTelemetryTabController.m
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetTelemetryTabController.h"
#import "AssetTelemetryHeader.h"
#import "AssetTelemetryCell.h"

@interface AssetTelemetryTabController ( )

@end

@implementation AssetTelemetryTabController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self.collectionView setDelegate:self];
    
}

//
// Pre-load the telemetry values from the sensor services prior
// to presenting the telemetry tab view.
- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    // Pre-load the surface metrics and limits from the sensor.
    
    self.surface            = self.sensor.surface.temperature;
    self.surfaceMinimum     = self.sensor.surface.temperatureMinimum;
    self.surfaceMaximum     = self.sensor.surface.temperatureMaximum;
    
    // Pre-load the ambient metrics and limits from the sensor.

    self.ambient            = self.sensor.atmosphere.ambient;
    self.ambientMinimum     = self.sensor.atmosphere.ambientMinimum;
    self.ambientMaximum     = self.sensor.atmosphere.ambientMaximum;

    // Pre-load the humidity metrics and limits from the sensor.

    self.humidity           = self.sensor.atmosphere.humidity;
    self.humidityMinimum    = self.sensor.atmosphere.humidityMinimum;
    self.humidityMaximum    = self.sensor.atmosphere.humidityMaximum;

    // Pre-load the pressure metrics and limits from the sensor.

    self.pressure           = self.sensor.atmosphere.pressure;
    self.pressureMinimum    = self.sensor.atmosphere.pressureMinimum;
    self.pressureMaximum    = self.sensor.atmosphere.pressureMaximum;
    
    // Pre-load the force metrics and limits from the sensor.
    
    self.force              = self.sensor.handling.force;
    self.forceMaximum       = self.sensor.handling.forceLimit;
    
    // Pre-load the angle metrics and limits from the sensor.
    
    self.angle              = self.sensor.handling.angle;
    self.angleMaximum       = self.sensor.handling.angleLimit;
    
    // Get the orientation from the sensor.
    
    self.orientation        = [NSNumber numberWithInteger:self.sensor.handling.face];
    
}

//
// Reload the collection view after showing the page so that
// the telemetry items are populated with the latest values.
- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self.collectionView reloadData];

}

#pragma mark - Collection Data Source

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collection { return ( nTelemetryGroups ); }

- (NSInteger) collectionView:(UICollectionView *)collection numberOfItemsInSection:(NSInteger)section {
    
    switch ( section ) {
            
        case kTelemetryGroupEnvironment:    return ( nEnvrionmentItems );
        case kTelemetryGroupHandling:       return ( nHandlingItems );
    
    }
    
    return ( 0 );
    
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collection viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)path {

    AssetTelemetryHeader *  header  = [collection dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"telemetryHeader" forIndexPath:path];
    
    if ( header ) {
        
        [header setText:[self collectionView:collection headerForItemAtIndexPath:path]];
        
    }
    
    return ( header );
    
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collection cellForItemAtIndexPath:(NSIndexPath *)path {
    
    AssetTelemetryCell *    cell    = [collection dequeueReusableCellWithReuseIdentifier:@"telemetryItem" forIndexPath:path];
    
    if ( cell ) {
    
        [cell setImage:[self collectionView:collection imageForItemAtIndexPath:path]];
        [cell setLabel:[self collectionView:collection labelForItemAtIndexPath:path]];
        [cell setValue:[self collectionView:collection valueForItemAtIndexPath:path]];
        [cell setUpper:[self collectionView:collection upperLimitForItemAtIndexPath:path]];
        [cell setLower:[self collectionView:collection lowerLimitForItemAtIndexPath:path]];
                
    }
    
    return ( cell );

}

- (NSString *) collectionView:(UICollectionView *)collection labelForItemAtIndexPath:(NSIndexPath *)path {

    if ( path.section == kTelemetryGroupEnvironment ) switch ( path.row ) {
    
        case kEnvironmentItemSurface:   return @"Surface";
        case kEnvironmentItemAmbient:   return @"Ambient";
        case kEnvironmentItemHumidity:  return @"Humidity";
        case kEnvironmentItemPressure:  return @"Pressure";

    }

    if ( path.section == kTelemetryGroupHandling ) switch ( path.row ) {
    
        case kHandlingItemForce:       return @"Forces";
        case kHandlingItemAngle:       return [self orientationLabel];

    }
    
    return nil;
    
}

- (NSString *) collectionView:(UICollectionView *)collection headerForItemAtIndexPath:(NSIndexPath *)path {

    switch ( path.section ) {
    
        case kTelemetryGroupEnvironment:    return @"Environment";
        case kTelemetryGroupHandling:       return @"Handling";
            
    }
    
    return nil;
    
}

- (NSString *) collectionView:(UICollectionView *)collection valueForItemAtIndexPath:(NSIndexPath *)path {

    if ( path.section == kTelemetryGroupEnvironment ) switch ( path.row ) {
            
         case kEnvironmentItemSurface:  if ( self.surface ) return [NSString stringWithFormat:@"%1.2f \u2103", [self.surface floatValue]];
         else break;
             
         case kEnvironmentItemAmbient:  if ( self.ambient ) return [NSString stringWithFormat:@"%1.2f \u2103", [self.ambient floatValue]];
         else break;
             
         case kEnvironmentItemHumidity: if ( self.humidity ) return [NSString stringWithFormat:@"%1.2f %%", 100.0 * [self.humidity floatValue]];
         else break;
             
         case kEnvironmentItemPressure: if ( self.pressure ) return [NSString stringWithFormat:@"%1.3f bar", [self.pressure floatValue]];
         else break;

    }

    if ( path.section == kTelemetryGroupHandling ) switch ( path.row ) {
    
        case kHandlingItemAngle:        if ( self.angle ) return [NSString stringWithFormat:@"%1.1f \u00b0", [self.angle floatValue]];
        else break;
            
        case kHandlingItemForce:        if ( self.force ) return [NSString stringWithFormat:@"%1.2f g", [self.force floatValue]];
        else break;

    }
    
    return @"--";

}

- (NSString *) collectionView:(UICollectionView *)collection upperLimitForItemAtIndexPath:(NSIndexPath *)path {

    if ( path.section == kTelemetryGroupEnvironment ) switch ( path.row ) {

        case kEnvironmentItemSurface:   if ( [self.surfaceMaximum integerValue] > [self.surfaceMinimum integerValue] ) return [NSString stringWithFormat:@"%1.2f\u2103", [self.surfaceMaximum floatValue]];
        else break;
            
        case kEnvironmentItemAmbient:   if ( [self.ambientMaximum integerValue] > [self.ambientMinimum integerValue] ) return [NSString stringWithFormat:@"%1.2f\u2103", [self.ambientMaximum floatValue]];
        else break;
            
        case kEnvironmentItemHumidity:  if ( [self.humidityMaximum integerValue] > [self.humidityMinimum integerValue] ) return [NSString stringWithFormat:@"%1.2f%%", 100.0 * [self.humidityMaximum floatValue]];
        else break;
            
        case kEnvironmentItemPressure:  if ( [self.pressureMaximum integerValue] > [self.pressureMinimum integerValue] ) return [NSString stringWithFormat:@"%1.3f", [self.pressureMaximum floatValue]];
        else break;
    
    }

    if ( path.section == kTelemetryGroupHandling ) switch ( path.row ) {

        case kHandlingItemAngle:        if ( [self.angleMaximum integerValue] > 0 ) return [NSString stringWithFormat:@"%1.1f \u00b0", [self.angleMaximum floatValue]];
        else break;
            
        case kHandlingItemForce:        if ( [self.forceMaximum integerValue] > 0 ) return [NSString stringWithFormat:@"%1.1f g", [self.forceMaximum floatValue]];
        else break;
            
    }
    
    return nil;

}

- (NSString *) collectionView:(UICollectionView *)collection lowerLimitForItemAtIndexPath:(NSIndexPath *)path {

    if ( path.section == kTelemetryGroupEnvironment ) switch ( path.row ) {

        case kEnvironmentItemSurface:   if ( [self.surfaceMaximum integerValue] > [self.surfaceMinimum integerValue] ) return [NSString stringWithFormat:@"%1.2f \u2103", [self.surfaceMinimum floatValue]];
        else break;
            
        case kEnvironmentItemAmbient:   if ( [self.ambientMaximum integerValue] > [self.ambientMinimum integerValue] ) return [NSString stringWithFormat:@"%1.2f \u2103", [self.ambientMinimum floatValue]];
        else break;
            
        case kEnvironmentItemHumidity:  if ( [self.humidityMaximum integerValue] > [self.humidityMinimum integerValue] ) return [NSString stringWithFormat:@"%1.2f %%", 100.0 * [self.humidityMinimum floatValue]];
        else break;
            
        case kEnvironmentItemPressure:  if ( [self.pressureMaximum integerValue] > [self.pressureMinimum integerValue] ) return [NSString stringWithFormat:@"%1.3f", [self.pressureMinimum floatValue]];
        else break;

    }

    return nil;

}

- (UIImage *) collectionView:(UICollectionView *)collection imageForItemAtIndexPath:(NSIndexPath *)path {

    if ( path.section == kTelemetryGroupEnvironment ) switch ( path.row ) {

        case kEnvironmentItemSurface:   return [UIImage imageNamed:@"Surface"];
        case kEnvironmentItemAmbient:   return [UIImage imageNamed:@"Temperature"];
        case kEnvironmentItemHumidity:  return [UIImage imageNamed:@"Moisture"];
        case kEnvironmentItemPressure:  return [UIImage imageNamed:@"Pressure"];

    }
    
    if ( path.section == kTelemetryGroupHandling ) switch ( path.row ) {
    
        case kHandlingItemAngle:        return [UIImage imageNamed:@"Angles"];
        case kHandlingItemForce:        return [UIImage imageNamed:@"Forces"];

    }
    
    return nil;

}

#pragma mark - Collection Delegate

 - (BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath { return NO; }


#pragma mark - Flow Layout Delegate

- (CGSize) collectionView:(UICollectionView *)collection layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)path {

    CGFloat     insets      = 20.0;
    CGFloat     spacing     = 20.0;
    CGFloat     width       = collection.bounds.size.width - (2 * insets) - spacing;
    CGFloat     height      = collection.bounds.size.height - (2 * insets) - spacing;
    CGSize      size        = (height > width ) ? CGSizeMake ( floor(width / 2), floor(width / 2) ) : CGSizeMake ( floor(height / 2), floor(height / 2));
    
    return ( size );
    
}

- (CGSize) collectionView:(UICollectionView *)collection layout:(UICollectionViewLayout *)layout referenceSizeForHeaderInSection:(NSInteger)section {

    CGSize      size        = CGSizeMake ( collection.bounds.size.width, 35.0 );
    
    return ( size );
    
}

#pragma mark - Telemetry Values

- (void) setPressure:(NSNumber *)pressure {

    if ( (_pressure = pressure) ) {
    
        NSIndexPath *   path = [NSIndexPath indexPathForRow:kEnvironmentItemPressure inSection:kTelemetryGroupEnvironment];

        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:path]];
        
    }
    
}

- (void) setHumidity:(NSNumber *)humidity {

    if ( (_humidity = humidity) ) {

        NSIndexPath *   path = [NSIndexPath indexPathForRow:kEnvironmentItemHumidity inSection:kTelemetryGroupEnvironment];

        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:path]];

    }

}

- (void) setAmbient:(NSNumber *)ambient {

    if ( (_ambient = ambient) ) {

        NSIndexPath *   path = [NSIndexPath indexPathForRow:kEnvironmentItemAmbient inSection:kTelemetryGroupEnvironment];

        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:path]];

    }

}

- (void) setSurface:(NSNumber *)surface {

    if ( (_surface = surface) ) {

        NSIndexPath *   path = [NSIndexPath indexPathForRow:kEnvironmentItemSurface inSection:kTelemetryGroupEnvironment];

        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:path]];

    }

}

#pragma mark - Orientation and Angle Values

- (NSString *) orientationLabel {

    switch ( (OrientationFace) [self.orientation unsignedIntegerValue] ) {

        case kOrientationFaceUpright:   return @"Upright";
        case kOrientationFaceInverted:  return @"Inverted";
        case kOrientationFaceLeftHand:  return @"Left Handed";
        case kOrientationFaceRightHand: return @"Right Handed";
        case kOrientationFaceDown:      return @"Face Down";
        case kOrientationFaceUp:        return @"Face Up";
        default:                        return @"Orientation";

    }

}

- (void) setOrientation:(NSNumber *)orientation {

    if ( (_orientation = orientation) ) {

        NSIndexPath *   path = [NSIndexPath indexPathForRow:kHandlingItemAngle inSection:kTelemetryGroupHandling];

        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:path]];

    }

}

- (void) setAngle:(NSNumber *)angle {

    if ( (_angle = angle) ) {

        NSIndexPath *   path = [NSIndexPath indexPathForRow:kHandlingItemAngle inSection:kTelemetryGroupHandling];

        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:path]];

    }

}

#pragma mark - Force Values

- (void) setForce:(NSNumber *)force {

    if ( (_force = force) ) {

        NSIndexPath *   path = [NSIndexPath indexPathForRow:kHandlingItemForce inSection:kTelemetryGroupHandling];

        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:path]];

    }

}

@end
