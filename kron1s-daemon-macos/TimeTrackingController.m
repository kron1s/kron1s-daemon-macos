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
#import "WindowInformation+WindowInformationRecord.h"
#import "TimeTrackingPersistence.h"

static WindowInformation *_getActiveWindowInformation()
{
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
    
    WindowInformation *windowInformation = [WindowInformation new];
    windowInformation.bundleURL = activeApplication.bundleURL;
    windowInformation.bundleIdentifier = activeApplication.bundleIdentifier;
    windowInformation.executableURL = activeApplication.executableURL;
    windowInformation.localizedName = activeApplication.localizedName;
    windowInformation.processIdentifier = activeApplication.processIdentifier;
    
    return windowInformation;
}

static WindowInformationRecord *_generateWindowInformationRecord(WindowInformation *windowInformation)
{
    WindowInformationRecord *windowInformationRecord = [WindowInformationRecord new];
    windowInformationRecord.windowInformation = windowInformation;
    windowInformationRecord.timestamp = [[NSDate date] timeIntervalSince1970];
    return windowInformationRecord;
}

@interface TimeTrackingController ()

@property (nonatomic, strong) dispatch_source_t timer;

@property (retain, nonnull) TimeTrackingPersistence *timeTrackingPersistence;

@end

@implementation TimeTrackingController

- (instancetype)initWithTimeTrackingPersistence:(nonnull TimeTrackingPersistence *)timeTrackingPersistence
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
        
        self.timeTrackingPersistence = timeTrackingPersistence;
    }
    return self;
}

- (void)_enableTracking
{
    [self _disableTracking];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    double interval = 1.000f;
    if (_timer) {
        __block __typeof__(self) _self = self;
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(_timer, ^{
            WindowInformation *windowInformation = _getActiveWindowInformation();
            WindowInformationRecord *windowInformationRecord = _generateWindowInformationRecord(windowInformation);
#ifdef DEBUG
            NSLog(@"%@", [windowInformation toNSDictionary]);
#endif
            [_self->_timeTrackingPersistence pushWindowInformationRecord:windowInformationRecord];
        });
        dispatch_resume(_timer);
    }
}

- (void)_disableTracking
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (int)temp
{
    if (![[PrivacyConsentController sharedController] accessibilityConsentWithPrompt]) {
        return 1;
    }
    
    WindowInformation *windowInformation = _getActiveWindowInformation();
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
