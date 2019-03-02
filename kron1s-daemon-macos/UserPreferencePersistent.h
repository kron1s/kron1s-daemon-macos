//
//  UserPreferencePersistent.h
//  kron1s-daemon-macos
//
//  Created by Yuanzhe Bian on 3/1/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserPreferencePersistent : NSObject
+ (instancetype)sharedController;

@end

NS_ASSUME_NONNULL_END
