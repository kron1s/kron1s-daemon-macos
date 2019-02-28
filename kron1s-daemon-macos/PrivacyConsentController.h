//
//  PrivacyConsentController.h
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/27/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// https://github.com/Panopto/test-mac-privacy-consent/blob/master/Privacy%20Permissions%20Checker/Privacy%20Permissions%20Checker/PrivacyConsentController.h
typedef NS_ENUM(NSInteger, PrivacyConsentState) {
    PrivacyConsentStateUnknown,
    PrivacyConsentStateGranted,
    PrivacyConsentStateDenied
};

@interface PrivacyConsentController : NSObject
+ (instancetype)sharedController;

- (BOOL)accessibilityConsentWithPrompt;

- (PrivacyConsentState)automationConsentForBundleIdentifier:(NSString *)bundleIdentifier promptIfNeeded:(BOOL)promptIfNeeded;

@end

NS_ASSUME_NONNULL_END
