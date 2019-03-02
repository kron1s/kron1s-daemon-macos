//
//  UserPreferencePersistent.m
//  kron1s-daemon-macos
//
//  Created by Yuanzhe Bian on 3/1/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "UserPreferencePersistent.h"

static NSString* const kTrackingEnabledKey = @"TRACKING_ENABLED";

@interface UserPreferencePersistent ()

@property (atomic) BOOL trackingEnabled;

@end

@implementation UserPreferencePersistent

@synthesize trackingEnabled = _trackingEnabled;

+ (instancetype)sharedController
{
    static dispatch_once_t once;
    static UserPreferencePersistent *sharedController;
    dispatch_once(&once, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self _loadAndFulfillTrackingEnabledFromUserDefaults];
    }
    return self;
}

- (void)setTrackingEnabled:(BOOL)trackingEnabled
{
    if (_trackingEnabled == trackingEnabled) return;
    _trackingEnabled = trackingEnabled;
    
    [self _saveTrackingEnabledToUserDefaults:trackingEnabled]; // save to user default
}

- (BOOL)trackingEnabled
{
    return _trackingEnabled;
}

- (BOOL)_loadAndFulfillTrackingEnabledFromUserDefaults
{
    _trackingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kTrackingEnabledKey];
    return _trackingEnabled;
}

- (void)_saveTrackingEnabledToUserDefaults:(BOOL)trackingEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:trackingEnabled forKey:kTrackingEnabledKey];
}

@end