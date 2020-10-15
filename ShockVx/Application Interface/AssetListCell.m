//
//  project: ShockVx
//     file: AssetListCell.h
//
//  Asset list cell for shipped as well as received assets.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetListCell.h"
#import "BatteryControl.h"

@interface AssetListCell ( )

@property (nonatomic, weak) IBOutlet    BatteryControl *    assetBattery;
@property (nonatomic, weak) IBOutlet    UIImageView *       assetImage;

@property (nonatomic, weak) IBOutlet    UILabel *           assetLocation;
@property (nonatomic, weak) IBOutlet    UILabel *           assetStatus;
@property (nonatomic, weak) IBOutlet    UILabel *           assetLabel;

@property (nonatomic, weak) IBOutlet    UIImageView *       assetRange;

@property (nonatomic, weak) IBOutlet    UILabel *           assetAmbient;
@property (nonatomic, weak) IBOutlet    UILabel *           assetSurface;
@property (nonatomic, weak) IBOutlet    UILabel *           assetHumidity;
@property (nonatomic, weak) IBOutlet    UILabel *           assetPressure;

@end

@implementation AssetListCell

- (void) awakeFromNib {

    [super awakeFromNib];
    
    [self.assetImage setTintColor:[UIColor lightGrayColor]];
    
}

- (void) willMoveToSuperview:(UIView *)view {

    [super willMoveToSuperview:view];
    
    [self setTintColor:view.tintColor];
    
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

}

- (void) setLocation:(NSString *)location {

    if ( (_location = location) ) [self.assetLocation setText:location];
    else [self.assetLocation setText:@"(unknown location)"];
    
}

- (void) setStatus:(NSString *)status {

    if ( (_status = status) ) [self.assetStatus setText:status];
    else [self.assetStatus setText:@"pending"];

}

- (void) setIdentity:(NSString *)identity {

    if ( (_identity = identity) ) [self.assetLabel setText:identity];
    
}

- (void) setLabel:(NSString *)label {

    if ( (_label = label) ) [self.assetLabel setText:label];

}

- (void) setRange:(NSNumber *)range {

    if ( (_range = range) ) {
    
        UIImage *   image = nil;
        
        if ( [range floatValue] <= 5.0 ) { image = [UIImage imageNamed:@"Near"]; }
        else if ( [range floatValue] <= 20.0 ) { image = [UIImage imageNamed:@"Proximate"]; }
        else { image = [UIImage imageNamed:@"Distant"]; }

        [self.assetImage setImage:[self.assetImage.image imageWithTintColor:self.tintColor]];
        [self.assetRange setImage:[image imageWithTintColor:self.tintColor]];
        [self.assetRange setHidden:NO];
        
    } else {

        [self.assetImage setImage:[self.assetImage.image imageWithTintColor:[UIColor lightGrayColor]]];
        [self.assetRange setImage:nil];
        [self.assetRange setHidden:YES];
        
    }

}

- (void) setSurface:(NSNumber *)surface {

    if ( (_surface = surface) ) {
    
        [self.assetSurface setTextColor:self.tintColor];
        [self.assetSurface setText:[NSString stringWithFormat:@"%1.2f\u2103", [surface floatValue]]];
        
    } else {
    
        [self.assetSurface setTextColor:[UIColor secondaryLabelColor]];
        [self.assetSurface setText:@"--"];
    
    }
    
}

- (void) setAmbient:(NSNumber *)ambient {

    if ( (_ambient = ambient) ) {
    
        [self.assetAmbient setTextColor:self.tintColor];
        [self.assetAmbient setText:[NSString stringWithFormat:@"%1.2f\u2103", [ambient floatValue]]];
        
    } else {
    
        [self.assetAmbient setTextColor:[UIColor secondaryLabelColor]];
        [self.assetAmbient setText:@"--"];
    
    }
    
}

- (void) setHumidity:(NSNumber *)humidity {

    if ( (_humidity = humidity) ) {
        
        [self.assetHumidity setTextColor:self.tintColor];
        [self.assetHumidity setText:[NSString stringWithFormat:@"%1.1f%%", [humidity floatValue]]];
        
    } else {
        
        [self.assetHumidity setTextColor:[UIColor secondaryLabelColor]];
        [self.assetHumidity setText:@"--"];
    
    }
    
}

- (void) setPressure:(NSNumber *)pressure {

    if ( (_pressure = pressure) ) {
        
        [self.assetPressure setTextColor:self.tintColor];
        [self.assetPressure setText:[NSString stringWithFormat:@"%1.3f bar", [pressure floatValue]]];
        
    } else {
    
        [self.assetPressure setTextColor:[UIColor secondaryLabelColor]];
        [self.assetPressure setText:@"--"];
    
    }
    
}

- (void) setBattery:(NSNumber *)battery {

    if ( (_battery = battery) ) {

        [self.assetBattery setBatteryLevel:[(_battery = battery) floatValue]];
        [self.assetBattery setHidden:NO];

    } else [self.assetBattery setHidden:YES];

}

@end
