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

@property (nonatomic, weak) IBOutlet    UILabel *           assetIdentity;
@property (nonatomic, weak) IBOutlet    UILabel *           assetLocation;
@property (nonatomic, weak) IBOutlet    UILabel *           assetStatus;
@property (nonatomic, weak) IBOutlet    UILabel *           assetLabel;
@property (nonatomic, weak) IBOutlet    UILabel *           assetRange;

@property (nonatomic, weak) IBOutlet    UILabel *           assetAmbient;
@property (nonatomic, weak) IBOutlet    UILabel *           assetSurface;
@property (nonatomic, weak) IBOutlet    UILabel *           assetHumidity;
@property (nonatomic, weak) IBOutlet    UILabel *           assetPressure;

@end

@implementation AssetListCell

- (void) willMoveToSuperview:(UIView *)view {

    [super willMoveToSuperview:view];
    
    [self setTintColor:view.tintColor];
    [self.assetImage setImage:[self.assetImage.image imageWithTintColor:self.tintColor]];

}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

}

- (void) setIdentity:(NSString *)identity {

    if ( (_identity = identity) ) [self.assetIdentity setText:identity];
    else [self.assetIdentity setText:@""];

}

- (void) setLocation:(NSString *)location {

    if ( (_location = location) ) [self.assetLocation setText:location];
    else [self.assetLocation setText:@"(unknown location)"];
    
}

- (void) setStatus:(NSString *)status {

    if ( (_status = status) ) [self.assetStatus setText:status];
    else [self.assetStatus setText:@"pending"];

}

- (void) setLabel:(NSString *)label {

    if ( (_label = label) ) [self.assetLabel setText:label];
    else [self.assetLabel setText:@"Asset"];

}

- (void) setRange:(NSString *)range {

    if ( (_range = range) ) [self.assetRange setText:range];
    else [self.assetRange setText:@""];

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
