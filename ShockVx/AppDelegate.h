//
//  AppDelegate.h
//  ShockVx
//
//  Created by Eric Bodnar on 9/11/20.
//  Copyright © 2020 com.velvetwire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

