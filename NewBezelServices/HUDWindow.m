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
        self.styleMask |= NSWindowStyleMaskBorderless;
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

- (void)setFrameOrigin:(NSPoint)point
{
    if (_animating)
        return ;
    [super setFrameOrigin:point];
}

- (void)makeKeyAndOrderFront:(id)sender
{
    if (self.visible)
    {
        [super makeKeyAndOrderFront:sender];
        return ;
    }

    const NSRect destRect = self.frame;

    [self setAlphaValue:0];
    [self setFrameOrigin:NSMakePoint(destRect.origin.x, self.screen.frame.size.height + destRect.size.height)];
    //[self setFrame:NSMakeRect(destRect.origin.x + destRect.size.width / 4, self.screen.frame.size.height + destRect.size.height, destRect.size.width / 2, destRect.size.height / 2) display:YES];

    [super makeKeyAndOrderFront:sender];

    _animating = YES;
    [NSAnimationContext beginGrouping];
    [NSAnimationContext.currentContext setDuration:0.5];
    [NSAnimationContext.currentContext setCompletionHandler:^{ self->_animating = NO; }];
    [self.animator setAlphaValue:1];
    [self.animator setFrame:destRect display:NO];
    [NSAnimationContext endGrouping];
}

@end
