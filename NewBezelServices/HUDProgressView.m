//
//  HUDProgressView.m
//  NewBezelServices
//
//  Created by Kelian on 03/11/2020.
//  Copyright © 2020 MLforAll. All rights reserved.
//

#import "HUDProgressView.h"

@implementation HUDProgressView

@synthesize tag = _tag;

- (NSView *)getVibrantView:(BOOL)foreground
{
    NSRect rect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    
    if (@available(macOS 10.10, *))
    {
        NSVisualEffectView *vibrant = [[NSVisualEffectView alloc] initWithFrame:rect];

        [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [vibrant setState:NSVisualEffectStateActive];
        [vibrant setMaterial:foreground ? NSVisualEffectMaterialMenu : NSVisualEffectMaterialDark];

        return vibrant;
    }

    NSView *fallback = [[NSView alloc] initWithFrame:rect];
    [fallback.layer setBackgroundColor:foreground ? NSColor.grayColor.CGColor : NSColor.blackColor.CGColor];
    return fallback;
}

- (void)scrollWheel:(NSEvent *)event
{
    [super scrollWheel:event];

    double delta = _delta + event.deltaX / self.frame.size.width;
    [self setDoubleValue:delta];

    [self performAction];
}

- (void)awakeFromNib
{
    [self addSubview:(_background = [self getVibrantView:NO]) positioned:NSWindowBelow relativeTo:nil];
    [self addSubview:(_foreground = [self getVibrantView:YES]) positioned:NSWindowAbove relativeTo:nil];

    _maxValue = 100;
    _enabled = YES;
}

- (void)setDoubleValue:(double)doubleValue
{
    if (doubleValue < _minValue)
        doubleValue = _minValue;
    else if (doubleValue > _maxValue)
        doubleValue = _maxValue;

    [NSAnimationContext beginGrouping];
    [NSAnimationContext.currentContext setDuration:0.25];
    [_foreground.animator setFrameSize:NSMakeSize(self.frame.size.width / _maxValue * doubleValue, self.frame.size.height)];
    [NSAnimationContext endGrouping];

    _doubleValue = _delta = doubleValue;
}

- (void)setTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)performAction
{
    if (!_target || !_action)
        return ;

    IMP imp = [_target methodForSelector:_action];
    void (*fptr)(id, SEL, id) = (void *)imp;
    fptr(_target, _action, self);
}

@end
