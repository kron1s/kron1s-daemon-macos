//
//  StatusBarController.m
//  kron1s-daemon-macos
//
//  Created by Rijn on 2/28/19.
//  Copyright © 2019 Rijn. All rights reserved.
//

#import "StatusBarController.h"

#import <Cocoa/Cocoa.h>

#import "PopoverContentViewController.h"

@interface StatusBarController ()

@property(atomic, strong) NSStatusItem *statusItem;
@property(atomic, strong) NSPopover *popover;
@property(atomic, strong) NSViewController *popoverContentViewController;

@end

@implementation StatusBarController

+ (instancetype)sharedController
{
    static dispatch_once_t once;
    static StatusBarController *sharedController;
    dispatch_once(&once, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        
        NSImage *icon = [NSImage imageNamed:@"StatusBarButtonImage"];
        icon.template = YES;
        
        _statusItem.button.image = icon;
        [_statusItem.button.cell setTarget:self];
        [_statusItem.button setAction:@selector(togglePopover:)];

        _popoverContentViewController = [[PopoverContentViewController alloc] init];
        
        _popover = [[NSPopover alloc] init];
        _popover.animates = YES;
        _popover.contentViewController = _popoverContentViewController;
    }
    return self;
}

- (void)togglePopover:(id)sender
{
    if (_popover.isShown) {
        [_popover performClose:sender];
    } else {
        [_popover showRelativeToRect:_statusItem.button.bounds
                              ofView:_statusItem.button
                       preferredEdge:NSRectEdgeMinY];
    }
}

@end
