//
//  project: ShockVx
//     file: AssetTelemetryCell.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetTelemetryCell : UICollectionViewCell

@property (nonatomic, strong)   UIImage *   image;

@property (nonatomic, strong)   NSString *  label;
@property (nonatomic, strong)   NSString *  value;
@property (nonatomic, strong)   NSString *  upper;
@property (nonatomic, strong)   NSString *  lower;

@end
