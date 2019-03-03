//
//  TimeTrackingPersistence.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 3/2/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "TimeTrackingPersistence.h"

#import "FMDatabase.h"

#import "NSFileManager+DirectoryLocations.h"

static NSString* const kUserDatabaseFilename = @"RECORD.DB";

@interface TimeTrackingPersistence ()

@property (retain) FMDatabase *database;

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
        self.database = [FMDatabase databaseWithPath:path];
        if (![self.database open]) {
            self.database = nil;
        }
    }
    return self;
}


@end
