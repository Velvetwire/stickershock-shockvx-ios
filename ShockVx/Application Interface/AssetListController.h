//
//  project: ShockVx
//     file: AssetListController.h
//
//  Asset list table view controller with sections for
//  shipped assets and received assets.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#import "AssetIdentifier.h"
#import "AssetSensor.h"
#import "AssetTag.h"

@interface AssetListController : UITableViewController <CBCentralManagerDelegate, AssetTagDelegate>

@end
