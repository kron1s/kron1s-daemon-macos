//
//  PrivacyConsentController.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/27/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "PrivacyConsentController.h"

#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>

@interface PrivacyConsentController ()

@property(atomic, strong) NSMutableDictionary *consentStates;

@end

@implementation PrivacyConsentController

+ (instancetype)sharedController
{
    static dispatch_once_t once;
    static PrivacyConsentController *sharedController;
    dispatch_once(&once, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        _consentStates = [NSMutableDictionary alloc];
        if (@available(macOS 10.14, *)) {
            [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                                   selector:@selector(applicationLaunched:)
                                                                       name:NSWorkspaceDidLaunchApplicationNotification
                                                                     object:nil];
        }
    }
    return self;
}

- (BOOL)accessibilityConsentWithPrompt
{
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)@{
                                                                   (__bridge id)kAXTrustedCheckOptionPrompt: @YES
                                                                   });
}

- (PrivacyConsentState)automationConsentForBundleIdentifier:(NSString *)bundleIdentifier promptIfNeeded:(BOOL)promptIfNeeded
{
    PrivacyConsentState result;
    if (@available(macOS 10.14, *)) {
        AEAddressDesc addressDesc;
        const char *bundleIdentifierCString = [bundleIdentifier cStringUsingEncoding:NSUTF8StringEncoding];
        OSErr createDescResult = AECreateDesc(typeApplicationBundleID, bundleIdentifierCString, strlen(bundleIdentifierCString), &addressDesc);
        OSStatus appleScriptPermission = AEDeterminePermissionToAutomateTarget(&addressDesc, typeWildCard, typeWildCard, promptIfNeeded);
        AEDisposeDesc(&addressDesc);
        switch (appleScriptPermission) {
            case errAEEventWouldRequireUserConsent:
                NSLog(@"Automation consent not yet granted for %@, would require user consent.", bundleIdentifier);
                result = PrivacyConsentStateUnknown;
                break;
            case noErr:
                NSLog(@"Automation permitted for %@.", bundleIdentifier);
                result = PrivacyConsentStateGranted;
                break;
            case errAEEventNotPermitted:
                NSLog(@"Automation of %@ not permitted.", bundleIdentifier);
                result = PrivacyConsentStateDenied;
                break;
            case procNotFound:
                NSLog(@"%@ not running, automation consent unknown.", bundleIdentifier);
                result = PrivacyConsentStateUnknown;
                break;
            default:
                NSLog(@"%s switch statement fell through: %@ %d", __PRETTY_FUNCTION__, bundleIdentifier, appleScriptPermission);
                result = PrivacyConsentStateUnknown;
        }
        return result;
    }
    else {
        return PrivacyConsentStateGranted;
    }
}

- (void)applicationLaunched:(NSNotification *)notification
{
    NSRunningApplication *app = notification.userInfo[NSWorkspaceApplicationKey];
    if ([app.bundleIdentifier isEqualToString:@"com.apple.dt.Xcode"]) {
        [self automationConsentForBundleIdentifier:@"com.apple.dt.Xcode" promptIfNeeded:YES];
    }
}

@end
