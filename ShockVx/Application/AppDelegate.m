//
//  project: ShockVx
//     file: AppDelegate.m
//
//  Handle application launch and instantiation as well as the link
//  to Core Data services.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AppDelegate.h"

//
// Application delegate instance
//

@interface AppDelegate ( )

@end

//
// Application delegate implementation
//

@implementation AppDelegate

//
// The application has completed its launch
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Load the application settings from the user defaults.
    
    _settings   = [[AppSettings alloc] init];

    // Construct the asset registry.
    
    _registry   = [AssetRegistry registryForContext:self.dataContext];

    // Ok to launch.
    
    return YES;

}


#pragma mark - UISceneSession lifecycle

//
// The application has now established its main window scene
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {

    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.

    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];

}

//
// The application has discarded its scene
- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.

}


#pragma mark - Core Data Container

@synthesize persistence = _persistence;

//
// Rerieve an instance of the assocated Core Data persistent information
- (NSPersistentContainer *) persistence {

    @synchronized ( self ) {
        
        // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.

        if ( _persistence == nil ) [(_persistence = [[NSPersistentContainer alloc] initWithName:@"ShockVx"]) loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            
            if ( error ) {
                
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog( @"Unresolved error %@, %@", error, error.userInfo );
                abort( );

            }

        }];
        
    }
    
    return ( _persistence );

}

#pragma mark - Core Data Context

//
// Get the Core Data context asssocated with the application
- (NSManagedObjectContext *) dataContext { return [self.persistence viewContext]; }

//
// Update persistent storage
- (void) saveContext {
    
    NSManagedObjectContext *    context = self.persistence.viewContext;
    NSError *                   error   = nil;
    
    if ( [context hasChanges] && ![context save:&error] ) {
        
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog( @"Unresolved error %@, %@", error, error.userInfo );
        abort( );
    
    }

}

@end
