//
//  project: ShockVx
//     file: AssetTrackingTabController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetTrackingTabController.h"
#import "BatteryControl.h"
#import "SignalControl.h"
#import "AppDelegate.h"

@interface AssetTrackingTabController ( )

@property (nonatomic, weak, readonly)   AppSettings *       settings;

@property (nonatomic, weak) IBOutlet    UIImageView *       graphicImage;
@property (nonatomic, weak) IBOutlet    BatteryControl *    batteryControl;
@property (nonatomic, weak) IBOutlet    SignalControl *     signalControl;

@property (nonatomic, weak) IBOutlet    UIView *            assetView;
@property (nonatomic, weak) IBOutlet    UIScrollView *      scrollView;
@property (nonatomic, weak) IBOutlet    UILabel *           openedLabel;
@property (nonatomic, weak) IBOutlet    UILabel *           closedLabel;
@property (nonatomic, weak) IBOutlet    UILabel *           trackingOpened;
@property (nonatomic, weak) IBOutlet    UILabel *           trackingClosed;
@property (nonatomic, weak) IBOutlet    UILabel *           trackingNumber;

@property (nonatomic, weak) IBOutlet    UITextField *       descriptionField;
@property (nonatomic, weak) IBOutlet    UITextField *       locationField;
@property (nonatomic, weak) IBOutlet    UIButton *          locationReset;
@property (nonatomic, strong )          NSString *          locationName;

@property (nonatomic, weak) IBOutlet    UIButton *          actionButton;

@end

@implementation AssetTrackingTabController

- (void) awakeFromNib {

    [super awakeFromNib];

    [self.graphicImage setTintColor:self.view.tintColor];
    [self.graphicImage setImage:[self.graphicImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];

}

- (void) viewDidLoad {

    AppDelegate *   application = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    _settings                   = application.settings;

    [super viewDidLoad];

    [self.assetView.layer setBorderWidth:1.0];
    [self.assetView.layer setBorderColor:[self.view tintColor].CGColor];
    [self.assetView.layer setCornerRadius:10.0];
    [self.assetView setClipsToBounds:YES];

    [self.actionButton setClipsToBounds:YES];
    [self.actionButton setBackgroundColor:self.view.tintColor];
    [self.actionButton setTintColor:[UIColor whiteColor]];
    [self.actionButton.layer setCornerRadius:10.0];

}

- (void) viewWillAppear:(BOOL)animated {

    if ( self.assetDescription ) [self.descriptionField setText:self.assetDescription];
    if ( self.assetLocale ) [self.locationField setText:self.assetLocale];
    
}

#pragma mark - Current location information

- (void) setLocation:(CLLocation *)location {

    dispatch_async( dispatch_get_main_queue( ), ^{ [self.locationReset setEnabled:YES]; });
    
}

- (void) setPlacemark:(CLPlacemark *)placemark {
 
    NSMutableString *   address = [[NSMutableString alloc] initWithString:@""];
    
    if ( placemark.thoroughfare ) [address appendString:placemark.thoroughfare];
    if ( placemark.subLocality ) [address appendString:[NSString stringWithFormat:@", %@", placemark.subLocality]];
    if ( placemark.locality ) [address appendString:[NSString stringWithFormat:@" %@", placemark.locality]];
    
    if ( placemark.administrativeArea ) [address appendString:[NSString stringWithFormat:@", %@", placemark.administrativeArea]];
    if ( placemark.ISOcountryCode ) [address appendString:[NSString stringWithFormat:@" (%@)", placemark.ISOcountryCode]];

    if ( (_locationName = address) ) dispatch_async( dispatch_get_main_queue( ), ^{

        [self setAssetLocale:address];

    });
    
}

- (IBAction) locationReset:(id)sender {

    if ( self.locationName ) [self setAssetLocale:self.locationName];
    
}

#pragma mark - Sensor Signal and Battery

- (void) setSignal:(NSNumber *)signal {

    if ( (_signal = signal) ) [self.signalControl setSignalLevel:[signal floatValue]];
    
    [self.signalControl setHidden:NO];
    
}

- (void) setBattery:(NSNumber *)battery {

    if ( (_battery = battery) ) [self.batteryControl setBatteryLevel:[battery floatValue]];
    
    [self.batteryControl setHidden:NO];
    
}

#pragma mark - Asset Tracking Window

- (void) setAssetNumber:(NSString *)number {

    if ( (_assetNumber = number) ) { [self.trackingNumber setText:number]; }

}

- (void) setAssetDescription:(NSString *)description {

    if ( (_assetDescription = description) ) { [self.descriptionField setText:description]; }
    
}

- (void) setAssetLocale:(NSString *)locale {

    if ( (_assetLocale = locale) ) { [self.locationField setText:locale]; }
    
}

- (void) setDateOpened:(NSDate *)date {

    if ( (_dateOpened = date) ) {

        NSDateFormatter *   formatter   = [[NSDateFormatter alloc] init];
        formatter.dateStyle             = NSDateFormatterMediumStyle;
        formatter.timeStyle             = NSDateFormatterShortStyle;
        
        [self.trackingOpened setText:[formatter stringFromDate:date]];
        [self.trackingOpened setHidden:NO];
        [self.openedLabel setHidden:NO];
        
    } else {

        [self.trackingOpened setText:@"--"];
        [self.trackingOpened setHidden:YES];
        [self.openedLabel setHidden:YES];

    }

    [self setAction];
    
}

- (void) setDateClosed:(NSDate *)date {

    if ( (_dateClosed = date) ) {

        NSDateFormatter *   formatter   = [[NSDateFormatter alloc] init];
        formatter.dateStyle             = NSDateFormatterMediumStyle;
        formatter.timeStyle             = NSDateFormatterShortStyle;
        
        [self.trackingClosed setText:[formatter stringFromDate:date]];
        [self.trackingClosed setHidden:NO];
        [self.closedLabel setHidden:NO];
        
    } else {

        [self.trackingClosed setText:@"--"];
        [self.trackingClosed setHidden:YES];
        [self.closedLabel setHidden:YES];

    }

    [self setAction];

}

#pragma mark - Tracking Actions

- (void) setAction {

    if ( self.dateClosed ) {

        // NOTE: this is temporary
        [self.actionButton setTitle:NSLocalizedString( @"Reset Sensor", @"Reset" ) forState:UIControlStateNormal];
        [self.actionButton setHidden:NO];

    } else if ( self.dateOpened ) {

        [self.actionButton setTitle:NSLocalizedString( @"Close Tracking", @"Accept" ) forState:UIControlStateNormal];
        [self.actionButton setHidden:NO];
        
    } else {

        [self.actionButton setTitle:NSLocalizedString( @"Open Tracking", @"Open" ) forState:UIControlStateNormal];
        [self.actionButton setHidden:NO];

    }

}

- (IBAction) pressAction:(id)sender {
    
    if ( self.dateClosed ) {
        
        [self.sensor.access requestErase];
        
    } else if ( self.dateOpened ) {
        
        if ( self.delegate ) [self.delegate assetTrackingClosed];
        [self.sensor.control closeUsingIdentifier:self.settings.userCode];
        
    } else {
        
        if ( self.delegate ) [self.delegate assetTrackingOpened];
        [self.sensor.control openUsingIdentifier:self.settings.userCode];
        
    }
    
}

#pragma mark - Text Fields

- (void) textFieldDidBeginEditing:(UITextField *)field {

    [self.scrollView setContentOffset:CGPointMake( 0, field.frame.origin.y - 10.0 ) animated:YES];

}

- (void) textFieldDidEndEditing:(UITextField *)field {

    [self.scrollView setContentOffset:CGPointMake( 0, 0 ) animated:YES];

    switch ( field.tag ) {
    
        case 1: _assetDescription = field.text; break;
        case 2: _assetLocale = field.text; break;
    
    }
    
}

- (bool) textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string { return ( YES ); }

- (bool) textFieldShouldReturn:(UITextField *)field {
    
    [field resignFirstResponder];
    
    return ( YES );
    
}

@end
