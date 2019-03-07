//
//  TimeTrackingController.h
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/28/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TimeTrackingPersistence.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeTrackingController : NSObject

- (instancetype)initWithTimeTrackingPersistence:(TimeTrackingPersistence *)timeTrackingPersistence;

@end

NS_ASSUME_NONNULL_END
