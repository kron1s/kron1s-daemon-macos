//
//  AppDelegate.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/27/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "AppDelegate.h"

#import "StatusBarController.h"
#import "UserPreferencePersistent.h"
#import "TimeTrackingController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    (void)[UserPreferencePersistent sharedController];
    (void)[StatusBarController sharedController];
    (void)[TimeTrackingController sharedController];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
