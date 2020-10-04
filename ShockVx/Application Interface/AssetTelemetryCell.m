//
//  project: ShockVx
//     file: AssetTelemetryCell.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetTelemetryCell.h"

@interface AssetTelemetryCell ( )

@property (nonatomic, weak) IBOutlet UIImageView *  titleImage;
@property (nonatomic, weak) IBOutlet UILabel *      titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *      valueLabel;
@property (nonatomic, weak) IBOutlet UILabel *      upperLabel;
@property (nonatomic, weak) IBOutlet UILabel *      lowerLabel;

@end

@implementation AssetTelemetryCell

- (void) awakeFromNib {

    [super awakeFromNib];
    
    // Make the upper label into a rounded rectangle.
    
    [self.upperLabel.layer setBorderWidth:0.5];
    [self.upperLabel.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.upperLabel.layer setCornerRadius:5.0];
    [self.upperLabel setClipsToBounds:YES];

    // Make the lower label into a rounded rectangle.
    
    [self.lowerLabel.layer setBorderWidth:0.5];
    [self.lowerLabel.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.lowerLabel.layer setCornerRadius:5.0];
    [self.lowerLabel setClipsToBounds:YES];

    // Make the entire cell into a rounded rectangle.
    
    [self.layer setBorderWidth:1.0];
    [self.layer setCornerRadius:10.0];
    [self setClipsToBounds:YES];

}

- (void) didMoveToSuperview {

    [self.layer setBorderColor:[self tintColor].CGColor];
    
}

- (void) setImage:(UIImage *)image {

    if ( (_image = image) ) {
        
        [self.titleImage setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    }

}

- (void) setLabel:(NSString *)label {

    if ( (_label = label) ) {

        [self.titleLabel setText:label];
        [self.titleLabel setHidden:NO];

    } else { [self.titleLabel setHidden:YES]; }

}

- (void) setValue:(NSString *)value {

    if ( (_value = value) ) {

        [self.valueLabel setText:value];
        [self.valueLabel setHidden:NO];
        
    } else { [self.valueLabel setHidden:YES]; }

}

- (void) setUpper:(NSString *)upper {

    if ( (_upper = upper) ) {
        
        [self.upperLabel setText:upper];
        [self.upperLabel setHidden:NO];
        
    } else { [self.upperLabel setHidden:YES]; }

}

- (void) setLower:(NSString *)lower {

    if ( (_lower = lower) ) {
        
        [self.lowerLabel setText:lower];
        [self.lowerLabel setHidden:NO];
        
    } else { [self.lowerLabel setHidden:YES]; }

}

@end
