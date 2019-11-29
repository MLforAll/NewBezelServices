//
//  HUDWindowController.m
//  NewBezelServices
//
//  Created by Kelian on 29/11/2019.
//  Copyright © 2019 OSXHackers. All rights reserved.
//

#import "HUDWindowController.h"

#define kDefaultVolumeSoundPath @"/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/volume.aiff"
#define kHUDHorizontalBias  330
#define kHUDVerticalBias    45

@implementation HUDWindowController

- (void)setHUDpos
{
    NSScreen *mouseScreen;
    NSPoint mouseLoc = [NSEvent mouseLocation];
    for (NSScreen *screen in [NSScreen screens])
        if (NSMouseInRect(mouseLoc, [screen frame], NO))
            mouseScreen = screen;
    NSRect mouseScreenRect = [mouseScreen frame];
    NSRect mouseScreenVisibleRect = [mouseScreen visibleFrame];
    
    /*float menuBarHeight = [[NSStatusBar systemStatusBar] thickness];
     float dockHeight = mouseScreenRect.size.height+menuBarHeight-mouseScreenVisibleRect.size.height-49;
     NSLog(@"%f", dockHeight);
     if (mouseScreenVisibleRect.size.height+dockHeight+menuBarHeight+5 < mouseScreenRect.size.height) {
     dockHeight += menuBarHeight;
     heightDiffWindow -= menuBarHeight;
     }*/
    
    NSPoint pt = NSMakePoint(mouseScreenVisibleRect.origin.x + kHUDHorizontalBias, mouseScreen.frame.origin.y + mouseScreenRect.size.height - self.window.frame.size.height - kHUDVerticalBias);

    [self.window setFrameOrigin:pt];
}

- (void)showWindow:(id)sender
{
    [self setHUDpos];
    [super showWindow:sender];
}

- (void)setVolumeSoundPath:(NSString * __nullable)volumeSoundPath
{
    _volumeSoundPath = (volumeSoundPath) ? volumeSoundPath : kDefaultVolumeSoundPath;
    volumeSound = [[NSSound alloc] initWithContentsOfFile:_volumeSoundPath byReference:YES];
}

- (void)loadWindow
{
    [super loadWindow];

    [self.window setCanBecomeVisibleWithoutLogin:YES];
    [self.window setLevel:kCGMaximumWindowLevel];
    [self.window setMovable:NO];
    [_slider setDoubleValue:0];
    [_text setTextColor:[NSColor whiteColor]];
    
    if (@available(macOS 10.10, *))
    {
        [self.window setStyleMask:NSWindowStyleMaskUtilityWindow];
        NSVisualEffectView *vibrant = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
        [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [vibrant setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
        [vibrant setState:NSVisualEffectStateActive];
        [self.window.contentView addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
        //[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(adaptUI) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    }
    else
        [self.window setStyleMask:NSWindowStyleMaskHUDWindow];

    [self setVolumeSoundPath:nil]; // set default value
}

@end
