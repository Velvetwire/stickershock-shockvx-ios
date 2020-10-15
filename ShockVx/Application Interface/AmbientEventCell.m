//
//  project: ShockVx
//     file: AmbientEventCell.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AmbientEventCell.h"

@interface AmbientEventCell ( )

@property (nonatomic, weak) IBOutlet UILabel *      valueLabel;
@property (nonatomic, weak) IBOutlet UILabel *      timeLabel;

@end

@implementation AmbientEventCell

- (void) awakeFromNib {
    
    [super awakeFromNib];

}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

}

#pragma mark - Event values

- (void) setTimestamp:(NSDate *)date {

    if ( (_timestamp = date) ) {
    
        NSDateFormatter *   formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        
        [self.timeLabel setText:[formatter stringFromDate:date]];
        
    }
    
}

- (void) setTemperature:(NSNumber *)temperature {

    if ( (_temperature = temperature) ) [self.valueLabel setText:[NSString stringWithFormat:@"%1.2f \u2103", [temperature floatValue]]];

}

@end
