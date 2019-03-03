//
//  TimeTrackingController.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/28/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "TimeTrackingController.h"

#import <Cocoa/Cocoa.h>
#import <ScriptingBridge/ScriptingBridge.h>

#import "PrivacyConsentController.h"
#import "UserPreferencePersistence.h"

@interface ActiveWindowInformation : NSObject

@property (atomic, copy) NSURL *bundleURL;
@property (atomic, copy) NSString *bundleIdentifier;
@property (atomic, copy) NSURL *executableURL;
@property (atomic, copy) NSString *localizedName;
@property (nonatomic, assign) NSInteger processIdentifier;
@property (atomic, copy) NSString *title;
@property (atomic, copy) NSString *path;

- (NSDictionary *)toNSDictionary;

@end

@implementation ActiveWindowInformation

@synthesize title = _title;
@synthesize path = _path;

- (void)setTitle:(NSString *)title
{
    if (title == _title) return;
    _title = title;
}

- (NSString *)title
{
    return _title == nil ? @"" : _title;
}

- (void)setPath:(NSString *)path
{
    if (path == _path) return;
    _path = path;
}

- (NSString *)path
{
    return _path == nil ? @"" : _path;
}

- (NSDictionary *)toNSDictionary
{
    return @{
             @"bundleURL": _bundleURL,
             @"bundleIdentifier": _bundleIdentifier,
             @"executableURL": _executableURL,
             @"localizedName": _localizedName,
             @"processIdentifier": [NSNumber numberWithInteger:_processIdentifier],
             @"title": self.title,
             @"path": self.path,
             };
}

@end

ActiveWindowInformation *_getActiveWindowInformation() {
    __block NSRunningApplication *activeApplication;
    __block NSDictionary *activeWindow;
    
    NSArray *windows = (__bridge_transfer NSArray*)CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    [[NSWorkspace sharedWorkspace].runningApplications enumerateObjectsUsingBlock:^(NSRunningApplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stopOuter) {
        NSRunningApplication *app = (NSRunningApplication*)obj;
        if (app.isActive) {
            [windows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stopInner) {
                NSDictionary *window = (__bridge NSDictionary*)(__bridge CFDictionaryRef)obj;
                
                if ([app.localizedName isEqualToString:window[@"kCGWindowOwnerName"]]) {
                    activeApplication = app;
                    activeWindow = window;
                    *stopInner = YES;
                    *stopOuter = YES;
                }
            }];
        }
    }];
    
    ActiveWindowInformation *activeWindowInformation = [ActiveWindowInformation new];
    activeWindowInformation.bundleURL = activeApplication.bundleURL;
    activeWindowInformation.bundleIdentifier = activeApplication.bundleIdentifier;
    activeWindowInformation.executableURL = activeApplication.executableURL;
    activeWindowInformation.localizedName = activeApplication.localizedName;
    activeWindowInformation.processIdentifier = activeApplication.processIdentifier;
    
    return activeWindowInformation;
}

@implementation TimeTrackingController

+ (instancetype)sharedController
{
    static dispatch_once_t once;
    static TimeTrackingController *sharedController;
    dispatch_once(&once, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self.KVOController observe:[UserPreferencePersistence sharedController]
                            keyPath:@"trackingEnabled"
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                              block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                  BOOL trackingEnabled = [change[NSKeyValueChangeNewKey] boolValue];
                                  if (trackingEnabled) {
                                      [self _enableTracking];
                                  } else {
                                      [self _disableTracking];
                                  }
                              }];
    }
    return self;
}

- (void)_enableTracking
{
    ActiveWindowInformation *windowInformation = _getActiveWindowInformation();
    NSLog(@"%@", [windowInformation toNSDictionary]);
}

- (void)_disableTracking
{
    
}

- (int)temp
{
    if (![[PrivacyConsentController sharedController] accessibilityConsentWithPrompt]) {
        return 1;
    }
    
    ActiveWindowInformation *windowInformation = _getActiveWindowInformation();
    NSLog(@"%@", windowInformation);
    
    PrivacyConsentState consentState = [[PrivacyConsentController sharedController] cachedAutomationConsentForBundleIdentifier:windowInformation.bundleIdentifier
                                                                                                                promptIfNeeded:YES];
    
    if (consentState != PrivacyConsentStateGranted) {
        return 0;
    }
    
    //    SBApplication *application = [SBApplication applicationWithProcessIdentifier:activeApplication.processIdentifier];
    
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"getPathAndTitle" ofType:@"scpt"];
    NSLog(@"Path %@", path);
    NSURL *scriptURL = [[NSURL alloc] initFileURLWithPath:path];
    NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:&errorDict];
    
    returnDescriptor = [script executeAndReturnError: &errorDict];
    
    if (returnDescriptor != NULL)
    {
        // successful execution
        NSLog(@"%@", [returnDescriptor stringValue]);
        if (kAENullEvent != [returnDescriptor descriptorType])
        {
            // script returned an AppleScript result
            if (cAEList == [returnDescriptor descriptorType])
            {
                // result is a list of other descriptors
            }
            else
            {
                // coerce the result to the appropriate ObjC type
            }
        }
    }
    else
    {
        NSLog(@"%@", errorDict);
        // no script result, handle error here
    }
    
    //    [[NSRunLoop currentRunLoop] run];
    
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}

@end
