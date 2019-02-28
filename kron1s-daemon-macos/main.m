//
//  main.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/27/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <ScriptingBridge/ScriptingBridge.h>

#import "PrivacyConsentController.h"

NSDictionary *_getActiveWindowInformation() {
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
    
    NSDictionary *windowInfo = @{
                                 @"bundleURL": activeApplication.bundleURL,
                                 @"bundleIdentifier": activeApplication.bundleIdentifier,
                                 @"executableURL": activeApplication.executableURL,
                                 @"localizedName": activeApplication.localizedName,
                                 @"PID": [NSNumber numberWithInt:activeApplication.processIdentifier],
                                 };
    
    return windowInfo;
}

int main(int argc, const char * argv[]) {
    if (![[PrivacyConsentController sharedController] accessibilityConsentWithPrompt]) {
        return 1;
    }
    
    NSDictionary *windowInformation = _getActiveWindowInformation();
    NSLog(@"%@", windowInformation);
    
    PrivacyConsentState consentState = [[PrivacyConsentController sharedController] automationConsentForBundleIdentifier:windowInformation[@"bundleIdentifier"] promptIfNeeded:YES];
    
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
    
    [[NSRunLoop currentRunLoop] run];
    
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return NSApplicationMain(argc, argv);
    return 0;
}
