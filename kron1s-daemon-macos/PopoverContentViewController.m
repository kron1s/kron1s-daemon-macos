//
//  PopoverContentViewController.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/28/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "PopoverContentViewController.h"

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <ITSwitch/ITSwitch.h>

#import "UserPreferencePersistent.h"

@interface PopoverContentViewController ()

@property(atomic, strong) NSTextField *titleLabel;
@property(atomic, strong) ITSwitch *activateTrackingSwitch;
@property(atomic, strong) NSTextField *promptLabel;

@end

@implementation PopoverContentViewController

- (void)loadView
{
    self.view = [NSView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSInteger width = 200;
    NSInteger height = 120;
    
    self.view.frame = NSMakeRect(0, 0, width, height);
    
    _titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, height - 30, width, 20)];
    [_titleLabel setStringValue:@"Kron1s"];
    [_titleLabel setBezeled:NO];
    [_titleLabel setBordered:NO];
    [_titleLabel setEditable:NO];
    [_titleLabel setDrawsBackground:NO];
    [_titleLabel setSelectable:NO];
    [_titleLabel setAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[NSFont boldSystemFontOfSize:14]];
    [self.view addSubview:_titleLabel];

    NSInteger buttonWidth = width * 0.3;
    _activateTrackingSwitch = [[ITSwitch alloc] initWithFrame:NSMakeRect((width - buttonWidth) / 2, height - 80, buttonWidth, buttonWidth / 1.618)];
    [self.view addSubview:_activateTrackingSwitch];
    [_activateTrackingSwitch setTarget:self];
    [_activateTrackingSwitch setAction:@selector(toggleActivateTrackingSwitch:)];

    _promptLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, height - 110, width, 20)];
    [_promptLabel setStringValue:@"Tracking disabled."];
    [_promptLabel setBezeled:NO];
    [_promptLabel setBordered:NO];
    [_promptLabel setEditable:NO];
    [_promptLabel setDrawsBackground:NO];
    [_promptLabel setSelectable:NO];
    [_promptLabel setAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_promptLabel];
    
    [self.KVOController observe:[UserPreferencePersistent sharedController]
                        keyPath:@"trackingEnabled"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                          block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                              BOOL trackingEnabled = [change[NSKeyValueChangeNewKey] boolValue];
                              if (trackingEnabled) {
                                  [self _enableTracking];
                              } else {
                                  [self _disableTracking];
                              }
                          }];
}

- (void)toggleActivateTrackingSwitch:(id)sender
{
    [[UserPreferencePersistent sharedController] setTrackingEnabled:_activateTrackingSwitch.checked];
}

- (void)_enableTracking
{
    [_activateTrackingSwitch setChecked:YES];
    [_promptLabel setStringValue:@"Tracking enabled."];
}

- (void)_disableTracking
{
    [_activateTrackingSwitch setChecked:NO];
    [_promptLabel setStringValue:@"Tracking disabled."];
}

@end
