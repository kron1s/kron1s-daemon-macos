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

//extern CGSConnection CGSDefaultConnectionForThread(void);
//extern CGError CGSCopyWindowProperty(const CGSConnection cid, NSInteger wid, CFStringRef key, CFStringRef *output);

int main(int argc, const char * argv[]) {
    
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
                                 };
    
    NSLog(@"%@", windowInfo);
    NSLog(@"%@", activeWindow);
    
//    SBApplication *application = [SBApplication applicationWithProcessIdentifier:activeApplication.processIdentifier];
    
    
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
//    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
//                                   [NSString stringWithFormat:
//                                    @"\
//                                    global windowTitle\
//                                    set windowTitle to \"\"\
//                                    tell process id %i\
//                                    tell (1st window whose value of attribute \"AXMain\" is true)\
//                                    set windowTitle to value of attribute \"AXTitle\"\
//                                    end tell\
//                                    end tell\
//                                    return {windowTitle}",
//                                    activeApplication.processIdentifier]
//                                   ];
    
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
        // no script result, handle error here
    }
    
//    NSObject *window = [[[application classForScriptingClass:@"window"] alloc] initWithProperties:nil];
    
//    NSAppleScript *script= [[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\" to return URL of the active tab of the front window"];
//    NSDictionary *scriptError = nil;
//    NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&scriptError];
//    if(scriptError) {
//        NSLog(@"Error: %@",scriptError);
//    } else {
//        NSAppleEventDescriptor *unicode = [descriptor coerceToDescriptorType:typeUnicodeText];
//        NSData *data = [unicode data];
//        NSString *result = [[NSString alloc] initWithCharacters:(unichar*)[data bytes] length:[data length] / sizeof(unichar)];
//        NSLog(@"Result: %@",result);
//    }
    
//    [[NSRunLoop currentRunLoop] run];
    
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
