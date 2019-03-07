//
//  WindowInformation+WindowInformationRecord.h
//  kron1s-daemon-macos
//
//  Created by Rijn on 3/2/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowInformation : NSObject

@property (atomic, copy) NSURL *bundleURL;
@property (atomic, copy) NSString *bundleIdentifier;
@property (atomic, copy) NSURL *executableURL;
@property (atomic, copy) NSString *localizedName;
@property (nonatomic, assign) NSInteger processIdentifier;
@property (atomic, copy) NSString *title;
@property (atomic, copy) NSString *path;

- (NSDictionary *)toNSDictionary;

@end

@interface WindowInformationRecord : NSObject

@property (nonatomic, retain) WindowInformation *windowInformation;
@property (atomic, copy) NSString *deviceIdentifier;
@property (nonatomic, assign) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
