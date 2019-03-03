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
#import "UserPreferencePersistence.h"

@interface StatusBarController ()

@property(atomic, strong) NSStatusItem *statusItem;
@property(atomic, strong) NSMenu *statusMenu;
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
        [_statusItem.button setAction:@selector(showContextMenu:)];
        [_statusItem.button sendActionOn:(NSEventMaskLeftMouseUp | NSEventMaskRightMouseUp)];
        
        _popoverContentViewController = [[PopoverContentViewController alloc] init];
        
        _statusMenu = [NSMenu new];
        
        NSMenuItem *trackedItem = [[NSMenuItem alloc] initWithTitle:@"2h tracked today on this computer" action:nil keyEquivalent:@""];
        [_statusMenu addItem:trackedItem];
        
        NSMenuItem *menuItemLastSync = [[NSMenuItem alloc] initWithTitle:@"Last sync: 13:31" action:nil keyEquivalent:@""];
        [_statusMenu addItem:menuItemLastSync];
        
        [_statusMenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *menuItemQuit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(togglePopover:) keyEquivalent:@""];
        [menuItemQuit setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
        [menuItemQuit setKeyEquivalent:@"q"];
        [_statusMenu addItem:menuItemQuit];
        
        _popover = [[NSPopover alloc] init];
        _popover.animates = YES;
        _popover.contentViewController = _popoverContentViewController;
    }
    return self;
}

- (void)showContextMenu:(id)sender
{
    switch ([NSApp currentEvent].type) {
        case NSEventTypeRightMouseUp:
        case NSEventTypeRightMouseDown:
            [_popover performClose:sender];
            [_statusItem popUpStatusItemMenu:_statusMenu];
//            if (@available(macOS 10.14, *)) {
//                [NSMenu popUpContextMenu:_statusMenu withEvent:[NSApp currentEvent] forView:_statusItem.button];
//            } else {
//                [_statusItem popUpStatusItemMenu:_statusMenu];
//            }
            break;
        default:
            [self togglePopover:sender];
    }
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
