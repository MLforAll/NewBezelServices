//
//  HUDWindowController.m
//  NewBezelServices
//
//  Created by Kelian on 29/11/2019.
//  Copyright © 2019 OSXHackers. All rights reserved.
//

#import "HUDWindowController.h"
#import "VolumeControl.h"
#import "BrightnessControl.h"
#import "NSImage+ColorInvert.h"

#define kDefaultVolumeSoundPath @"/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/volume.aiff"

#if DEBUG
# define kHUDHorizontalBias  330
# define kHUDVerticalBias    45
#else
# define kHUDHorizontalBias  30
# define kHUDVerticalBias    45
#endif

#pragma mark - Functions

static BOOL isDarkModeEnabled(void)
{
    NSDictionary *udsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    NSString *style = [udsDict valueForKey:@"AppleInterfaceStyle"];
    return (style && [[style lowercaseString] isEqualToString:@"dark"]);
}

#pragma mark -

@implementation HUDWindowController

#pragma mark Theme Switch

- (void)adaptUI
{
    BOOL themeState = isDarkModeEnabled();

    if (bezelImages && themeState == previousThemeState)
        return ;

    previousThemeState = themeState;

    NSAppearanceName vappn = (themeState) ? NSAppearanceNameVibrantDark : NSAppearanceNameVibrantLight;
    if (_visualEffectView)
        [_visualEffectView setAppearance:[NSAppearance appearanceNamed:vappn]];
    if (@available(macOS 10.14, *))
    {
        NSAppearanceName cvappn = (themeState) ? NSAppearanceNameDarkAqua : NSAppearanceNameAqua;
        [self.window.contentView setAppearance:[NSAppearance appearanceNamed:cvappn]];
    }

    NSArray *imagePathContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesPath error:nil];

    NSMutableArray *hudImagesFilenames = [NSMutableArray new];
    for (NSString *filename in imagePathContents)
        if ([filename hasSuffix:@".pdf"])
            [hudImagesFilenames addObject:filename];

    NSMutableArray *dictNSImages = [NSMutableArray new];
    for (NSString *filename in hudImagesFilenames)
    {
        NSImage *hudImg = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", imagesPath, filename]];
        if (themeState)
            hudImg = [hudImg imageByInvertingColors];
        NSColor *textColor = (themeState) ? [NSColor whiteColor] : [NSColor blackColor];

        [_text setTextColor:textColor];
        [dictNSImages addObject:hudImg];
    }

    bezelImages = [NSDictionary dictionaryWithObjects:dictNSImages forKeys:hudImagesFilenames];
    [_image setImage:[bezelImages valueForKey:currImgName]];
}

#pragma mark - Set HUD

- (void)updateImageForAction:(bezel_action_t)action muted:(BOOL)muted
{
    NSString *imageName;

    switch (action)
    {
        case kBezelActionVolume:
            imageName = muted ? @"Mute.pdf" : @"Volume.pdf";
            break ;
        case kBezelActionBrightness:
            imageName = @"Brightness.pdf";
            break ;
        case kBezelActionEject:
            imageName = @"Eject.pdf";
            break ;
        default:
            break ;
    }

    if (currImgName == imageName)
        return ;
    [_image setImage:[bezelImages valueForKey:imageName]];
    currImgName = imageName;
}

- (void)updateProgressVolume:(BOOL)muted
{
    float level = (muted) ? 0 : VolumeControl.volumeLevel * 100;
    [_slider setDoubleValue:(double)level];
}
- (void)updateProgressBrightness
{
    float currLevel = [BrightnessControl getBrightnessLevel] * 100;
    [_slider setDoubleValue:(double)currLevel];
}

#pragma mark - HUD Interaction

- (void)setProgressVolumeWithSliderDoubleValue:(double)sdv
{
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    if (event.type == NSLeftMouseUp)
        [volumeSound play];

    Float32 currSliderVolumeEquivalent = sdv / 100.0f;
    [VolumeControl setVolumeLevel:currSliderVolumeEquivalent];
    [self updateImageForAction:kBezelActionVolume muted:[VolumeControl isAudioMuted]];
    
}

- (IBAction)sliderAction:(id)sender
{
    assert(sender != nil);

    if ([closeWindowTimer isValid])
        [closeWindowTimer invalidate];

    bezel_action_t action = (bezel_action_t)[sender tag];
    double sliderdv = [sender doubleValue];

    switch (action)
    {
        case kBezelActionVolume:
            [self setProgressVolumeWithSliderDoubleValue:sliderdv];
            break ;
        case kBezelActionBrightness:
            [BrightnessControl setBrightnessLevel:sliderdv / 100];
            break ;
        default:
            break ;
    }

    [self scheduleCloseTimerWithInterval:2.5];
}

#pragma mark - Open & Close

- (void)showWindow:(id)sender
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

    [super showWindow:sender];
}

- (void)scheduleCloseTimerWithInterval:(NSTimeInterval)interval
{
    closeWindowTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(close) userInfo:nil repeats:NO];
}

- (void)showHUDForAction:(bezel_action_t)action enableSlider:(BOOL)eslider textStringValue:(NSString * __nullable)tsval
{
    if (closeWindowTimer.isValid)
        [closeWindowTimer invalidate];

    if (eslider)
        [_tabView selectFirstTabViewItem:nil];
    else
    {
        if (tsval)
            [_text setStringValue:tsval];
        [_tabView selectLastTabViewItem:nil];
    }
    [_slider setTag:(NSInteger)action];

    BOOL muted = NO;
    switch (action)
    {
        case kBezelActionVolume:
            muted = VolumeControl.muted;
            [self updateProgressVolume:muted];
            break ;
        case kBezelActionBrightness:
            [self updateProgressBrightness];
            break ;
        default:
            break ;
    }
    [self updateImageForAction:action muted:muted];

    [self showWindow:nil];
    [self scheduleCloseTimerWithInterval:2];
}

#pragma mark - Properties

- (void)setVolumeSoundPath:(NSString * __nullable)volumeSoundPath
{
    _volumeSoundPath = (volumeSoundPath) ? volumeSoundPath : kDefaultVolumeSoundPath;
    volumeSound = [[NSSound alloc] initWithContentsOfFile:_volumeSoundPath byReference:YES];
}

#pragma mark - Init

- (void)loadWindow
{
    [super loadWindow];

    NSString *elcap_earlier_imagespath = @"/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/BezelUI/HiDPI";
    NSString *sierra_later_imagespath = @"/System/Library/CoreServices/OSDUIHelper.app/Contents/Resources";
    if ([[NSFileManager defaultManager] fileExistsAtPath:elcap_earlier_imagespath])
        imagesPath = elcap_earlier_imagespath;
    else
        imagesPath = sierra_later_imagespath;

    [self.window setCanBecomeVisibleWithoutLogin:YES];
    [self.window setLevel:kCGMaximumWindowLevel];
    [self.window setMovable:NO];
    [_slider setDoubleValue:0];
    [_text setTextColor:[NSColor whiteColor]];

    if (@available(macOS 10.10, *))
    {
        NSVisualEffectView *vibrant = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
        [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [vibrant setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
        [vibrant setState:NSVisualEffectStateActive];
        [self.window.contentView addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];

        _visualEffectView = vibrant;
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(adaptUI) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    }

    previousThemeState = isDarkModeEnabled();
    [self adaptUI];

    [self setVolumeSoundPath:nil]; // set default value
}

@end
