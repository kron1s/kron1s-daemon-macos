//
//  TimeTrackingPersistence.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 3/2/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#define QUOTE(...) #__VA_ARGS__

#import "TimeTrackingPersistence.h"

#import <FMDatabase.h>
#import <FMDatabaseQueue.h>
#import <FMResultSet.h>

#import "NSFileManager+DirectoryLocations.h"

static NSString* const kUserDatabaseFilename = @"RECORD.DB";

static NSString* const kUserDatabaseQueryCreateTable = @QUOTE(
    CREATE TABLE IF NOT EXISTS time_tracking_records
    (
        uuid VARCHAR(36) PRIMARY KEY NOT NULL,
        timestamp int NOT NULL,
        deviceIdentifier VARCHAR(255),
        bundleIdentifier VARCHAR(255)
    );
    CREATE UNIQUE INDEX time_tracking_records_uuid_uindex ON time_tracking_records (uuid);
);

static NSString* const kUserDatabaseQuerySelectTimeTrackingRecordCoundTemplate = @QUOTE(
    SELECT COUNT(*) as c FROM time_tracking_records WHERE timestamp >= %lld AND timestamp < %lld
);

static NSString* const kUserDatabaseQueryInsertTimeTrackingRecordTemplate = @QUOTE(
    INSERT INTO "time_tracking_records"
    (
        "uuid",
        "timestamp",
        "deviceIdentifier",
        "bundleIdentifier"
    ) VALUES (
        %@,
        %lld,
        'NULL',
        %@
    )
);

@interface TimeTrackingPersistence ()

@property (retain) FMDatabaseQueue *databaseQueue;

@property (atomic, assign) NSUInteger secondsTrackedToday;

@end

@implementation TimeTrackingPersistence

- (instancetype)init
{
    if (self = [super init]) {
        NSString *applicationSupportDirectory = [[NSFileManager defaultManager] applicationSupportDirectory];
        NSString *path = [applicationSupportDirectory stringByAppendingPathComponent:kUserDatabaseFilename];
#ifdef DEBUG
        NSLog(@"Database Path %@", path);
#endif
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];

        [self _tryCreateTimeTrackingRecordTable];
        [self _populateSecondsTrackedTodayFromDatabase];
    }
    return self;
}

- (void)_tryCreateTimeTrackingRecordTable
{
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:kUserDatabaseQueryCreateTable];
    }];
}

- (void)_populateSecondsTrackedTodayFromDatabase
{
    __block __typeof__(self) _self = self;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *startTime = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
        NSDate *endTime = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0];
        FMResultSet *result = [db executeQueryWithFormat:kUserDatabaseQuerySelectTimeTrackingRecordCoundTemplate,
         (long long)round([startTime timeIntervalSince1970]),
         (long long)round([endTime timeIntervalSince1970])
         ];
        if ([result next]) {
            _self->_secondsTrackedToday = [result unsignedLongLongIntForColumn:@"c"];
            [_self->_delegate secondsTrackedTodayUpdated:_self->_secondsTrackedToday];
        }
        [result close];
    }];
}

- (void)insertWindowInformationRecord:(WindowInformationRecord *)windowInformationRecord
{
    __block NSString * const uuid = [[NSUUID UUID] UUIDString];
    __block __typeof__(self) _self = self;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdateWithFormat:kUserDatabaseQueryInsertTimeTrackingRecordTemplate,
         uuid,
         (long long)round(windowInformationRecord.timestamp),
         windowInformationRecord.windowInformation.bundleIdentifier];
        _self->_secondsTrackedToday += 1;
        [_self->_delegate secondsTrackedTodayUpdated:_self->_secondsTrackedToday];
    }];
}

@end
