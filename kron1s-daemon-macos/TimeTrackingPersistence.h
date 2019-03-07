//
//  TimeTrackingPersistence.h
//  kron1s-daemon-macos
//
//  Created by Rijn on 3/2/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WindowInformation+WindowInformationRecord.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TimeTrackingPersistenceDelegate <NSObject>

- (void)secondsTrackedTodayUpdated:(NSUInteger)secondsTrackedToday;

@end

@interface TimeTrackingPersistence : NSObject

@property (nonatomic, weak) id<TimeTrackingPersistenceDelegate> delegate;

- (void)insertWindowInformationRecord:(WindowInformationRecord *)windowInformationRecord;

@end

NS_ASSUME_NONNULL_END
