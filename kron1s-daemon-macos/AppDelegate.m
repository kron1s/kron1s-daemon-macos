//
//  AppDelegate.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/27/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "AppDelegate.h"

#import "StatusBarController.h"
#import "UserPreferencePersistence.h"
#import "TimeTrackingController.h"
#import "TimeTrackingPersistence.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (retain) StatusBarController *statusBarController;
@property (retain) UserPreferencePersistence *userPreferencePersistence;
@property (retain) TimeTrackingController *timeTrackingController;
@property (retain) TimeTrackingPersistence *timeTrackingPersistence;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _userPreferencePersistence = [UserPreferencePersistence new];
    _statusBarController = [StatusBarController new];
    _timeTrackingPersistence = [TimeTrackingPersistence new];
    _timeTrackingPersistence.delegate = self;
    _timeTrackingController = [[TimeTrackingController alloc] initWithTimeTrackingPersistence:_timeTrackingPersistence];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)secondsTrackedTodayUpdated:(NSUInteger)secondsTrackedToday
{
#ifdef DEBUG
    NSLog(@"secondsTrackedTodayUpdated %ld", secondsTrackedToday);
#endif
    [_statusBarController updateSecondsTrackedToday:secondsTrackedToday];
}

@end
