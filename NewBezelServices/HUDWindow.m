//
//  HUDWindow.m
//  NewBezelServices
//
//  Created by Kelian on 09/12/2019.
//  Copyright © 2019 MLforAll. All rights reserved.
//

#import "HUDWindow.h"

@implementation HUDWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
    if (self)
    {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        if (@available(macOS 10.9, *))
            [self setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameAqua]];
    }
    return self;
}

- (void)setContentView:(__kindof NSView *)contentView
{
    [contentView setWantsLayer:YES];
    [contentView.layer setCornerRadius:12.0f];
    [contentView.layer setBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.75].CGColor];

    [super setContentView:contentView];
}

@end
