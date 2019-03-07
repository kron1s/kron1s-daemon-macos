//
//  WindowInformation.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 3/2/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "WindowInformation+WindowInformationRecord.h"

@implementation WindowInformation

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

@implementation WindowInformationRecord

@end
