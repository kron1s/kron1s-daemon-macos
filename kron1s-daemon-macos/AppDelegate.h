//
//  AppDelegate.h
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/27/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TimeTrackingPersistence.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, TimeTrackingPersistenceDelegate>

@end
