//
//  UserPreferencePersistence.h
//  kron1s-daemon-macos
//
//  Created by Yuanzhe Bian on 3/1/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KVOController/NSObject+FBKVOController.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserPreferencePersistence : NSObject
+ (instancetype)sharedController;

- (void)setTrackingEnabled:(BOOL)trackingEnabled;
- (BOOL)trackingEnabled;

@end

NS_ASSUME_NONNULL_END
