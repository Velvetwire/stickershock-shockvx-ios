//
//  project: ShockVx
//     file: Application.m
//
//  Application entry point. Instantiate the application delegate
//  and launch the main application window.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

//
// Launch the application delegate
int main ( int argc, char * argv[] ) {
    
    NSString * appDelegateClassName;
    
    @autoreleasepool { appDelegateClassName = NSStringFromClass([AppDelegate class]); }
    
    return UIApplicationMain( argc, argv, nil, appDelegateClassName );
    
}
