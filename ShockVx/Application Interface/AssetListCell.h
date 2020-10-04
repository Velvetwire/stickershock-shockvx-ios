//
//  project: ShockVx
//     file: AssetListCell.h
//
//  Asset list cell for shipped as well as received assets.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetBroadcast.h"

@interface AssetListCell : UITableViewCell

@property (nonatomic, strong)   NSString *      identity;
@property (nonatomic, strong)   NSString *      location;
@property (nonatomic, strong)   NSString *      status;
@property (nonatomic, strong)   NSString *      label;
@property (nonatomic, strong)   NSString *      range;

@property (nonatomic, strong)   NSNumber *      battery;
@property (nonatomic, strong)   NSNumber *      surface;
@property (nonatomic, strong)   NSNumber *      ambient;
@property (nonatomic, strong)   NSNumber *      humidity;
@property (nonatomic, strong)   NSNumber *      pressure;

@end
