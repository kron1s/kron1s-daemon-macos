//
//  StatusBarController.h
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/28/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatusBarController : NSObject
+ (instancetype)sharedController;

- (void)updateSecondsTrackedToday:(NSUInteger)secondsTrackedToday;

@end

NS_ASSUME_NONNULL_END
