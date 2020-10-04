//
//  project: ShockVx
//     file: AppDelegate.h
//
//  Handle application launch and instantiation as well as the link
//  to Core Data services.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#import "AppSettings.h"
#import "AssetRegistry.h"

// The application delegate contains references to persistent data

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *    persistence;
@property (readonly, strong) AssetRegistry *            registry;
@property (readonly, strong) AppSettings *              settings;

- (NSManagedObjectContext *) dataContext;
- (void) saveContext;

@end
