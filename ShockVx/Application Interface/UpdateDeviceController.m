//
//  project: ShockVx
//     file: UpdateDeviceController.m
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "UpdateDeviceController.h"
#import "AssetPackage.h"

@interface UpdateDeviceController ( )

@property (nonatomic, strong) AssetPackage *            package;

@property (nonatomic, weak) IBOutlet UIButton *         updateButton;
@property (nonatomic, weak) IBOutlet UIButton *         cancelButton;

@property (nonatomic, weak) IBOutlet UILabel *          statusLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *   statusProgress;
@property (nonatomic, weak) IBOutlet UILabel *          statusNote;

@property (nonatomic, weak) IBOutlet UIView *           fromView;
@property (nonatomic, weak) IBOutlet UILabel *          fromVersion;
@property (nonatomic, weak) IBOutlet UILabel *          fromBuild;

@property (nonatomic, weak) IBOutlet UIView *           toView;
@property (nonatomic, weak) IBOutlet UILabel *          toVersion;
@property (nonatomic, weak) IBOutlet UILabel *          toBuild;

@end

@implementation UpdateDeviceController

- (void) awakeFromNib {

    [super awakeFromNib];
 
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    [self viewPostLoad];

    // Load the firmware package from the embedded bundle.
    
    [self setPackage:[self loadPackage:@"firmware"]];

    // Register for connection notices.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMeasureSignal:) name:kDeviceNotificationSignal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDropConnection:) name:kDeviceNotificationDropped object:nil];

    // Register for firmware package information notices.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPackageArea:) name:kUpdateNotificationPackageArea object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPackageData:) name:kUpdateNotificationPackageData object:nil];
 
    // Register for firmware update notices.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartUpdate:) name:kUpdateNotificationPackageStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didContinueUpdate:) name:kUpdateNotificationPackageProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteUpdate:) name:kUpdateNotificationPackageComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailUpdate:) name:kUpdateNotificationPackageFailure object:nil];

}

- (void) viewPostLoad {
    
    [self.fromView setClipsToBounds:YES];
    [self.fromView.layer setCornerRadius:10.0];
    [self.fromView.layer setBorderWidth:1.0];
    [self.fromView.layer setBorderColor:[self.view.tintColor CGColor]];

    [self.toView setClipsToBounds:YES];
    [self.toView.layer setCornerRadius:10.0];
    [self.toView.layer setBorderWidth:1.0];
    [self.toView.layer setBorderColor:[self.view.tintColor CGColor]];

    [self.updateButton setClipsToBounds:YES];
    [self.updateButton setBackgroundColor:self.view.tintColor];
    [self.updateButton setTintColor:[UIColor whiteColor]];
    [self.updateButton.layer setCornerRadius:10.0];

}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) { [self.device detachFromManager]; }
    
}

- (void) viewWillAppear:(BOOL)animated {

    [self viewRefreshFrom];
    [self viewRefreshTo];

}

- (void) viewRefreshTo {

    if ( self.package.majorVersion && self.package.minorVersion ) {
    
        [self.toVersion setText:[NSString stringWithFormat:@"Version %u.%u", [self.package.majorVersion unsignedIntValue], [self.package.minorVersion unsignedIntValue]]];
    
    }
    
    if ( self.package.buildNumber ) {
        
        if ( [self.package.buildNumber unsignedShortValue] < ((unsigned short) -1) ) {
            [self.toBuild setText:[NSString stringWithFormat:@"(%u)", [self.package.buildNumber unsignedIntValue]]];
        } else [self.toBuild setText:@"(release)"];
    
    }

}

- (void) viewRefreshFrom {

    if ( self.device.update.versionMajor && self.device.update.versionMinor ) {
    
        [self.fromVersion setText:[NSString stringWithFormat:@"Version %u.%u", [self.device.update.versionMajor unsignedIntValue], [self.device.update.versionMinor unsignedIntValue]]];
    
    }
    
    if ( self.device.update.versionBuild ) {
    
        if ( [self.device.update.versionBuild unsignedShortValue] < ((unsigned short) -1) ) {
            [self.fromBuild setText:[NSString stringWithFormat:@"(%u)", [self.device.update.versionBuild unsignedIntValue]]];
        } else [self.fromBuild setText:@"(release)"];
    
    }

}

- (IBAction) startUpdate:(id)sender {

    // Start the update of the package.

    [self.device updatePackage:[self.package data] atAddress:[self.package address]];

}

- (IBAction) cancelUpdate:(id)sender {

    // Cancel the update by re-booting the device back to its original firmware.
    
    [self.device.access requestReboot];
    
}

#pragma mark - Device connection notifications

- (void) didMeasureSignal:(NSNotification *)notification {

    UpdateDevice *          device      = (UpdateDevice *) notification.object;
    NSNumber *              signal      = [notification.userInfo objectForKey:@"signal"];
    
}

- (void) didDropConnection:(NSNotification *)notification {

    UpdateDevice *          device      = (UpdateDevice *) notification.object;

    if ( [device isEqual:self.device] ) { [self performSegueWithIdentifier:@"lostConnection" sender:self]; }

}

#pragma mark - Package update notifications

- (void) didGetPackageArea:(NSNotification *)notification {

    UpdateDevice *          device      = (UpdateDevice *) notification.object;
    NSNumber *              size        = [notification.userInfo objectForKey:@"size"];

    if ( [device isEqual:self.device] ) { [self.updateButton setEnabled:YES]; }

}

- (void) didGetPackageData:(NSNotification *)notification {

    UpdateDevice *          device      = (UpdateDevice *) notification.object;
    NSNumber *              code        = [notification.userInfo objectForKey:@"code"];
    
    if ( [device isEqual:self.device] ) { [self viewRefreshFrom]; }
    
}

- (void) didStartUpdate:(NSNotification *)notification {

    UpdateDevice *          device      = (UpdateDevice *) notification.object;
    
    // The update has started for this device so switch the status text
    // and note to inform the user and disable both the update and cancel
    // buttons.
    
    if ( [device isEqual:self.device] ) {
        
        [self.statusLabel setText:@"preparing"];
        [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.statusNote setText:@"Keep your mobile device nearby until the update is complete."];
        
        [self.statusProgress setProgress:0];
        [self.statusProgress setHidden:NO];
        
        [self.updateButton setEnabled:NO];
        [self.cancelButton setHidden:YES];
        
    }

}

- (void) didContinueUpdate:(NSNotification *)notification {

    UpdateDevice *          device      = (UpdateDevice *) notification.object;
    NSNumber *              progress    = [notification.userInfo objectForKey:@"progress"];
    
    // The update is proceeding with firmware writes. Update the progress
    // bar and inform the user.
    
    if ( [device isEqual:self.device] ) {
        
        [self.statusLabel setText:@"updating"];
        
        if ( progress ) [self.statusProgress setProgress:[progress floatValue] animated:YES];

    }

}

- (void) didCompleteUpdate:(NSNotification *)notification {

    UpdateDevice *          device      = (UpdateDevice *) notification.object;
    
    // The update is complete. Inform the user. Make sure that progress
    // is full. Reboot the device into the new firmware.
    
    if ( [device isEqual:self.device] ) {
        
        [self.statusLabel setText:@"complete"];
        
        [self.statusProgress setProgress:1.0 animated:YES];
     
        [self.device.access requestReboot];
        
    }

}

- (void) didFailUpdate:(NSNotification *)notification {

    UpdateDevice *          device      = (UpdateDevice *) notification.object;
    
    if ( [device isEqual:self.device] ) {
        
        [self.statusLabel setText:@"(problem)"];
        
    }

}

#pragma mark - Load bundled firmware package

//
// Load the firmware package binary from the bundle
- (AssetPackage *) loadPackage:(NSString *)package {

    NSBundle *      bundle  = [NSBundle mainBundle];
    NSString *      path    = [bundle pathForResource:package ofType:@"pkg"];
    NSData *        data    = [NSData dataWithContentsOfFile:path];
    
    if ( data ) return [AssetPackage packageWithData:data];
    else return nil;
    
}

@end
