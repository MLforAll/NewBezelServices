//
//  HUDWindowController.m
//  NewBezelServices
//
//  Created by Kelian on 29/11/2019.
//  Copyright © 2019 MLforAll. All rights reserved.
//

#import "HUDWindowController.h"
#import "VolumeControl.h"
#import "BrightnessControl.h"
#import "NSImage+ColorInvert.h"

#define kDefaultVolumeSoundPath @"/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/volume.aiff"

#ifdef DEBUG
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

@interface HUDWindowController ()

@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSTextField *text;
@property (weak) IBOutlet NSImageView *image;

@end

@implementation HUDWindowController

#pragma mark Theme Switch

- (void)adaptUI
{
    BOOL themeState = isDarkModeEnabled();

    if (_bezelImages && themeState == _previousThemeState)
        return ;

    _previousThemeState = themeState;

    NSAppearanceName vappn = (themeState) ? NSAppearanceNameVibrantDark : NSAppearanceNameVibrantLight;
    if (_visualEffectView)
        [_visualEffectView setAppearance:[NSAppearance appearanceNamed:vappn]];
    if (@available(macOS 10.14, *))
    {
        NSAppearanceName cvappn = (themeState) ? NSAppearanceNameDarkAqua : NSAppearanceNameAqua;
        [self.window.contentView setAppearance:[NSAppearance appearanceNamed:cvappn]];
    }

    NSArray *imagePathContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_imagesPath error:nil];

    NSMutableArray *hudImagesFilenames = [NSMutableArray new];
    for (NSString *filename in imagePathContents)
        if ([filename hasSuffix:@".pdf"])
            [hudImagesFilenames addObject:filename];

    NSMutableArray *dictNSImages = [NSMutableArray new];
    for (NSString *filename in hudImagesFilenames)
    {
        NSImage *hudImg = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", _imagesPath, filename]];
        if (themeState)
            hudImg = [hudImg imageByInvertingColors];
        NSColor *textColor = (themeState) ? [NSColor whiteColor] : [NSColor blackColor];

        [_text setTextColor:textColor];
        [dictNSImages addObject:hudImg];
    }

    _bezelImages = [NSDictionary dictionaryWithObjects:dictNSImages forKeys:hudImagesFilenames];
    [_image setImage:[_bezelImages valueForKey:_currImgName]];
}

#pragma mark - Set HUD

- (void)updateImageForAction:(bezel_action_t)action
{
    NSString *imageName;
    NSString *names[] = {
        @"Volume.pdf", @"Mute.pdf", @"Brightness.pdf",
        @"kBright.pdf", @"kBrightOff.pdf",
        @"Eject.pdf"
    };

    if (action >= kBezelActionMax || _currImgName == (imageName = names[action]))
        return ;

    [_image setImage:_bezelImages[imageName]];
    _currImgName = imageName;
}

#pragma mark - HUD Interaction

- (void)setProgressVolumeWithSliderDoubleValue:(double)doubleValue maxValue:(double)maxValue
{
    if (NSApp.currentEvent.type == NSLeftMouseUp)
        [_volumeSound play];

    Float32 currSliderVolumeEquivalent = doubleValue / maxValue;
    [VolumeControl setVolumeLevel:currSliderVolumeEquivalent];
    [self updateImageForAction:kBezelActionVolume];
}

- (IBAction)sliderAction:(id)sender
{
    assert(sender != nil);

    if (_closeWindowTimer.isValid)
        [_closeWindowTimer invalidate];

    bezel_action_t action = (bezel_action_t)[sender tag];

    double sliderValue = [sender doubleValue];
    double sliderMaxValue = [sender maxValue];

    switch (action)
    {
        case kBezelActionMute:
        case kBezelActionVolume:
            [self setProgressVolumeWithSliderDoubleValue:sliderValue maxValue:sliderMaxValue];
            break ;
        case kBezelActionBrightness:
            [BrightnessControl setBrightnessLevel:sliderValue / sliderMaxValue];
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
        if (NSMouseInRect(mouseLoc, screen.frame, NO))
            mouseScreen = screen;

    NSRect mouseScreenRect = mouseScreen.frame;
    NSRect mouseScreenVisibleRect = mouseScreen.visibleFrame;

    NSPoint pt = NSMakePoint(mouseScreenVisibleRect.origin.x + kHUDHorizontalBias, mouseScreen.frame.origin.y + mouseScreenRect.size.height - self.window.frame.size.height - kHUDVerticalBias);

    [self.window setFrameOrigin:pt];

    [super showWindow:sender];
}

- (void)scheduleCloseTimerWithInterval:(NSTimeInterval)interval
{
    _closeWindowTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(close) userInfo:nil repeats:NO];
}

- (void)showHUDForAction:(bezel_action_t)action sliderFilled:(double)filled sliderMax:(double)max textStringValue:(NSString * __nullable)tsval
{
    if (_closeWindowTimer.isValid)
        [_closeWindowTimer invalidate];

    if (tsval || action == kBezelActionEject)
    {
        [_text setStringValue:tsval];
        [_tabView selectLastTabViewItem:nil];
    }
    else
    {
        [_slider setEnabled:max > 0 && action != kBezelActionKeyBrightness && action != kBezelActionKeyBrightnessOff];
        [_tabView selectFirstTabViewItem:nil];
    }

    [_slider setMaxValue:max];
    [_slider setDoubleValue:filled];
    [_slider setTag:(NSInteger)action];

    [self updateImageForAction:action];

    [self showWindow:nil];
    [self scheduleCloseTimerWithInterval:2];
}

#pragma mark - Properties

- (void)setVolumeSoundPath:(NSString * __nullable)volumeSoundPath
{
    _volumeSoundPath = (volumeSoundPath) ? volumeSoundPath : kDefaultVolumeSoundPath;
    _volumeSound = [[NSSound alloc] initWithContentsOfFile:_volumeSoundPath byReference:YES];
}

#pragma mark - Init

- (void)loadWindow
{
    [super loadWindow];

    NSString *elcap_earlier_imagespath = @"/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/BezelUI/HiDPI";
    NSString *sierra_later_imagespath = @"/System/Library/CoreServices/OSDUIHelper.app/Contents/Resources";
    if ([[NSFileManager defaultManager] fileExistsAtPath:elcap_earlier_imagespath])
        _imagesPath = elcap_earlier_imagespath;
    else
        _imagesPath = sierra_later_imagespath;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adaptUI) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    }

    _previousThemeState = isDarkModeEnabled();
    [self adaptUI];

    [self setVolumeSoundPath:nil]; // set default value
}

@end
