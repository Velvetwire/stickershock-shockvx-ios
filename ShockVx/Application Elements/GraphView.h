//
//  project: ShockVx
//     file: GraphView.h
//
//  Linear graph plot.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView

@property (nonatomic, strong)   NSArray *   points;
@property (nonatomic, strong)   NSNumber *  select;

@property (nonatomic)           float       range;
@property (nonatomic)           float       scale;

@end
