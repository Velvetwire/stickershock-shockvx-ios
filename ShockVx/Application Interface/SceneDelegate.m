//
//  project: ShockVx
//     file: SceneDelegate.m
//
//  Process state transitions for the application within a shared application
//  environment.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SceneDelegate.h"
#import "AppDelegate.h"

//
// Scene delegate instance
//

@interface SceneDelegate ( )

@end

//
// Scene delegate implemenation
//

@implementation SceneDelegate

//
// Connecting to a window session
- (void) scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

}

//
// Disconnecting from session
- (void) sceneDidDisconnect:(UIScene *)scene {

}

//
// Application scene became active
- (void) sceneDidBecomeActive:(UIScene *)scene {

}

//
// Application scene became inactive
- (void) sceneWillResignActive:(UIScene *)scene {

}

//
// Application process is now in the foreground
- (void) sceneWillEnterForeground:(UIScene *)scene {

}

//
// Application process has been backgrounded
- (void) sceneDidEnterBackground:(UIScene *)scene {

    // Save changes in the application's managed object context when the application transitions to the background.

    [(AppDelegate *)UIApplication.sharedApplication.delegate saveContext];

}

@end
