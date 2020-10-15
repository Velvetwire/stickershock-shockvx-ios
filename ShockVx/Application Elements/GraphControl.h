//
//  project: ShockVx
//     file: GraphControl.h
//
//  Linear graph visualization control.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphControl : UIControl

@property (nonatomic)       float       scale;
@property (nonatomic)       float       range;
@property (nonatomic)       float       bias;

- (void) addPlot:(NSString *)label color:(UIColor *)color;
- (void) setPlot:(NSString *)label points:(NSArray *)points;

@end
